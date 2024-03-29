
import dbus
import common
import util

from service  import Characteristic, Descriptor
from settings import Settings

class TimeCharacteristic(Characteristic):

    def __init__(self, service, settings: Settings):
        self.notifying = False
        self.settings  = settings

        Characteristic.__init__(
            self, common.TIME_CHARACTERISTIC_UUID,
            ["notify", "read"], service)
        self.add_descriptor(TimeDescriptor(self))

    def get_time(self):

        value = []

        if self.settings.timeFormat == 1:
            cmd = "date '+%I:%M %p %Z'"
        else:
            cmd = "date '+%H:%M %Z'"

        # cmd="date +%H:%M"

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


class TimeDescriptor(Descriptor):
    TIME_DESCRIPTOR_VALUE = "Current Time"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, common.TIME_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.TIME_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value