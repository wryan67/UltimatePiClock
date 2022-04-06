#include <log4pi.h>

#include "tcplistener.h"
#include "StringUtil.h"
#include "tcpclient.h"

namespace common { namespace tcpservice { 

	vector<tcplistener*> tcplistener::threads;

    tcplistener::~tcplistener() {
		logger->debug("destroy tcplistener called");
		shutdown();
		delete logger;
	}

	tcplistener::tcplistener(int port) {
        this->servicePort=port;
        logger = new Logger("Listener<%d>",port);
    }

	void signal_SIGPIPE_handler(int signum) {
    	fprintf(stderr,"broken pipe\n"); fflush(stderr);
	}

	void tcplistener::start() {
        struct sockaddr_in  bindAddress;

		signal(SIGPIPE, signal_SIGPIPE_handler);

		socketDescriptor = socket(AF_INET, SOCK_STREAM, 0);
		if (socketDescriptor < 0) {
			throw RuntimeException("Could not create socket");
		}

		int on = 1;
		if (setsockopt(socketDescriptor, IPPROTO_TCP, TCP_NODELAY, &on, sizeof(on)) < 0) {
			throw RuntimeException("could not set socket options on port %d", servicePort);
		}


		if (setsockopt(socketDescriptor, SOL_SOCKET, SO_REUSEPORT|SO_KEEPALIVE, &on, sizeof(on)) < 0) {
			throw RuntimeException("could not set socket options on port %d", servicePort);
		}


		// SO_REUSEADDR - this made it really aganozingly slow
		// SO_REUSEPORT - could not set socket options
		// if (setsockopt(socketDescriptor, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)) < 0) {
		// 	logger->error("could not set socket options on port %d", servicePort);
		// 	return NULL;
		// }
		//    if (setsockopt(socketDescriptor, IPPROTO_TCP, TCP_CORK,&on,sizeof(on))<0) {
		//        logger->error("could not set socket options on port %d",servicePort);
		//        return 9;
		//    }


		bindAddress.sin_family = AF_INET;
		bindAddress.sin_addr.s_addr = INADDR_ANY;
		bindAddress.sin_port = htons(servicePort);


		if (bind(socketDescriptor, (struct sockaddr *)&bindAddress, sizeof(bindAddress)) < 0) {
			throw RuntimeException("bind failed on port %d", servicePort);
		}

		if (listen(socketDescriptor, SOMAXCONN) < 0) {
			throw RuntimeException("failed to listen on port %d", servicePort);
		}


		logger->info("service listening on port %d", servicePort);

		thread([this]{serviceListener();}).detach();

	}



	void tcplistener::shutdown() {
		isRunning=false;
	}

	void tcplistener::serviceListener() {
		sockaddr remoteAddress;
		int socketSize = sizeof(remoteAddress);
		int newSocket;

		isRunning=true;

// todo - check for socket accept timeout 

		while (isRunning && (newSocket = accept(socketDescriptor, (struct sockaddr *)&remoteAddress, (socklen_t*)&socketSize))) {

			if (newSocket < 0) {
				logger->error("client accept failed");
                continue;
			}

            thread(&tcplistener::serviceClient,this,newSocket).detach();

            // add clientThread to active clinet list ?

		}

		logger->info("closing socket");

		if (socketDescriptor>=0) {
			int rs=close(socketDescriptor);
			if (rs!=0) {
				logger->error("tcpServcie::close failed: %s", strerror(errno)); 
			}
			socketDescriptor=-1;
		}

		logger->info("listener stopped");
	}

	void tcplistener::apiClient(SessionData &session) {
		logger->debug("apiClient has not been implemented"); 
		tcpclient{session}.run();
	}

	void tcplistener::apiShutdown(SessionData &session) {
		logger->debug("apiShutdown has not been implemented"); 
		tcpclient{session}.shutdown();
	}


	void tcplistener::serviceClient(int clientSocket) {
		SessionData session;
		session.clientSocket =   clientSocket;
		session.clientId     = ++threadIdSeq;

		try {
			apiClient(session);
		} catch (exception &e) {
			logger->error("session failed; caused by: %s", e.what());
		}

		if (session.dirty) {
			apiShutdown(session);
		}

		if (session.goodbye) {
			logger->debug("clinet<%d> disconnected", session.clientId); 
		} else {
			logger->error("client<%d> departed unexpectedly 200", session.clientId);
		}
		close(clientSocket);

		return;
	}

}}