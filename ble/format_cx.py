
import common
import dbus
import config

from service import Characteristic, Descriptor


class FormatCharacteristic(Characteristic):

    def __init__(self, service):
        Characteristic.__init__(
                self, common.FORMAT_CHARACTERISTIC_UUID,
                ["read", "write"], service)
        self.add_descriptor(FormatDescriptor(self))

    def WriteValue(self, value, options):
        val = str(value[0]).upper()
        if val == "1":
            config.settings.timeFormat = 1
        elif val == "2":
            config.settings.timeFormat = 2

    def ReadValue(self, options):
        value = []

        if self.service.is_fahrenheit(): val = "F"
        else: val = "C"
        value.append(dbus.Byte(val.encode()))

        return value

class FormatDescriptor(Descriptor):
    FORMAT_DESCRIPTOR_VALUE = "Temperature Formats (F or C)"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, common.FORMAT_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.FORMAT_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value
