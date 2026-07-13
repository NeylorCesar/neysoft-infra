#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT_DIR/lib/logging.sh"
source "$ROOT_DIR/lib/common.sh"

require_root

ADMIN_USER="${ADMIN_USER:-operator}"
ADMIN_GROUP="${ADMIN_GROUP:-neysoft}"

NEY_ROOT="${NEY_ROOT:-/opt/neysoft}"
NEY_NGINX="${NEY_NGINX:-${NEY_ROOT}/nginx}"

NGINX_CONFIG="/etc/nginx/nginx.conf"
DEBIAN_DEFAULT_SITE="/etc/nginx/sites-enabled/default"

INCLUDE_CONF='include /opt/neysoft/nginx/conf.d/*.conf;'
INCLUDE_SITES='include /opt/neysoft/nginx/sites-enabled/*.conf;'

log_info "Configuring Nginx..."

###############################################################################
# Package installation
###############################################################################

if ! command_exists nginx; then
    log_info "Installing Nginx..."

    apt-get update
    apt-get install -y nginx
fi

###############################################################################
# Directory structure
###############################################################################

log_info "Creating Neysoft Nginx directory structure..."

install -d \
    -o "$ADMIN_USER" \
    -g "$ADMIN_GROUP" \
    -m 0775 \
    "$NEY_NGINX/conf.d" \
    "$NEY_NGINX/sites-available" \
    "$NEY_NGINX/sites-enabled" \
    "$NEY_NGINX/snippets" \
    "$NEY_NGINX/ssl"

###############################################################################
# Backup
###############################################################################

backup_file "$NGINX_CONFIG"

###############################################################################
# Integrate /opt/neysoft/nginx with the Debian nginx.conf
###############################################################################

if ! grep -Fq "$INCLUDE_CONF" "$NGINX_CONFIG"; then
    log_info "Adding Neysoft conf.d include..."

    sed -i \
        "\|include /etc/nginx/sites-enabled/\*;|a\\
        ${INCLUDE_CONF}" \
        "$NGINX_CONFIG"
fi

if ! grep -Fq "$INCLUDE_SITES" "$NGINX_CONFIG"; then
    log_info "Adding Neysoft sites-enabled include..."

    sed -i \
        "\|${INCLUDE_CONF}|a\\
        ${INCLUDE_SITES}" \
        "$NGINX_CONFIG"
fi

grep -Fq "$INCLUDE_CONF" "$NGINX_CONFIG" \
    || die "Failed to add the Neysoft conf.d include."

grep -Fq "$INCLUDE_SITES" "$NGINX_CONFIG" \
    || die "Failed to add the Neysoft sites-enabled include."

###############################################################################
# Global Neysoft HTTP configuration
###############################################################################

cat > "$NEY_NGINX/conf.d/00-global.conf" <<'NGINX'
###############################################################################
# Neysoft Infrastructure
#
# File: 00-global.conf
# Purpose:
#   Global HTTP settings shared by Neysoft applications.
#
# Keep this file limited to directives not already defined in nginx.conf.
###############################################################################

client_max_body_size 100M;

client_body_timeout 30s;
client_header_timeout 30s;
send_timeout 60s;

log_not_found off;
NGINX

###############################################################################
# Common reverse proxy snippet
###############################################################################

cat > "$NEY_NGINX/snippets/proxy-common.conf" <<'NGINX'
###############################################################################
# Neysoft Infrastructure
#
# Common reverse proxy configuration.
###############################################################################

proxy_http_version 1.1;

proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-Host $host;
proxy_set_header X-Forwarded-Port $server_port;

proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";

proxy_connect_timeout 60s;
proxy_send_timeout 60s;
proxy_read_timeout 60s;
NGINX

###############################################################################
# Default catch-all virtual host
###############################################################################

cat > "$NEY_NGINX/sites-available/00-default.conf" <<'NGINX'
###############################################################################
# Neysoft Infrastructure
#
# Default catch-all server.
# Rejects requests that do not match a configured domain.
###############################################################################

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    access_log off;

    return 444;
}
NGINX

ln -sfn \
    ../sites-available/00-default.conf \
    "$NEY_NGINX/sites-enabled/00-default.conf"

###############################################################################
# Disable Debian default virtual host
###############################################################################

if [[ -e "$DEBIAN_DEFAULT_SITE" || -L "$DEBIAN_DEFAULT_SITE" ]]; then
    log_info "Disabling the Debian default Nginx site..."
    rm -f "$DEBIAN_DEFAULT_SITE"
fi

###############################################################################
# Ownership and permissions
###############################################################################

chown -R "$ADMIN_USER:$ADMIN_GROUP" "$NEY_NGINX"

find "$NEY_NGINX" -type d -exec chmod 0775 {} \;
find "$NEY_NGINX" -type f -exec chmod 0664 {} \;

###############################################################################
# Validation and service activation
###############################################################################

log_info "Validating Nginx configuration..."

nginx -t || die "Nginx configuration validation failed."

systemctl enable nginx >/dev/null
systemctl restart nginx

systemctl is-active --quiet nginx \
    || die "Nginx service is not active."

nginx -T 2>/dev/null \
    | grep -Fq "$NEY_NGINX/conf.d/00-global.conf" \
    || die "Neysoft global Nginx configuration was not loaded."

nginx -T 2>/dev/null \
    | grep -Fq "$NEY_NGINX/sites-enabled/00-default.conf" \
    || die "Neysoft default virtual host was not loaded."

log_ok "Nginx configured successfully."
log_ok "Neysoft configuration path: $NEY_NGINX"
