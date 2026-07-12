# Security

> Document Version: 1.0
> Project: Neysoft Infrastructure
> Status: Active

---

# Overview

Security is a fundamental principle of Neysoft Infrastructure.

Every server should be deployed with a secure-by-default approach, minimizing the attack surface while maintaining operational simplicity.

Security is not considered an optional feature.

It is part of the architecture.

---

# Security Principles

The infrastructure follows these principles:

- Security by Design
- Least Privilege
- Defense in Depth
- Zero Trust Mindset
- Secure Defaults
- Continuous Updates
- Automation
- Auditability

Security should never depend on manual procedures.

---

# Operating System

The operating system is the foundation of the infrastructure.

Current standard:

- Debian Stable

Recommendations:

- Keep packages updated.
- Remove unused software.
- Disable unnecessary services.
- Use official repositories whenever possible.

---

# User Management

Infrastructure administration should never rely on the root account.

Recommended users:

- root
- operator

Guidelines:

- Root should only be used when necessary.
- Daily administration should be performed using the operator account.
- Administrative privileges should be granted through sudo.

---

# SSH

SSH is the primary administration interface.

Recommended configuration:

- Non-default SSH port
- Public key authentication
- Disable password authentication whenever possible
- Disable root login
- Strong ciphers only
- Idle timeout

Example:

```text
Port 22822

PermitRootLogin no

PasswordAuthentication no

PubkeyAuthentication yes
```

---

# Firewall

The infrastructure adopts a default deny policy.

Allowed inbound ports:

| Port | Service |
|------:|---------|
| 22822 | SSH |
| 80 | HTTP |
| 443 | HTTPS |

All other inbound traffic should remain blocked.

Firewall management:

- UFW

---

# Fail2Ban

Fail2Ban protects exposed services against brute-force attacks.

Protected services:

- SSH

Future services may include:

- Nginx
- Application authentication
- APIs

---

# TLS / HTTPS

Every public service must use HTTPS.

Certificates are managed using:

- Let's Encrypt

TLS termination occurs exclusively at the Nginx layer.

Applications should not manage certificates individually.

---

# Docker Security

Containers should:

- Run with minimal privileges.
- Avoid privileged mode.
- Avoid unnecessary capabilities.
- Avoid mounting sensitive host directories.
- Use dedicated networks.
- Store persistent data in volumes.

Containers should remain isolated.

---

# Secrets Management

Sensitive information must never be committed to Git.

Examples:

- Passwords
- Tokens
- API Keys
- Private Keys
- Certificates

Secrets should be stored outside source code.

---

# Permissions

Recommended defaults:

Directories

```text
775
```

Files

```text
664
```

Sensitive files should have stricter permissions.

Examples:

```text
600
640
```

---

# Logging

Security events should be logged whenever possible.

Examples:

- SSH authentication
- Failed logins
- Firewall events
- Application errors

Logs should be preserved according to operational requirements.

---

# Backups

Backups are part of the security strategy.

Backups should include:

- Infrastructure configuration
- Databases
- Persistent data
- Docker Compose files

Backups should be tested regularly.

---

# Updates

Security updates should be applied regularly.

Recommended approach:

- Scheduled maintenance
- Validation before deployment
- Rollback plan

Infrastructure should remain up to date.

---

# Monitoring

Infrastructure should be monitored continuously.

Future integrations may include:

- Prometheus
- Grafana
- Loki
- Alertmanager

Monitoring should include security metrics whenever possible.

---

# Incident Response

Every security incident should follow a documented response process.

Recommended phases:

1. Detection
2. Containment
3. Investigation
4. Recovery
5. Documentation
6. Lessons Learned

---

# Security Checklist

Before a server enters production:

- Operating System updated
- Firewall configured
- SSH hardened
- Fail2Ban enabled
- HTTPS configured
- Docker secured
- Backups configured
- Monitoring enabled
- Documentation updated

---

# Security Philosophy

Security is not a product.

Security is a continuous process.

Every server should become more secure over time.

---

# Related Documents

- architecture.md
- networking.md
- docker.md
- nginx.md
- deployment.md
- bootstrap.md
