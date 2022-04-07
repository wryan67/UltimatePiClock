
import dbus
import common
import util

from service  import Characteristic, Descriptor
from settings import Settings

class HH24Characteristic(Characteristic):

    def __init__(self, service, settings: Settings):
        self.notifying = False
        self.settings  = settings

        Characteristic.__init__(
            self, common.HH24_CHARACTERISTIC_UUID,
            ["notify", "read"], service)
        self.add_descriptor(HH24Descriptor(self))

    def get_time(self):

        value = []

        cmd = "date '+%H'"

        now = util.execOne(cmd)

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


class HH24Descriptor(Descriptor):
    TIME_DESCRIPTOR_VALUE = "Current Hour 00-24"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, common.HH24_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.HH24_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value