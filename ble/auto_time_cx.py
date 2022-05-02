
import os
import dbus
import common
import util

from service  import Characteristic, Descriptor
from settings import Settings

class AutoTimeCharacteristic(Characteristic):

    def __init__(self, service, settings: Settings):
        self.notifying = False
        self.settings  = settings

        Characteristic.__init__(
            self, common.AUTO_TIME_CHARACTERISTIC_UUID,
            ["read","write"], service)
        self.add_descriptor(AutoTimeDescriptor(self))

    def WriteValue(self, value, options):
        val = ''.join([str(v) for v in value])

        rs =  os.system("sudo timedatectl set-ntp "+val)

    def get_setting(self):
        value = []

        cmd = r"""timedatectl status | egrep "NTP service" | awk '{print $NF}'"""

        now = util.execOne(cmd)

        strtemp = str(now.strip())
        for c in strtemp:
            value.append(dbus.Byte(c.encode()))

        return value

    def ReadValue(self, options):
        value = self.get_setting()

        return value


class AutoTimeDescriptor(Descriptor):
    AUTO_TIME_DESCRIPTOR_VALUE = "Auto Time Update Setting"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, common.WIFI_UPDATE_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.AUTO_TIME_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value