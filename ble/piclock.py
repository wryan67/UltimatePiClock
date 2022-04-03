#!/usr/bin/python3

"""Copyright (c) 2019, Douglas Otwell

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

import os
import dbus
import json
import util

from advertisement import Advertisement
from service import Application, Service, Characteristic, Descriptor
from gpiozero import CPUTemperature

import common
import time_cx


class ServiceAdvertisement(Advertisement):
    def __init__(self, index):
        Advertisement.__init__(self, index, "peripheral")
        self.add_local_name("PiClock")
        self.include_tx_power = True

class ClockService(Service):
    CLOCK_SVC_UUID = "00000001-9233-face-8d75-3e5b444bc3cf"

    def __init__(self, index):
        self.fahrenheit = False

        Service.__init__(self, index, self.CLOCK_SVC_UUID, True)
        self.add_characteristic(time_cx.TimeCharacteristic(self))
        self.add_characteristic(TempCharacteristic(self))
        self.add_characteristic(UnitCharacteristic(self))

    def is_fahrenheit(self):
        return self.fahrenheit

    def set_fahrenheit(self, fahrenheit):
        self.fahrenheit = fahrenheit



class TempCharacteristic(Characteristic):
    TEMP_CHARACTERISTIC_UUID = "00000002-9233-face-8d75-3e5b444bc3cf"

    def __init__(self, service):
        self.notifying = False

        Characteristic.__init__(
                self, self.TEMP_CHARACTERISTIC_UUID,
                ["notify", "read"], service)
        self.add_descriptor(TempDescriptor(self))

    def get_temperature(self):
        value = []
        unit = "C"

        cpu = CPUTemperature()
        temp = cpu.temperature
        if self.service.is_fahrenheit():
            temp = (temp * 1.8) + 32
            unit = "F"

        strtemp = str(round(temp, 1)) + " " + unit
        for c in strtemp:
            value.append(dbus.Byte(c.encode()))

        return value

    def set_temperature_callback(self):
        if self.notifying:
            value = self.get_temperature()
            self.PropertiesChanged(common.GATT_CHRC_IFACE, {"Value": value}, [])

        return self.notifying

    def StartNotify(self):
        if self.notifying:
            return

        self.notifying = True

        value = self.get_temperature()
        self.PropertiesChanged(common.GATT_CHRC_IFACE, {"Value": value}, [])
        self.add_timeout(common.NOTIFY_TIMEOUT, self.set_temperature_callback)

    def StopNotify(self):
        self.notifying = False

    def ReadValue(self, options):
        value = self.get_temperature()

        return value



class TempDescriptor(Descriptor):
    TEMP_DESCRIPTOR_UUID = "2901"
    TEMP_DESCRIPTOR_VALUE = "CPU Temperature"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, self.TEMP_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.TEMP_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value

class UnitCharacteristic(Characteristic):
    UNIT_CHARACTERISTIC_UUID = "00000003-9233-face-8d75-3e5b444bc3cf"

    def __init__(self, service):
        Characteristic.__init__(
                self, self.UNIT_CHARACTERISTIC_UUID,
                ["read", "write"], service)
        self.add_descriptor(UnitDescriptor(self))

    def WriteValue(self, value, options):
        val = str(value[0]).upper()
        if val == "C":
            self.service.set_fahrenheit(False)
        elif val == "F":
            self.service.set_fahrenheit(True)

    def ReadValue(self, options):
        value = []

        if self.service.is_fahrenheit(): val = "F"
        else: val = "C"
        value.append(dbus.Byte(val.encode()))

        return value

class UnitDescriptor(Descriptor):
    UNIT_DESCRIPTOR_UUID = "2901"
    UNIT_DESCRIPTOR_VALUE = "Temperature Units (F or C)"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, self.UNIT_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.UNIT_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value

#:############:#
def readConfig():
#:############:#
    global config

    configFile = configPath+"/config.json"

    if os.path.exists(configFile):
        print("reading config....")
        with open(configFile) as json_file:
            config = json.load(json_file)
    else:
        config = {
            'dateFormat': 1
        }
        os.makedirs(configPath, exist_ok=True)
        with open(configFile, 'w') as outfile:
            outfile.write(json.dumps(config))

    return


#:############:#
#:#         Main         #:#
#:############:#

logname=os.getlogin()
home=util.execOne("awk -F: '{if($1==\""+logname+"\")print $6}' /etc/passwd")
configPath = home+"/.config/piclock"

app = Application()
app.add_service(ClockService(0))
app.register()

adv = ServiceAdvertisement(0)
adv.register()

readConfig()
print("dateFormat: "+str(config['dateFormat']))
try:
    app.run()
except KeyboardInterrupt:
    app.quit()
