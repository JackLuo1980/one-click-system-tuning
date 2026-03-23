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

mkdir -p /home/docker/cloudreve/{uploads,avatar}

docker rm -f cloudreve >/dev/null 2>&1 || true
docker pull cloudreve/cloudreve:latest
docker run -d \
  --name cloudreve \
  --restart=always \
  -p 5212:5212 \
  -v /home/docker/cloudreve/uploads:/cloudreve/uploads \
  -v /home/docker/cloudreve/avatar:/cloudreve/avatar \
  -v /home/docker/cloudreve/cloudreve.db:/cloudreve/cloudreve.db \
  cloudreve/cloudreve:latest
