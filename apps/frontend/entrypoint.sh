#!/bin/sh
set -e
# Single root .env for the whole monorepo.
if [ ! -f /app/.env ]; then
  cp /app/.env.example /app/.env
  echo "Created /app/.env from /app/.env.example"
fi
exec "$@"
