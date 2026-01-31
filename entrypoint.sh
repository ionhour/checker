#!/bin/sh
set -eu

targets_raw=${DEPENDENCIES-}
targets_trimmed=$(printf "%s" "$targets_raw" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [ -z "$targets_trimmed" ]; then
  : "${DEPENDENCY_CHECK_URL:?}"
  : "${SERVICE_HOST:?}"
  : "${SERVICE_PORT:?}"
fi

PING_INTERVAL_SECONDS="${PING_INTERVAL_SECONDS:-10}"
GRACE_PERIOD_SECONDS="${GRACE_PERIOD_SECONDS:-0}"

sleep "$GRACE_PERIOD_SECONDS"

while true; do
  ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  if [ -n "$targets_trimmed" ]; then
    old_ifs=$IFS
    IFS='
'
    for entry in $targets_raw; do
      IFS=$old_ifs
      entry=$(printf "%s" "$entry" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      if [ -z "$entry" ]; then
        continue
      fi
      hostport=${entry%%|*}
      url=${entry#*|}
      if [ "$hostport" = "$url" ]; then
        echo "[pinger] $ts invalid target entry: $entry"
        continue
      fi
      host=${hostport%%:*}
      port=${hostport#*:}
      if [ -z "$host" ] || [ -z "$port" ]; then
        echo "[pinger] $ts invalid host/port in entry: $entry"
        continue
      fi
      if nc -z -w 1 "$host" "$port" >/dev/null 2>&1; then
        status=$(curl -sS -o /dev/null -w "%{http_code}" \
          "$url" || echo "000")
        if [ "$status" = "000" ]; then
          echo "[pinger] $ts ping failed url=$url"
        else
          echo "[pinger] $ts ping status=$status url=$url"
        fi
      else
        echo "[pinger] $ts service tcp unavailable host=$host port=$port; skip ping"
      fi
    done
    IFS=$old_ifs
  else
    if nc -z -w 1 "$SERVICE_HOST" "$SERVICE_PORT" >/dev/null 2>&1; then
      status=$(curl -sS -o /dev/null -w "%{http_code}" \
        "$DEPENDENCY_CHECK_URL" || echo "000")
      if [ "$status" = "000" ]; then
        echo "[pinger] $ts ping failed url=$DEPENDENCY_CHECK_URL"
      else
        echo "[pinger] $ts ping status=$status url=$DEPENDENCY_CHECK_URL"
      fi
    else
      echo "[pinger] $ts service tcp unavailable; skip ping"
    fi
  fi
  sleep "$PING_INTERVAL_SECONDS"
done
