
import os
import dbus
import common
import util

from service  import Characteristic, Descriptor
from settings import Settings

class WiFiUpdateCharacteristic(Characteristic):

    def __init__(self, service, settings: Settings):
        self.notifying = False
        self.settings  = settings

        Characteristic.__init__(
            self, common.WIFI_UPDATE_CHARACTERISTIC_UUID,
            ["read","write"], service)
        self.add_descriptor(WiFiUpdateDescriptor(self))

    def WriteValue(self, value, options):
        val = ''.join([str(v) for v in value])

        print("received wifi list request : "+val)

        cmd = "sudo date +%T -s "+val+":00"
        os.system(cmd)
        print("wifi changed")

    def get_wifi(self):
        value = []

        cmd = r"""iwgetid | sed -ne 's/.*ESSID:"\(.*\)"$/\1/p'"""

        now = util.execOne(cmd)

        strtemp = str(now.strip())
        for c in strtemp:
            value.append(dbus.Byte(c.encode()))

        return value

    def ReadValue(self, options):
        value = self.get_wifi()

        return value


class WiFiUpdateDescriptor(Descriptor):
    WIFI_DESCRIPTOR_VALUE = "WiFi List SSID"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, common.WIFI_UPDATE_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.WIFI_UPDATE_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value