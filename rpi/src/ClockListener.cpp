
#include <stdio.h>

#include <iostream>
#include <fstream>
#include <jsoncpp/json/json.h> 

#include "StringUtil.h"
#include "ClockListener.h"
#include "ClockClient.h"

using namespace std;
using namespace common::utility;

#define maxFieldLength 1024

namespace piclock {

    ClockListener::ClockListener():tcplistener(settings.servicePort) {
        logger.info("db pool stats");
    }

    void ClockListener::apiClient(SessionData &session) {
        ClockCLient clock{session};
        clock.apiClient();
    }

    void ClockListener::apiShutdown(SessionData &session) {

        logger.debug("api client api shutdown");

    }
}