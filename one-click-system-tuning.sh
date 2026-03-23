#!/usr/bin/env bash

set -euo pipefail

DEFAULT_TIMEZONE="Asia/Shanghai"

usage() {
  cat <<'EOF'
Usage:
  sudo bash one-click-system-tuning.sh [--yes] [--timezone Asia/Shanghai|Asia/Hong_Kong]

Options:
  --yes         Skip the confirmation prompt.
  --timezone    Set timezone to Asia/Shanghai or Asia/Hong_Kong.
  -h, --help    Show this help text
EOF
}

log() {
  printf '[%s] %s\n' "$(date +'%F %T')" "$*"
}

step_banner() {
  printf '\n================================================\n'
  printf '%s\n' "$1"
  printf '================================================\n'
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Please run this script as root."
    exit 1
  fi
}

normalize_timezone() {
  case "${1:-}" in
    ""|sh|shanghai|Asia/Shanghai)
      echo "Asia/Shanghai"
      ;;
    hk|hongkong|hong_kong|Asia/Hong_Kong)
      echo "Asia/Hong_Kong"
      ;;
    *)
      echo "$1"
      ;;
  esac
}

script_dir() {
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}

confirm() {
  cat <<EOF
------------------------------------------------
This will run the following local scripts in order:
1. step-1-bootstrap.sh
2. step-4-tools.sh
3. step-5-bbr.sh
4. step-13-apps.sh
5. step-timezone.sh (${DEFAULT_TIMEZONE} or Asia/Hong_Kong)
------------------------------------------------
EOF

  if [[ "${ASSUME_YES:-false}" == "true" ]]; then
    return 0
  fi

  if [[ ! -t 0 ]]; then
    return 0
  fi

  read -r -p "Type yes to continue: " answer
  [[ "${answer}" == "yes" ]]
}

run_step() {
  local step="$1"
  shift
  local step_path
  step_path="$(script_dir)/${step}"

  step_banner "BEGIN ${step}"
  log "Running ${step_path}"
  if bash "${step_path}" "$@"; then
    log "Completed ${step}"
    step_banner "OK ${step}"
  else
    local exit_code=$?
    log "Failed ${step} with exit code ${exit_code}"
    step_banner "FAIL ${step}"
    exit "${exit_code}"
  fi
}

main() {
  local timezone="${DEFAULT_TIMEZONE}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes)
        ASSUME_YES="true"
        shift
        ;;
      --timezone)
        timezone="$(normalize_timezone "${2:?missing timezone value}")"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done

  require_root
  confirm

  step_banner "START LOCAL SERVER TUNING"
  run_step step-1-bootstrap.sh
  run_step step-4-tools.sh
  run_step step-5-bbr.sh
  run_step step-13-apps.sh
  run_step step-timezone.sh "$timezone"
  step_banner "DONE"
  log "All steps finished successfully"
}

main "$@"
