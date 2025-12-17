# 🏔️ TundraSoft Alpine Base Image

<!-- DESCRIPTION-START -->
A lightweight, secure Alpine Linux base image with S6 overlay, cron support, and developer-friendly utilities pre-installed.
<!-- DESCRIPTION-END -->

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/TundraSoft/alpine/build-docker.yml?event=push&logo=github&label=build)](https://github.com/TundraSoft/alpine/actions/workflows/build-docker.yml)
[![Security Scan](https://img.shields.io/github/actions/workflow/status/TundraSoft/alpine/security-scan.yml?logo=adguard&label=security)](https://github.com/TundraSoft/alpine/actions/workflows/security-scan.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/tundrasoft/alpine.svg?logo=docker)](https://hub.docker.com/r/tundrasoft/alpine)
[![License](https://img.shields.io/github/license/TundraSoft/alpine.svg)](https://github.com/TundraSoft/alpine/blob/main/LICENSE)

---

## 📋 Table of Contents

- [🚀 Quick Start](#-quick-start)
- [🏷️ Available Tags](#️-available-tags)
- [✨ Features](#-features)
- [📖 Usage](#-usage)
  - [Basic Usage](#basic-usage)
  - [Environment Variables](#environment-variables)
  - [Volumes](#volumes)
- [⚙️ Service Management](#️-service-management)
  - [S6 Service Architecture](#s6-service-architecture)
  - [Initialization Flow](#initialization-flow)
  - [Adding Custom Services](#adding-custom-services)
  - [Service Examples](#service-examples)
- [⏰ Cron Jobs](#-cron-jobs)
  - [Dynamic Cron Setup](#dynamic-cron-setup)
  - [Cron Examples](#cron-examples)
  - [Security Best Practices](#security-best-practices)
- [🔧 Building](#-building)
- [� Examples](#-examples)
- [�🔒 Security](#-security)
- [📚 Components](#-components)
- [📖 Reference](#reference)
- [📝 Changelog](#changelog)
- [🤝 Contributing](#-contributing)

---

## 🚀 Quick Start

### 📦 Available Registries

This image is available on multiple registries:

- **Docker Hub**: `tundrasoft/alpine`
- **GitHub Container Registry**: `ghcr.io/tundrasoft/alpine`

```bash
# Pull from Docker Hub (recommended)
docker pull tundrasoft/alpine:latest

# Pull from GitHub Container Registry
docker pull ghcr.io/tundrasoft/alpine:latest

# Run with basic setup
docker run -d --name my-app tundrasoft/alpine:latest

# Run with custom timezone and user
docker run -d \
  -e TZ=Asia/Kolkata \
  -e PUID=1001 \
  -e PGID=1001 \
  --name my-app \
  tundrasoft/alpine:latest
```

--- 
## 🏷️ Available Tags

<!-- TAGS-START -->
| Version | Tags |
|---------|------|
| [latest](https://hub.docker.com/r/tundrasoft/alpine/tags?name=latest) | Latest stable release |
| [edge](https://hub.docker.com/r/tundrasoft/alpine/tags?name=edge) | Edge/development version |
| [3.23](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.23) | [3.23.2](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.23.2) |
| [3.22](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.22) | [3.22.2](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.22.2), [3.22.1](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.22.1), [3.22.0](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.22.0) |
| [3.21](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.21) | [3.21.5](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.21.5), [3.21.4](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.21.4), [3.21.3](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.21.3) |
| [3.20](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.20) | [3.20.7](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.20.7), [3.20.6](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.20.6) |
| [3.19](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.19) | [3.19.1](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.19.1) |

<!-- TAGS-END -->

---

## ✨ Features

- 🐧 **Latest Alpine Linux** - Minimal, secure base OS
- 🔧 **S6 Overlay** - Advanced process supervision and service management
- ⏰ **Dynamic Cron Support** - Environment variable-driven cron jobs
- 👤 **Pre-configured User** - Non-root `tundra` user (UID/GID: 1000)
- 🌍 **Timezone Support** - Easy timezone configuration
- 🔄 **envsubst** - Environment variable substitution in config files
- 🔒 **Security Focused** - Regular vulnerability scanning and updates

---

## 📖 Usage

### Basic Usage

Use as a base image in your Dockerfile:

```dockerfile
# From Docker Hub
FROM tundrasoft/alpine:latest
# Your application setup here
```

```dockerfile
# From GitHub Container Registry
FROM ghcr.io/tundrasoft/alpine:latest
# Your application setup here
```

For specific versions:
```dockerfile
FROM tundrasoft/alpine:3.22.0
# or
FROM ghcr.io/tundrasoft/alpine:3.22.0
```

### Environment Variables

<!-- ENV-VARS-START -->
| Variable | Description | Default |
|----------|-------------|---------|
| `PUID` | User ID for the `tundra` user | `1000` |
| `PGID` | Group ID for the `tundra` group | `1000` |
| `TZ` | Timezone (e.g., `Asia/Kolkata`, `America/New_York`) | `UTC` |
<!-- ENV-VARS-END -->

### Volumes

| Path | Description |
|------|-------------|
| `/crons` | Directory for cron job files (automatically loaded) |

---

## ⚙️ Service Management

This image uses [S6 Overlay](https://github.com/just-containers/s6-overlay) for advanced process supervision and service management. S6 is a lightweight init system that provides reliable service supervision, dependency management, and graceful shutdown handling.

### S6 Service Architecture

The S6 service hierarchy follows this structure:

```
s6-rc.d/
├── base/                    # Foundational services (always run)
├── user/                    # User-defined service bundle
│   └── contents.d/          # Services included in user bundle
├── timezone/                # Timezone configuration service
├── init-user/               # User/group initialization
├── os-ready/                # Oneshot: Triggered when OS is ready
├── config-start/            # Oneshot: Configuration phase starts
├── config-cron/             # Oneshot: Load cron jobs
├── config-ready/            # Oneshot: Configuration complete
├── crond/                   # Longrun: Cron daemon process
├── service-start/           # Oneshot: Service phase starts
└── service-ready/           # Oneshot: Services initialized
```

### Initialization Flow

The container initialization follows this dependency chain:

```
Container Start
    ↓
[base] (supervisor)
    ↓
[timezone] → Sets TZ from env var
[init-user] → Configures tundra user/group
    ↓
[os-ready] ← When base services complete
    ↓
[config-start] → Configuration phase begins
    ↓
[config-cron] → Loads cron jobs from /crons
[config-ready] ← Configuration complete
    ↓
[service-start] → Application services begin
    ↓
[crond] → Cron daemon starts
[service-ready] ← All services initialized
    ↓
Container Ready (running indefinitely)
```

### 📋 Built-in Services

| Service | Type | Purpose | Dependencies |
|---------|------|---------|--------------|
| `timezone` | `oneshot` | Sets timezone from `TZ` environment variable | None |
| `init-user` | `oneshot` | Configures `tundra` user/group IDs using `PUID`/`PGID` | None |
| `os-ready` | `oneshot` | Signals OS initialization complete | `base`, `init-user`, `timezone` |
| `config-start` | `oneshot` | Signals configuration phase start | `os-ready` |
| `config-cron` | `oneshot` | Loads cron jobs from `/crons` directory | `config-start` |
| `config-ready` | `oneshot` | Signals configuration complete | `config-cron`, `config-start` |
| `service-start` | `oneshot` | Signals service initialization phase | `config-ready` |
| `crond` | `longrun` | Runs cron daemon process | `config-cron`, `service-start` |
| `service-ready` | `oneshot` | Signals all services initialized | `crond`, `service-start` |

### Adding Custom Services

#### Step-by-Step Guide

**1. Create Service Directory Structure**

```bash
FROM tundrasoft/alpine:latest

# Create service with proper structure
RUN mkdir -p /etc/s6-overlay/s6-rc.d/my-app/dependencies.d

# Set service type (longrun = daemon, oneshot = runs once)
RUN echo "longrun" > /etc/s6-overlay/s6-rc.d/my-app/type

# Create the run script (entry point for the service)
COPY my-app-run.sh /etc/s6-overlay/s6-rc.d/my-app/run
RUN chmod +x /etc/s6-overlay/s6-rc.d/my-app/run

# Declare dependencies
RUN touch /etc/s6-overlay/s6-rc.d/my-app/dependencies.d/service-start

# Add to user bundle so it starts automatically
RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/my-app
```

**2. Create the Run Script** (`my-app-run.sh`)

```bash
#!/command/with-contenv bash
# This script runs the service
# 'with-contenv' provides environment variables from s6
# 'exec' replaces the shell with the application (required for signals)

exec 2>&1  # Redirect stderr to stdout for s6 logging

# Run your application
exec my-application \
  --config /etc/my-app.conf \
  --user tundra \
  --log-level info
```

**3. Optional: Add Finish Script** (runs when service stops)

```bash
# /etc/s6-overlay/s6-rc.d/my-app/finish
#!/command/execlineb -S0
# Cleanup code here (runs when service is stopping)
echo "my-app is stopping..."
```

**4. Optional: Add Timeout Handler**

```bash
# /etc/s6-overlay/s6-rc.d/my-app/timeout-finish
# Timeout in milliseconds before force-killing the service
echo "5000" > /etc/s6-overlay/s6-rc.d/my-app/timeout-finish
```

### Service Examples

#### Example 1: Simple HTTP Server

```dockerfile
FROM tundrasoft/alpine:latest

# Install application
RUN apk add --no-cache nginx

# Create service
RUN mkdir -p /etc/s6-overlay/s6-rc.d/webserver/dependencies.d

RUN echo "longrun" > /etc/s6-overlay/s6-rc.d/webserver/type

RUN cat > /etc/s6-overlay/s6-rc.d/webserver/run << 'EOF'
#!/command/with-contenv bash
exec 2>&1
exec nginx -g "daemon off;"
EOF

RUN chmod +x /etc/s6-overlay/s6-rc.d/webserver/run

RUN touch /etc/s6-overlay/s6-rc.d/webserver/dependencies.d/service-start
RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/webserver
```

#### Example 2: Configuration Builder (Oneshot Service)

```dockerfile
FROM tundrasoft/alpine:latest

# Create oneshot service that generates config
RUN mkdir -p /etc/s6-overlay/s6-rc.d/generate-config/dependencies.d

RUN echo "oneshot" > /etc/s6-overlay/s6-rc.d/generate-config/type

RUN cat > /etc/s6-overlay/s6-rc.d/generate-config/up << 'EOF'
#!/command/with-contenv bash
# This script runs once during boot
# 'up' is used for oneshot services instead of 'run'

envsubst < /etc/my-app.template > /etc/my-app.conf
echo "Generated /etc/my-app.conf with:"
cat /etc/my-app.conf
EOF

RUN chmod +x /etc/s6-overlay/s6-rc.d/generate-config/up

RUN touch /etc/s6-overlay/s6-rc.d/generate-config/dependencies.d/config-start
RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/generate-config
```

#### Example 3: Service with Health Check

```dockerfile
FROM tundrasoft/alpine:latest

# Create service with periodic health check
RUN mkdir -p /etc/s6-overlay/s6-rc.d/app-service/dependencies.d

RUN echo "longrun" > /etc/s6-overlay/s6-rc.d/app-service/type

RUN cat > /etc/s6-overlay/s6-rc.d/app-service/run << 'EOF'
#!/command/with-contenv bash
exec 2>&1
exec my-service --config /etc/my-service.conf
EOF

RUN chmod +x /etc/s6-overlay/s6-rc.d/app-service/run

# Add finish script for graceful shutdown
RUN cat > /etc/s6-overlay/s6-rc.d/app-service/finish << 'EOF'
#!/command/execlineb -S0
# S6 sends TERM, wait a bit, then sends KILL
echo "Shutting down my-service..."
EOF

RUN chmod +x /etc/s6-overlay/s6-rc.d/app-service/finish

RUN touch /etc/s6-overlay/s6-rc.d/app-service/dependencies.d/service-start
RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/app-service
```

---

## ⏰ Cron Jobs

### Dynamic Cron Setup

This image provides dynamic cron job loading with environment variable substitution support:

1. **Create cron files** in the `/crons` directory
2. **Use environment variables** with `$VARIABLE_NAME` syntax
3. **Pass environment variables** when running the container
4. **S6 automatically** loads and installs jobs at startup

The `config-cron` service processes all files in `/crons`, expands environment variables using `envsubst`, and installs them in the `tundra` user's crontab.

### Cron Examples

#### Example 1: Basic Scheduled Task

**File:** `/crons/daily-backup`
```bash
# Run backup at 2 AM daily
0 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1
```

**Run container:**
```bash
docker run -d \
  -v /host/crons:/crons:ro \
  tundrasoft/alpine:latest
```

**Verify:**
```bash
docker exec <container> crontab -l
# Output: 0 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1
```

#### Example 2: Environment Variable Substitution

**File:** `/crons/dynamic-jobs`
```bash
# Schedule from environment variables
$SCHEDULE_BACKUP /home/tundra/backup.sh
$SCHEDULE_CLEANUP /home/tundra/cleanup.sh
$SCHEDULE_HEALTH_CHECK curl http://localhost:8080/health

# Multiple jobs, one with custom schedule
0 */6 * * * /usr/local/bin/sync.sh
```

**Run container:**
```bash
docker run -d \
  -e SCHEDULE_BACKUP='0 2 * * *' \
  -e SCHEDULE_CLEANUP='0 4 * * 0' \
  -e SCHEDULE_HEALTH_CHECK='*/5 * * * *' \
  -v /host/crons:/crons:ro \
  tundrasoft/alpine:latest
```

**Result:**
```bash
docker exec <container> crontab -l
# 0 2 * * * /home/tundra/backup.sh
# 0 4 * * 0 /home/tundra/cleanup.sh
# */5 * * * * curl http://localhost:8080/health
# 0 */6 * * * /usr/local/bin/sync.sh
```

#### Example 3: Complex Configuration

**File:** `/crons/production-jobs`
```bash
# Backup with compression and rotation
$BACKUP_TIME /usr/local/bin/backup.sh --compress --rotate 7 >> /var/log/cron-backup.log 2>&1

# Database maintenance
$DB_MAINTAIN_TIME /usr/local/bin/db-vacuum.sh --analyze >> /var/log/cron-db.log 2>&1

# Log rotation (using logrotate)
$LOG_ROTATE_TIME /usr/sbin/logrotate /etc/logrotate.conf

# Cleanup old files
$CLEANUP_TIME find /var/tmp -type f -mtime +$CLEANUP_DAYS -delete

# Health check with alerting
$HEALTH_CHECK_TIME /usr/local/bin/health-check.sh || mail -s "Alert: Health check failed" admin@example.com
```

**Run container with production settings:**
```bash
docker run -d \
  --name prod-app \
  -e BACKUP_TIME='0 1 * * *' \
  -e DB_MAINTAIN_TIME='0 3 * * 0' \
  -e LOG_ROTATE_TIME='0 0 * * *' \
  -e CLEANUP_TIME='0 4 * * *' \
  -e CLEANUP_DAYS='30' \
  -e HEALTH_CHECK_TIME='*/10 * * * *' \
  -v /data/app/crons:/crons:ro \
  -v /data/app/scripts:/usr/local/bin:ro \
  tundrasoft/alpine:latest
```

### 🔐 Security Best Practices

> ⚠️ **Warning:** Cron files are executed with the `tundra` user privileges. Ensure they come from trusted sources.

#### ✅ Secure Setup

```bash
# Mount from read-only, trusted source
docker run -d \
  -v /secure/trusted/crons:/crons:ro \
  tundrasoft/alpine:latest

# Verify file permissions before mounting
ls -la /secure/trusted/crons/
# drwxr-xr-x - owned by trusted user
# -rw-r--r-- - files not world-writable
```

#### ❌ Insecure Patterns

```bash
# DON'T: Mount /tmp (world-writable)
docker run -d -v /tmp:/crons tundrasoft/alpine:latest

# DON'T: World-writable cron directory
chmod 777 /data/crons
docker run -d -v /data/crons:/crons tundrasoft/alpine:latest

# DON'T: Untrusted scripts in crons
# Any user could modify cron jobs!
```

#### 🛡️ Hardening Tips

```bash
# 1. Use read-only mount
-v /trusted/crons:/crons:ro

# 2. Validate permissions
find /path/to/crons -type f ! -perm 0644 -exec ls -la {} \;
find /path/to/crons -type d ! -perm 0755 -exec ls -la {} \;

# 3. Use restrictive umask in cron files
umask 0077  # Prevent world-readable secrets

# 4. Scan cron files for suspicious content
grep -r 'chmod\|curl.*http\|ssh' /path/to/crons

# 5. Monitor crontab changes
docker exec <container> crontab -l > /var/log/crontab-snapshot.txt
```

---

## 🔧 Building

### 🏗️ Build Command

```bash
docker build \
  --build-arg ALPINE_BRANCH=v3.22 \
  --build-arg S6_VERSION=3.1.6.2 \
  -t my-alpine-image .
```

### ⚙️ Build Arguments

<!-- BUILD-ARGS-START -->
| Argument | Description | Example |
|----------|-------------|---------|
| `ALPINE_BRANCH` | Alpine Linux branch (latest patch version auto-detected) | `v3.22`, `v3.21`, `edge` |
| `S6_VERSION` | S6 Overlay version | `3.1.6.2` |
<!-- BUILD-ARGS-END -->

---

## � Examples

Practical examples are available in the [examples/](examples/) directory:

- **Web Service** ([Dockerfile.web-service](examples/Dockerfile.web-service)): Custom S6 service with HTTP server and health checks
- **Cron Application** ([Dockerfile.cron-app](examples/Dockerfile.cron-app)): Scheduled tasks with logging and volume mounts

See [examples/README.md](examples/README.md) for detailed build/run instructions, debugging tips, and common patterns.

---

## �🔒 Security

This repository implements comprehensive security scanning:

- 🛡️ **Multi-layered scanning** with Trivy, CodeQL, Semgrep, and Grype
- 🔍 **Secret detection** with GitLeaks (runs early in build process)
- 📊 **Automated reporting** to GitHub Security tab
- 🔄 **Daily security scans** and vulnerability monitoring

For security issues, please use [GitHub's private vulnerability reporting](https://github.com/TundraSoft/alpine/security/advisories/new).

---

## 📚 Components

### 🏔️ Alpine Linux
[Alpine Linux](https://alpinelinux.org/) is a security-focused, lightweight Linux distribution (~5MB) based on musl libc and BusyBox. Perfect for containerized applications with minimal resource requirements.

**Key features:**
- Minimal image size (< 10MB base image)
- Security-first design
- Automatic security patches
- Extensive package repository

### 🔧 S6 Overlay
[S6 Overlay](https://github.com/just-containers/s6-overlay) provides an advanced init system and process supervisor for containers.

**Key features:**
- Reliable process supervision and auto-restart
- Sophisticated dependency management between services
- Clean shutdown with configurable timeouts
- Logging integration
- Zero-downtime service reloading

**When to use:**
- Multi-process applications (e.g., web server + worker queue)
- Services requiring specific startup/shutdown order
- Applications needing health checks and auto-recovery

### ⏰ Cron
Full [crond daemon](https://en.wikipedia.org/wiki/Cron) from BusyBox with dynamic job loading and environment variable support.

**Features:**
- Standard cron scheduling (minute, hour, day, month, weekday)
- Environment variable expansion
- Logging to syslog
- Per-user crontabs

### 🔄 envsubst
[GNU gettext envsubst](https://www.gnu.org/software/gettext/manual/gettext.html#envsubst-Invocation) utility for environment variable substitution. Used for template expansion in configuration files and cron jobs.

**Usage:**
```bash
envsubst < template.conf > final.conf
envsubst '$VARIABLE1:$VARIABLE2' < config.tmpl
```

### 🌍 Timezone Support
Complete timezone database (from `tzdata`) with `TZ` environment variable support for easy configuration.

**Usage:**
```bash
docker run -e TZ=America/New_York tundrasoft/alpine:latest
docker run -e TZ=Asia/Tokyo tundrasoft/alpine:latest
```

**Common timezones:**
- `UTC` - Coordinated Universal Time
- `America/New_York` - Eastern Time
- `Europe/London` - Greenwich Mean Time
- `Asia/Tokyo` - Japan Standard Time
- `Australia/Sydney` - Australian Eastern Time

---

## 📖 Reference

### Container Lifecycle

```
1. Image starts (docker run)
   ↓
2. Entrypoint: /init (S6 init)
   ↓
3. Base services start (supervisor)
   ↓
4. Timezone service runs → Sets TZ
   ↓
5. Init-user service runs → Configures tundra user
   ↓
6. os-ready signal sent
   ↓
7. config-start oneshot runs
   ↓
8. config-cron service loads /crons
   ↓
9. config-ready signal sent
   ↓
10. service-start oneshot runs
    ↓
11. User services start (from /etc/s6-overlay/s6-rc.d/user/contents.d/*)
    ↓
12. crond daemon starts
    ↓
13. service-ready signal sent
    ↓
14. Container ready (PID 1 = s6-svscan)
    ↓
15. SIGTERM received → Graceful shutdown
    ↓
16. Services stopped in reverse order
    ↓
17. Container exits
```

### File Structure Reference

```
/
├── /init                          # S6 init system (PID 1)
├── /run/service/                  # Active service directory
├── /etc/s6-overlay/
│   ├── s6-rc.d/                   # Service definitions
│   │   ├── user/
│   │   │   └── contents.d/        # Services to auto-start
│   │   ├── base/
│   │   ├── timezone/
│   │   ├── init-user/
│   │   ├── os-ready/
│   │   ├── config-start/
│   │   ├── config-cron/
│   │   ├── config-ready/
│   │   ├── service-start/
│   │   ├── crond/
│   │   └── service-ready/
│   └── s6-rc
├── /crons/                        # Mount point for cron files
├── /home/tundra/                  # Home directory
└── /var/spool/cron/crontabs/      # Installed crontabs
```

### Environment Variables Reference

**Built-in Variables:**

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `PUID` | int | User ID for `tundra` user | `1000` |
| `PGID` | int | Group ID for `tundra` group | `1000` |
| `TZ` | string | Timezone identifier | `America/New_York` |
| `PATH` | string | Command search path | `/scripts:$PATH` |
| `LANG` | string | Locale setting | `C.UTF-8` |

**S6 Variables (read-only):**

| Variable | Description |
|----------|-------------|
| `S6_CMD_WAIT_FOR_SERVICES_MAXTIME` | Max wait for service startup (0 = no limit) |
| `S6_GLOBAL_PATH` | Search path for commands | 

**Available for Custom Use:**

Any variables prefixed with custom names (e.g., `BACKUP_SCHEDULE`, `APP_CONFIG_URL`) can be used in cron files and templates with `$VARIABLE_NAME` syntax and expanded via `envsubst`.

### S6 Service Definition Files

Each service is a directory with configuration files:

| File | Type | Purpose |
|------|------|---------|
| `type` | file | `longrun` (daemon) or `oneshot` (run-once) |
| `run` | script | Main script for `longrun` services |
| `up` | script | Initialization script for `oneshot` services |
| `finish` | script | Cleanup script when service stops |
| `timeout-finish` | file | Milliseconds to wait before force-kill |
| `dependencies.d/` | dir | Contains dependency file names |
| `notification-fd` | file | File descriptor for readiness notification |

### Common S6 Patterns

**Pattern 1: Oneshot → Longrun Dependency**

```bash
# Service A: generates config (oneshot)
type: oneshot
up: /generate-config.sh
dependencies.d/: [os-ready]

# Service B: uses config (longrun)
type: longrun
run: /start-app.sh
dependencies.d/: [service-a]  # Waits for service-a to complete
```

**Pattern 2: Multiple Services, Single Trigger**

```bash
# Service A (longrun)
dependencies.d/: [service-start]

# Service B (longrun)
dependencies.d/: [service-start]

# Both start after service-start trigger
```

**Pattern 3: Graceful Shutdown**

```bash
# Service definition
type: longrun
run: /usr/bin/myapp
finish: /scripts/shutdown-hook.sh
timeout-finish: 10000  # 10 seconds before SIGKILL
```

### Docker Compose Example

```yaml
version: '3.8'

services:
  app:
    image: tundrasoft/alpine:latest
    container_name: my-app
    environment:
      - TZ=America/New_York
      - PUID=1001
      - PGID=1001
      - BACKUP_TIME='0 2 * * *'
      - CLEANUP_TIME='0 4 * * 0'
    volumes:
      - ./crons:/crons:ro
      - ./scripts:/usr/local/bin:ro
      - app-data:/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Another service depending on the base image
  worker:
    build:
      context: ./worker
      dockerfile: Dockerfile
    depends_on:
      - app
    environment:
      - TZ=America/New_York
      - PUID=1001

volumes:
  app-data:
```

### Troubleshooting Reference

**Issue: Service not starting**

```bash
# Check S6 supervisor status
docker exec <container> s6-svstat /run/service/*

# View service logs
docker logs <container>

# Inspect service definition
docker exec <container> cat /etc/s6-overlay/s6-rc.d/my-service/type
docker exec <container> ls -la /etc/s6-overlay/s6-rc.d/my-service/dependencies.d/
```

**Issue: Cron jobs not running**

```bash
# Verify crontab was loaded
docker exec <container> crontab -l

# Check cron logs
docker exec <container> tail -f /var/log/messages

# Verify file permissions
docker exec <container> ls -la /crons/
```

**Issue: Container exits immediately**

```bash
# Check init system logs
docker run --rm tundrasoft/alpine:latest s6-rc-service-status

# Run with interactive shell
docker run -it --entrypoint /bin/sh tundrasoft/alpine:latest

# Check Dockerfile for issues
docker build --progress=plain .
```

### External Resources

- 📖 [S6 Documentation](https://skarnet.org/software/s6/)
- 📖 [S6-Overlay GitHub](https://github.com/just-containers/s6-overlay)
- 📖 [Alpine Linux Documentation](https://wiki.alpinelinux.org/)
- 📖 [Cron Format Guide](https://crontab.guru/)
- 📖 [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

## 🤝 Contributing

1. 🍴 **Fork** the repository
2. 🌟 **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. 💾 **Commit** changes: `git commit -m 'Add amazing feature'`
4. 📤 **Push** to branch: `git push origin feature/amazing-feature`
5. 🔄 **Open** a Pull Request

### 📋 Issue Templates

- 🐛 **Bug Report**: Report issues with the image
- ✨ **Feature Request**: Suggest improvements
- 🔒 **Security**: Use private vulnerability reporting

---

## 📝 Changelog

This project maintains a comprehensive changelog following [Keep a Changelog](https://keepachangelog.com/) format.

### 📖 View Changelog

- **Full Changelog**: See [CHANGELOG.md](./CHANGELOG.md)
- **Changelog Guide**: Read [CHANGELOG-GUIDE.md](./CHANGELOG-GUIDE.md) for process details

### 🤖 Automatic Updates

The changelog is automatically updated when PRs are merged to `main`:

- Entries are organized by **merge date** (YYYY-MM-DD format)
- Changes are **categorized** automatically (Added, Fixed, Security, etc.)
- Each entry includes PR number, title, and author
- PR titles should be **clear and descriptive** for best results

### ✍️ Writing Good PR Titles

For proper categorization, use conventional commit format:

```
feat: Add new feature description
fix: Fix bug description
docs: Update documentation
security: Security update or patch
chore: Maintenance or refactoring
```

See [CHANGELOG-GUIDE.md](./CHANGELOG-GUIDE.md) for detailed guidelines on maintaining the changelog and PR naming conventions.

---

## 🤝 Contributing

**Built with ❤️ by [TundraSoft](https://github.com/TundraSoft)**

[View on GitHub](https://github.com/TundraSoft/alpine) • [Docker Hub](https://hub.docker.com/r/tundrasoft/alpine) • [Report Issue](https://github.com/TundraSoft/alpine/issues)

</div>