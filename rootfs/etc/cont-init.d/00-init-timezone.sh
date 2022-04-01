#!/usr/bin/with-contenv sh
# Remove existing file if exists
if [ -f /etc/timezone ]; then
  echo 'deleting'
  rm -rf /etc/timezone /etc/localtime
  echo 'deleted'
fi
# Set timezone
if [ -f /usr/share/zoneinfo/${TZ} ]; then
  echo "Setting timezone to ${TZ}..."
  cp /usr/share/zoneinfo/${TZ} /etc/localtime
  echo $TZ >/etc/timezone
  echo "Timezone successfully set..."
fi
