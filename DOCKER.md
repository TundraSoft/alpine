# Alpine Docker Image

A lightweight, secur### Build Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| `ALPINE_BRANCH` | Alpine Linux branch (latest patch version auto-detected) | `v3.22`, `v3.21`, `edge` |
| `S6_VERSION` | S6 Overlay version | `3.1.6.2` |ne Linux base image with S6 overlay, cron support, and developer-friendly utilities pre-installed.

[![Docker Pulls](https://img.shields.io/docker/pulls/tundrasoft/alpine.svg?logo=docker)](https://hub.docker.com/r/tundrasoft/alpine)
[![GitHub](https://img.shields.io/github/license/TundraSoft/alpine.svg)](https://github.com/TundraSoft/alpine)

## 📋 Quick Links

- � [Documentation](https://github.com/TundraSoft/alpine)
- � [Issues](https://github.com/TundraSoft/alpine/issues)
- � [Security](https://github.com/TundraSoft/alpine/security)

## � Quick Start

```bash
# Pull and run
docker pull TundraSoft/alpine:latest
docker run -d --name my-app TundraSoft/alpine:latest
```

## 🏷️ Available Tags

- [`latest`](https://hub.docker.com/r/tundrasoft/alpine/tags?name=latest) - Latest stable release
- [`edge`](https://hub.docker.com/r/tundrasoft/alpine/tags?name=edge) - Alpine edge (development branch)

### Stable Versions

- [`3.22.0`](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.22.0), [`3.22`](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.22) - Alpine 3.22.x
- [`3.21.3`](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.21.3), [`3.21`](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.21) - Alpine 3.21.x  
- [`3.20.6`](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.20.6), [`3.20`](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.20) - Alpine 3.20.x
- [`3.19.1`](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.19.1), [`3.19`](https://hub.docker.com/r/tundrasoft/alpine/tags?name=3.19) - Alpine 3.19.x

## 📖 Usage

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PUID` | User ID for the `tundra` user | `1000` |
| `PGID` | Group ID for the `tundra` group | `1000` |
| `TZ` | Timezone (e.g., `Asia/Kolkata`, `America/New_York`) | `UTC` |

### Build Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| `ALPINE_BRANCH` | Alpine Linux branch (version automatically detected) | `v3.22`, `v3.21`, `edge` |
| `S6_VERSION` | S6 Overlay version | `3.1.6.2` |

## 🔧 Building Custom Images

```dockerfile
FROM TundraSoft/alpine:latest

# Install additional packages
RUN apk add --no-cache your-package

# Copy your application
COPY app/ /app/

# Set working directory
WORKDIR /app

# Your application startup
CMD ["/app/start.sh"]
```

## 🤝 Support & Contributing

- 📖 **Documentation**: [GitHub Repository](https://github.com/TundraSoft/alpine)
- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/TundraSoft/alpine/issues)
- 🔒 **Security Issues**: [Private Vulnerability Reporting](https://github.com/TundraSoft/alpine/security)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/TundraSoft/alpine/discussions)

---

<div align="center">

**Built with ❤️ by [TundraSoft](https://github.com/TundraSoft)**

[View on GitHub](https://github.com/TundraSoft/alpine) • [Docker Hub](https://hub.docker.com/r/tundrasoft/alpine) • [Report Issue](https://github.com/TundraSoft/alpine/issues)

</div>
