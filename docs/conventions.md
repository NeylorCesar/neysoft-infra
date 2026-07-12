# Project Conventions

> Document Version: 1.0  
> Project: Neysoft Infrastructure  
> Status: Active

---

# Overview

This document defines the official conventions adopted by the Neysoft Infrastructure project.

The objective is to establish consistency across documentation, source code, infrastructure, automation and operational procedures.

Every repository, server and application should follow these standards whenever applicable.

---

# General Principles

The infrastructure follows these principles:

- Keep it simple.
- Prefer explicit over implicit.
- Automate repetitive tasks.
- Documentation is part of the project.
- Infrastructure should be reproducible.
- Security comes before convenience.
- Every component should have a single responsibility.

---

# Language

The official language of the project is:

- English

English is used to maximize accessibility within the open-source community and maintain consistency across documentation.

---

# Naming Convention

Names should be:

- Short
- Descriptive
- Predictable
- Lowercase whenever possible

Examples:

```text
docker
nginx
bootstrap
scripts
templates
monitoring
```

Avoid:

```text
MyDocker
DockerFiles
Configs
Misc
TempFiles
```

---

# Directory Convention

Directories use:

- lowercase
- hyphen-separated when necessary

Examples:

```text
sites-available
sites-enabled
group-vars
```

---

# File Naming

Documentation:

```text
architecture.md
docker.md
networking.md
```

Shell Scripts:

```text
docker.sh
bootstrap.sh
security.sh
```

Configuration:

```text
docker-compose.yml
nginx.conf
```

---

# Git Branches

Permanent branches:

```text
main
develop
```

Feature branches:

```text
feature/docker
feature/nginx
feature/bootstrap
feature/security
```

Bug fixes:

```text
fix/docker-network
fix/nginx-reload
```

Hotfixes:

```text
hotfix/security-patch
```

---

# Commit Messages

Use short and descriptive commit messages.

Examples:

```text
Add Docker bootstrap module

Improve nginx templates

Update security documentation

Implement UFW provisioning
```

Avoid:

```text
update

fix

changes

test
```

---

# Versioning

The project follows Semantic Versioning.

Pattern:

```text
MAJOR.MINOR.PATCH
```

Example:

```text
1.0.0
1.1.0
1.1.1
2.0.0
```

---

# Documentation Standards

Every document should begin with:

```markdown
# Document Title

> Document Version: 1.0
> Project: Neysoft Infrastructure
> Status: Active

---
```

Documentation should:

- Explain purpose before implementation.
- Be concise.
- Prefer diagrams.
- Avoid duplicated information.
- Reference related documents whenever appropriate.

---

# Infrastructure Standards

Applications should:

- Run inside Docker containers.
- Own their own repository.
- Own their own Docker Compose file.
- Remain isolated.
- Never expose public ports directly.

Nginx is the single public entry point.

---

# Docker Standards

Each application should contain only its own resources.

Example:

```text
app/
├── backend/
├── frontend/
├── docker-compose.yml
├── .env
└── README.md
```

Shared resources belong under:

```text
/opt/neysoft/shared
```

Persistent storage belongs under:

```text
/opt/neysoft/data
```

---

# Nginx Standards

Virtual hosts:

```text
sites-available/
```

Enabled hosts:

```text
sites-enabled/
```

Reusable configuration:

```text
snippets/
```

Templates:

```text
templates/
```

Applications should never modify Nginx configuration directly.

---

# Script Standards

Every shell script should:

- Use Bash.
- Be idempotent whenever possible.
- Exit immediately on failure.
- Validate prerequisites.
- Produce readable output.
- Log meaningful operations.

Recommended header:

```bash
#!/usr/bin/env bash

set -Eeuo pipefail
```

---

# Security Standards

Infrastructure should:

- Disable unnecessary services.
- Minimize exposed ports.
- Use SSH keys whenever possible.
- Use HTTPS by default.
- Keep systems updated.
- Store secrets outside Git repositories.

Sensitive information must never be committed.

---

# Logging

Scripts should produce readable logs.

Recommended prefixes:

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

[WARN] Docker network already exists.

[ERROR] Failed to restart nginx.
```

---

# Automation

Manual work should eventually become automation.

Whenever a manual procedure becomes repetitive, it should be converted into:

1. Bootstrap module.
2. Documentation.
3. Ansible role (future).

---

# Documentation Lifecycle

The expected workflow is:

```text
Decision

↓

Documentation

↓

Implementation

↓

Validation

↓

Automation
```

Documentation always precedes automation.

---

# Related Documents

- architecture.md
- server-layout.md
- bootstrap.md
- deployment.md
- security.md
