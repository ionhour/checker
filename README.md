# Ionhour Checker

Ionhour Checker is a lightweight container that checks TCP dependencies and only
then triggers HTTP pings. It supports multiple dependencies in a single service
via a simple multi-line environment variable.

## Usage (Docker Compose)

```yaml
services:
  ionhour-checker:
    image: kareemarafa/ionhour-checker:1.0.0
    environment:
      DEPENDENCIES: |
        db:3306|https://your-check-endpoint/ping/db
        cache:6379|https://your-check-endpoint/ping/cache
      PING_INTERVAL_SECONDS: "10"
      GRACE_PERIOD_SECONDS: "60"
    restart: unless-stopped
    networks:
      - shared_db_network
```

## Environment variables

Required
- DEPENDENCIES: Multi-line list of `host:port|url` entries.

Optional
- PING_INTERVAL_SECONDS: Time between checks (default: 10).
- GRACE_PERIOD_SECONDS: Delay before first check (default: 0).

## Example DEPENDENCIES format

```
db:3306|https://your-check-endpoint/ping/db
cache:6379|https://your-check-endpoint/ping/cache
```

## Behavior

- For each dependency entry, the checker runs a TCP check on `host:port`.
- If TCP is reachable, it triggers the HTTP ping for that entry.
- If TCP is unreachable, it logs and skips that entry.
