
import os
import json
import util

from  settings import Settings

logname=os.getlogin()
settings = Settings()

#:############:#
def getHome():
#:############:#
    return util.execOne("awk -F: '{if($1==\"" + logname + "\")print $6}' /etc/passwd")

#:############:#
def getConfigPath():
#:############:#
    return getHome()+"/.config/piclock"

#:############:#
def readConfig():
#:############:#
    global settings

    configFile = getConfigPath()+"/config.json"

    if os.path.exists(configFile):
        print("reading config<"+configFile+">....")
        with open(configFile) as json_file:
            settings = Settings(**json.load(json_file))
    else:
        print("creating config<"+configFile+">....")
        os.makedirs(getConfigPath(), exist_ok=True)
        print(settings.toJson())
        with open(configFile, 'w') as outfile:
            outfile.write(settings.toJson())

    return


readConfig()