# openconnect + microsocks

This Docker image contains an [openconnect client](http://www.infradead.org/openconnect/) (version 8.10 with pulse/juniper support) and the [microsocks proxy](https://github.com/rofl0r/microsocks) for socks5 connections (default on port 8889) and the [openssh](https://www.openssh.com/) for ssh tunnel (default on port 22) in a very small [alpine linux](https://www.alpinelinux.org/) image (around 26 MB).

You can find the image on docker hub:
https://hub.docker.com/r/axelburks/openconnect-proxy

# Requirements

If you don't want to set the environment variables on the command line
set the environment variables in a `env` file:

	AUTHORIZED_KEYS=<AUTHORIZED_KEYS>
  SOCKS_USER=<Username>
  SOCKS_PASSWORD=<Password>
  OPENCONNECT_URL=<Gateway URL>
	OPENCONNECT_USER=<Username>
	OPENCONNECT_PASSWORD=<Password>
	OPENCONNECT_OPTIONS=--authgroup <VPN Group> \
		--servercert <VPN Server Certificate> --protocol=<Protocol> \
		--timestamp --reconnect-timeout 86400

_Don't use quotes around the values!_

See the [openconnect documentation](https://www.infradead.org/openconnect/manual.html) for available options. 

Either set the password in the `env` file or leave the variable `OPENCONNECT_PASSWORD` unset, so you get prompted when starting up the container.

Optionally set a multi factor authentication code:

	OPENCONNECT_MFA_CODE=<Multi factor authentication code>

# Run container in foreground

To start the container in foreground run:

	docker run -it --rm --privileged --env-file=env \
	  -p 8889:8889 axelburks/openconnect-proxy:latest

The proxies are listening on ports 8889 (socks). Either use `--net host` or `-p <local port>:8889` to make the proxy ports available on the host.

Without using a `env` file set the environment variables on the command line with the docker run option `-e`:

	docker run … -e OPENCONNECT_URL=vpn.gateway.com/example \
	-e OPENCONNECT_OPTIONS='<Openconnect Options>' \
	-e OPENCONNECT_USER=<Username> …

# Run container in background

To start the container in daemon mode (background) set the `-d` option:

	docker run -d -it --rm …

In daemon mode you can view the stderr log with `docker logs`:

	docker logs `docker ps|grep "axelburks/openconnect-proxy"|awk -F' ' '{print $1}'`

# Use container with docker-compose

version: '3'
services:
  vpn:
    image: 'axelburks/openconnect-proxy:latest'
    container_name: vpn
    privileged: true
    env_file:
      - ./env
    ports:
      - '8990:8889'
      - '8992:22'



Set the environment variables for _openconnect_ in the `env` file again (or specify another file) and 
map the configured ports in the container to your local ports if you want to access the VPN 
on the host too when running your containers. Otherwise only the docker containers in the same
network have access to the proxy ports.

# Route traffic through VPN container

Let's say you have a `vpn` container defined as above, then add `network_mode` option to your other containers:

	depends_on:
	  - vpn
	network_mode: "service:vpn"

Keep in mind that `networks`, `extra_hosts`, etc. and `network_mode` are mutually exclusive!

# Configure proxy

The container is connected via _openconnect_ and now you can configure your browser
and other software to use one of the proxies (8889 for socks).

# ssh through the proxy

You need nc (netcat), corkscrew or something similar to make this work.

Unfortunately some git clients (e.g. Gitkraken) don't use the settings from ssh config
and you can't pull/push from a repository that's reachable (DNS resolution) only through VPN.

## nc (netcat, ncat)

Set a `ProxyCommand` in your `~/.ssh/config` file like

	Host <hostname>
		ProxyCommand            nc -x 127.0.0.1:8889 %h %p

or (depending on your ncat version)

	Host <hostname>
		ProxyCommand            ncat --proxy 127.0.0.1:8889 --proxy-type socks5 %h %p

and your connection will be passed through the proxy.
The above example is for using git with ssh keys.

# Build

You can build the container yourself with

	version="2.0";docker buildx build --platform linux/amd64,linux/arm/v7,linux/arm64 -f build/Dockerfile -t axelburks/openconnect-proxy:latest -t axelburks/openconnect-proxy:$version ./build
