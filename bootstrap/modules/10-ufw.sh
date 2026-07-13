#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/lib/logging.sh"
source "$ROOT_DIR/lib/common.sh"

require_root

SSH_PORT="${SSH_PORT:-22822}"

log_info "Configuring UFW..."

if ! command_exists ufw; then
    apt-get update
    apt-get install -y ufw
fi

ufw default deny incoming
ufw default allow outgoing

ufw allow "${SSH_PORT}/tcp" comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'

ufw --force enable

ufw status | grep -q "${SSH_PORT}/tcp" || die "SSH firewall rule was not applied."
ufw status | grep -q "80/tcp" || die "HTTP firewall rule was not applied."
ufw status | grep -q "443/tcp" || die "HTTPS firewall rule was not applied."

log_ok "UFW configured successfully."
