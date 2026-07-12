# Networking

> Document Version: 1.0
> Project: Neysoft Infrastructure
> Status: Active

---

# Overview

This document defines the networking architecture adopted by Neysoft Infrastructure.

Its objective is to provide a secure, scalable and predictable networking model for every server managed by the project.

The networking layer is designed to isolate applications while exposing only the services that should be publicly accessible.

---

# Design Principles

The networking architecture follows these principles:

- Security by Default
- Least Privilege
- Network Isolation
- Single Public Entry Point
- Predictable Routing
- Centralized SSL Management

---

# High-Level Network Architecture

```text
                Internet
                    │
                    ▼
             Cloudflare DNS
                    │
                    ▼
        Router / Firewall (Optional)
                    │
                    ▼
            Linux Firewall (UFW)
                    │
                    ▼
           Nginx Reverse Proxy
                    │
                    ▼
          Docker Internal Network
          ┌─────────┼─────────┐
          ▼         ▼         ▼
   Application  Application  Service
```

---

# Public Access

Only the following services should be publicly accessible:

| Service | Port |
|---------|-----:|
| HTTP | 80 |
| HTTPS | 443 |
| SSH | 22822 |

No other application should expose public ports.

---

# Reverse Proxy

Nginx is the only component allowed to receive HTTP and HTTPS requests from the Internet.

Responsibilities include:

- SSL termination
- Virtual Hosts
- HTTP Routing
- HTTPS Routing
- Reverse Proxy
- Compression
- Header Management

Applications should only communicate with Nginx.

---

# Docker Networking

Applications communicate through Docker Networks.

Example:

```text
   Internet
      │
      ▼
    Nginx
      │
      ▼
docker network
      │
 ┌────┴────┐
 ▼         ▼
App A    App B
```

Each application may have:

- Private network
- Shared network (when necessary)

Applications should never communicate through public interfaces.

---

# Network Isolation

Isolation is a core security requirement.

Each application should be isolated from unrelated services.

Whenever possible:

- Separate Docker networks.
- Separate databases.
- Separate environment variables.

---

# Internal Communication

Applications communicate internally through:

- Docker DNS
- Docker Networks
- Reverse Proxy (when appropriate)

Hardcoded IP addresses should be avoided.

Container names or service names should be preferred.

---

# DNS Strategy

External DNS is managed through Cloudflare.

Responsibilities include:

- Domain resolution
- DNS management
- Proxy (optional)
- TLS support
- DDoS protection

Internal service discovery is handled by Docker.

---

# Firewall Policy

The infrastructure follows a deny-by-default policy.

Allowed inbound ports:

| Port | Service |
|------:|---------|
| 22822 | SSH |
| 80 | HTTP |
| 443 | HTTPS |

All other inbound traffic should be denied unless explicitly required.

---

# IPv4 and IPv6

Both IPv4 and IPv6 should be supported whenever possible.

Firewall rules should always consider both protocols.

---

# SSL Strategy

HTTPS is mandatory for every public application.

Certificates are managed through Let's Encrypt.

SSL termination occurs at the Nginx layer.

Applications should not manage certificates individually.

---

# Load Balancing

Current architecture assumes a single server.

Future versions may introduce:

- Multiple application servers
- Dedicated reverse proxy
- High Availability
- Horizontal scaling

The networking model should remain compatible with these future improvements.

---

# Future Evolution

Potential future additions include:

- WireGuard
- Tailscale
- VLAN segmentation
- Kubernetes networking
- Overlay networks
- Service Mesh

These features should integrate without changing the core networking philosophy.

---

# Networking Philosophy

Networking should be:

- Simple
- Predictable
- Secure
- Centralized
- Easy to troubleshoot

Infrastructure should expose as little as possible.

Internal communication should remain private.

---

# Related Documents

- architecture.md
- server-layout.md
- security.md
- docker.md
- nginx.md
