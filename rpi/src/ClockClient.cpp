
#include "ClockListener.h"
#include "ClockClient.h"
#include "StringUtil.h"
#include <stdio.h>
#include "Settings.h"

#include <iostream>
#include <fstream>
#include <jsoncpp/json/json.h> 
#include <time.h>

using namespace std;
using namespace common::utility;

#define maxFieldLength 1024

namespace piclock {

    int    ClockCLient::maxCommandLen=4096;
    char   ClockCLient::fieldSeparator[128] = "þ";

    atomic<int>      ClockCLient::registerCount;
    atomic<uint64_t> ClockCLient::registerTime;


    ClockCLient::ClockCLient(SessionData &session):tcpclient(session) {
        logger = new Logger{"ClockCLient<%d>",session.clientId};

        this->session      = &session;
    }




    void ClockCLient::apiClient() {
        const char *prompt = "IDG> ";

        logger->info("web client connected");

        while (!session->goodbye) {
            vector<string> requestVector;
            auto rq = doPost();

            if (rq.clientDisconnected) {
                session->goodbye = true;
                break;
            }

            if (isDebug) {
                for (const auto &item: rq.headers) {
                    auto key = item.first;
                    auto value = item.second;
                    logger->debug("header<%s>=%s", key.c_str(), value.c_str());
                }
            }

            if (!operationProcess(rq)) {
                session->goodbye = true;
                logger->info("goodbye");
                break;
            }
        }
    }

    bool ClockCLient::notFound(HttpRequest request, const char* dateTimeGMT) {
        bool status = false;


        string body = "not found";

        writeLine(httpStatus.at(404).c_str());
        writeLine("Connection: %s", (status)?"Keep-Alive":"close");
        writeLine("Server: idgcore");
        writeLine("Content-Type: application/json");
        writeLine("Content-Length: %d", body.length());
        writeLine("Date: %s", dateTimeGMT);
        writeLine("");
        writeMessage(body.c_str());

        return status;
    }


    bool ClockCLient::operationProcess(HttpRequest request) {
        time_t rawtime;
        struct tm * timeinfo;
        struct tm * gmtinfo;
        char dateTimeHour[80];
        char dateTimeGMT[80];
        bool status=true;

        time (&rawtime);
        timeinfo = localtime (&rawtime);
        strftime (dateTimeHour,80,"%Y-%m-%d-%H",timeinfo);

        gmtinfo = gmtime(&rawtime);
        strftime (dateTimeGMT, 80,"%a, %d %b %Y %H:%M:%S GMT",gmtinfo);

        const char *instance = getenv("INSTANCE");
        if (instance==nullptr) {
            instance="dev";
        }

        logDebugX("raw body: +++Start+++\n%s\n+++End+++",request.body.c_str());

        string jbossid = getUUID();
        logger->setTransactionId(jbossid);

        try {
            logDebugX("request.path='%s'", request.path.c_str());

            string body;

            if (!request.path.compare("/hello")) {
                logger->info("hello");
                body="hello there!";
                status=false;
            } else if (!request.path.compare("/timeFormat")) {
                if (strstr(request.body.c_str(),"1")) {
                    settings.dateFormat='1';
                    body="{\"timeFormat\":\"1\"}";
                } else {
                    settings.dateFormat='2';
                    body="{\"timeFormat\":\"2\"}";
                }
            } else {
                return notFound(request, dateTimeGMT);
            }

            writeLine(httpStatus.at(200).c_str());
            writeLine("Connection: %s", (status)?"Keep-Alive":"close");
            writeLine("Server: idgcore");
            writeLine("Content-Type: application/json");
            writeLine("Content-Length: %d", body.length());
            writeLine("Date: %s", dateTimeGMT);
            writeLine("");
            writeMessage(body.c_str());

            logDebugX("[RS:%d]%s", body.length(), body.c_str());

        } catch (std::exception &e) {

            StringBuilder tmpstr;
            tmpstr.appendf("Register  failed; caused by: %s", e.what());

            logger->error("%s",tmpstr.c_str());

            string body = "internal server error";

            writeLine(httpStatus.at(400).c_str());
            writeLine("Connection: close");
            writeLine("Server: idgcore");
            writeLine("Content-Type: application/json");
            writeLine("Content-Length: %d", body.length());
            writeLine("Date: %s", dateTimeGMT);
            writeLine("");
            writeMessage(body.c_str());

            logger->info("RS[400]: %s",body.c_str());
            status=false;
        }
        fsync(session->clientSocket);
        fdatasync(session->clientSocket);
        logger->clearTransactionId();

        return status;
    }

}