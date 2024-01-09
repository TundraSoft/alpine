ARG ALPINE_VERSION

FROM alpine:${ALPINE_VERSION}
LABEL maintainer="Abhinav A V <36784+abhai2k@users.noreply.github.com>"

ARG S6_OVERLAY_VERSION \
    TARGETPLATFORM \
    TARGETARCH \
    TARGETVARIANT

ENV PUID=1000 \
    PGID=1000 \ 
    TZ="UTC" \
    S6_GLOBAL_PATH="/command:/usr/bin:/bin:/usr/sbin" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    PATH="/scripts/bin:$PATH" \
    LANG=C.UTF-8

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
  fi; \
  if [ "${TARGETARCH}" == "arm64" ] || [[ "${TARGETARCH}" == "arm" && "${TARGETVARIANT}" == 'v8' ]]; \
  then \
    wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.xz -O /tmp/s6-overlay-arch.tar.xz;\
  fi; \
  if [ "${TARGETARCH}" == "arm" ] && [[ "${TARGETVARIANT}" == 'v7' || "${TARGETVARIANT}" == 'v6' ]]; \
  then \
    wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-armhf.tar.xz -O /tmp/s6-overlay-arch.tar.xz;\
  fi; \
  tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz; \
  tar -C / -Jxpf /tmp/s6-overlay-arch.tar.xz; \
  tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz; \
  tar -C / -Jxpf /tmp/syslogd-overlay-noarch.tar.xz; \
  rm -rf /tmp/* /var/cache/apk/*; \
  apk del wget gettext -r; \
  addgroup -g ${PGID} tundra; \
  adduser -DH -s /sbin/nologin -u ${PUID} tundra -G tundra;

ADD /rootfs /

# VOLUME [ "/crons" ]

# Init
ENTRYPOINT [ "/init" ]