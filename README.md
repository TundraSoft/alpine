# 🏔️ TundraSoft Alpine Base Image

A lightweight, secure Alpine Linux base image with S6 overlay, cron support, and developer-friendly utilities pre-installed.

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/TundraSoft/alpine/build-docker.yml?event=push&logo=github&label=build)](https://github.com/TundraSoft/alpine/actions/workflows/build-docker.yml)
[![Security Scan](https://img.shields.io/github/actions/workflow/status/TundraSoft/alpine/security-scan.yml?event=schedule&logo=shield&label=security)](https://github.com/TundraSoft/alpine/actions/workflows/security-scan.yml)
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
- [⏰ Cron Jobs](#-cron-jobs)
- [🔧 Building](#-building)
- [🔒 Security](#-security)
- [📚 Components](#-components)
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
## Tags

| Version | Tags |
|---------|------|
| [latest](https://hub.docker.com/r/TundraSoft/alpine/tags?name=latest) | Latest stable release |
| [edge](https://hub.docker.com/r/TundraSoft/alpine/tags?name=edge) | Edge/development version |
| [3.22](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.22) | [3.22.0](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.22.0) |
| [3.21](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.21) | [3.21.3](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.21.3) |
| [3.20](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.20) | [3.20.6](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.20.6) |
| [3.19](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.19) | [3.19.1](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.19.1), [3.19.0](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.19.0) |
| [3.18](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.18) | [3.18.6](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.18.6), [3.18.5](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.18.5), [3.18.4](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.18.4) |

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
FROM tundrasoft/alpine:3.22
# or
FROM ghcr.io/tundrasoft/alpine:3.22
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PUID` | User ID for the `tundra` user | `1000` |
| `PGID` | Group ID for the `tundra` group | `1000` |
| `TZ` | Timezone (e.g., `Asia/Kolkata`, `America/New_York`) | `UTC` |

### Volumes

| Path | Description |
|------|-------------|
| `/crons` | Directory for cron job files (automatically loaded) |

---

## ⚙️ Service Management

This image uses [S6 Overlay](https://github.com/just-containers/s6-overlay) for advanced process supervision and service management.

### 🎯 Service Triggers

S6 provides dependency management through trigger points. Use these recommended triggers in your derived images:

| Trigger | Description |
|---------|-------------|
| `os-ready` | Container booted, basic setup complete (timezone, user/group) |
| `config-start` | Start configuration changes (triggered after `os-ready`) |
| `config-ready` | Configuration complete (cron setup dependency) |
| `service-start` | Begin service initialization |
| `service-ready` | All services initialized |

### 📋 Built-in Services

| Service | Purpose | Dependencies |
|---------|---------|--------------|
| `timezone` | Sets timezone from `TZ` env var | None |
| `init-user` | Configures user/group IDs | None |
| `config-cron` | Loads cron jobs from `/crons` | `config-start` |
| `crond` | Starts cron daemon | `service-start`, `config-cron` |

### 💡 Example: Adding Custom Services

```bash
# Create service directory
mkdir -p /etc/s6-overlay/s6-rc.d/my-service

# Service type
echo "longrun" > /etc/s6-overlay/s6-rc.d/my-service/type

# Service script
cat > /etc/s6-overlay/s6-rc.d/my-service/run << 'EOF'
#!/command/with-contenv bash
exec my-application --config /etc/my-app.conf
EOF

# Dependencies
mkdir -p /etc/s6-overlay/s6-rc.d/my-service/dependencies.d
touch /etc/s6-overlay/s6-rc.d/my-service/dependencies.d/service-start

# Add to user bundle
mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d
touch /etc/s6-overlay/s6-rc.d/user/contents.d/my-service
```

---

## ⏰ Cron Jobs

### 🚀 Dynamic Cron Setup

Create cron jobs with environment variable substitution:

1. **Create cron file** in `/crons/` directory
2. **Use variables** that will be replaced by `envsubst`
3. **Set environment variables** when running container

### 📝 Example

**Cron file:** `/crons/backup`
```bash
$BACKUP_SCHEDULE /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1
$CLEANUP_SCHEDULE find /tmp -type f -mtime +7 -delete
```

**Run container:**
```bash
docker run -d \
  -e BACKUP_SCHEDULE='0 2 * * *' \
  -e CLEANUP_SCHEDULE='0 4 * * 0' \
  -v /host/crons:/crons \
  tundrasoft/alpine:latest
```

**Result:**
```bash
# docker exec container crontab -l
0 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1
0 4 * * 0 find /tmp -type f -mtime +7 -delete
```

### 🔒 Security Best Practices

> ⚠️ **Warning:** Only mount trusted cron files to prevent privilege escalation.

✅ **Secure:**
```bash
docker run -v /secure/path/crons:/crons tundrasoft/alpine:latest
```

❌ **Insecure:**
```bash
docker run -v /tmp:/crons tundrasoft/alpine:latest  # /tmp is world-writable!
```

---

## 🔧 Building

### 🏗️ Build Command

```bash
docker build \
  --build-arg ALPINE_VERSION=3.22.0 \
  --build-arg S6_VERSION=3.1.6.2 \
  -t my-alpine-image .
```

### ⚙️ Build Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| `ALPINE_VERSION` | Alpine Linux version | `3.22.0` |
| `S6_VERSION` | S6 Overlay version | `3.1.6.2` |

---

## 🔒 Security

This repository implements comprehensive security scanning:

- 🛡️ **Multi-layered scanning** with Trivy, CodeQL, Semgrep, and Grype
- 🔍 **Secret detection** with GitLeaks (runs early in build process)
- 📊 **Automated reporting** to GitHub Security tab
- 🔄 **Daily security scans** and vulnerability monitoring

For security issues, please use [GitHub's private vulnerability reporting](https://github.com/TundraSoft/alpine/security/advisories/new).

---

## 📚 Components

### 🏔️ Alpine Linux
Minimal, security-focused Linux distribution with small footprint.

### 🔧 S6 Overlay
Advanced init system and process supervisor for containers. Provides:
- Service dependency management
- Process supervision and restart
- Clean shutdown handling

### ⏰ Cron
Full cron daemon with dynamic job loading and environment variable substitution.

### 🔄 envsubst
GNU gettext utility for environment variable substitution in configuration files.

### 🌍 Timezone Support
Full timezone database with easy configuration via `TZ` environment variable.

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

<div align="center">

**Built with ❤️ by [TundraSoft](https://github.com/TundraSoft)**

[View on GitHub](https://github.com/TundraSoft/alpine) • [Docker Hub](https://hub.docker.com/r/tundrasoft/alpine) • [Report Issue](https://github.com/TundraSoft/alpine/issues)

</div>