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
    ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download"; \
    ALPINE_GLIBC_PACKAGE_VERSION="2.34-r0"; \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk"; \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk"; \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk"; \
    apk add --no-cache --virtual=.build-dependencies ca-certificates; \
    echo \
      "-----BEGIN PUBLIC KEY-----\
      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
      y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
      tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
      m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
      KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
      Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
      1QIDAQAB\
      -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub"; \
    wget \
      "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"; \
    mv /etc/nsswitch.conf /etc/nsswitch.conf.bak; \
    apk add --no-cache --force-overwrite \
      "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"; \
    mv /etc/nsswitch.conf.bak /etc/nsswitch.conf; \
    rm "/etc/apk/keys/sgerrand.rsa.pub"; \
    (/usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true); \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh; \
    apk del glibc-i18n; \
    rm "/root/.wget-hsts"; \
    apk del .build-dependencies; \
    rm \
      "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"; \
  fi; \
  rm -rf /tmp/* /var/cache/apk/*; \
  apk del wget gettext -r; \
  addgroup -g ${PGID} tundra; \
  adduser -DH -s /sbin/nologin -u ${PUID} tundra -G tundra;

ADD /rootfs /

# VOLUME [ "/crons" ]

# Init
ENTRYPOINT [ "/init" ]