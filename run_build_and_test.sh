#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="shvirtd-example-python:local"

echo "1) Собираем образ из Dockerfile.python..."
docker build -f Dockerfile.python -t "${IMAGE_NAME}" "${REPO_ROOT}"

echo "2) Поднимаем docker-compose (compose.yaml)..."
docker compose -f compose.yaml up -d --build

echo "3) Проверяем доступность приложения на http://localhost:5000"
MAX_TRIES=30
TRY=0
URL="http://localhost:5000/"

until curl -fsS "${URL}" >/dev/null 2>&1; do
  TRY=$((TRY+1))
  if [ "${TRY}" -ge "${MAX_TRIES}" ]; then
    echo "Ошибка: приложение не ответило после ${MAX_TRIES} попыток."
    docker compose -f compose.yaml ps
    exit 1
  fi
  echo "Ожидание... (${TRY}/${MAX_TRIES})"
  sleep 1
done

echo "✅ Приложение доступно на ${URL}"
echo "Чтобы посмотреть логи: docker compose -f compose.yaml logs -f app"
echo "Чтобы остановить: docker compose -f compose.yaml down"
