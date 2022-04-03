
import os
import json
import util

logname=os.getlogin()


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
    configFile = getConfigPath()+"/config.json"

    if os.path.exists(configFile):
        print("reading config....")
        with open(configFile) as json_file:
            config = json.load(json_file)
    else:
        config = {
            'dateFormat': 1
        }
        os.makedirs(getConfigPath(), exist_ok=True)
        with open(configFile, 'w') as outfile:
            outfile.write(json.dumps(config))

    return config

settings=readConfig()