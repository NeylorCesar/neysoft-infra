# Neysoft Infrastructure

> Secure • Reproducible • Automated

## Overview

The **Neysoft Infrastructure** project defines the standards, architecture, automation, documentation and operational procedures used across all Neysoft servers.

Its purpose is to provide a reproducible, secure and maintainable infrastructure that can be deployed consistently across development, staging and production environments.

This repository is the foundation for every server running Neysoft products.

---

## Objectives

- Standardize server provisioning.
- Infrastructure as Code (IaC).
- Security by default.
- Automation first.
- Documentation first.
- Reproducible deployments.
- Long-term maintainability.

---

## Infrastructure Stack

- Debian Linux
- Docker Engine
- Docker Compose
- Nginx Reverse Proxy
- Bun Runtime
- Node.js (when required)
- Let's Encrypt
- UFW Firewall
- Fail2Ban

---

## Repository Structure

```
infra/
├── ansible/
├── bootstrap/
├── docker/
├── docs/
├── nginx/
├── scripts/
├── templates/
└── tools/
```

---

## Project Philosophy

This repository does **not** contain production applications.

It defines how infrastructure is provisioned, configured and maintained.

Applications remain isolated inside their own repositories.

---

## Documentation

Additional documentation is available under:

```
docs/
```

---

## License

MIT License
