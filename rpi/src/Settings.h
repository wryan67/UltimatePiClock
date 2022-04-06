#pragma once

struct Settings_st {
    char dateFormat  = '1';
    int  servicePort = 8080;
};

typedef Settings_st Settings;

extern Settings settings;


#define isDebug             (Logger::getGlobalLevel()<=DEBUG)
#define logDebug(args...)   {if(isDebug){logger.debug(args);}}
#define logDebugX(args...)  {if(isDebug){logger->debug(args);}}
