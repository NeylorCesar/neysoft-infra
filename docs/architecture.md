# Infrastructure Architecture

> Document Version: 1.0  
> Project: Neysoft Infrastructure  
> Status: Active

---

# Overview

The Neysoft Infrastructure architecture defines the standards, principles and components used to provision, secure, deploy and maintain every server hosting Neysoft products.

The infrastructure is designed to be reproducible, secure, scalable and easy to maintain throughout its entire lifecycle.

Every architectural decision should reinforce these principles.

---

# Core Principles

The infrastructure is built upon the following principles:

- Simplicity
- Security by Default
- Reproducibility
- Automation First
- Scalability
- Maintainability
- Infrastructure as Code (IaC)
- Documentation First

These principles guide every technical decision within this project.

---

# High-Level Architecture

The infrastructure follows a layered architecture where each layer has a single responsibility.

```text
                 Internet
                     │
                     ▼
              Cloudflare DNS
                     │
                     ▼
          Firewall (UFW / Router)
                     │
                     ▼
            Nginx Reverse Proxy
                     │
                     ▼
               Docker Network
        ┌────────────┼────────────┐
        ▼            ▼            ▼
     GoTracker    BRSync     Ticket API
        ▼            ▼            ▼
     Bun/PHP        Bun        Bun/PHP
        ▼            ▼            ▼
     MariaDB     PostgreSQL     Redis
```

This separation reduces complexity while improving maintainability and operational consistency.

---

# Infrastructure Layers

## Layer 1 — Operating System

The operating system provides the foundation for the entire infrastructure.

Responsibilities:

- Hardware abstraction
- Filesystem management
- Process management
- Network management
- Package management
- Security updates

Current Standard:

- Debian Stable

---

## Layer 2 — Security

Responsible for protecting the operating system and hosted services.

Components:

- SSH
- UFW Firewall
- Fail2Ban
- Let's Encrypt
- Linux Permissions
- Security Updates

Security is established before any application deployment.

---

## Layer 3 — Runtime

Responsible for application execution.

Components:

- Docker Engine
- Docker Compose
- Bun Runtime
- Node.js (when required)

Applications should execute inside containers whenever possible.

---

## Layer 4 — Reverse Proxy

Responsible for handling all inbound HTTP and HTTPS traffic.

Component:

- Nginx

Responsibilities:

- SSL Termination
- Reverse Proxy
- HTTP Routing
- HTTPS Routing
- Compression
- Static Content Delivery
- Header Management

Only Nginx should expose ports **80** and **443** to the Internet.

Applications should never expose public ports directly.

---

## Layer 5 — Applications

Business applications and services.

Examples:

- GoTracker
- BRSync
- Ticket System
- Internal Services
- Web Applications

Each application:

- Owns its own repository.
- Owns its own Docker Compose configuration.
- Is isolated from other applications.
- Can be deployed independently.

---

## Layer 6 — Data

Responsible for persistent storage.

Examples:

- Databases
- Uploaded Files
- Docker Volumes
- Application Logs
- Backups

Application code must always remain separated from persistent data.

---

# Reverse Proxy Model

The infrastructure adopts a centralized Reverse Proxy architecture.

```text
Internet
    │
    ▼
Cloudflare
    │
    ▼
Nginx (Host)
    │
    ▼
Docker Network
    │
    ▼
Applications
```

Benefits:

- Single public entry point
- Centralized SSL management
- Simplified firewall rules
- Easier monitoring
- Easier maintenance
- Better scalability

---

# Docker Strategy

Applications are containerized by default.

Each application may contain:

- Backend
- Frontend
- Database (when required)
- Cache (when required)
- Workers (when required)

Containers communicate through isolated Docker Networks.

Persistent data should always reside outside the application container.

---

# Deployment Strategy

Applications are deployed independently.

Infrastructure updates should not require application changes.

Application deployments should not impact the infrastructure layer.

This separation improves reliability, reduces downtime and simplifies maintenance.

---

# Design Goals

The infrastructure is designed to achieve the following objectives:

- High Availability
- Predictable Deployments
- Infrastructure as Code
- Security by Default
- Easy Disaster Recovery
- Operational Simplicity
- Reproducible Environments
- Long-Term Maintainability

---

# Scalability

The architecture is designed to scale horizontally.

Future capabilities may include:

- Multiple Servers
- Load Balancing
- Monitoring
- Centralized Logging
- CI/CD Pipelines
- High Availability
- Cluster Management

The architectural principles should remain unchanged regardless of infrastructure growth.

---

# Infrastructure Philosophy

Infrastructure should be treated as software.

Every configuration should be:

- Versioned
- Documented
- Reproducible
- Testable
- Automated whenever possible

Manual configuration should be minimized.

Automation should replace repetitive operational tasks.

---

# Future Evolution

The long-term roadmap includes:

- Bootstrap Automation
- Ansible
- Infrastructure as Code
- Monitoring
- Automated Backups
- Disaster Recovery
- Continuous Deployment

---

# Related Documents

- server-layout.md
- networking.md
- security.md
- docker.md
- nginx.md
- deployment.md

---

> Infrastructure should be predictable.
>
> Infrastructure should be reproducible.
>
> Infrastructure should be treated as code.
