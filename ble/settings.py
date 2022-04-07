
import os
import util
import json
from common import *

class Settings(object):

    def __init__(self,
                 unitType:   str='C',
                 timeFormat: int=1,
                 timezone:   str='Central',
                 isAutoUpdate: str='U'
                ):

        self.unitType     = unitType
        self.timeFormat   = timeFormat
        self.timezone     = timezone
        self.isAutoUpdate = isAutoUpdate


    def toJson(self, prettyPrint:PrettyPrint=PrettyPrint.true):
        if prettyPrint == PrettyPrint.true:
            return json.dumps(self, default=lambda o: o.__dict__, indent=4)
        else:
            return json.dumps(self, default=lambda o: o.__dict__)



    @staticmethod
    def getConfigPath():
        return util.getHome()+"/.config/piclock"

    @staticmethod
    def readConfig():
        settings = Settings()
        configFile = Settings.getConfigPath()+"/config.json"

        if os.path.exists(configFile):
            print("reading config<"+configFile+">...")
            with open(configFile) as json_file:
                settings = Settings.fromJson(configFile,JsonConversionType.file)
        else:
            print("creating config<"+configFile+">...")
            os.makedirs(Settings.getConfigPath(), exist_ok=True)
            print(settings.toJson())
            Settings.update(settings)

        return settings


    def update(self):
        configFile = Settings.getConfigPath() + "/config.json"

        with open(configFile, 'w') as outfile:
            outfile.write(self.toJson())
            outfile.close()

    @staticmethod
    def fromJson(input: str, mode: JsonConversionType = JsonConversionType.string):
        jsonString:str
        if mode == JsonConversionType.string:
            jsonString = input
        else:
            inputFile = open(input, "r");
            jsonString = inputFile.read()
            inputFile.close()

        thisDict=json.loads(jsonString)
        return Settings(**thisDict)


