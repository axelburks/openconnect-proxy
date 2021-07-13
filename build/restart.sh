#!/bin/sh

openconnect_status=`ps aux | grep openconnect | grep -v grep`
sleep_status=`ps aux | grep sleep | grep -v grep`
if [[ ! -z "${openconnect_status}" ]] || [[ ! -z "${sleep_status}" ]]; then
  ps -ef|grep 'openconnect'|grep -v 'grep'|awk '{print $1}'|xargs kill -9
  echo "nameserver 114.114.114.114" > /etc/resolv.conf
  sleep 1
  ps -ef|grep 'sleep'|grep -v 'grep'|awk '{print $1}'|xargs kill -9
fi