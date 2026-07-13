# Application Standard

> Document Version: 1.0  
> Project: Neysoft Infrastructure  
> Status: Active

---

# Overview

This document defines the infrastructure compatibility standard for applications hosted by Neysoft Infrastructure.

It describes the contract between an application and the infrastructure responsible for deploying, exposing, securing, monitoring and maintaining it.

This standard does not define how an application must be structured internally.

Applications remain free to use any suitable:

- Programming language
- Framework
- Runtime
- Database
- Directory structure
- Architectural pattern
- Build system

The infrastructure only defines the requirements an application must satisfy to operate safely and predictably within the Neysoft ecosystem.

---

# Objectives

The application standard exists to ensure that every hosted application is:

- Deployable
- Reproducible
- Configurable
- Secure
- Observable
- Maintainable
- Recoverable
- Compatible with automated infrastructure processes

Applications should integrate with the infrastructure without requiring undocumented manual configuration.

---

# Non-Goals

This document does not require applications to use:

- PHP
- Bun
- Node.js
- TypeScript
- A specific framework
- A specific directory layout
- A specific database
- A specific frontend architecture
- A monolith or microservice architecture

Internal application design remains the responsibility of each project.

---

# Infrastructure Model

Applications are expected to operate behind the Neysoft Infrastructure network model:

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
Nginx Reverse Proxy
    │
    ▼
Application Endpoint
    │
    ▼
Internal Services and Data
```

Nginx is the public HTTP and HTTPS entry point.

Applications should not expose themselves directly to the Internet.

---

# Mandatory Application Capabilities

Every application must provide:

- A reproducible installation or build process.
- A documented start process.
- Environment-based configuration.
- An internal HTTP endpoint or another documented service interface.
- A health validation method.
- Predictable logs.
- A persistent data strategy when required.
- A backup and recovery strategy when required.
- A documented update process.
- A rollback strategy for production deployments.

---

# Configuration Contract

Application configuration must be externalized.

Sensitive or environment-specific values must not be hardcoded in source code.

Examples include:

- Environment name
- Application URL
- Database credentials
- API keys
- Tokens
- SMTP credentials
- Storage paths
- Cache configuration
- Session configuration
- Third-party service credentials

Recommended environment variables include:

```text
APP_ENV
APP_DEBUG
APP_URL
APP_TIMEZONE

DB_HOST
DB_PORT
DB_NAME
DB_USER
DB_PASSWORD
```

Applications may define additional variables as required.

---

# Environment Files

Projects may use:

```text
.env
```

for local or deployment-specific configuration.

A reference file should be provided:

```text
.env.example
```

The reference file must:

- List every required variable.
- Contain safe example values.
- Avoid real credentials.
- Explain non-obvious variables.

The real `.env` file must never be committed to Git.

---

# Secrets

Secrets must remain outside version-controlled source code.

Examples:

- Passwords
- Private keys
- API tokens
- Database credentials
- Cloud credentials
- Certificates
- Encryption keys

Applications must never log secrets or expose them through HTTP responses.

Future infrastructure versions may integrate dedicated secret-management systems.

---

# Runtime Contract

An application must provide a reproducible runtime method.

Supported approaches may include:

- Docker Compose
- OCI containers
- systemd services
- Precompiled binaries
- Language-specific runtimes

Docker Compose is the preferred default for Neysoft-hosted applications.

Applications should not depend on manually modified runtime environments.

---

# Container Contract

When using containers, applications should:

- Use explicit image versions.
- Avoid `latest` tags in production whenever possible.
- Use restart policies.
- Declare required networks.
- Declare persistent volumes.
- Provide health checks where possible.
- Avoid privileged mode.
- Minimize Linux capabilities.
- Run as a non-root user whenever feasible.
- Avoid mounting unnecessary host directories.
- Keep runtime containers replaceable.

Containers should be disposable.

Persistent data should remain outside disposable container filesystems.

---

# Port Exposure

Applications must not expose public ports directly.

Recommended host binding:

```text
127.0.0.1:<host-port>:<container-port>
```

Example:

```yaml
ports:
  - "127.0.0.1:8080:80"
```

Databases should normally have no published host port:

```yaml
services:
  database:
    networks:
      - internal
```

Internal services should communicate using container or service names rather than fixed IP addresses.

---

# Reverse Proxy Contract

Public web applications must operate behind the host Nginx reverse proxy.

Applications must correctly support forwarded request metadata:

```text
X-Forwarded-For
X-Forwarded-Host
X-Forwarded-Port
X-Forwarded-Proto
X-Real-IP
```

Applications must not assume that the direct connection to the application container uses HTTPS.

TLS normally terminates at the Nginx layer.

For example:

```text
Browser HTTPS
    │
    ▼
Nginx TLS Termination
    │
    ▼
Internal HTTP Application
```

Applications using secure cookies or URL generation must correctly detect the original forwarded protocol.

---

# Domain Independence

Applications should not hardcode production domains.

Domain-related configuration should be provided through environment variables or deployment configuration.

Example:

```text
APP_URL=https://example.com
```

The same application should be deployable under different domains without source-code changes.

---

# Network Independence

Applications must not depend on:

- Fixed container IP addresses
- Fixed host IP addresses
- Public database addresses
- Undocumented external ports

Internal service discovery should use:

- Docker service names
- DNS names
- Environment variables
- Explicit configuration

---

# Health Contract

Every critical application should provide a health validation method.

For HTTP applications, recommended endpoints include:

```text
/health
/status
/ready
```

A health endpoint should:

- Return quickly.
- Avoid expensive operations.
- Return a clear success or failure status.
- Avoid exposing sensitive information.

Recommended status codes:

```text
200 — Healthy
503 — Unavailable
```

Where a dedicated endpoint is not available, another reliable health-check command must be documented.

---

# Readiness and Liveness

When applicable, applications should distinguish:

- **Liveness:** the process is running.
- **Readiness:** the application is ready to receive traffic.

Example:

```text
/health/live
/health/ready
```

Readiness checks may validate critical dependencies such as database connectivity.

---

# Logging Contract

Applications must produce useful and predictable logs.

Containerized applications should prefer:

```text
stdout
stderr
```

Persistent application logs may also be stored in an application-specific storage directory when required.

Logs should include:

- Timestamp
- Severity
- Component
- Event description
- Request or correlation identifier when available

Logs must not expose:

- Passwords
- Tokens
- Session identifiers
- Private keys
- Complete sensitive payloads

---

# Error Handling

Production applications must not expose internal exception messages, stack traces or database errors to end users.

Detailed errors should be written to logs.

External responses should remain safe and predictable.

Example:

```json
{
  "success": false,
  "error": "An internal error occurred."
}
```

---

# Persistent Data Contract

Application source code and persistent data must remain separate.

Persistent data may include:

- Databases
- User uploads
- Generated files
- Sessions
- Queues
- Application state
- Backups

Persistent data should use:

- Named Docker volumes
- Explicit host directories
- External storage services

The persistence strategy must be documented.

---

# Writable Directories

Applications must explicitly identify writable directories.

Examples:

```text
storage/
uploads/
sessions/
cache/
logs/
```

The deployment process must create these directories and apply the required ownership and permissions.

Applications must not rely on undocumented writable paths.

---

# Database Contract

Applications using databases must document:

- Supported database engine and version.
- Required database name.
- Required user permissions.
- Initial schema process.
- Migration process.
- Backup process.
- Restore process.

Database credentials must be provided through configuration.

Applications must not assume that the database runs on `localhost`.

Inside Docker Compose, a database host will normally be the service name:

```text
DB_HOST=db
```

---

# Schema Initialization

Initial database creation must be deterministic.

Supported strategies include:

- Initialization scripts
- Migration tools
- Application bootstrap commands
- Versioned schema files

Initialization scripts must not be expected to run repeatedly against an existing production database.

For Docker database images, files in:

```text
/docker-entrypoint-initdb.d/
```

normally run only when the data directory is empty.

---

# Database Migrations

Production applications should use versioned migrations for schema evolution.

Migrations should:

- Be version-controlled.
- Be repeatable or state-aware.
- Fail clearly.
- Preserve existing production data.
- Support rollback or recovery where practical.

Destructive schema operations must require explicit administrative action.

---

# Backup Contract

Applications containing persistent data must define a backup procedure.

The procedure should identify:

- What must be backed up.
- How the backup is created.
- Where backups are stored.
- How retention is managed.
- How restoration is performed.
- How restoration is validated.

A backup is not considered valid until restoration has been tested.

---

# Deployment Contract

Applications should support a predictable deployment flow.

Preferred workflow:

```text
git pull
docker compose config
docker compose up -d --build
health validation
```

A deployment should not require manual changes inside running containers.

The application must document any additional required step, such as:

- Database migrations
- Cache clearing
- Asset compilation
- Permission adjustment
- Queue restart

---

# Update Contract

Updating an application should be reproducible.

A standard update process should:

1. Fetch the intended version.
2. Validate configuration.
3. Create a backup when required.
4. Build or retrieve the runtime artifact.
5. Apply database migrations when required.
6. Restart or replace services.
7. Perform health checks.
8. Confirm public availability.

Applications should not rely on editing files directly on the production server.

---

# Rollback Contract

Every production application should define a rollback strategy.

Rollback may include:

- Reverting to a previous Git commit.
- Reusing a previous container image.
- Restoring a previous configuration.
- Restoring a database backup.
- Reverting a migration.

The rollback strategy must account for database compatibility.

---

# Build Contract

Applications requiring compilation must define a reproducible build command.

Examples:

```text
bun run build
npm run build
composer install --no-dev
go build
cargo build --release
```

Production artifacts should not depend on uncommitted local files.

Build dependencies should not remain in the final runtime image unless required.

Multi-stage Docker builds are recommended when appropriate.

---

# Development and Production

Applications may use different development and production implementations while preserving equivalent behavior.

Examples:

- Source bind mounts in development.
- Immutable container images in production.
- Debug output enabled only in development.
- Development-only administration tools.
- Production-only security controls.

Environment differences must be explicit and documented.

---

# Administrative Tools

Tools such as phpMyAdmin, database consoles or debugging services must not be publicly exposed.

Recommended approaches include:

- Docker Compose profiles
- Loopback-only port binding
- SSH tunnels
- Temporary activation

Example:

```yaml
profiles:
  - tools

ports:
  - "127.0.0.1:8081:80"
```

---

# Security Contract

Applications must follow secure defaults.

Minimum requirements include:

- No hardcoded secrets.
- No detailed production error output.
- Prepared database statements.
- Secure password hashing.
- Secure session configuration.
- Input validation.
- Output escaping.
- CSRF protection where applicable.
- Authentication and authorization enforcement.
- Restricted file-upload handling.
- Dependency update strategy.

Security should be part of application design.

---

# Session Contract

Applications using browser sessions must support operation behind HTTPS reverse proxies.

Recommended cookie settings:

```text
HttpOnly
Secure
SameSite
```

Applications must correctly interpret:

```text
X-Forwarded-Proto: https
```

when determining whether a secure cookie is required.

Session storage must be writable and persistent when sessions must survive container replacement.

---

# CORS Contract

Applications should not enable unrestricted CORS unless it is explicitly required.

This combination should be avoided:

```text
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
```

Applications served from the same origin generally do not require CORS.

When cross-origin access is necessary, allowed origins must be explicitly configured.

---

# File Uploads

Applications accepting uploads must define:

- Maximum upload size.
- Allowed file types.
- Filename strategy.
- Storage destination.
- Access-control strategy.
- Backup requirements.
- Malware-validation strategy when applicable.

Uploaded files must not allow arbitrary code execution.

---

# Observability Contract

Applications should expose enough information for operational monitoring.

Recommended information includes:

- Application health
- Application version
- Build identifier
- Uptime
- Dependency status
- Error rate

Sensitive internal information must not be exposed through public endpoints.

---

# Version Contract

Applications should expose or document the deployed version.

Supported approaches include:

- Git tag
- Commit hash
- Build number
- Version file
- `/version` endpoint

This information is important for diagnostics and rollback.

---

# Documentation Requirements

Every application should document:

```text
README.md
```

At minimum, documentation must describe:

- Application purpose
- Runtime requirements
- Environment variables
- Development startup
- Production deployment
- Database initialization
- Update process
- Backup process
- Restore process
- Health validation

Additional documentation may be placed under:

```text
docs/
```

---

# Git Contract

Production deployments should use version-controlled source or versioned artifacts.

Recommended permanent branch:

```text
main
```

Optional development branch:

```text
develop
```

Stable releases should use tags:

```text
v1.0.0
v1.1.0
```

Servers should normally deploy from a stable branch or explicit release tag.

---

# Application Isolation

Each application should remain operationally isolated.

An application should own its:

- Repository
- Configuration
- Runtime services
- Docker Compose project
- Internal network
- Persistent data
- Logs
- Backup strategy

Applications must not depend on undocumented files from unrelated projects.

---

# Host Integration

Applications hosted under Neysoft Infrastructure are normally installed under:

```text
/opt/neysoft/apps/<application-name>
```

Application data may use infrastructure-managed locations where required:

```text
/opt/neysoft/data/<application-name>
/opt/neysoft/backups/<application-name>
/opt/neysoft/logs/<application-name>
```

Host integration must remain explicit.

---

# Nginx Integration

Each public application receives its own virtual host under:

```text
/opt/neysoft/nginx/sites-available/
```

Enabled sites are linked under:

```text
/opt/neysoft/nginx/sites-enabled/
```

The virtual host forwards requests to the application’s loopback-bound endpoint.

Example:

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name example.com www.example.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        include /opt/neysoft/nginx/snippets/proxy-common.conf;
    }
}
```

Applications should not modify host Nginx configuration directly.

---

# Compliance Checklist

Before an application enters production, verify:

- [ ] Configuration is externalized.
- [ ] Secrets are not committed.
- [ ] `.env.example` is available.
- [ ] Runtime is reproducible.
- [ ] Public traffic passes through Nginx.
- [ ] Application port is bound to loopback.
- [ ] Database is not publicly exposed.
- [ ] Health validation is available.
- [ ] Logs are operationally useful.
- [ ] Writable directories are documented.
- [ ] Persistent data is identified.
- [ ] Database initialization is documented.
- [ ] Migration strategy is documented.
- [ ] Backup and restore procedures exist.
- [ ] Update procedure is documented.
- [ ] Rollback procedure is documented.
- [ ] Production errors do not expose internal details.
- [ ] HTTPS and forwarded headers are supported.
- [ ] Administrative tools are not publicly exposed.
- [ ] Deployment has been validated.

---

# Golden Path

A well-prepared application should be deployable using a flow similar to:

```bash
git clone <repository>
cd <application>

cp .env.example .env
nano .env

docker compose config
docker compose up -d --build
```

After application startup:

```text
Create Nginx virtual host
Enable virtual host
Validate Nginx
Issue TLS certificate
Run health checks
```

Application-specific database initialization or migrations must be explicitly documented.

---

# Standard Philosophy

The Neysoft application standard defines integration requirements, not internal architecture.

Applications may evolve independently.

Infrastructure expectations should remain predictable.

The standard prioritizes:

- Freedom of implementation
- Clear operational contracts
- Reproducible deployments
- Secure configuration
- Infrastructure compatibility
- Long-term maintainability

---

# Final Principle

An application should not need to understand the entire infrastructure.

The infrastructure should not need to understand the application’s internal implementation.

Both sides should communicate through a clear and stable contract.

---

# Related Documents

- architecture.md
- conventions.md
- deployment.md
- docker.md
- networking.md
- nginx.md
- security.md
- server-layout.md
