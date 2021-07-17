#!/bin/sh

openconnect_status=`ps aux | grep openconnect | grep -v grep`
sleep_status=`ps aux | grep sleep | grep -v grep`
if [[ ! -z "${openconnect_status}" ]] || [[ ! -z "${sleep_status}" ]]; then
  ps -ef|grep 'openconnect'|grep -v 'grep'|awk '{print $1}'|xargs kill -9
  sleep 1
  
  # Init vars
  if [ -z "${RETRY_INTERVAL}" ]; then
    RETRY_INTERVAL=60
  fi
  echo $RETRY_INTERVAL > retry_interval.txt
  echo 0 > fail_times.txt

  echo "nameserver 114.114.114.114" > /etc/resolv.conf
  ps -ef|grep 'sleep'|grep -v 'grep'|awk '{print $1}'|xargs kill -9
fi