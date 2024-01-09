ARG ALPINE_VERSION \
    WITH_GLIBC=0

FROM alpine:${ALPINE_VERSION}
LABEL maintainer="Abhinav A V <36784+abhai2k@users.noreply.github.com>"

ARG S6_OVERLAY_VERSION \
    WITH_GLIBC \
    GLIBC_VARIANT='x86_64' \
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
        https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz \
        https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/syslogd-overlay-noarch.tar.xz -P /tmp/; \
  if [ "${TARGETARCH}" == "amd64" ]; \
  then \
    wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz -O /tmp/s6-overlay-arch.tar.xz;\
    # Set GLIBC variant also
    GLIBC_VARIANT='x86_64'; \
  fi; \
  if [ "${TARGETARCH}" == "arm64" ] || [[ "${TARGETARCH}" == "arm" && "${TARGETVARIANT}" == 'v8' ]]; \
  then \
    wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.xz -O /tmp/s6-overlay-arch.tar.xz;\
    GLIBC_VARIANT='aarch64'; \
  fi; \
  if [ "${TARGETARCH}" == "arm" ] && [[ "${TARGETVARIANT}" == 'v7' || "${TARGETVARIANT}" == 'v6' ]]; \
  then \
    wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-armhf.tar.xz -O /tmp/s6-overlay-arch.tar.xz;\
    GLIBC_VARIANT='armhf'; \
  fi; \
  tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz; \
  tar -C / -Jxpf /tmp/s6-overlay-arch.tar.xz; \
  tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz; \
  tar -C / -Jxpf /tmp/syslogd-overlay-noarch.tar.xz; \
  if [ $WITH_GLIBC == 1 ]; \
  then \
    GLIBC_VERSION="$(curl -SL https://api.github.com/repos/SatoshiPortal/alpine-pkg-glibc/releases/latest | awk '/tag_name/{print $4;exit}' FS='[""]' | sed -e 's_v__')"     && echo "Using GLIBC Version: ${GLIBC_VERSION}"; \
    wget "https://github.com/SatoshiPortal/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/cyphernode@satoshiportal.com.rsa.pub" -O /etc/apk/keys/cyphernode@satoshiportal.com.rsa.pub; \
    wget https://github.com/SatoshiPortal/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}-${GLIBC_VARIANT}.apk -O glibc.apk; \
    wget https://github.com/SatoshiPortal/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}-${GLIBC_VARIANT}.apk -O glibc-bin.apk; \
    apk add --force-overwrite glibc-bin.apk glibc.apk; \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib; \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf; \
    rm -rf glibc.apk glibc-bin.apk /var/cache/apk/*; \
  fi; \
  rm -rf /tmp/* /var/cache/apk/*; \
  apk del wget gettext -r; \
  addgroup -g ${PGID} tundra; \
  adduser -DH -s /sbin/nologin -u ${PUID} tundra -G tundra;

ADD /rootfs /

# VOLUME [ "/crons" ]

# Init
ENTRYPOINT [ "/init" ]