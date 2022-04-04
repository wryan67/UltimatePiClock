
import json

class Settings(object):
    unitType: str
    timeFormat: int
    timezone: str

    def __init__(self):
        self.unitType='C'
        self.timzone = "Central"
        self.timeFormat = 1


    def __init__(self, unitType: str, timeFormat: int, timezone: str):
        self.unitType = unitType
        self.timeFormat = timeFormat
        self.timezone   = timezone

    def toJson(self):
        return json.dumps(self, default=lambda o: o.__dict__)


