#!/bin/bash

MAIN=piclock.py

CT=`ps -ef | grep python | grep $MAIN | wc -l`

if [ $CT -lt 1 ];then
  cd `dirname $0`
  nohup sudo ./$MAIN > server.log 2>&1 &
  echo service started
else
  ps -ef | grep python | grep $MAIN 
  echo service is running
fi
