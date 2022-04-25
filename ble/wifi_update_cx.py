
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

        print("received wifi update request : "+val)

        (ssid,passwd) = val.split(":<>:")

        print("received wifi new SSID/Passwd: " + ssid.strip() + "/" + passwd.strip())

        userHome = util.getHome()

        cmd = "find . "+userHome+"/apps "+userHome+"/projects "+userHome+" -type f -name wpa_supplicant.template | head -1"

        wpa_supplicant = util.execOne(cmd)


        fmt = "sed -e 's"+chr(0x1f)+"@SSID@"+chr(0x1f)+"%s"+chr(0x1f)+"' -e 's"+chr(0x1f)+"@PASSWD@"+chr(0x1f)+"%s"+chr(0x1f)+"' "+wpa_supplicant+" > /tmp/wpa_supplicant.template"
        cmd = fmt % (ssid.strip(),passwd.strip())

        rs=os.system(cmd)
        if rs==0:
          rs=os.system("sudo cp /tmp/wpa_supplicant.template /etc/wpa_supplicant/wpa_supplicant.conf")
          if rs==0:
            rs=os.system("sudo wpa_cli -i wlan0 reconfigure")
            if rs==0:
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