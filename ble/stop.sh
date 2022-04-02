#!/bin/bash

MAIN=piclock.py

CT=`ps -ef | grep python | grep $MAIN | wc -l`

if [ $CT -lt 1 ];then
  echo service is not running
else
  sudo kill -9 `ps -ef | grep python | grep $MAIN | awk '{print $2}'`
  echo killed service 
fi
