# Alpine Docker Image

A lightweight, secure Alpine Linux base image with S6 overlay, cron support, and developer-friendly utilities pre-installed.

[![Docker Pulls](https://img.shields.io/docker/pulls/TundraSoft/alpine.svg?logo=docker)](https://hub.docker.com/r/TundraSoft/alpine)
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

- [`latest`](https://hub.docker.com/r/TundraSoft/alpine/tags?name=latest) - Latest stable release (3.22.0)

### Stable Versions

- [`3.22.0`](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.22.0) - Alpine 3.22.0
- [`3.22`](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.22) - Latest Alpine 3.22.x
- [`3.21.3`](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.21.3) - Alpine 3.21.3
- [`3.21`](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.21) - Latest Alpine 3.21.x
- [`3.20.6`](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.20.6) - Alpine 3.20.6
- [`3.20`](https://hub.docker.com/r/TundraSoft/alpine/tags?name=3.20) - Latest Alpine 3.20.x

### Development Versions

- [`edge`](https://hub.docker.com/r/TundraSoft/alpine/tags?name=edge) - Alpine edge (development branch)

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
| `ALPINE_VERSION` | Alpine Linux version | `3.22.0` |
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

[View on GitHub](https://github.com/TundraSoft/alpine) • [Docker Hub](https://hub.docker.com/r/TundraSoft/alpine) • [Report Issue](https://github.com/TundraSoft/alpine/issues)

</div>
