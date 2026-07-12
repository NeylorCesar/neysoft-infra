# Docker

> Document Version: 1.0
> Project: Neysoft Infrastructure
> Status: Active

---

# Overview

Docker is the standard application runtime adopted by Neysoft Infrastructure.

All business applications should be containerized whenever technically feasible.

Containerization provides:

- Isolation
- Reproducibility
- Portability
- Simplified deployment
- Easier maintenance
- Better scalability

Docker is considered the default execution environment for every hosted application.

---

# Design Principles

The Docker architecture follows these principles:

- Container First
- One Responsibility per Container
- Immutable Infrastructure
- Infrastructure as Code
- Reproducible Deployments
- Network Isolation
- Persistent Data Separation

---

# Runtime Components

Current standard components:

- Docker Engine
- Docker Compose
- Docker Networks
- Docker Volumes
- BuildKit
- Docker Buildx

---

# Directory Structure

Docker-related resources are stored under:

```text
/opt/neysoft/docker
```

Structure:

```text
docker/
├── compose/
├── images/
├── networks/
└── volumes/
```

---

## compose/

Contains Docker Compose files.

Example:

```text
compose/
├── gotracker.yml
├── brsync.yml
└── monitoring.yml
```

---

## images/

Contains Dockerfiles and image-related resources.

Example:

```text
images/
├── php/
├── bun/
├── nginx/
└── python/
```

---

## networks/

Contains network documentation and templates.

Example:

```text
networks/
├── public.md
├── internal.md
└── proxy.md
```

---

## volumes/

Persistent Docker volumes.

Application data should remain outside containers.

---

# Application Structure

Every application should follow a predictable layout.

Example:

```text
application/

├── backend/
├── frontend/
├── docker-compose.yml
├── .env
├── README.md
└── LICENSE
```

Each application owns its own Docker Compose configuration.

---

# Container Responsibilities

Containers should have a single responsibility.

Examples:

Application

↓

Database

↓

Cache

↓

Worker

↓

Reverse Proxy

Avoid combining multiple unrelated services inside a single container.

---

# Docker Compose

Docker Compose is the standard deployment mechanism.

Each application should own its own:

```text
docker-compose.yml
```

Compose files should:

- Be readable
- Be versioned
- Be reproducible
- Use named volumes
- Use dedicated networks

---

# Docker Networks

Networking should be isolated.

Typical layout:

```text
Internet

↓

Nginx

↓

Proxy Network

↓

Application Network

↓

Database
```

Applications should not communicate through public interfaces.

---

# Volumes

Persistent data must be stored using Docker Volumes.

Examples:

- Databases
- Uploaded files
- Cache
- Logs

Containers should remain disposable.

---

# Images

Images should:

- Be lightweight
- Use official base images whenever possible
- Pin versions
- Avoid unnecessary packages
- Minimize attack surface

Latest tags should be avoided.

---

# Environment Variables

Configuration should be externalized.

Examples:

```text
.env
```

Never hardcode:

- Passwords
- API Keys
- Secrets
- Tokens

---

# Logging

Containers should log to stdout/stderr whenever possible.

Infrastructure is responsible for log aggregation.

Future integrations may include:

- Loki
- Grafana
- ELK

---

# Health Checks

Applications should expose health checks.

Example:

```text
/health

/status

/ping
```

Health checks improve deployment reliability.

---

# Updates

Containers should be rebuilt instead of modified.

Recommended workflow:

```text
Source Code

↓

Build

↓

Docker Image

↓

Deploy

↓

Replace Container
```

Avoid changing running containers manually.

---

# Security

Containers should:

- Avoid privileged mode
- Use non-root users whenever possible
- Avoid unnecessary capabilities
- Limit mounted directories
- Use isolated networks

Security should be considered during image creation.

---

# Backup Strategy

Backups should include:

- Docker Compose files
- Environment files
- Named volumes
- Databases

Container images do not replace backups.

---

# Future Evolution

Future improvements may include:

- Docker Swarm
- Kubernetes
- Image Registry
- Automatic Image Scanning
- Container Signing
- SBOM Generation

Current architecture should remain compatible with these technologies.

---

# Docker Philosophy

Containers should be:

- Small
- Predictable
- Disposable
- Reproducible

Applications should be easy to rebuild.

Servers should never depend on manually modified containers.

---

# Related Documents

- architecture.md
- networking.md
- security.md
- nginx.md
- deployment.md
- bootstrap.md
