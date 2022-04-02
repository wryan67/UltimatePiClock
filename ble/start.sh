#!/bin/bash

CT=`ps -ef | grep python | grep main.py | wc -l`

if [ $CT -lt 1 ];then
  cd `dirname $0`
  nohup sudo ./main.py > server.log 2>&1 &
  echo service started
else
  ps -ef | grep python | grep main.py 
  echo service is running
fi
