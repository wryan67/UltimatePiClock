
import os
import util
from common import JsonConversionType, PrettyPrint

from  settings import Settings

class Config:

    @staticmethod
    def getHome():
        return util.execOne("awk -F: '{if($1==\"" + os.getlogin() + "\")print $6}' /etc/passwd")

    @staticmethod
    def getConfigPath():
        return Config.getHome()+"/.config/piclock"

    @staticmethod
    def readConfig():
        settings: Settings
        configFile = Config.getConfigPath()+"/config.json"

        if os.path.exists(configFile):
            print("reading config<"+configFile+">...")
            with open(configFile) as json_file:
                settings = Settings.fromJson(configFile,JsonConversionType.file)
        else:
            print("creating config<"+configFile+">...")
            os.makedirs(Config.getConfigPath(), exist_ok=True)
            print(settings.toJson())
            with open(configFile, 'w') as outfile:
                outfile.write(settings.toJson())

        return settings