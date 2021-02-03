MAINTAINER cbwang <cbwang2016@outlook.com>

ARG ALPINE_VERSION=3.13

# Set microsocks vars
ARG MICROSOCKS_REPO=https://github.com/rofl0r/microsocks
ARG MICROSOCKS_BRANCH=v1.0.1
ARG MICROSOCKS_URL=${MICROSOCKS_REPO}/archive/${MICROSOCKS_BRANCH}.tar.gz

# Build microsocks
FROM alpine:${ALPINE_VERSION} as builder

ARG MICROSOCKS_REPO
ARG MICROSOCKS_BRANCH
ARG MICROSOCKS_URL

ENV MICROSOCKS_REPO=${MICROSOCKS_REPO} \
    MICROSOCKS_BRANCH=${MICROSOCKS_BRANCH} \
    MICROSOCKS_URL=${MICROSOCKS_URL}

# Change working dir.
WORKDIR /tmp

# Add MICROSOCKS repo archive
ADD ${MICROSOCKS_URL} /tmp/microsocks.tar.gz

# Install deps and build binary.
RUN \
  echo "Installing build dependencies..." && \
  apk add --update --no-cache \
    git \
    build-base \
    tar && \
  echo "Building MicroSocks..." && \
    tar -xvf microsocks.tar.gz --strip 1 && \
    make && \
    chmod +x /tmp/microsocks && \
    mkdir -p /tmp/microsocks-bin && \
    cp -v /tmp/microsocks /tmp/microsocks-bin

# Runtime container
FROM alpine:${ALPINE_VERSION}

# Copy binary from build container.
COPY --from=builder /tmp/microsocks-bin/microsocks /usr/local/bin/microsocks

RUN apk add --no-cache libcrypto1.1 libssl1.1 libstdc++ tinyproxy nettle --repository http://dl-cdn.alpinelinux.org/alpine/edge/main
RUN apk add --no-cache oath-toolkit-libpskc openconnect --repository http://dl-cdn.alpinelinux.org/alpine/edge/community

# add vpn-slice with dependencies (dig) https://github.com/dlenski/vpn-slice
RUN apk add --no-cache python3 bind-tools && pip3 install --upgrade pip \
    && pip3 install https://github.com/dlenski/vpn-slice/archive/master.zip \
    # always add the docker DNS server
    && grep -qxF 'nameserver 127.0.0.11' /etc/resolv.conf || echo 'nameserver 127.0.0.11' >> /etc/resolv.conf

# Use an up-to-date version of vpnc-script
# https://www.infradead.org/openconnect/vpnc-script.html
COPY vpnc-script /etc/vpnc/vpnc-script
RUN chmod 755 /etc/vpnc/vpnc-script

COPY tinyproxy.conf /etc/tinyproxy.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8888
EXPOSE 8889

ENTRYPOINT ["/entrypoint.sh"]
