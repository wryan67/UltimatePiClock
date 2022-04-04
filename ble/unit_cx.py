
import common
import dbus

from service import Characteristic, Descriptor


class UnitCharacteristic(Characteristic):

    def __init__(self, service):
        Characteristic.__init__(
                self, common.UNIT_CHARACTERISTIC_UUID,
                ["read", "write"], service)
        self.add_descriptor(UnitDescriptor(self))

    def WriteValue(self, value, options):
        val = str(value[0]).upper()
        if val == "C":
            self.settings.unitType='C'
        elif val == "F":
            self.settings.unitType='F'

    def ReadValue(self, options):
        value = []

        value.append(dbus.Byte(self.settings.unitType.encode()))

        return value

class UnitDescriptor(Descriptor):
    UNIT_DESCRIPTOR_VALUE = "Temperature Units (F or C)"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, common.UNIT_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.UNIT_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value
