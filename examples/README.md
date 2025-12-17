# 📦 Alpine S6 Examples

Practical examples showing how to build applications on top of the TundraSoft Alpine base image.

## 🌐 Web Service Example

**File:** `Dockerfile.web-service`

A complete web service with S6 supervision and health checks.

### Features
- Runs busybox HTTP server on port 8080
- Custom S6 service with proper supervision
- Health check using curl
- Shows how to integrate services with S6

### Build & Run
```bash
# Build the example
docker build -f examples/Dockerfile.web-service -t my-web-service .

# Run the service
docker run -d -p 8080:8080 --name web my-web-service

# Test the service
curl http://localhost:8080

# View health status
docker ps  # Check STATUS column

# View logs
docker logs web

# Cleanup
docker stop web && docker rm web
```

### Key Concepts
- **S6 Services**: How to add custom services in `/etc/s6-overlay/s6-rc.d/`
- **Service Dependencies**: Making services part of `user/contents.d` for automatic startup
- **Health Checks**: Using HEALTHCHECK with the service
- **Supervision**: S6 automatically restarts failed services

---

## ⏰ Cron Application Example

**File:** `Dockerfile.cron-app`

An application that runs scheduled cron jobs with logging.

### Features
- Runs scheduled tasks every minute
- Logs to `/var/log/cron.log`
- Shows environment variable-based cron setup
- Health check validates cron daemon is running

### Build & Run
```bash
# Build the example
docker build -f examples/Dockerfile.cron-app -t my-cron-app .

# Run the application
docker run -d --name cron my-cron-app

# View cron logs
docker exec cron tail -f /var/log/cron.log

# View health status
docker ps  # Check STATUS column

# Cleanup
docker stop cron && docker rm cron
```

### Cron Configuration Methods

#### Method 1: Environment Variables (Simplest)
```dockerfile
ENV CRON_JOB_1="*/5 * * * * /app/backup.sh"
ENV CRON_JOB_2="0 2 * * * /app/cleanup.sh"
```

#### Method 2: Volume Mount (Recommended for Complex)
```bash
# Create cron files
mkdir -p ./my-crons
echo "*/1 * * * * /app/job.sh" > ./my-crons/task.sh
echo "TZ=Asia/Kolkata" > ./my-crons/15min.env

# Run with volume
docker run -d -v ./my-crons:/crons --name cron my-cron-app
```

#### Method 3: Baked Into Image
Copy cron scripts directly in the Dockerfile (as shown in example).

### Key Concepts
- **Cron Daemon**: Automatically started by base image
- **Logging**: Write to `/var/log/cron.log` for persistence
- **Volumes**: Use `/crons` for configuration, `/var/log` for logs
- **Supervision**: S6 restarts crond if it crashes

---

## 🚀 Quick Start Template

Use this template to build your own application:

```dockerfile
FROM tundrasoft/alpine:latest

# Install your dependencies
RUN apk add --no-cache your-packages

# Copy application code
COPY app/ /app/

# Set working directory
WORKDIR /app

# Option A: Add S6 service
# (See web-service example)

# Option B: Add cron job
# (See cron-app example)

# Option C: Simple application
# (Just inherit /init entrypoint and let S6 manage the base services)

EXPOSE 8000
```

---

## 📚 Tips & Tricks

### Debugging S6 Services
```bash
# Exec into running container
docker exec -it container-name sh

# Check running services
s6-svstat /run/service/*

# View service logs
ls -la /run/s6-overlay/env/container-name/

# Test service startup manually
/etc/s6-overlay/s6-rc.d/your-service/run
```

### Debugging Cron
```bash
# View cron logs
docker logs container-name
tail -f /var/log/cron.log

# List active crons
crontab -l

# Test cron syntax
crontab -T

# Run cron job manually
/path/to/job.sh
```

### Environment Variables
```bash
# These are always available in S6 services:
# - TZ: Timezone (set at runtime)
# - PUID: User ID (default 1000)
# - PGID: Group ID (default 1000)

# Pass custom variables at runtime
docker run -e MY_VAR=value my-image
```

### Volumes & Persistence
```bash
# Mount configuration
docker run -v ./config:/etc/myapp my-image

# Mount logs
docker run -v ./logs:/var/log my-image

# Mount cron jobs
docker run -v ./crons:/crons my-image
```

---

## 🔗 Resources

- [S6 Overlay Documentation](https://skarnet.org/software/s6/overview.html)
- [Alpine Linux Packages](https://pkgs.alpinelinux.org/)
- [Crontab Format](https://en.wikipedia.org/wiki/Cron)
- [Base Image README](../README.md)

---

## ❓ Common Issues

### "Service not starting"
1. Check service run script has correct shebang: `#!/command/execlineb -P`
2. Verify script is executable: `chmod +x /etc/s6-overlay/s6-rc.d/service/run`
3. Check logs: `docker logs container-name`

### "Cron jobs not running"
1. Verify syntax: `crontab -T < /path/to/crontab`
2. Check permissions on script: `chmod +x /app/job.sh`
3. View logs: `tail -f /var/log/cron.log`

### "Container exits immediately"
1. Check for startup errors: `docker logs container-name`
2. Verify base image runs successfully: `docker run tundrasoft/alpine /bin/sh`
3. Review service configuration

---
