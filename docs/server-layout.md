# Server Layout

> Document Version: 1.0  
> Project: Neysoft Infrastructure  
> Status: Active

---

# Overview

This document defines the official directory structure adopted by Neysoft Infrastructure.

The goal is to provide a predictable, organized and scalable filesystem layout that remains consistent across every server.

Every server provisioned by the Neysoft Infrastructure project should follow this standard.

---

# Root Layout

The infrastructure is organized under:

```text
/opt/neysoft
```

This directory contains every component managed by the infrastructure.

Operating system files remain untouched whenever possible.

---

# Directory Structure

```text
/opt/neysoft
├── apps
├── backups
├── certbot
├── data
├── docker
│   ├── compose
│   ├── images
│   ├── networks
│   └── volumes
├── infra
├── letsencrypt
├── logs
├── monitoring
├── nginx
│   ├── examples
│   ├── sites-available
│   ├── sites-enabled
│   ├── snippets
│   ├── ssl
│   └── templates
├── scripts
├── shared
└── temp
```

---

# Directory Responsibilities

## apps/

Contains all business applications.

Examples:

- GoTracker
- BRSync
- Ticket System
- Internal Services

Each application owns:

- Source code
- Docker Compose
- Environment variables
- Documentation

Applications remain isolated from one another.

---

## backups/

Stores infrastructure and application backups.

Examples:

- Database dumps
- Configuration backups
- Compressed archives

Backups should never be stored inside application directories.

---

## certbot/

Auxiliary files used during certificate management.

---

## data/

Persistent shared data.

Examples:

- Uploaded files
- Shared storage
- Persistent application data

Application source code should never be stored here.

---

## docker/

Docker-related resources.

### compose/

Official Docker Compose files.

### images/

Custom Dockerfiles and image resources.

### networks/

Shared Docker network definitions.

### volumes/

Persistent Docker volumes.

---

## infra/

Infrastructure source repository.

Contains:

- Documentation
- Bootstrap
- Templates
- Ansible
- Scripts

This repository defines the infrastructure.

It is **not** part of production applications.

---

## letsencrypt/

Let's Encrypt certificates and related data.

Managed automatically by Certbot.

---

## logs/

Infrastructure logs.

Examples:

- Deployment logs
- Maintenance logs
- Automation logs

Application logs should remain inside their own logging strategy whenever possible.

---

## monitoring/

Monitoring configuration.

Future integrations may include:

- Prometheus
- Grafana
- Loki
- Alertmanager

---

## nginx/

Reverse Proxy configuration.

### examples/

Configuration examples.

### sites-available/

Available virtual hosts.

### sites-enabled/

Enabled virtual hosts.

### snippets/

Reusable configuration blocks.

### ssl/

SSL-related configuration.

### templates/

Configuration templates.

---

## scripts/

Operational scripts.

Examples:

- Backup
- Restore
- Maintenance
- Cleanup

Scripts should be idempotent whenever possible.

---

## shared/

Shared resources between applications.

Examples:

- Shared libraries
- Assets
- Common configuration

Applications should minimize dependencies on this directory.

---

## temp/

Temporary files.

This directory may be cleaned automatically.

Applications must never rely on its contents.

---

# Ownership

The default ownership is:

```text
operator:neysoft
```

Application-specific requirements may override this when necessary.

---

# Permissions

Recommended defaults:

Directories:

```text
775
```

Files:

```text
664
```

Sensitive files may require stricter permissions.

---

# Design Rules

The following rules must always be respected:

- Applications must remain isolated.
- Persistent data must be separated from application code.
- Infrastructure must remain independent from hosted applications.
- Every component should have a single responsibility.
- Directory names should remain stable over time.

---

# Future Expansion

The directory structure is designed to support future additions without requiring reorganization.

Possible future directories:

```text
cluster/
kubernetes/
terraform/
packer/
vault/
```

---

# Related Documents

- architecture.md
- networking.md
- docker.md
- deployment.md
- bootstrap.md
