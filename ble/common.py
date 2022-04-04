GATT_CHRC_IFACE = "org.bluez.GattCharacteristic1"
NOTIFY_TIMEOUT = 5000
CUD_UUID = 'face'

TEMP_CHARACTERISTIC_UUID = "00000002-9233-face-8d75-3e5b444bc3cf"
UNIT_CHARACTERISTIC_UUID = "00000003-9233-face-8d75-3e5b444bc3cf"
TIME_CHARACTERISTIC_UUID = "00000004-9233-face-8d75-3e5b444bc3cf"
FORMAT_CHARACTERISTIC_UUID = "00000005-9233-face-8d75-3e5b444bc3cf"

TEMP_DESCRIPTOR_UUID = "00000002-9233-face-deaf-3e5b444bc3cf"
UNIT_DESCRIPTOR_UUID = "00000003-9233-face-deaf-3e5b444bc3cf"
TIME_DESCRIPTOR_UUID = "00000004-9233-face-deaf-3e5b444bc3cf"
FORMAT_DESCRIPTOR_UUID = "00000005-9233-face-deaf-3e5b444bc3cf"

from enum import Enum
class JsonConversionType(Enum):
    string = 1
    file = 2

class PrettyPrint(Enum):
    false = 0
    true = 1
