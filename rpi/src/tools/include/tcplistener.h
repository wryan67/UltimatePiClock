#pragma once

#include <errno.h>
#include <stdio.h>
#include <dirent.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <signal.h>
#include <netinet/in.h>
#include <pthread.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <netinet/tcp.h>

#include <stdexcept>
#include <iostream>
#include <thread>
#include <atomic>

#include <log4pi.h>

using namespace common::utility;

namespace common { namespace tcpservice { 

    // TCP interface stuff
    #define MessageBuffersLength 32768

    struct SessionStruct {
        int   clientId;
        int   clientSocket;
        bool  authorized=false;
        bool  goodbye=false;
        char  buffer[MessageBuffersLength];
        char  socketBuffer[MessageBuffersLength];
        int   socketBufferStart=0;
        int   socketBufferEnd=0;
        bool  commandPrompt=false;
        int   responseMessageMaxLength=MessageBuffersLength-1;
        char  responseMessage[MessageBuffersLength];
        bool  dirty=true;
    };

    typedef SessionStruct SessionData;

    class tcplistener {

    public:
        tcplistener(int port);
       ~tcplistener();

        void start();
        void shutdown();
        atomic<bool> isRunning{true};

    protected:

        virtual void apiClient(SessionData &session);
        virtual void apiShutdown(SessionData &session);

    private:
        Logger             *logger;
    	int                 servicePort;
        int                 socketDescriptor=-1;
        atomic<int>         threadIdSeq{0};


        void serviceListener();
        void serviceClient(int clientSocket);
        void internalClient(SessionData &session);
        void tcpClient(SessionData &session);
        void tcpShutdown(SessionData &session);

        static vector<tcplistener*> threads;

    };
}}