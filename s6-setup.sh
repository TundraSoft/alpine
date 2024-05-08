#!/bin/sh
#
# Copyright (c) 2018-2020 Dave Hall <skwashd@gmail.com>
# MIT Licensed, see LICENSE for more information.
#

apk add --no-cache tzdata wget libintl gettext shadow curl jq
cp /usr/bin/envsubst /usr/local/bin/envsubst
wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz
wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz
wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/syslogd-overlay-noarch.tar.xz -P /tmp/
if [ "${TARGETARCH}" == "amd64" ];
then
  wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz -O /tmp/s6-overlay-arch.tar.xz;
fi
if [ "${TARGETARCH}" == "arm64" ] || [[ "${TARGETARCH}" == "arm" && "${TARGETVARIANT}" == 'v8' ]]
then
  wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.xz -O /tmp/s6-overlay-arch.tar.xz
fi
if [ "${TARGETARCH}" == "arm" ] && [[ "${TARGETVARIANT}" == 'v7' || "${TARGETVARIANT}" == 'v6' ]]
then
  wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-armhf.tar.xz -O /tmp/s6-overlay-arch.tar.xz
fi
tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
tar -C / -Jxpf /tmp/s6-overlay-arch.tar.xz
tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz
tar -C / -Jxpf /tmp/syslogd-overlay-noarch.tar.xz
rm -rf /tmp/* /var/cache/apk/*
apk del wget gettext -r
# Add a standard user.
addgroup -g ${PGID} tundra
adduser -DH -s /sbin/nologin -u ${PUID} tundra -G tundra