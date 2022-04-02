#!/bin/bash

MAIN=piclock.py

CT=`ps -ef | grep python | grep $MAIN | wc -l`

if [ $CT -lt 1 ];then
  echo service is not running
else
  ps -ef | grep python | grep $MAIN 
  echo service is running
fi
