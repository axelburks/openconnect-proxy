#!/bin/sh

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

run () {
  # Start openconnect
  if [[ -z "${OPENCONNECT_PASSWORD}" ]]; then
  # Ask for password
    openconnect -u $OPENCONNECT_USER $OPENCONNECT_OPTIONS $OPENCONNECT_URL
  elif [[ ! -z "${OPENCONNECT_PASSWORD}" ]] && [[ ! -z "${OPENCONNECT_MFA_CODE}" ]]; then
  # Multi factor authentication (MFA)
    (echo $OPENCONNECT_PASSWORD; echo $OPENCONNECT_MFA_CODE) | openconnect -u $OPENCONNECT_USER $OPENCONNECT_OPTIONS --passwd-on-stdin $OPENCONNECT_URL
  elif [[ ! -z "${OPENCONNECT_PASSWORD}" ]]; then
  # Standard authentication
    echo $OPENCONNECT_PASSWORD | openconnect -u $OPENCONNECT_USER $OPENCONNECT_OPTIONS --passwd-on-stdin $OPENCONNECT_URL
  fi
}

until (run); do
  echo "nameserver 114.114.114.114" > /etc/resolv.conf
  echo "openconnect exited. Restarting process in 60 seconds…" >&2
  sleep 60
done

