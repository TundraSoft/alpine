ARG S6_VERSION=3.1.6.2 \
  ALPINE_BRANCH=v3.23

FROM alpine:latest AS src

ARG S6_VERSION \
    ALPINE_BRANCH \
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
  # Dynamically fetch the latest version for the specified branch
  if [ "${ALPINE_BRANCH}" = "edge" ]; then \
    ALPINE_VERSION="edge"; \
  else \
    ALPINE_VERSION=$(wget -qO- "https://cz.alpinelinux.org/alpine/${ALPINE_BRANCH}/releases/x86_64/latest-releases.yaml" | awk '/version:/ {print $2; exit}'); \
  fi; \
  echo "Using Alpine ${ALPINE_VERSION} from branch ${ALPINE_BRANCH}"; \
  # Set architecture mappings
  case "${TARGETPLATFORM}" in \
    "linux/amd64"|"linux/x86_64") export ALPINE_ARCH="x86_64"; export S6_ARCH="x86_64" ;; \
    "linux/arm64"|"linux/arm/v8") export ALPINE_ARCH="aarch64"; export S6_ARCH="aarch64" ;; \
    "linux/arm/v7") export ALPINE_ARCH="armv7"; export S6_ARCH="armhf" ;; \
    "linux/arm/v6") export ALPINE_ARCH="armhf"; export S6_ARCH="armhf" ;; \
    *) echo "Unsupported platform: ${TARGETPLATFORM}" ; exit 1 ;; \
    esac; \
  # Download Alpine minirootfs with dynamically determined version
  if [ "${ALPINE_BRANCH}" = "edge" ]; then \
    wget -qO- "https://dl-cdn.alpinelinux.org/alpine/edge/releases/${ALPINE_ARCH}/latest-releases.yaml" | \
    awk '/file:.*minirootfs.*\.tar\.gz/ {print "https://dl-cdn.alpinelinux.org/alpine/edge/releases/'${ALPINE_ARCH}'/" $2}' | \
    head -1 | xargs wget -qO- | tar -xz; \
  else \
    wget -qO- "https://dl-cdn.alpinelinux.org/alpine/${ALPINE_BRANCH}/releases/${ALPINE_ARCH}/alpine-minirootfs-${ALPINE_VERSION}-${ALPINE_ARCH}.tar.gz" | tar -xz; \
  fi; \
  wget https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-noarch.tar.xz \
        https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-symlinks-noarch.tar.xz \
        https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/syslogd-overlay-noarch.tar.xz \
        https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-${S6_ARCH}.tar.xz -P /tmp; \
  tar -C /install/ -Jxpf /tmp/s6-overlay-noarch.tar.xz; \
  tar -C /install/ -Jxpf /tmp/s6-overlay-${S6_ARCH}.tar.xz; \
  tar -C /install/ -Jxpf /tmp/syslogd-overlay-noarch.tar.xz; \
  tar -C /install/ -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz; \
  rmdir -p /home \
         /media/cdrom \
         /media/floppy \
         /media/usb \
         /mnt \
         /srv \
         /usr/local/bin \
         /usr/local/lib \
         /usr/local/share 2>/dev/null || true; \
  rm -rf /tmp/* /var/cache/apk/*;

FROM scratch

LABEL maintainer="Abhinav A V <36784+abhai2k@users.noreply.github.com>" \
      org.opencontainers.image.title="Alpine Linux with S6 Overlay" \
      org.opencontainers.image.description="Lightweight, secure Alpine Linux base image with S6 overlay, cron support, and developer-friendly utilities" \
      org.opencontainers.image.vendor="TundraSoft" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.url="https://github.com/TundraSoft/alpine" \
      org.opencontainers.image.documentation="https://github.com/TundraSoft/alpine/blob/main/README.md" \
      org.opencontainers.image.source="https://github.com/TundraSoft/alpine.git"

ARG S6_VERSION \
    ALPINE_BRANCH \
    TARGETPLATFORM \
    TARGETARCH \
    TARGETVARIANT

ENV PUID=1000 \
    PGID=1000 \ 
    TZ="UTC" \
    S6_GLOBAL_PATH="/command:/usr/bin:/bin:/usr/sbin" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    PATH="/scripts:$PATH" \
    LANG=C.UTF-8

COPY --from=src /install /

RUN set -eux; \
  apk add --no-cache apk-tools ca-certificates curl gettext jq libintl shadow ssl_client tzdata wget; \
  cp /usr/bin/envsubst /usr/local/bin/envsubst; \
  update-ca-certificates; \
  rm -rf /tmp/* /var/cache/apk/*; \
  apk del wget gettext -r; \
  addgroup -g ${PGID} tundra; \
  adduser -DH -s /sbin/nologin -u ${PUID} tundra -G tundra;

COPY /rootfs /

ENTRYPOINT ["/init"]