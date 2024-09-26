ARG S6_VERSION=3.1.6.2 \
  ALPINE_BRANCH=v3.19 \
  ALPINE_VERSION=3.19.1

FROM alpine:latest AS src

ARG S6_VERSION \
    ALPINE_BRANCH \
    ALPINE_VERSION \
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

WORKDIR /install

RUN set -eux; \ 
  case "${TARGETPLATFORM}" in \
    "linux/amd64"|"linux/x86_64") export ALPINE_ARCH="x86_64"; export S6_ARCH="x86_64" ;; \
    "linux/arm64"|"linux/arm/v8") export ALPINE_ARCH="aarch64"; export S6_ARCH="aarch64" ;; \
    "linux/arm/v7") export ALPINE_ARCH="armv7"; export S6_ARCH="armhf" ;; \
    "linux/arm/v6") export ALPINE_ARCH="armhf"; export S6_ARCH="armhf" ;; \
    *) echo "Unsupported platform: ${TARGETPLATFORM}" ; exit 1 ;; \
    esac; \
  wget -qO- https://dl-cdn.alpinelinux.org/alpine/${ALPINE_BRANCH}/releases/${ALPINE_ARCH}/alpine-minirootfs-${ALPINE_VERSION}-${ALPINE_ARCH}.tar.gz| tar -xz; \
  wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-noarch.tar.xz \
        https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-symlinks-noarch.tar.xz \
        https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/syslogd-overlay-noarch.tar.xz \
        https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-${S6_ARCH}.tar.xz -P /tmp; \
  tar -C /install/ -Jxpf /tmp/s6-overlay-noarch.tar.xz; \
  tar -C /install/ -Jxpf /tmp/s6-overlay-${S6_ARCH}.tar.xz; \
  tar -C /install/ -Jxpf /tmp/syslogd-overlay-noarch.tar.xz; \
  tar -C /install/ -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz; \
  rmdir -p /home /media/cdrom /media/floppy /media/usb /mnt /srv /usr/local/bin /usr/local/lib /usr/local/share 2>/dev/null || true; \
  rm -rf /tmp/* /var/cache/apk/*;

FROM scratch

LABEL maintainer="Abhinav A V <36784+abhai2k@users.noreply.github.com>"

ARG S6_VERSION \
    ALPINE_BRANCH \
    ALPINE_VERSION \
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

COPY --from=src /install /

RUN set -eux; \
  apk upgrade --update --no-cache; \
  apk add --no-cache tzdata wget libintl gettext shadow curl jq apk-tools ca-certificates ssl_client; \
  cp /usr/bin/envsubst /usr/local/bin/envsubst; \
  update-ca-certificates; \
  rm -rf /tmp/* /var/cache/apk/*; \
  apk del wget gettext -r; \
  addgroup -g ${PUID} tundra; \
  adduser -DH -s /sbin/nologin -u ${PGID} tundra -G tundra;

ADD /rootfs /

ENTRYPOINT ["/init"]