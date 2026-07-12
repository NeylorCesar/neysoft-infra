# Bootstrap

> Document Version: 1.0  
> Project: Neysoft Infrastructure  
> Status: Active

---

# Overview

The bootstrap system is responsible for transforming a clean Debian installation into a standardized Neysoft Infrastructure server.

Its objective is to provide a secure, reproducible and idempotent provisioning process.

The bootstrap process should minimize manual configuration and ensure that every server follows the same infrastructure standards.

---

# Objectives

The bootstrap system should:

- Validate the operating system.
- Install required packages.
- Configure administrative users.
- Create the official directory structure.
- Install application runtimes.
- Install and configure Docker.
- Install and configure Nginx.
- Configure SSH.
- Configure the firewall.
- Configure Fail2Ban.
- Install Certbot.
- Apply laptop-server settings when required.
- Validate the final server state.

---

# Design Principles

The bootstrap architecture follows these principles:

- Idempotency
- Safety
- Predictability
- Modularity
- Validation First
- Secure Defaults
- Clear Logging
- Fail Fast

The bootstrap should be safe to execute multiple times.

Existing valid configurations should not be unnecessarily replaced.

---

# Bootstrap Architecture

```text
Clean Debian Server
        │
        ▼
Environment Validation
        │
        ▼
Base System Configuration
        │
        ▼
Packages and Runtimes
        │
        ▼
Security Configuration
        │
        ▼
Docker and Nginx
        │
        ▼
Directory Structure
        │
        ▼
Final Validation
        │
        ▼
Production-Ready Server
```

---

# Directory Structure

The bootstrap implementation is stored under:

```text
bootstrap/
├── install.sh
├── validate.sh
├── lib/
│   ├── common.sh
│   ├── logging.sh
│   └── validation.sh
└── modules/
    ├── system.sh
    ├── packages.sh
    ├── users.sh
    ├── directories.sh
    ├── networkmanager.sh
    ├── bun.sh
    ├── node.sh
    ├── docker.sh
    ├── nginx.sh
    ├── ssh.sh
    ├── ufw.sh
    ├── fail2ban.sh
    ├── certbot.sh
    ├── laptop-server.sh
    └── cleanup.sh
```

---

# Main Components

## install.sh

Primary bootstrap entry point.

Responsibilities:

- Load configuration.
- Validate execution requirements.
- Execute modules in the correct order.
- Stop immediately when a critical error occurs.
- Run final validation.

Expected usage:

```bash
sudo ./bootstrap/install.sh
```

Optional module execution:

```bash
sudo ./bootstrap/install.sh --only docker
sudo ./bootstrap/install.sh --only nginx
sudo ./bootstrap/install.sh --only security
```

---

## validate.sh

Validates the current server state without changing the system.

Expected usage:

```bash
sudo ./bootstrap/validate.sh
```

Example output:

```text
[OK] Debian detected
[OK] operator user exists
[OK] neysoft group exists
[OK] Docker is installed
[OK] Nginx is running
[WARN] UFW is not enabled
[ERROR] Fail2Ban is not installed
```

The validator should be usable:

- Before provisioning.
- After provisioning.
- During infrastructure audits.
- During troubleshooting.

---

# Bootstrap Modules

Each module should manage a single responsibility.

## system.sh

Responsibilities:

- Validate Debian version.
- Update package indexes.
- Apply system upgrades.
- Configure timezone and locale when required.

---

## packages.sh

Installs the official base package set.

Examples:

- git
- curl
- wget
- unzip
- zip
- nano
- vim
- tree
- jq
- htop
- btop
- bash-completion
- net-tools
- bind9-dnsutils
- ca-certificates
- gnupg
- lsb-release

---

## users.sh

Responsibilities:

- Validate the `operator` user.
- Validate the `neysoft` group.
- Configure sudo access.
- Apply required group memberships.
- Validate the user home directory.

---

## directories.sh

Creates the official server layout under:

```text
/opt/neysoft
```

Responsibilities:

- Create required directories.
- Apply ownership.
- Apply permissions.
- Preserve existing data.

---

## networkmanager.sh

Responsibilities:

- Install NetworkManager when required.
- Enable NetworkManager.
- Validate managed network interfaces.
- Avoid conflicting legacy network configuration.

Credentials must never be stored in the repository.

---

## bun.sh

Responsibilities:

- Install Bun for the administrative user.
- Configure the user PATH.
- Validate the installed version.

Bun should not be installed as root unless explicitly required.

---

## node.sh

Optional Node.js installation module.

Node.js should only be installed when required by application dependencies or tooling.

---

## docker.sh

Responsibilities:

- Install Docker from the official repository.
- Install Docker Engine.
- Install Docker Compose.
- Install Buildx.
- Enable the Docker service.
- Add the administrative user to the Docker group.
- Validate Docker execution.

---

## nginx.sh

Responsibilities:

- Install Nginx.
- Enable the service.
- Configure infrastructure includes.
- Validate configuration with:

```bash
nginx -t
```

Nginx must not be reloaded when validation fails.

---

## ssh.sh

Responsibilities:

- Create a configuration backup.
- Configure the official SSH port.
- Disable root login.
- Enable public key authentication.
- Validate SSH configuration before restart.

Official SSH port:

```text
22822
```

The module must avoid locking administrators out of the server.

---

## ufw.sh

Responsibilities:

- Install UFW.
- Apply deny-by-default policy.
- Allow the official public ports.
- Validate SSH access before activation.

Official inbound ports:

| Port | Service |
|------:|---------|
| 22822 | SSH |
| 80 | HTTP |
| 443 | HTTPS |

---

## fail2ban.sh

Responsibilities:

- Install Fail2Ban.
- Configure SSH protection.
- Use the official SSH port.
- Enable and validate the service.

---

## certbot.sh

Responsibilities:

- Install Certbot.
- Install the Nginx plugin.
- Validate the renewal timer.
- Prepare certificate management.

Certificate issuance should only occur after DNS and Nginx validation.

---

## laptop-server.sh

Optional module for laptops used as servers.

Responsibilities may include:

- Disable suspend.
- Disable hibernation.
- Ignore lid close events.
- Apply power-management settings.

This module should only run when explicitly enabled.

---

## cleanup.sh

Responsibilities:

- Remove unnecessary packages.
- Clear package caches.
- Remove temporary files.
- Produce a cleanup summary.

Cleanup must never remove application data or persistent volumes.

---

# Execution Order

Recommended execution order:

```text
1. system
2. packages
3. users
4. directories
5. networkmanager
6. bun
7. node
8. docker
9. nginx
10. ssh
11. ufw
12. fail2ban
13. certbot
14. laptop-server
15. cleanup
16. validation
```

Security-sensitive modules should validate their configuration before restarting services.

---

# Idempotency

Every module must be idempotent.

This means that running the same module multiple times should produce the same final state without causing damage.

Examples:

- Do not recreate an existing user.
- Do not duplicate repository entries.
- Do not duplicate configuration lines.
- Do not overwrite valid configuration unnecessarily.
- Do not recreate existing Docker networks.
- Do not reinstall already valid components without reason.

---

# Error Handling

Every script should use:

```bash
#!/usr/bin/env bash

set -Eeuo pipefail
```

Critical failures must stop execution immediately.

Error messages should clearly identify:

- The failing module.
- The failing command.
- The required corrective action.

---

# Logging

Bootstrap output should use standardized prefixes:

```text
[INFO]
[OK]
[WARN]
[ERROR]
```

Example:

```text
[INFO] Installing Docker...
[OK] Docker installed successfully.
[WARN] Docker is already installed.
[ERROR] Nginx configuration validation failed.
```

Bootstrap execution logs may be stored under:

```text
/opt/neysoft/logs
```

---

# Backup Policy

Before changing an existing system configuration, the bootstrap should create a backup.

Examples:

```text
/etc/ssh/sshd_config
/etc/nginx/nginx.conf
/etc/fail2ban/
```

Backup names should include a timestamp.

Example:

```text
sshd_config.20260711-183000.bak
```

---

# Configuration

Environment-specific values should remain external to the code.

Examples:

```text
SSH_PORT
ADMIN_USER
ADMIN_GROUP
BASE_PATH
TIMEZONE
INSTALL_BUN
INSTALL_NODE
ENABLE_LAPTOP_MODE
```

A future configuration file may use:

```text
bootstrap.conf
```

or:

```text
.env
```

Secrets must never be stored in Git.

---

# Validation

Provisioning is complete only after validation.

Final validation should verify:

- Operating system.
- Administrative user.
- Administrative group.
- Sudo access.
- Directory structure.
- Network management.
- Docker Engine.
- Docker Compose.
- Nginx.
- SSH port.
- Firewall.
- Fail2Ban.
- Certbot.
- Required services.
- Public listening ports.

---

# Safety Requirements

The bootstrap must never:

- Delete application data.
- Delete Docker volumes.
- Replace secrets.
- Disable SSH before validating the new configuration.
- Enable the firewall before allowing the active SSH port.
- Reload Nginx with an invalid configuration.
- Commit credentials to Git.
- Expose internal application ports publicly.

---

# Future Evolution

The shell bootstrap represents the first automation layer.

Future evolution includes:

```text
Shell Bootstrap
      │
      ▼
Ansible Roles
      │
      ▼
Multi-Server Provisioning
      │
      ▼
Continuous Infrastructure Management
```

The bootstrap should remain useful for initial provisioning and recovery scenarios.

---

# Bootstrap Philosophy

The bootstrap should be:

- Safe
- Modular
- Idempotent
- Transparent
- Reusable
- Easy to audit

Provisioning should produce a predictable server state.

A server should never depend on undocumented manual configuration.

---

# Related Documents

- architecture.md
- server-layout.md
- conventions.md
- networking.md
- security.md
- docker.md
- nginx.md
- deployment.md
