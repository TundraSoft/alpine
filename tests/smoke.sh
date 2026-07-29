#!/usr/bin/env bash
#
# Smoke test for the tundrasoft/alpine base image.
#
# Because the image's ENTRYPOINT is /init, every `docker run <img> <cmd>` boots
# the full s6-overlay bring-up (init-user, timezone, config-cron oneshots) BEFORE
# running <cmd>. So these behavioural checks double as proof that s6 booted.
#
# Usage: tests/smoke.sh <image> [expected-alpine-version]
set -euo pipefail

IMG="${1:?usage: smoke.sh <image> [expected-alpine-version]}"
EXPECTED_ALPINE="${2:-}"

fail() { printf '\033[31mFAIL\033[0m %s\n' "$*" >&2; exit 1; }
pass() { printf '\033[32mPASS\033[0m %s\n' "$*"; }

# S6_VERBOSITY=1 keeps warnings/errors but silences the per-service boot chatter.
run() { docker run --rm -e S6_VERBOSITY="${S6_VERBOSITY:-1}" "$@"; }

# 1. Alpine version baked in (only when an expected version is supplied and non-empty)
if [ -n "$EXPECTED_ALPINE" ]; then
  run "$IMG" cat /etc/alpine-release | grep -qF "$EXPECTED_ALPINE" \
    || fail "/etc/alpine-release does not contain '$EXPECTED_ALPINE'"
  pass "alpine-release contains $EXPECTED_ALPINE"
else
  echo "SKIP alpine-release version check (no expected version given)"
fi

# 2. envsubst is on PATH (the image's headline utility)
run "$IMG" sh -c 'command -v envsubst >/dev/null' \
  || fail "envsubst not found on PATH"
pass "envsubst present"

# 3. tundra user/group exist at the default ids
def_ids="$(run "$IMG" sh -c 'id -u tundra; id -g tundra')"
[ "$(printf '%s\n' "$def_ids" | sed -n 1p)" = "1000" ] || fail "default tundra uid != 1000"
[ "$(printf '%s\n' "$def_ids" | sed -n 2p)" = "1000" ] || fail "default tundra gid != 1000"
pass "tundra defaults to uid/gid 1000/1000"

# 4. PUID/PGID remap — regression test for the init-user defect where PGID
#    followed PUID and a custom group id was silently ignored.
map_ids="$(run -e PUID=1500 -e PGID=2000 "$IMG" sh -c 'id -u tundra; id -g tundra')"
[ "$(printf '%s\n' "$map_ids" | sed -n 1p)" = "1500" ] || fail "PUID remap failed (got '$(printf '%s\n' "$map_ids" | sed -n 1p)')"
[ "$(printf '%s\n' "$map_ids" | sed -n 2p)" = "2000" ] || fail "PGID remap failed (got '$(printf '%s\n' "$map_ids" | sed -n 2p)')"
pass "PUID/PGID remap to 1500/2000"

# 5. Timezone is applied from the TZ env var
run -e TZ=Asia/Kolkata "$IMG" cat /etc/timezone | grep -qx 'Asia/Kolkata' \
  || fail "timezone not set to Asia/Kolkata"
pass "timezone applied from TZ"

# 6. Cron files dropped in /crons are imported into the crontab at boot
cron_out="$(run -v "$(cd "$(dirname "$0")/fixtures/crons" && pwd):/crons:ro" "$IMG" sh -c 'crontab -l 2>/dev/null')"
printf '%s\n' "$cron_out" | grep -qF 'smoke-cron-marker' \
  || fail "cron file in /crons was not imported into the crontab"
pass "cron import from /crons"

# 7. Healthcheck script reports healthy while the s6 supervisor is running
run "$IMG" /usr/bin/healthcheck.sh \
  || fail "healthcheck.sh returned non-zero while s6 was running"
pass "healthcheck reports healthy"

echo
pass "all smoke tests passed for $IMG"
