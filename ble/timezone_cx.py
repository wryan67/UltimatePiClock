
import os
import dbus
import common

from service  import Characteristic, Descriptor
from settings import Settings

class TimezoneCharacteristic(Characteristic):
    validTimezones = ["America/Chicago", "America/New_York", "America/Denver", "America/Los_Angeles"]

    def __init__(self, service, settings: Settings):
        self.settings=settings
        Characteristic.__init__(
                self, common.TIMEZONE_CHARACTERISTIC_UUID,
                ["read", "write"], service)
        self.add_descriptor(TimezoneDescriptor(self))

    def WriteValue(self, value, options):
        val = ''.join([str(v) for v in value])

        if val in self.validTimezones:
            cmd="sudo timedatectl set-timezone '"+val+"'"
            rs=os.system(cmd)
            self.settings.timezone = val
            self.settings.update()
        else:
            print("invalid tz:"+val);
	     

    def ReadValue(self, options):
        value = []

        for c in self.settings.timezone:
            value.append(dbus.Byte(c.encode()))

        return value

class TimezoneDescriptor(Descriptor):
    TIMEZONE_DESCRIPTOR_VALUE = "Timezones (linux format)"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, common.TIMEZONE_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.TIMEZONE_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value
