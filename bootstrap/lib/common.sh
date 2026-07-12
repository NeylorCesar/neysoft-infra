#!/usr/bin/env bash

set -Eeuo pipefail

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "[ERROR] This module must run as root." >&2
        exit 1
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

service_is_active() {
    systemctl is-active --quiet "$1"
}

service_is_enabled() {
    systemctl is-enabled --quiet "$1"
}

backup_file() {
    local file="$1"

    if [[ -f "$file" ]]; then
        local timestamp
        timestamp="$(date +%Y%m%d-%H%M%S)"
        cp -a "$file" "${file}.${timestamp}.bak"
    fi
}
