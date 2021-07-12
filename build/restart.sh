microsocks_status=`ps aux | grep microsocks | grep -v grep`
if [[ -z "${microsocks_status}" ]]; then
  if [[ ! -z "${SOCKS_USER}" ]] && [[ ! -z "${SOCKS_PASSWORD}" ]]; then
    echo "✔︎✔︎✔︎✔︎✔︎✔︎ Setup socks proxy with auth ✔︎✔︎✔︎✔︎✔︎✔︎"
    /usr/local/bin/microsocks -i 0.0.0.0 -p 8889 -u ${SOCKS_USER} -P ${SOCKS_PASSWORD} &
  else
    echo "xxxxxx Setup socks proxy without auth xxxxxx"
    /usr/local/bin/microsocks -i 0.0.0.0 -p 8889 &
  fi
fi

openconnect_status=`ps aux | grep openconnect | grep -v grep`
sleep_status=`ps aux | grep sleep | grep -v grep`
if [[ ! -z "${openconnect_status}" ]] || [[ ! -z "${sleep_status}" ]]; then
  ps -ef|grep 'openconnect'|grep -v 'grep'|awk '{print $1}'|xargs kill -9
  echo "nameserver 114.114.114.114" > /etc/resolv.conf
  sleep 1
  ps -ef|grep 'sleep'|grep -v 'grep'|awk '{print $1}'|xargs kill -9
fi