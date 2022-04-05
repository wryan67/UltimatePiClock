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

import common
from settings import Settings

from advertisement import Advertisement
from service import Application, Service

from time_cx        import TimeCharacteristic
from temperature_cx import TempCharacteristic
from unit_cx        import UnitCharacteristic
from format_cx      import FormatCharacteristic
from timezone_cx    import TimezoneCharacteristic

class ServiceAdvertisement(Advertisement):
    def __init__(self, index):
        Advertisement.__init__(self, index, "peripheral")
        self.add_local_name("PiClock")
        self.include_tx_power = True

class ClockService(Service):

    def __init__(self, index, settings: Settings):
        Service.__init__(self, index, common.CLOCK_SVC_UUID, True)

        self.add_characteristic(TempCharacteristic(self))
        self.add_characteristic(UnitCharacteristic(self))
        self.add_characteristic(TimeCharacteristic(self,settings))
        self.add_characteristic(FormatCharacteristic(self,settings))
        self.add_characteristic(TimezoneCharacteristic(self,settings))


#:########################:#
#:#         Main         #:#
#:########################:#

settings = Settings.readConfig()

app = Application()
app.add_service(ClockService(0,settings))
app.register()

adv = ServiceAdvertisement(0)
adv.register()

print("Settings: " + settings.toJson())

try:
    app.run()
except KeyboardInterrupt:
    app.quit()
