
import dbus
import requests

import common

from service  import Characteristic, Descriptor
from settings import Settings

class FormatCharacteristic(Characteristic):

    def __init__(self, service, settings: Settings):
        self.settings=settings
        Characteristic.__init__(
                self, common.FORMAT_CHARACTERISTIC_UUID,
                ["read", "write"], service)
        self.add_descriptor(FormatDescriptor(self))

    def WriteValue(self, value, options):
        val = str(value[0]).upper()
        if val == "1":
            self.settings.timeFormat = 1
            self.settings.update()
            rs=requests.post("http://localhost:8080/timeFormat", data = "1")
        elif val == "2":
            self.settings.timeFormat = 2
            self.settings.update()
            rs=requests.post("http://localhost:8080/timeFormat", data = "2")

    def ReadValue(self, options):
        value = []

        value.append(dbus.Byte(0x30+self.settings.timeFormat))

        return value

class FormatDescriptor(Descriptor):
    FORMAT_DESCRIPTOR_VALUE = "Time Formats (1 or 2)"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, common.FORMAT_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.FORMAT_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value
