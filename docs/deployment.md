# Deployment

> Document Version: 1.0
> Project: Neysoft Infrastructure
> Status: Active

---

# Overview

This document defines the official deployment workflow adopted by Neysoft Infrastructure.

The objective is to provide a standardized, reproducible and secure deployment process for every hosted application.

Every application should follow the same deployment lifecycle.

---

# Deployment Principles

The deployment strategy follows these principles:

- Automation First
- Reproducible Deployments
- Zero Manual Configuration
- Independent Applications
- Version Controlled
- Rollback Friendly
- Minimal Downtime

---

# Deployment Lifecycle

Every deployment follows the same lifecycle.

```text
Developer
      │
      ▼
Git Repository
      │
      ▼
Clone / Pull
      │
      ▼
Configuration
      │
      ▼
Docker Build
      │
      ▼
Docker Compose
      │
      ▼
Health Check
      │
      ▼
Nginx
      │
      ▼
Production
```

Each step must be validated before continuing.

---

# Repository

Each application owns its own repository.

Example:

```text
GoTracker

BRSync

Ticket System
```

Infrastructure is maintained separately inside:

```text
/opt/neysoft/infra
```

Applications should never modify infrastructure directly.

---

# Directory Layout

Applications are deployed under:

```text
/opt/neysoft/apps
```

Example:

```text
apps/

├── gotracker
├── brsync
├── ticket
└── internal-api
```

Each application remains isolated.

---

# Configuration

Configuration should remain external to source code.

Typical files:

```text
.env

docker-compose.yml
```

Sensitive information must never be committed to Git.

---

# Build Process

Applications should be built using Docker.

Typical workflow:

```text
Source

↓

Docker Build

↓

Docker Image

↓

Container
```

Running containers should never be modified manually.

---

# Docker Compose

Each application owns its own deployment definition.

Example:

```text
docker-compose.yml
```

Compose should define:

- Services
- Networks
- Volumes
- Environment Variables
- Restart Policies

---

# Reverse Proxy

Applications are deployed internally.

Nginx exposes them publicly.

Example:

```text
Internet

↓

Nginx

↓

Application
```

Applications should never expose ports 80 or 443.

---

# SSL

HTTPS is mandatory.

Certificates are managed automatically through:

- Let's Encrypt

SSL termination occurs at the Nginx layer.

---

# Deployment Validation

Every deployment should verify:

- Containers running
- Health checks
- Reverse Proxy
- HTTPS
- Application logs

Deployment is considered successful only after validation.

---

# Health Checks

Applications should expose a health endpoint.

Examples:

```text
/health

/status

/ping
```

Health checks simplify monitoring and automated deployments.

---

# Rollback

Every deployment should be reversible.

Rollback strategy may include:

- Previous Docker Image
- Previous Docker Compose
- Previous Configuration
- Database Backup

Rollback procedures should be documented.

---

# Logging

Deployment should generate logs.

Examples:

- Build Log
- Deployment Log
- Container Log
- Reverse Proxy Log

Logs simplify troubleshooting.

---

# Zero Downtime

Whenever technically possible, deployments should minimize downtime.

Future improvements may include:

- Blue/Green Deployment
- Rolling Updates
- Health-based Switching

---

# Deployment Checklist

Before deployment:

- Repository updated
- Configuration validated
- Environment variables configured
- Docker images built
- Docker Compose validated

After deployment:

- Containers healthy
- Reverse Proxy active
- HTTPS operational
- Logs verified
- Monitoring updated

---

# Future Automation

Deployment should progressively evolve toward full automation.

Future roadmap includes:

- Bootstrap
- Deployment Scripts
- Ansible
- GitHub Actions
- CI/CD Pipelines

Manual deployment should become the exception.

---

# Deployment Philosophy

Deployments should be:

- Predictable
- Repeatable
- Automated
- Observable
- Recoverable

A deployment should never depend on undocumented manual steps.

---

# Related Documents

- architecture.md
- docker.md
- nginx.md
- bootstrap.md
- monitoring.md
