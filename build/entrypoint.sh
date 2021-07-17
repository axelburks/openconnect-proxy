#!/bin/sh

if [[ ! -z "${SOCKS_USER}" ]] && [[ ! -z "${SOCKS_PASSWORD}" ]]; then
  echo "✔︎✔︎✔︎✔︎✔︎✔︎ Setup socks proxy with auth ✔︎✔︎✔︎✔︎✔︎✔︎"
  /usr/local/bin/microsocks -i 0.0.0.0 -p 8889 -u ${SOCKS_USER} -P ${SOCKS_PASSWORD} &
else
  echo "xxxxxx Need SOCKS_USER and SOCKS_PASSWORD env vars. Exit. xxxxxx"
  exit 1
fi

if [ -z "${AUTHORIZED_KEYS}" ]; then
  echo "xxxxxx Need AUTHORIZED_KEYS env var and stop running ssh server xxxxxx"
else
  echo "✔︎✔︎✔︎✔︎✔︎✔︎ Setup ssh tunnel with key auth ✔︎✔︎✔︎✔︎✔︎✔︎"
  echo "${AUTHORIZED_KEYS}" > /root/.ssh/authorized_keys
  chown root /root/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys
  /usr/sbin/sshd -e
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

# Init vars
if [ -z "${RETRY_INTERVAL}" ]; then
  RETRY_INTERVAL=60
fi
echo $RETRY_INTERVAL > retry_interval.txt
echo 0 > fail_times.txt

# Running
until (run); do
  fail_times=`cat fail_times.txt`
  retry_interval=`cat retry_interval.txt`

  fail_times=$((fail_times+1))
  echo $fail_times > fail_times.txt

  if [ $fail_times -gt 5 ]; then
    retry_interval=$((retry_interval*fail_times))
    echo $retry_interval > retry_interval.txt
  fi

  echo "nameserver 114.114.114.114" > /etc/resolv.conf
  echo "openconnect exited. Restarting process in $retry_interval seconds…" >&2
  sleep $retry_interval
done

