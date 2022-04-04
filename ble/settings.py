
import json
from common import *

class Settings(object):

    def __init__(self,
                 unitType:   str='C',
                 timeFormat: int=1,
                 timezone:   str='Central'
                ):

        self.unitType = unitType
        self.timeFormat = timeFormat
        self.timezone   = timezone

    def toJson(self, prettyPrint:PrettyPrint=PrettyPrint.false):
        if prettyPrint == PrettyPrint.true:
            return json.dumps(self, default=lambda o: o.__dict__, indent=4)
        else:
            return json.dumps(self, default=lambda o: o.__dict__)

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
        return Settings(thisDict)

settings = Settings.fromJson("settings.json", JsonConversionType.file)



print("timeFormat="+str(settings.timeFormat))