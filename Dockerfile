ARG ALPINE_VERSION \
    WITH_GLIBC=0

FROM alpine:${ALPINE_VERSION}
LABEL maintainer="Abhinav A V <abhai2k@gmail.com>"

ARG S6_OVERLAY_VERSION \
    WITH_GLIBC \
    GLIBC_VERSION=2.34-r0 \
    TARGETPLATFORM \
    TARGETARCH \
    TARGETVARIANT

ENV PUID=1000 \
    PGID=1000 \ 
    TZ="UTC" \
    S6_GLOBAL_PATH="/command:/usr/bin:/bin:/usr/sbin" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    PATH="/scripts/bin:$PATH"

RUN set -eux; \ 
  apk upgrade --update --no-cache; \
  apk add --no-cache tzdata wget libintl gettext shadow curl jq; \
  cp /usr/bin/envsubst /usr/local/bin/envsubst; \
  wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz \
         https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz \
         https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz \
         https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/syslogd-overlay-noarch.tar.xz -P /tmp/; \
  tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz; \
  tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz; \
  tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz; \
  tar -C / -Jxpf /tmp/syslogd-overlay-noarch.tar.xz; \
  if [ $WITH_GLIBC == 1 ]; \
  then \
    if [ $TARGETARCH == "arm64" ]; \
    then \
      GLIBC_VERSION=2.32-r0; \
      wget https://github.com/ljfranklin/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}-arm64/ljfranklin-glibc.pub -O /etc/apk/keys/ljfranklin.rsa.pub; \
      wget https://github.com/ljfranklin/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}-arm64/glibc-${GLIBC_VERSION}.apk -O glibc.apk; \
      wget https://github.com/ljfranklin/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}-arm64/glibc-bin-${GLIBC_VERSION}.apk -O glibc-bin.apk; \
      apk add --allow-untrusted --force-overwrite glibc-bin.apk glibc.apk; \
    else \
      wget https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -O /etc/apk/keys/sgerrand.rsa.pub; \
      wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk -O glibc.apk; \
      wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk -O glibc-bin.apk; \
      apk add --force-overwrite glibc-bin.apk glibc.apk; \
    fi; \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib; \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf; \
    rm -rf glibc.apk glibc-bin.apk /var/cache/apk/*; \
  fi; \
  rm -rf /tmp/* /var/cache/apk/*; \
  apk del wget gettext -r; \
  addgroup -g ${PGID} tundra; \
  adduser -DH -s /sbin/nologin -u ${PUID} tundra -G tundra; \
  mkdir -p /app; \
  chown tundra:tundra /app;

ADD /rootfs /

# VOLUME [ "/crons" ]

# Init
ENTRYPOINT [ "/init" ]