#pragma once

#include <log4pi.h>
#include "Settings.h"
#include "tcplistener.h"
#include "tcpclient.h"


using namespace std;
using namespace common::utility;
using namespace common::tcpservice;

namespace piclock {

    class ClockCLient:public tcpclient {
    public:       
        ClockCLient(SessionData &session);

        void apiClient();

        static int   getRegisterCount();
        static float getRegisterAverage();

    private:
        Logger        *logger;
        SessionData   *session;

        static int  maxCommandLen;
        static char fieldSeparator[128];

        void login();
        void level();
        void parseCardFile();

        void executeServiceCommand();

        static atomic<int>      registerCount;
        static atomic<uint64_t> registerTime;

        bool operationProcess(HttpRequest request);

        bool notFound(HttpRequest request, const char* dateTimeGMT);
    };
}