
#include "Settings.h"

#include "tcplistener.h"
#include <log4pi.h>

using namespace common::utility;
using namespace common::tcpservice;

namespace piclock {

    class ClockListener:public tcplistener {
        public:  
            ClockListener();

            void apiClient(SessionData &session);
            void apiShutdown(SessionData &session);

        private:
            Logger         logger{"ClockListener"};

    };
}