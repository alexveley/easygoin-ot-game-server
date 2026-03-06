#!/bin/bash
set -euo pipefail

SERVER_DIR="/home/container"
cd "$SERVER_DIR"
echo ">> Server directory: $SERVER_DIR"

# ---- Ensure RSA key ----
if [ ! -f "${SERVER_DIR}/key.pem" ]; then
  echo ">> Generating RSA key..."
  openssl genpkey -algorithm RSA \
    -out "${SERVER_DIR}/key.pem" \
    -pkeyopt rsa_keygen_bits:2048
  chmod 600 "${SERVER_DIR}/key.pem"
fi

# ---- Wait for DB (retry loop) ----
echo ">> Waiting for database..."
for i in {1..15}; do
  if mysqladmin ping \
    -h "${MYSQL_HOST:-127.0.0.1}" \
    -P "${MYSQL_PORT:-3306}" \
    -u "${MYSQL_USER:-root}" \
    -p"${MYSQL_PASSWORD:-}" \
    --silent; then
    break
  fi
  sleep 2
done

# ---- Schema import ----
if mysqladmin ping \
  -h "${MYSQL_HOST:-127.0.0.1}" \
  -P "${MYSQL_PORT:-3306}" \
  -u "${MYSQL_USER:-root}" \
  -p"${MYSQL_PASSWORD:-}" \
  --silent; then

  TABLE_COUNT="$(mysql \
    -h "${MYSQL_HOST:-127.0.0.1}" \
    -P "${MYSQL_PORT:-3306}" \
    -u "${MYSQL_USER:-root}" \
    -p"${MYSQL_PASSWORD:-}" \
    -D "${MYSQL_DATABASE:-forgottenserver}" \
    -sN -e "SHOW TABLES;" 2>/dev/null | wc -l)"

  if [ "${TABLE_COUNT:-0}" -eq 0 ] && [ -f "${SERVER_DIR}/schema.sql" ]; then
    echo ">> Importing schema.sql..."
    mysql \
      -h "${MYSQL_HOST:-127.0.0.1}" \
      -P "${MYSQL_PORT:-3306}" \
      -u "${MYSQL_USER:-root}" \
      -p"${MYSQL_PASSWORD:-}" \
      "${MYSQL_DATABASE:-forgottenserver}" < "${SERVER_DIR}/schema.sql"
  fi
else
  echo ">> Database not reachable — skipping schema import."
fi

# ---- Graceful shutdown ----
term_handler() {
  echo ">> Shutting down..."
  exit 0
}
trap term_handler SIGTERM SIGINT

# ---- Start TFS (PID 1) ----
echo ">> Starting TFS..."
exec /bin/bash -c "cd '${SERVER_DIR}' && exec /usr/local/bin/tfs"
