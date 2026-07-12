# Nginx

> Document Version: 1.0
> Project: Neysoft Infrastructure
> Status: Active

---

# Overview

Nginx is the official Reverse Proxy adopted by Neysoft Infrastructure.

It is responsible for managing all inbound HTTP and HTTPS traffic, acting as the single public entry point for every hosted application.

No application should expose public HTTP or HTTPS ports directly.

---

# Design Principles

The Nginx architecture follows these principles:

- Single Public Entry Point
- Centralized SSL Management
- Reverse Proxy First
- Secure by Default
- Configuration Reusability
- Separation of Concerns

---

# Responsibilities

Nginx is responsible for:

- HTTP
- HTTPS
- Reverse Proxy
- SSL Termination
- Virtual Hosts
- HTTP Redirection
- Header Management
- Compression
- Static Content Delivery
- Security Headers

Application logic is never executed by Nginx.

---

# Infrastructure Role

Network flow:

```text
Internet
     │
     ▼
Cloudflare
     │
     ▼
Firewall
     │
     ▼
Nginx
     │
     ▼
Docker Network
     │
     ▼
Applications
```

Every public request passes through Nginx.

---

# Directory Structure

Infrastructure configuration:

```text
/opt/neysoft/nginx
```

Structure:

```text
nginx/
├── examples/
├── sites-available/
├── sites-enabled/
├── snippets/
├── ssl/
└── templates/
```

---

## sites-available/

Contains every available Virtual Host.

Example:

```text
gotracker.conf
brsync.conf
ticket.conf
```

---

## sites-enabled/

Contains symbolic links to enabled sites.

Only configurations inside this directory become active.

---

## snippets/

Reusable configuration fragments.

Examples:

- security headers
- gzip
- proxy settings
- cache rules

Snippets avoid duplicated configuration.

---

## ssl/

SSL-related resources.

Examples:

- DH Parameters
- Certificate templates
- SSL snippets

Certificates themselves are managed by Let's Encrypt.

---

## templates/

Reusable Virtual Host templates.

Templates are intended for automation.

Future Bootstrap and Ansible modules will generate Virtual Hosts from these templates.

---

# Reverse Proxy Strategy

Every application runs internally.

Example:

```text
Internet

↓

Nginx

↓

127.0.0.1:8080

↓

Application
```

Applications should never expose ports 80 or 443.

---

# SSL Strategy

HTTPS is mandatory.

Certificates are managed using:

- Let's Encrypt

Responsibilities:

- Certificate issuance
- Renewal
- Validation

SSL termination occurs at the Nginx layer.

Applications remain HTTP internally unless specific requirements dictate otherwise.

---

# Virtual Hosts

Each application owns a dedicated Virtual Host.

Example:

```text
gotracker.example.com

↓

gotracker.conf
```

Virtual Hosts should remain independent.

---

# Proxy Configuration

Every Virtual Host should:

- Preserve Host header
- Forward client IP
- Forward protocol information
- Support WebSockets when required

Proxy configuration should use reusable snippets whenever possible.

---

# Compression

Compression is enabled centrally.

Supported formats may include:

- gzip
- brotli (future)

Compression improves bandwidth utilization.

---

# Static Assets

Whenever appropriate, Nginx should serve:

- Images
- CSS
- JavaScript
- Fonts
- Downloads

Applications should focus on business logic.

---

# Logging

Nginx logs should remain centralized.

Typical logs:

- Access Log
- Error Log

Future integrations:

- Loki
- Grafana
- ELK

---

# Security

Nginx should implement:

- HTTPS
- HSTS
- Security Headers
- Rate Limiting (future)
- Request Size Limits
- TLS Best Practices

Security should be centralized.

---

# Performance

Nginx should be configured for:

- HTTP Keep-Alive
- Compression
- Efficient Proxy Buffers
- Connection Reuse

Performance tuning should remain centralized.

---

# Future Evolution

Potential future features:

- HTTP/3
- QUIC
- Load Balancing
- Reverse Proxy Clusters
- Web Application Firewall
- Automatic Virtual Host Generation

Current architecture should remain compatible.

---

# Nginx Philosophy

Nginx should remain:

- Simple
- Predictable
- Reusable
- Secure

Application deployment should never require modifications outside its own Virtual Host.

---

# Related Documents

- architecture.md
- networking.md
- security.md
- docker.md
- deployment.md
