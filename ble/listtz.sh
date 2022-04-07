#!/bin/ksh

timedatesctl list
find /usr/share/zoneinfo/US -type l -ls | awk '{print substr($NF,4)}' 
