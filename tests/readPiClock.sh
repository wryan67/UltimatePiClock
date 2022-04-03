#!/bin/ksh

DEVICE="B8:27:EB:13:1C:88"

HA=$(sudo gatttool -i hci0 -b $DEVICE --characteristics | 
  grep -- $1-9233-face-8d75-3e5b444bc3cf |
  sed -ne 's/.*char value handle.*0x\([0-9a-f]*\).*/\1/p'
)

sudo gatttool -i hci0 -b $DEVICE --char-read -a 0x$HA

#handle = 0x005f, char properties = 0x12, char value handle = 0x0060, uuid = 00000004-9233-face-8d75-3e5b444bc3cf
