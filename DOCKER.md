# 🏔️ TundraSoft Alpine Base Image

A lightweight, secure Alpine Linux base image with S6 overlay, cron support, and developer-friendly utilities pre-installed.

## 🚀 Quick Start

```bash
# Pull and run
docker pull tundrasoft/alpine:latest
docker run -d --name my-app tundrasoft/alpine:latest

# With custom timezone and user
docker run -d \
  -e TZ=America/New_York \
  -e PUID=1000 \
  -e PGID=1000 \
  --name my-app \
  tundrasoft/alpine:latest
```

## 🏷️ Available Tags

- `latest` - Latest stable Alpine version
- `3.21.x` - Specific Alpine versions
- `edge` - Alpine edge (development)

## ✨ Features

- 🏔️ **Alpine Linux** - Minimal, security-focused
- 🔧 **S6 Overlay** - Advanced init system and process supervisor
- ⏰ **Cron Support** - Built-in cron daemon with dynamic job loading
- 👤 **User Management** - Non-root `tundra` user (UID/GID 1000)
- 🌍 **Timezone Support** - Easy timezone configuration
- 🔄 **Environment Substitution** - Built-in envsubst utility
- 🔒 **Security Focused** - Regular security scans and updates

## 📖 Usage

### Environment Variables

- `TZ` - Set timezone (default: UTC)
- `PUID` - User ID for tundra user (default: 1000)
- `PGID` - Group ID for tundra group (default: 1000)

### Volumes

- `/crons` - Place cron job files here (auto-loaded)
- `/app` - Default working directory

### Cron Jobs

Place cron files in `/crons` directory:

```bash
# Example: /crons/backup
0 2 * * * /usr/local/bin/backup.sh
```

## 🔧 Building Custom Images

```dockerfile
FROM tundrasoft/alpine:latest

# Your application setup
COPY app/ /app/
COPY crons/ /crons/

# Set working directory
WORKDIR /app

# Your CMD or ENTRYPOINT
CMD ["/app/start.sh"]
```

## 🔒 Security

- Multi-layered security scanning (Trivy, CodeQL, Semgrep)
- Daily vulnerability monitoring
- Secret detection with GitLeaks
- Regular Alpine and S6 overlay updates

## 📚 Components

- **Alpine Linux** - Latest stable or edge versions
- **S6 Overlay** - Latest stable version
- **Cron** - Full cron daemon with environment variable support
- **Timezone Data** - Complete timezone database

## 🤝 Support

- [Documentation](https://github.com/TundraSoft/alpine)
- [Issues](https://github.com/TundraSoft/alpine/issues)
- [Security](https://github.com/TundraSoft/alpine/security)

Built with ❤️ by [TundraSoft](https://github.com/TundraSoft)
