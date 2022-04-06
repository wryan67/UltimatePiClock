#include <log4pi.h>

#include "tcpclient.h"
#include "StringUtil.h"
#include "HttpRequest.h"

using namespace common::utility;

namespace common { namespace tcpservice { 

    unordered_map<int,string> tcpclient::httpStatus  ({
        {200,     "HTTP/1.1 200 OK" },
        {400,     "HTTP/1.1 400 Bad Request" },
        {401,     "HTTP/1.1 401 Unauthorized" },
        {404,     "HTTP/1.1 404 Not Found" },
        {500,     "HTTP/1.1 500 Internal Server Error" }
    });

    tcpclient::tcpclient(SessionData &session) {
        this->session=&session;
        logger=new Logger("tcpclient<%d>", session.clientId);
    }

    tcpclient::~tcpclient() {
        delete logger;
    }

	void tcpclient::sync() {
		fsync(session->clientSocket);
	}



	void tcpclient::writeMessage(const char *message) {
		int xwritten;
		int len=strlen(message);

		xwritten=write(session->clientSocket, message, len);
		if (xwritten<0) {
			throw RuntimeException("%s",strerror(errno));
		}
		if (xwritten!=len) {
			throw RuntimeException("writeMessage: could not write entire message; only %d bytes of %d were written",xwritten, len);
		}		
	}
 
    void tcpclient::writeLine(const char *format, ...) {
        va_list valist;
        va_start(valist, format);
		vwriteLine(format, &valist);
        va_end(valist);
    }


	void tcpclient::vwriteLine(const char *format, va_list *valist) {
		int xwritten;
		int size=strlen(format)+65536;
		char *message=(char*)malloc(size);
		vsnprintf(message, size, format, *valist);

		int len=strlen(message);

		if (message[len-1]!='\n') {
			message[len]='\n';
			message[len+1]=0;
			++len;
		}

		xwritten=write(session->clientSocket, message, len);
		free(message);

		if (xwritten<0) {
			throw RuntimeException("%s",strerror(errno));
		}
		if (xwritten!=len) {
			throw RuntimeException("writeLine: could not write entire message; only %d bytes of %d were written",xwritten, len);
		}

		fsync(session->clientSocket);
	}

    int tcpclient::nipNewLine(int lineSize) {
        if (lineSize>0 && session->buffer[lineSize-1]=='\n') {
            session->buffer[--lineSize]=0;
        }
        if (lineSize>0 && session->buffer[lineSize-1]=='\r') {
            session->buffer[--lineSize]=0;
        }
        return lineSize;
    }

	int tcpclient::readLine() {
        int bytesReceived=0;
		int lineSize=0;
		int recvSize;
		int maxLength=sizeof(session->socketBuffer);


        if (session->socketBufferEnd>session->socketBufferStart) {
            logDebugX("readLine: reading from buffer...");
            for (;session->socketBufferStart<session->socketBufferEnd;++session->socketBufferStart) {
                if (session->socketBuffer[session->socketBufferStart]=='\n') {
                    session->socketBufferStart++;
                    return nipNewLine(lineSize);
                }
                session->buffer[lineSize++]=session->socketBuffer[session->socketBufferStart];
                --maxLength;
            }
        }

        logDebugX("readLine: receiving from socket...");
        session->socketBufferEnd=session->socketBufferStart=0;

		while ((recvSize = recv(session->clientSocket, &session->socketBuffer[lineSize], maxLength-1, 0)) > 0) {
			if (recvSize<0) {
                logger->error("client<%d> error reading file: %s\n", session->clientId, strerror(errno));
				return -1;
			}
            logDebugX("readLine.recvSize=%d",recvSize);
            bytesReceived+=recvSize;

			lineSize+=recvSize;
			maxLength-=recvSize;
            session->socketBuffer[lineSize]=0;
            if (strstr(session->socketBuffer,"\n")) {
                break;
            }
		}

        if (bytesReceived==0 && lineSize==0) {
            logger->info("readLine: client disconnected");
            return -1;
        } else {
            logDebugX("readLine: build response buffer");
            char *nl=strstr(session->socketBuffer,"\n");
            if (nl==nullptr) {
                logger->warn("readLine: no newline detected");

                strcpy(session->buffer,session->socketBuffer);
                return lineSize;
            } else {
                logDebugX("saving buffer overflow");
                *nl=0;
                strcpy(session->buffer,session->socketBuffer);
                session->socketBufferStart=nl-session->socketBuffer+1;
                session->socketBufferEnd=lineSize;
                lineSize=strlen(session->buffer);

                logDebugX("socket buffer len: %d", session->socketBufferEnd);
            }

            lineSize=nipNewLine(lineSize);
            logDebugX("readLine: buffer<%d>[%s]", lineSize, session->buffer);
            if (session->socketBufferEnd>session->socketBufferStart) {
                logDebugX("socketBuffer<%d>[%s]", session->socketBufferEnd-session->socketBufferStart, &session->socketBuffer[session->socketBufferStart]);
            }
            return lineSize;
        }
	}

    HttpRequest tcpclient::doPost() {
        HttpRequest rq;

        int recvSize = readLine();
        if (recvSize<0) {
            rq.clientDisconnected = true;
            return rq;
        }
        auto parts=splitWhitespace(session->buffer);

        if (parts.size()!=3) {
            logger->error("http protocol error; h1<%s>",session->buffer);
            rq.clientDisconnected = true;
            return rq;
        }

        rq.method=parts.at(0);
        rq.path=parts.at(1);
        rq.version=parts.at(2);

        // headers
        rq.contentLength=0;
        for (int recvSize = readLine(); recvSize > 0; recvSize = readLine()) {
            if (recvSize<0) {
                rq.clientDisconnected=true;
                return rq;
            }
            logDebugX("line: %s",session->buffer);
            auto colonPos = strstr(session->buffer, ":");


            if (colonPos) {
                auto keylen = colonPos - session->buffer;
                session->buffer[keylen] = 0;
                string key = session->buffer;
                string value;
                long vStart;
                for (vStart = keylen + 1; vStart < recvSize; ++vStart) {
                    if (session->buffer[vStart] == 0 || isspace(session->buffer[vStart])) {
                        continue;
                    } else {
                        break;
                    }
                }
                value = (char *) &session->buffer[vStart];

                rq.headers.push_back({key, value});

                if (strcasecmp(key.c_str(),"Content-Length")==0) {
                    rq.contentLength=stoul(value);
                }
            }
        }
        logDebugX("got headers");
        if (rq.contentLength>0) {
            int rs = read(rq.contentLength);
            if (rs < 0) {
                rq.clientDisconnected = true;
            }
            rq.body = session->buffer;
        }
        return rq;
    }

    int tcpclient::read(unsigned long bytes) {
        int maxLength=bytes;
        int lineSize=0;
        int recvSize=0;
        int bytesReceived=0;

        logDebugX("reading %uld bytes", bytes);

        if (session->socketBufferEnd > session->socketBufferStart) {
            for (;maxLength>0 && session->socketBufferStart < session->socketBufferEnd; ++session->socketBufferStart) {
                session->buffer[lineSize++] = session->socketBuffer[session->socketBufferStart];
                maxLength--;
            }
        }

        session->socketBufferEnd = session->socketBufferStart = 0;

        while (lineSize<bytes) {
            recvSize = recv(session->clientSocket, &session->buffer[lineSize], maxLength, 0);
            if (recvSize<0) {
                logger->error("client<%d> error reading file: %s\n", session->clientId, strerror(errno));
                return -1;
            }
            logger->info("read.recvSize=%d; expected=%d",recvSize, maxLength-1);
            bytesReceived+=recvSize;

            lineSize+=recvSize;
            maxLength-=recvSize;
            session->buffer[lineSize]=0;
        }

        if (bytesReceived==0 && lineSize==0) {
            logger->info("read: client disconnected");
            return -1;
        } else {
            return lineSize;
        }
    }

    void tcpclient::shutdown() {
		logger->error("The api client shutdown method has not been implemented");
	}

	void tcpclient::run() {
		const char *messages[]={
			"Hello.  The api client method has not been implemented.\n",
			"type 'quit' to exit.\n",
		};


		int recvSize=1;
		while (!session->goodbye || recvSize>=0) {
			try {
				writeMessage("CMD> ");
			} catch (RuntimeException &e) {
				logger->error("error writing prompt; caused by: %s", e.what());
			}

			int recvSize = readLine();

			if (recvSize>0) {

				str2lower(session->buffer);
				chomp(session->buffer, '\n');

				if (strcmp(session->buffer,"quit")==0) {
					session->goodbye=true;
					break;
				}

				for (auto message:messages) {
					int len=strlen(message);
					int xwritten=write(session->clientSocket, message, len);

					if (xwritten!=len) {
						logger->error("client<%d> error writing response on client socket", session->clientId);
					}
				}
			} else {
				logger->info("client<%d> empty command response", session->clientId);
			}
		}
	}


}}