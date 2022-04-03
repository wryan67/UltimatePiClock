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

import config

from advertisement import Advertisement
from service import Application, Service

import time_cx
import temperature_cx
import unit_cx


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
        self.add_characteristic(temperature_cx.TempCharacteristic(self))
        self.add_characteristic(unit_cx.UnitCharacteristic(self))

    def is_fahrenheit(self):
        return self.fahrenheit

    def set_fahrenheit(self, fahrenheit):
        self.fahrenheit = fahrenheit





#:############:#
#:#         Main         #:#
#:############:#


app = Application()
app.add_service(ClockService(0))
app.register()

adv = ServiceAdvertisement(0)
adv.register()

print("dateFormat: " + str(config.settings['dateFormat']))

try:
    app.run()
except KeyboardInterrupt:
    app.quit()
