#!/bin/sh
toKill=$1
echo "Try to kill $toKill"
ps -ef|grep $toKill| grep -v grep | grep -v smartkill
ps -ef|grep $toKill| grep -v grep | grep -v smartkill |awk '{print $2}' | xargs kill -9 
echo "Done "
