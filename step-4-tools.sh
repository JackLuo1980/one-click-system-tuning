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

DEBIAN_FRONTEND=noninteractive apt-get install -y \
  curl \
  ca-certificates \
  cron \
  acme \
  wget \
  sudo \
  socat \
  htop \
  iftop \
  unzip \
  tar \
  tmux \
  btop \
  ncdu \
  fzf \
  vim \
  nano \
  git \
  gnupg \
  lsb-release

install_docker_ce() {
  local os_id="${ID:-}"
  local os_version="${VERSION_CODENAME:-}"

  if [[ -z "$os_id" || -z "$os_version" ]]; then
    . /etc/os-release
    os_id="${ID:-}"
    os_version="${VERSION_CODENAME:-}"
  fi

  if [[ -z "$os_id" || -z "$os_version" ]]; then
    echo "Unable to detect distribution for Docker CE repository setup."
    exit 1
  fi

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/${os_id}/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  cat >/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${os_id} ${os_version} stable
EOF

  DEBIAN_FRONTEND=noninteractive apt-get update -y
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
}

install_docker_ce

if command -v systemctl >/dev/null 2>&1; then
  systemctl enable --now docker >/dev/null 2>&1 || true
else
  service docker start >/dev/null 2>&1 || true
fi
