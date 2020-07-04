FROM ubuntu:18.04

ARG LATEST_VERSION

RUN \
    echo "**** install runtime dependencies ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    gettext build-essential autoconf libtool libpcre3-dev \
    asciidoc xmlto libev-dev libc-ares-dev automake \
    libmbedtls-dev libsodium-dev \
    ca-certificates curl && \    
    if [ -z ${LATEST_VERSION+x} ]; then \
	    LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/shadowsocks/shadowsocks-libev/releases/latest);  \
        LATEST_VERSION=$(echo $LATEST_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/');  \
    fi && \
    echo "**** download shadowsocks-libev ${LATEST_VERSION} ****" && \
    LATEST_VERSION2=$(echo $LATEST_VERSION | sed -e 's/v\([0-9\.]*\).*/\1/') && \
    curl -L -O https://github.com/shadowsocks/shadowsocks-libev/releases/download/${LATEST_VERSION}/shadowsocks-libev-${LATEST_VERSION2}.tar.gz && \
    tar xzvf shadowsocks-libev-${LATEST_VERSION2}.tar.gz --transform s/shadowsocks-libev-${LATEST_VERSION2}/build/ && \ 
    echo "**** build from shadowsocks-libev ${LATEST_VERSION} ****" && \
    cd /build && \
    ./configure && \
    make

FROM alpine

RUN mkdir -p /export 

COPY --from=0 /build/src/ss-* /export/

