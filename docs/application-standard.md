# Neysoft Application Standard

> **Document Version:** 2.0.0  
> **Project:** Neysoft Infrastructure  
> **Status:** Active  
> **Scope:** Application-to-Infrastructure Contract

---

## 1. Overview

This document defines the operational contract for applications hosted by **Neysoft Infrastructure**.

It establishes how an application must integrate with the infrastructure responsible for:

- deployment;
- configuration;
- networking;
- reverse proxy;
- persistent data;
- health validation;
- updates;
- backup;
- rollback;
- security;
- operational documentation.

This standard does **not** define the application's internal architecture.

Applications remain free to use any appropriate:

- programming language;
- framework;
- runtime;
- database;
- directory structure;
- frontend architecture;
- build system;
- monolith or service-oriented design.

The infrastructure defines the contract. Each application defines its implementation.

---

## 2. Objectives

Every hosted application should be:

- reproducible;
- configurable;
- deployable;
- updateable;
- isolated;
- observable;
- recoverable;
- secure by default;
- compatible with Neysoft Infrastructure;
- maintainable without undocumented manual procedures.

A production deployment should be predictable from a clean checkout of the repository.

---

## 3. Non-Goals

This standard does not require:

- PHP;
- Node.js;
- Bun;
- TypeScript;
- Go;
- Python;
- a specific database;
- a specific framework;
- a fixed application directory layout;
- a specific migration tool;
- a specific frontend technology.

Project-specific technology decisions remain inside each application repository.

---

## 4. Infrastructure Model

Public applications normally operate through the following path:

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
Nginx Reverse Proxy on Host
    │
    ▼
Loopback-Bound Application Endpoint
    │
    ▼
Internal Application Services
    │
    ▼
Persistent Data
```

Nginx is the public HTTP and HTTPS entry point.

Application containers should not be exposed directly to the Internet.

TLS normally terminates at the host Nginx layer.

---

## 5. Minimum Application Contract

Every production application must provide:

- a reproducible runtime;
- environment-based configuration;
- documented required variables;
- an application start or deployment process;
- an internal service endpoint;
- health validation;
- a persistent data strategy when required;
- a database initialization strategy when required;
- an update procedure;
- a backup and restore procedure when persistent data exists;
- a rollback strategy;
- operational documentation.

---

## 6. Recommended Operational Files

Applications using Docker Compose should normally provide:

```text
.env.example
.gitignore
compose.yaml
README.md
scripts/deploy.sh
scripts/deploy.md
```

Optional files include:

```text
compose.dev.yaml
scripts/backup.sh
scripts/restore.sh
scripts/migrate.sh
scripts/init-db.sh
docs/
```

These are operational conventions, not restrictions on the application's internal source layout.

---

## 7. Environment Configuration Contract

Configuration must be externalized.

Sensitive or environment-specific values must not be hardcoded in source code.

Examples include:

- environment name;
- debug mode;
- domain or application URL;
- database host;
- database name;
- database credentials;
- API keys;
- SMTP credentials;
- tokens;
- storage paths;
- session configuration;
- cache configuration;
- service ports.

Recommended generic variables:

```text
APP_ENV
APP_DEBUG
APP_URL
APP_TIMEZONE

WEB_BIND_IP
WEB_PORT

DB_HOST
DB_PORT
DB_NAME
DB_USER
DB_PASSWORD
```

Database images may require engine-specific variables, for example:

```text
MARIADB_DATABASE
MARIADB_USER
MARIADB_PASSWORD
MARIADB_ROOT_PASSWORD
```

When the same logical value is represented by application and container variables, they must remain consistent.

Example:

```text
DB_NAME = MARIADB_DATABASE
DB_USER = MARIADB_USER
DB_PASSWORD = MARIADB_PASSWORD
```

Applications may define additional variables when necessary.

---

## 8. Environment Files

The deployment-specific configuration may be stored in:

```text
.env
```

A safe reference file must be provided:

```text
.env.example
```

The `.env.example` file must:

- list all required variables;
- contain safe example values;
- avoid real passwords, tokens or keys;
- explain non-obvious values;
- remain suitable for copying into a local `.env`.

The real `.env` file must:

- never be committed;
- be listed in `.gitignore`;
- use restrictive permissions in production when practical.

Recommended production permission:

```bash
chmod 600 .env
```

---

## 9. Secrets Contract

Secrets must remain outside version control.

Applications must not:

- commit real credentials;
- print secrets in deploy output;
- expose secrets through HTTP responses;
- write secrets to application logs;
- embed production passwords in Compose files;
- generate replacement credentials during routine deploys;
- overwrite an existing production `.env`.

Examples of secrets:

- passwords;
- API tokens;
- private keys;
- database credentials;
- cloud credentials;
- certificate private keys;
- encryption keys.

---

## 10. Runtime Contract

The application must provide a reproducible runtime method.

Supported approaches may include:

- Docker Compose;
- OCI containers;
- systemd services;
- precompiled binaries;
- language-specific runtimes.

Docker Compose is the preferred default for Neysoft-hosted applications.

The production server should not depend on undocumented manual modifications.

---

## 11. Docker Compose Contract

For applications using Docker Compose:

- the production file should be named `compose.yaml`;
- the Compose project name should be stable;
- runtime services should use explicit image versions;
- persistent volumes should use explicit names when stability matters;
- the application service should bind only to loopback;
- databases should normally have no published host port;
- restart policies should be defined;
- critical services should provide health checks where possible;
- privileged mode should be avoided;
- unnecessary host mounts should be avoided;
- containers should remain replaceable.

Example stable project declaration:

```yaml
name: example-app
```

Example stable named volume:

```yaml
volumes:
  db_data:
    name: example_app_db_data
```

A stable explicit volume name prevents the physical volume name from changing when the repository directory is moved or cloned elsewhere.

---

## 12. Development and Production Separation

Development and production may use different Compose layers.

Recommended model:

```text
compose.yaml
compose.dev.yaml
```

Production:

```bash
docker compose -f compose.yaml up -d --build
```

Development:

```bash
docker compose \
  -f compose.yaml \
  -f compose.dev.yaml \
  up -d --build
```

Typical development-only features:

- source bind mounts;
- debug mode;
- phpMyAdmin or equivalent tools;
- local database port mapping;
- hot reload;
- development seed data.

Typical production features:

- immutable runtime image;
- loopback-only web binding;
- no public database port;
- debug disabled;
- administrative tools disabled;
- multi-stage builds where appropriate.

---

## 13. Build Contract

Applications requiring compilation must provide a reproducible build.

Examples:

```text
bun run build
npm run build
composer install --no-dev
go build
cargo build --release
```

Production servers should not require build tools installed directly on the host when the build can be isolated inside Docker.

Multi-stage builds are recommended when appropriate.

Example model:

```text
Builder Stage
    │
    ├── installs build dependencies
    ├── compiles application assets
    ▼
Runtime Stage
    │
    ├── receives only runtime files
    └── excludes build-only dependencies
```

Production artifacts must not depend on uncommitted local files.

---

## 14. Port Exposure Contract

Public application services must bind to loopback.

Recommended mapping:

```yaml
ports:
  - "127.0.0.1:8080:80"
```

Or through variables:

```yaml
ports:
  - "${WEB_BIND_IP:-127.0.0.1}:${WEB_PORT:-8080}:80"
```

Database services should normally not publish ports:

```yaml
services:
  db:
    networks:
      - internal
```

Development-only database mappings must also bind to loopback:

```yaml
ports:
  - "127.0.0.1:3307:3306"
```

Internal services should communicate through service names rather than fixed container IP addresses.

---

## 15. Reverse Proxy Contract

Public web applications must operate behind the host Nginx reverse proxy.

Applications should support forwarded request metadata:

```text
X-Forwarded-For
X-Forwarded-Host
X-Forwarded-Port
X-Forwarded-Proto
X-Real-IP
```

Applications must not assume that the direct container connection uses HTTPS.

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

Applications using secure cookies or absolute URL generation must correctly detect the original forwarded protocol.

Forwarded headers should only be trusted when traffic originates from a trusted proxy path.

---

## 16. Domain Independence

Production domains should not be hardcoded in application logic.

Use environment or deployment configuration:

```text
APP_URL=https://example.com
```

The same application should be deployable under a different domain without source-code changes.

---

## 17. Network Independence

Applications must not depend on:

- fixed container IPs;
- fixed public IPs;
- hardcoded database addresses;
- undocumented host ports;
- unrelated project networks.

Use:

- Docker service names;
- DNS names;
- environment variables;
- explicit network configuration.

---

## 18. Persistent Data Contract

Source code and persistent data must remain separate.

Persistent data may include:

- database data;
- uploads;
- generated files;
- sessions;
- queues;
- application state;
- backups.

Approved persistence methods include:

- named Docker volumes;
- explicit host directories;
- external storage services.

Persistent data must not exist only inside a disposable container filesystem.

---

## 19. Writable Directories

Applications must document all writable directories.

Examples:

```text
storage/
uploads/
sessions/
cache/
logs/
```

The runtime or deploy process must ensure:

- the directory exists;
- permissions are correct;
- ownership is correct;
- failure is visible;
- production does not silently fall back to unsafe temporary paths.

---

## 20. Database Contract

Applications using databases must document:

- engine and supported version;
- database name;
- required user permissions;
- initial schema process;
- seed process;
- migration process;
- backup process;
- restore process.

Applications must not assume the database runs on `localhost`.

Inside Compose, the application normally connects using the service name:

```text
DB_HOST=db
```

---

## 21. Database Initialization

Initial database creation must be deterministic.

Supported approaches include:

- versioned schema file;
- migration tool;
- initialization script;
- explicit bootstrap command;
- dedicated `scripts/init-db.sh`.

Initial provisioning must not be confused with routine deployment.

A connection failure must never be interpreted as an empty database.

Before any automatic initialization, the application must distinguish:

1. successful database connection;
2. successful inspection;
3. confirmed empty database;
4. existing database with data;
5. connection or inspection error.

Only a successfully confirmed empty database may receive automatic initial schema or seed data.

---

## 22. Database Seed Rules

Seed data must be classified.

Recommended categories:

```text
schema
development seed
production bootstrap
```

Development data must not be automatically inserted into production.

Production administrator creation or sensitive initial records should use an explicit controlled command when appropriate.

Example:

```bash
docker compose exec web php path/to/create-admin.php
```

---

## 23. Database Preservation Guard

Applications may implement a database preservation guard during deploy.

A preservation guard may:

- confirm database connectivity;
- inspect whether the database already contains tables;
- initialize only a confirmed empty database;
- skip initialization when existing tables are present;
- fail when inspection fails.

A preservation guard must not claim to replace:

- migrations;
- schema validation;
- backups;
- database version control;
- integrity checks.

The existence of one or more tables only indicates that the database should be preserved. It does not prove that the schema is complete or current.

---

## 24. Database Migrations

Production schema evolution should use versioned migrations.

Migrations should:

- be stored in version control;
- execute in a known order;
- fail clearly;
- avoid repeated execution;
- preserve existing data;
- remain backward compatible when practical;
- record successful execution only after completion;
- prevent concurrent migration runs when necessary.

Destructive migrations must require explicit administrative action.

Routine deploy scripts should not silently execute destructive SQL.

---

## 25. Backup Contract

Applications containing persistent data must define backup procedures.

The backup documentation must describe:

- what is backed up;
- how it is backed up;
- where it is stored;
- retention policy;
- restore procedure;
- validation procedure.

Backups may include:

- database dumps;
- uploads;
- generated files;
- application configuration references;
- external storage metadata.

Sessions usually do not require long-term backup unless the application explicitly depends on them.

A backup is not considered valid until restoration has been tested.

---

## 26. Automated Deployment Contract

Applications may provide:

```text
scripts/deploy.sh
```

The deployment script should perform a predictable, non-destructive and repeatable deployment.

Recommended responsibilities:

1. resolve the repository root;
2. validate required project files;
3. verify `.env`;
4. validate required environment variables;
5. validate consistency between related variables;
6. validate identifier and port formats;
7. validate Docker Compose configuration;
8. build and start containers;
9. preserve existing volumes;
10. wait for critical services;
11. initialize only a confirmed empty database when explicitly supported;
12. display service status;
13. validate application availability;
14. return a non-zero exit code on failure.

---

## 27. Shell Deployment Script Quality

A Bash deploy script should normally use:

```bash
set -euo pipefail
```

It should:

- quote variable expansions;
- avoid exposing passwords;
- validate external command results;
- restore terminal state after interruption;
- use `trap` when hiding the cursor or creating temporary files;
- avoid treating command errors as valid empty results;
- use retry loops for services that require startup time;
- fail when final health validation fails;
- remain idempotent when executed repeatedly.

If interactive output hides the cursor, it must restore it on:

```text
EXIT
INT
TERM
```

---

## 28. Deploy Script Prohibited Actions

Routine deployment scripts must not automatically:

- execute `git pull`;
- remove volumes;
- run `docker compose down -v`;
- run `docker volume rm`;
- delete databases;
- truncate production tables;
- restore backups;
- replace `.env`;
- generate new production credentials;
- run destructive migrations;
- reset persistent data.

These actions require explicit administrative intent and separate procedures.

---

## 29. Secret-Safe Database Commands

Database credentials should not be printed in deploy logs or exposed unnecessarily in host process arguments.

When possible, execute database commands inside the container using variables already present there.

Example pattern:

```bash
docker compose exec -T db sh -c \
  'MYSQL_PWD="$MARIADB_PASSWORD" mariadb -u "$MARIADB_USER" "$MARIADB_DATABASE"'
```

Project-specific implementations may use a safer engine-native credential mechanism when available.

---

## 30. Service Startup Waiting

Deployment scripts should wait for critical dependencies.

Examples:

- database readiness;
- cache readiness;
- queue availability;
- application HTTP readiness.

A fixed delay alone is not considered sufficient.

Preferred approach:

```text
attempt
wait
retry
fail after defined limit
```

Dependency failures must stop the deployment.

---

## 31. Health Validation Contract

Every critical application must provide a reliable validation method.

Recommended HTTP endpoints:

```text
/health
/status
/ready
```

A health response should:

- return quickly;
- avoid expensive operations;
- avoid sensitive details;
- return a clear status;
- use appropriate HTTP codes.

Recommended codes:

```text
200 — Healthy or Ready
503 — Unavailable
```

---

## 32. Liveness and Readiness

When appropriate, distinguish:

- **Liveness:** the process and runtime are responding.
- **Readiness:** the application can serve real traffic.

Readiness may verify:

- database connectivity;
- writable storage;
- critical services;
- required configuration.

A Docker healthcheck should normally validate readiness when container health is used as an operational signal.

---

## 33. HTTP Validation in Deploy

The deployment script should validate the application after startup.

Recommended behavior:

- perform multiple attempts;
- wait briefly between attempts;
- accept only documented success codes;
- fail after the retry limit;
- use a container-internal fallback when host tools are unavailable.

Examples of accepted application-specific success codes may include:

```text
200
302
```

The deployment must not report success when the application remains unreachable.

---

## 34. Logging Contract

Applications must produce useful and predictable logs.

Containerized applications should prefer:

```text
stdout
stderr
```

Logs should include when practical:

- timestamp;
- severity;
- component;
- event;
- request or correlation identifier.

Logs must not include:

- passwords;
- private keys;
- API tokens;
- complete sensitive payloads;
- session secrets;
- database connection strings containing credentials.

---

## 35. Error Handling

Production applications must not expose:

- stack traces;
- absolute paths;
- raw database errors;
- internal exception details;
- credentials;
- SQL statements containing sensitive data.

Detailed errors should be logged internally.

External responses should remain generic and predictable.

Example:

```json
{
  "success": false,
  "error": "An internal error occurred."
}
```

---

## 36. Administrative Tools

Tools such as phpMyAdmin, database consoles and debug dashboards must not be publicly exposed.

Recommended approaches:

- development-only Compose override;
- Docker Compose profile;
- loopback-only binding;
- SSH tunnel;
- temporary activation.

Example:

```yaml
ports:
  - "127.0.0.1:8081:80"
```

---

## 37. Session Contract

Applications using browser sessions must support HTTPS behind a reverse proxy.

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

Session storage must be writable and persistent when sessions must survive container replacement.

Production should fail visibly when required session storage is unavailable.

---

## 38. CORS Contract

Applications should not enable unrestricted CORS unless required.

Avoid:

```text
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
```

Same-origin applications normally do not need CORS.

Cross-origin access must use explicitly configured allowed origins.

---

## 39. File Upload Contract

Applications accepting uploads must define:

- maximum file size;
- allowed file types;
- filename strategy;
- storage destination;
- access-control policy;
- backup requirements;
- malware validation when appropriate.

Uploaded files must not allow arbitrary code execution.

Upload storage must be persistent when files must survive container replacement.

---

## 40. Security Contract

Minimum requirements:

- no committed secrets;
- debug disabled in production;
- prepared database statements;
- secure password hashing;
- secure session cookies;
- input validation;
- output escaping;
- authorization enforcement;
- CSRF protection where applicable;
- restricted upload handling;
- dependency update process;
- no public database ports;
- no public administrative tools.

---

## 41. Update Contract

Production updates should be explicit and reproducible.

Recommended flow:

```bash
git pull --ff-only origin main
./scripts/deploy.sh
```

Or deploy a specific release:

```bash
git fetch --tags origin
git checkout v1.2.0
./scripts/deploy.sh
```

`--ff-only` prevents accidental merge commits on the production server.

The deploy script should not execute `git pull` automatically.

Code acquisition and application deployment remain separate operational steps.

---

## 42. Rollback Contract

Every production application should define a rollback strategy.

Preferred order:

1. rollback application code or image;
2. rebuild or restart services;
3. validate health;
4. address schema compatibility through backward-compatible migrations;
5. restore a database backup only when explicitly required.

Database restoration is an exceptional operation because it may remove records created after the backup.

Rollback procedures must consider database compatibility.

---

## 43. Git and Version Contract

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
v2.0.0
```

The deployed version should be identifiable through:

- Git tag;
- commit hash;
- build identifier;
- version file;
- version endpoint.

---

## 44. Application Isolation

Each application should own its:

- repository;
- `.env`;
- Compose project;
- internal network;
- runtime services;
- persistent volumes;
- logs;
- backup process;
- deployment script;
- operational documentation.

Applications must not depend on undocumented files from unrelated projects.

---

## 45. Host Integration

Applications are normally installed under:

```text
/opt/neysoft/apps/<application-name>
```

Infrastructure-managed data may use:

```text
/opt/neysoft/data/<application-name>
/opt/neysoft/backups/<application-name>
/opt/neysoft/logs/<application-name>
```

Host integration must remain explicit and documented.

---

## 46. Nginx Integration

Each public application normally receives a virtual host under:

```text
/opt/neysoft/nginx/sites-available/
```

Enabled sites are linked under:

```text
/opt/neysoft/nginx/sites-enabled/
```

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

Applications must not modify host Nginx configuration automatically.

Nginx and TLS certificate management belong to Neysoft Infrastructure.

---

## 47. Documentation Contract

Every application should provide:

```text
README.md
```

When an automated deploy script exists, also provide:

```text
scripts/deploy.md
```

Documentation should cover:

- application purpose;
- runtime requirements;
- environment variables;
- local development;
- initial production deploy;
- regular updates;
- persistent volumes;
- database initialization;
- migration process;
- backup;
- restore;
- rollback;
- health validation;
- destructive command warnings.

Documentation must not include real credentials.

---

## 48. Required Destructive Command Warnings

Commands such as:

```bash
docker compose down -v
docker volume rm
DROP DATABASE
TRUNCATE
```

must be clearly marked as destructive.

`docker compose down -v` must never appear as a routine production update command.

When documented for local reset, the documentation must explicitly state:

- development only;
- all related named volumes may be removed;
- database data will be lost;
- the action requires deliberate operator intent.

---

## 49. Deployment Validation

Before declaring a deploy successful, validate:

- `.env` exists;
- required variables are present;
- related variables are consistent;
- Docker Compose configuration is valid;
- containers started;
- database is reachable when required;
- existing persistent data was preserved;
- initial database setup occurred only when appropriate;
- application returned an accepted HTTP status;
- the command exited successfully.

A visually successful script output must always correspond to a successful exit status.

---

## 50. Compliance Checklist

Before production deployment, verify:

- [ ] Configuration is externalized.
- [ ] `.env.example` exists.
- [ ] `.env` is ignored by Git.
- [ ] No real secrets are committed.
- [ ] Production debug is disabled.
- [ ] Compose project name is stable.
- [ ] Persistent volume names are stable where required.
- [ ] Application port binds to loopback.
- [ ] Database has no public production port.
- [ ] Administrative tools are not publicly exposed.
- [ ] Production uses a reproducible build.
- [ ] Build-only dependencies are excluded from runtime where practical.
- [ ] Deploy script validates environment configuration.
- [ ] Deploy script preserves volumes.
- [ ] Deploy script does not perform `git pull`.
- [ ] Deploy script does not remove volumes.
- [ ] Database connection failure is not treated as an empty database.
- [ ] Automatic initialization occurs only after confirmed empty state.
- [ ] Migrations are documented.
- [ ] Backup and restore are documented.
- [ ] Health validation exists.
- [ ] HTTP validation uses retries.
- [ ] Production errors do not expose internal details.
- [ ] Reverse proxy headers are supported safely.
- [ ] Update uses `git pull --ff-only` or an explicit release tag.
- [ ] Rollback procedure exists.
- [ ] Destructive commands are clearly documented.
- [ ] Nginx integration is documented.
- [ ] Deployment has been tested in production-like conditions.

---

## 51. Golden Path — Initial Deployment

Recommended flow:

```bash
git clone <repository>
cd <application>

cp .env.example .env
nano .env
chmod 600 .env

./scripts/deploy.sh
```

After the application is healthy:

```text
Create Nginx virtual host
Enable virtual host
Validate Nginx
Issue TLS certificate
Validate public HTTPS access
```

Application-specific initialization commands must be documented.

---

## 52. Golden Path — Update

Recommended flow:

```bash
cd /opt/neysoft/apps/<application-name>

git pull --ff-only origin main
./scripts/deploy.sh
```

The deploy should:

```text
validate
build
start
preserve
wait
verify
```

It should not:

```text
pull code
delete data
replace secrets
reset the database
```

---

## 53. Reference Implementation

The **Rearmonize** application is a current reference implementation of this deployment contract.

Its implementation demonstrates:

- `.env.example`;
- production and development Compose separation;
- loopback-only application binding;
- no public production database port;
- stable named database volume;
- multi-stage frontend build;
- non-destructive `scripts/deploy.sh`;
- environment consistency validation;
- database readiness waiting;
- confirmed-empty database initialization;
- preservation of existing database tables;
- retry-based HTTP validation;
- `scripts/deploy.md` operational documentation.

Rearmonize is a reference implementation, not a mandatory technology stack.

Other applications may implement the same contract using different runtimes, databases and build tools.

---

## 54. Standard Philosophy

The Neysoft Application Standard defines integration requirements, not internal application architecture.

The standard prioritizes:

- freedom of implementation;
- operational consistency;
- secure configuration;
- reproducible deployments;
- persistent data protection;
- clear failure handling;
- infrastructure compatibility;
- maintainability.

---

## 55. Final Principle

An application should not need to understand the entire infrastructure.

The infrastructure should not need to understand the application's internal implementation.

Both sides should communicate through a clear, stable and documented operational contract.

---

## Related Documents

- `architecture.md`
- `conventions.md`
- `deployment.md`
- `docker.md`
- `networking.md`
- `nginx.md`
- `security.md`
- `server-layout.md`
