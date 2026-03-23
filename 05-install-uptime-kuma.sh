#!/usr/bin/env bash

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root."
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get was not found. This script targets Debian/Ubuntu."
  exit 1
fi

DEBIAN_FRONTEND=noninteractive apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io docker-compose-plugin

if command -v systemctl >/dev/null 2>&1; then
  systemctl enable --now docker >/dev/null 2>&1 || true
else
  service docker start >/dev/null 2>&1 || true
fi

mkdir -p /home/docker/uptime-kuma/uptime-kuma-data

docker rm -f uptime-kuma >/dev/null 2>&1 || true
docker pull louislam/uptime-kuma:latest
docker run -d \
  --name uptime-kuma \
  --restart=always \
  -p 3001:3001 \
  -v /home/docker/uptime-kuma/uptime-kuma-data:/app/data \
  louislam/uptime-kuma:latest
