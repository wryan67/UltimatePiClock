
import os
import dbus
import common
import util

from service  import Characteristic, Descriptor
from settings import Settings

class TimeUpdateCharacteristic(Characteristic):

    def __init__(self, service, settings: Settings):
        self.notifying = False
        self.settings  = settings

        Characteristic.__init__(
            self, common.TIME_UPDATE_CHARACTERISTIC_UUID,
            ["read","write"], service)
        self.add_descriptor(TimeUpdateDescriptor(self))

    def WriteValue(self, value, options):
        val = ''.join([str(v) for v in value])

        if self.settings.isAutoUpdate != "F":
            os.system("sudo timedatectl set-ntp 0")
            self.isAutoUpdate = False

        cmd = "sudo date +%T -s "+val+":00"
        os.system(cmd)

    def get_time(self):
        value = []

        cmd = "date '+%H:%M'"

        now = util.execOne(cmd)

        strtemp = str(now.strip())
        for c in strtemp:
            value.append(dbus.Byte(c.encode()))

        return value

    def ReadValue(self, options):
        value = self.get_time()

        return value


class TimeUpdateDescriptor(Descriptor):
    TIME_DESCRIPTOR_VALUE = "Time Update HH:MM"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, common.TIME_UPDATE_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.TIME_UPDATE_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value