ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION}
LABEL maintainer="Abhinav A V <abhai2k@gmail.com>"


# 2.2.0.3
ARG S6_OVERLAY_VERSION=\
ENV PUID=1000 \
    PGID=1000 \ 
    UNAME="tundrasoft" \
    GNAME="tundrasoft" \
    TZ="UTC" \
    S6_GLOBAL_PATH="/command:/usr/bin:/bin:/usr/sbin" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=5000 

RUN set -eux; \ 
  apk upgrade --update --no-cache; \
  apk add --no-cache tzdata wget libintl gettext; \
  cp /usr/bin/envsubst /usr/local/bin/envsubst; \
  wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch-${S6_OVERLAY_VERSION}.tar.xz -O /tmp/s6-overlay-noarch.tar.xz; \
  wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64-${S6_OVERLAY_VERSION}.tar.xz -O /tmp/s6-overlay-x86_64.tar.xz; \
  wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch-${S6_OVERLAY_VERSION}.tar.xz -O /tmp/s6-overlay-symlinks-noarch.tar.xz; \
  wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/syslogd-overlay-noarch-${S6_OVERLAY_VERSION}.tar.xz -O /tmp/syslogd-overlay-noarch.tar.xz; \
  tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz; \
  tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz; \
  tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz; \
  tar -C / -Jxpf /tmp/syslogd-overlay-noarch.tar.xz; \
  rm -rf /tmp/*; \
  apk del wget gettext -r; \
  addgroup -g ${PGID} ${GNAME}; \
  adduser -DH -s /sbin/nologin -u ${PUID} ${UNAME} -G ${GNAME};

ADD /rootfs /
# Init
ENTRYPOINT [ "/init" ]