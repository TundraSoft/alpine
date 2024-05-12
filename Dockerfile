ARG S6_VERSION=3.1.6.2 \
  ALPINE_BRANCH=3.19 \
  ALPINE_VERSION=3.19.1

FROM alpine:latest AS src

ARG S6_VERSION \
    ALPINE_BRANCH \
    ALPINE_VERSION \
    TARGETPLATFORM \
    TARGETARCH \
    TARGETVARIANT \
    OSARCH

ENV PUID=1000 \
    PGID=1000 \ 
    TZ="UTC" \
    S6_GLOBAL_PATH="/command:/usr/bin:/bin:/usr/sbin" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    PATH="/scripts/bin:$PATH" \
    LANG=C.UTF-8

WORKDIR /install

RUN set -eux; \ 
  apk add --no-cache jq; \
  echo '{"amd64":"x86_64", "arm64":"aarch64", "armv8":"aarch64", "armv7":"armv7", "armv6":"armhf"}' > /arch_map.json; \
  export ARCH=$(jq -r .${TARGETARCH} /arch_map.json); \
  wget -qO- https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_BRANCH}/releases/${ARCH}/alpine-minirootfs-${ALPINE_VERSION}-${ARCH}.tar.gz| tar -xz; \
  wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-noarch.tar.xz \
        https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-symlinks-noarch.tar.xz \
        https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/syslogd-overlay-noarch.tar.xz \
        https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-${ARCH}.tar.xz -P /tmp; \
  tar -C /install/ -Jxpf /tmp/s6-overlay-noarch.tar.xz; \
  tar -C /install/ -Jxpf /tmp/s6-overlay-${ARCH}.tar.xz; \
  tar -C /install/ -Jxpf /tmp/syslogd-overlay-noarch.tar.xz; \
  tar -C /install/ -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz; \
  rmdir -p /home /media/cdrom /media/floppy /media/usb /mnt /srv /usr/local/bin /usr/local/lib /usr/local/share 2>/dev/null || true; \
  rm -rf /tmp/* /var/cache/apk/*;

FROM scratch

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

USER tundra

ADD /rootfs /

ENTRYPOINT ["/init"]