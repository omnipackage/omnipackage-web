#!/bin/sh
set -e

minio server /data --console-address :9001 &
MINIO_PID=$!

until mc alias set local http://localhost:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD >/dev/null 2>&1; do
  echo "Waiting for MinIO to be ready..."
  sleep 2
done

if ! mc ls local/activestorage >/dev/null 2>&1; then
  mc mb local/activestorage
fi

if ! mc ls local/repositories >/dev/null 2>&1; then
  mc mb local/repositories
  mc anonymous set download local/repositories
fi

wait $MINIO_PID
