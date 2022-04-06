#pragma once

#include "tcplistener.h"
#include "HttpRequest.h"
#include <unordered_map>
#include "Settings.h"

using namespace common::utility;

namespace common { namespace tcpservice { 

    class tcpclient {
    private:
        Logger      *logger;
        SessionData *session;

    public:
       ~tcpclient();
        tcpclient(SessionData &session);

        static unordered_map<int,string> httpStatus;

        void run();

        void  writeMessage(const char *message);
        void  writeLine(const char *format, ...);
        void  vwriteLine(const char *format, va_list *valist);

        int    readLine();
        void   sync();
        HttpRequest doPost();

        virtual void shutdown();


        int nipNewLine(int lineSize);

        int read(unsigned long bytes);
    };
}}