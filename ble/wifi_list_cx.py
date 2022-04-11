
import time
import os
import dbus
import common
import util

from service  import Characteristic, Descriptor
from settings import Settings

class WiFiListCharacteristic(Characteristic):
    wifiIterator=-1;

    def __init__(self, service, settings: Settings):
        self.notifying = False
        self.settings  = settings

        Characteristic.__init__(
            self, common.WIFI_LIST_CHARACTERISTIC_UUID,
            ["read","write"], service)
        self.add_descriptor(WiFiListDescriptor(self))

    def WriteValue(self, value, options):
        val = ''.join([str(v) for v in value])

        print("received wifi request: "+val)

        cmd = r"""sudo iwlist wlan0 scan |sed -ne 's/^\s*ESSID:"\(.*\)"$/\1/p' | tr -dc '[\n[:print:]]' | awk '{if (NF>0 && length<55) print}' | sort -u"""

        allWifi=util.execList(cmd)

        self.wifiIterator=-1;
        self.wifiList=[]
        for ssid in allWifi:
            if len(ssid)>0:
                self.wifiList.append(ssid)
        self.wifiIterator=0;

    def get_wifi(self):
        value = []
        now=""

        while self.wifiIterator<0:
            time.sleep(0.1)


        if self.wifiIterator<len(self.wifiList):
            now = self.wifiList[self.wifiIterator]
            self.wifiIterator+=1
        else:
            now="###end-transmission###"
            self.wifiIterator=-1

        strtemp = str(now.strip())
        for c in strtemp:
            value.append(dbus.Byte(c.encode()))

        return value

    def ReadValue(self, options):
        value = self.get_wifi()

        return value


class WiFiListDescriptor(Descriptor):
    WIFI_DESCRIPTOR_VALUE = "WiFi Update HH:MM"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, common.WIFI_LIST_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.WIFI_LIST_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value