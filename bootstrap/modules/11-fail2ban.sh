#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/lib/logging.sh"
source "$ROOT_DIR/lib/common.sh"

require_root

SSH_PORT="${SSH_PORT:-22822}"
JAIL_FILE="/etc/fail2ban/jail.d/neysoft.conf"
LEGACY_JAIL_FILE="/etc/fail2ban/jail.d/sshd.local"
MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-15}"

log_info "Configuring Fail2Ban..."

if ! command_exists fail2ban-client; then
    apt-get update
    apt-get install -y fail2ban
fi

cat > "$JAIL_FILE" <<JAIL
[DEFAULT]
backend = systemd
maxretry = 5
findtime = 10m
bantime = 24h

[sshd]
enabled = true
port = ${SSH_PORT}
mode = normal
JAIL

# Remove configuration created by an earlier module version.
if [[ -f "$LEGACY_JAIL_FILE" ]]; then
    rm -f "$LEGACY_JAIL_FILE"
fi

systemctl enable fail2ban
systemctl restart fail2ban

log_info "Waiting for Fail2Ban daemon..."

for ((attempt = 1; attempt <= MAX_WAIT_SECONDS; attempt++)); do
    if fail2ban-client ping >/dev/null 2>&1; then
        break
    fi

    sleep 1
done

fail2ban-client ping >/dev/null 2>&1 \
    || die "Fail2Ban daemon is not responding."

systemctl is-active --quiet fail2ban \
    || die "Fail2Ban service is not active."

fail2ban-client status | grep -qw sshd \
    || die "Fail2Ban sshd jail is not active."

# Validate the configured SSH port from Fail2Ban's generated configuration.
fail2ban-client -d 2>/dev/null \
    | grep -Fq "'port', '${SSH_PORT}'" \
    || die "Fail2Ban sshd jail is not configured for port ${SSH_PORT}."

log_ok "Fail2Ban configured for SSH port ${SSH_PORT}."
