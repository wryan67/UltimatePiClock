
import os
import dbus
import common

from service import Characteristic, Descriptor


class TimeCharacteristic(Characteristic):
    TIME_CHARACTERISTIC_UUID = "00000004-9233-face-8d75-3e5b444bc3cf"

    def __init__(self, service):
        self.notifying = False

        Characteristic.__init__(
            self, self.TIME_CHARACTERISTIC_UUID,
            ["notify", "read"], service)
        self.add_descriptor(TimeDescriptor(self))

    def get_time(self):
        global config

        value = []


        if config['dateFormat'] == 1:
            pdate = os.popen("date '+%I:%M %p %Z'")
        else:
            pdate = os.popen("date '+%H:%M %Z'")

        now = pdate.read()
        pdate.close()

        strtemp = str(now.strip())
        for c in strtemp:
            value.append(dbus.Byte(c.encode()))

        return value

    def set_time_callback(self):
        if self.notifying:
            value = self.get_time()
            self.PropertiesChanged(common.GATT_CHRC_IFACE, {"Value": value}, [])

        return self.notifying

    def StartNotify(self):
        if self.notifying:
            return

        self.notifying = True

        value = self.get_time()
        self.PropertiesChanged(common.GATT_CHRC_IFACE, {"Value": value}, [])
        self.add_timeout(common.NOTIFY_TIMEOUT, self.set_time_callback)

    def StopNotify(self):
        self.notifying = False

    def ReadValue(self, options):
        value = self.get_time()

        return value


class TimeDescriptor(Descriptor):
    TIME_DESCRIPTOR_UUID = "2901"
    TIME_DESCRIPTOR_VALUE = "Current Time"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, self.TIME_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.TIME_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value