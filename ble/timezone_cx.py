
import common
import dbus

from service  import Characteristic, Descriptor
from settings import Settings

class TimezoneCharacteristic(Characteristic):
    validTimezones = ["Central", "Eastern", "Mountain", "Pacific"]

    def __init__(self, service, settings: Settings):
        self.settings=settings
        Characteristic.__init__(
                self, common.TIMEZONE_CHARACTERISTIC_UUID,
                ["read", "write"], service)
        self.add_descriptor(TimezoneDescriptor(self))

    def WriteValue(self, value, options):
        global validTimezones
        if value in validTimezones:
            self.settings.timezone = value
            self.settings.update()

    def ReadValue(self, options):
        value = []

        for c in self.settings.timezone:
            value.append(dbus.Byte(c.encode()))

        return value

class TimezoneDescriptor(Descriptor):
    TIMEZONE_DESCRIPTOR_VALUE = "Timezones (Eastern, Central, Mountain, Pacific)"

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
