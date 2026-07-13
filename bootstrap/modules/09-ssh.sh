#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/lib/logging.sh"
source "$ROOT_DIR/lib/common.sh"

require_root

SSH_CONFIG="/etc/ssh/sshd_config"
SSH_PORT="${SSH_PORT:-22822}"
ADMIN_USER="${ADMIN_USER:-operator}"

log_info "Configuring SSH..."

backup_file "$SSH_CONFIG"

sed -i -E "s/^[#[:space:]]*Port .*/Port ${SSH_PORT}/" "$SSH_CONFIG"

grep -qE '^Port ' "$SSH_CONFIG" || printf '\nPort %s\n' "$SSH_PORT" >> "$SSH_CONFIG"

sed -i -E 's/^[#[:space:]]*PermitRootLogin .*/PermitRootLogin no/' "$SSH_CONFIG"
grep -qE '^PermitRootLogin ' "$SSH_CONFIG" || printf 'PermitRootLogin no\n' >> "$SSH_CONFIG"

sed -i -E 's/^[#[:space:]]*PubkeyAuthentication .*/PubkeyAuthentication yes/' "$SSH_CONFIG"
grep -qE '^PubkeyAuthentication ' "$SSH_CONFIG" || printf 'PubkeyAuthentication yes\n' >> "$SSH_CONFIG"

sed -i -E 's/^[#[:space:]]*PasswordAuthentication .*/PasswordAuthentication yes/' "$SSH_CONFIG"
grep -qE '^PasswordAuthentication ' "$SSH_CONFIG" || printf 'PasswordAuthentication yes\n' >> "$SSH_CONFIG"

grep -qE '^AllowUsers ' "$SSH_CONFIG" || printf 'AllowUsers %s\n' "$ADMIN_USER"

sshd -t || die "SSH configuration validation failed."

systemctl restart ssh

ss -ltn | grep -q ":${SSH_PORT} " || die "SSH is not listening on port ${SSH_PORT}."

log_ok "SSH configured on port ${SSH_PORT}."
