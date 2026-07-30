# Contributing to TundraSoft Docker Images

Thank you for your interest in contributing to our Docker image projects! We welcome contributions from the community and appreciate your help in making our images better.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Reporting Issues](#reporting-issues)
- [Suggesting Features](#suggesting-features)
- [Security Issues](#security-issues)
- [Code Standards](#code-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)
- [Code of Conduct](#code-of-conduct)

---

## Getting Started

### Prerequisites

- **Docker** (latest stable version)
- **Git** for version control
- **Basic knowledge** of Dockerfiles and containerization
- **Understanding** of the base technology (Alpine, Ubuntu, etc.)

### Quick Start

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create** a feature branch
4. **Make** your changes
5. **Test** thoroughly
6. **Submit** a pull request

---

## Development Setup

### Local Development

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/REPO_NAME.git
cd REPO_NAME

# Add upstream remote
git remote add upstream https://github.com/TundraSoft/REPO_NAME.git

# Create a feature branch
git checkout -b feature/your-feature-name

# Build the image locally
docker build -t local-test .

# Test the image
docker run --rm -it local-test
```

### Environment Setup

- Use latest stable Docker version
- Ensure sufficient disk space for image builds
- Consider using Docker BuildKit for enhanced build features

---

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

- **Bug fixes** - Fix issues in existing functionality
- **Feature additions** - Add new capabilities
- **Documentation** - Improve or add documentation
- **Tests** - Add or improve test coverage
- **Build improvements** - Optimize Dockerfiles or build process
- **Security** - Security enhancements and fixes
- **Cleanup** - Code cleanup, refactoring, or optimization

### Workflow

1. **Check existing issues** before starting work
2. **Open an issue** to discuss major changes
3. **Fork and branch** from the main branch
4. **Make focused commits** with clear messages
5. **Test thoroughly** before submitting
6. **Update documentation** as needed
7. **Submit a pull request** with detailed description

---

## Reporting Issues

### Before Reporting

- **Search existing issues** to avoid duplicates
- **Test with latest version** to ensure issue persists
- **Gather relevant information** (OS, Docker version, etc.)

### Issue Template

When reporting issues, please include:

```markdown
**Issue Type**: Bug/Feature Request/Question

**Description**: Clear description of the issue

**Environment**:
- OS: (e.g., Ubuntu 22.04, macOS 13, Windows 11)
- Docker Version: (docker --version)
- Image Tag: (e.g., latest, 3.22.0)

**Steps to Reproduce**:
1. Step one
2. Step two
3. Step three

**Expected Behavior**: What should happen

**Actual Behavior**: What actually happens

**Additional Context**:
- Error messages
- Logs
- Screenshots (if applicable)
```

---

## Suggesting Features

### Feature Requests

- **Be specific** about the use case
- **Explain the problem** the feature would solve
- **Consider alternatives** and mention them
- **Provide examples** or mockups if applicable

### Enhancement Process

1. **Open a feature request** issue
2. **Discuss with maintainers** and community
3. **Wait for approval** before starting work
4. **Follow the development workflow**

---

## Security Issues

### Reporting Security Vulnerabilities

 **Do NOT open public issues for security vulnerabilities!**

Instead:
- Use [GitHub's private vulnerability reporting](../../security/advisories/new)
- Email security-related issues to maintainers
- Provide detailed information about the vulnerability
- Allow time for assessment and fix before public disclosure

### Security Best Practices

- Always scan images for vulnerabilities
- Keep base images updated
- Follow principle of least privilege
- Avoid including sensitive information in images
- Use multi-stage builds to minimize attack surface

---

## Code Standards

### Dockerfile Guidelines

```dockerfile
# Use specific base image versions
FROM alpine:3.22.0

# Group related RUN commands to minimize layers
RUN apk update && \
    apk add --no-cache \
        package1 \
        package2 && \
    rm -rf /var/cache/apk/*

# Use meaningful labels
LABEL maintainer="TundraSoft" \
      version="1.0.0" \
      description="Brief description"

# Create non-root user
RUN addgroup -g 1000 appgroup && \
    adduser -D -u 1000 -G appgroup appuser

# Set proper permissions
COPY --chown=appuser:appgroup files/ /app/

# Use explicit COPY instead of ADD when possible
COPY requirements.txt /app/

# Expose only necessary ports
EXPOSE 8080

# Use exec form for ENTRYPOINT and CMD
ENTRYPOINT ["./entrypoint.sh"]
CMD ["--default-option"]
```

### Shell Script Guidelines

```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Use meaningful variable names
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="/etc/myapp/config.yml"

# Function documentation
# Description: Does something useful
# Arguments: $1 - input parameter
# Returns: 0 on success, 1 on failure
function do_something() {
    local input="$1"

    if [[ -z "$input" ]]; then
        echo "Error: Input parameter required" >&2
        return 1
    fi

    echo "Processing: $input"
    return 0
}

# Error handling
if ! do_something "$1"; then
    echo "Error: Failed to process input" >&2
    exit 1
fi
```

---

## Testing

### Required Tests

Before submitting PRs, ensure:

- **Image builds successfully** on multiple architectures
- **Container starts and runs** without errors
- **All services function** as expected
- **Environment variables** work correctly
- **Volume mounts** function properly
- **Network connectivity** works as designed
- **Security scans** pass without critical issues

### Testing Commands

```bash
# Build test
docker build -t test-image .

# Basic functionality test
docker run --rm test-image --version

# Interactive test
docker run --rm -it test-image /bin/sh

# Service test (if applicable)
docker run -d --name test-container test-image
docker exec test-container ps aux
docker logs test-container
docker stop test-container

# Multi-architecture test (if supported)
docker buildx build --platform linux/amd64,linux/arm64 .
```

---

## Documentation

### Documentation Requirements

- **Update README.md** for new features
- **Update CHANGELOG.md** with changes
- **Update version tags** in documentation
- **Add inline comments** for complex logic
- **Document new environment variables**
- **Update docker-compose examples** if applicable

### Documentation Style

- Use clear, concise language
- Provide practical examples
- Include code snippets for complex procedures
- Use consistent formatting and structure
- Test all documented procedures

---

## Pull Request Process

### Before Submitting

- Ensure your fork is up to date with upstream
- Rebase your branch on latest main
- Test thoroughly on your local environment
- Update documentation as needed
- Ensure CI/CD checks pass

### PR Description Template

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that causes existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Refactoring (no functional changes)

## Testing
- [ ] Tested locally
- [ ] Image builds successfully
- [ ] Container runs without errors
- [ ] All features work as expected
- [ ] Documentation updated

## Screenshots (if applicable)

## Related Issues
Fixes #(issue number)

## Additional Notes
Any additional information or context.
```

### Review Process

1. **Automated checks** must pass (CI/CD, security scans)
2. **Code review** by maintainers
3. **Testing** in various environments
4. **Documentation review**
5. **Final approval** and merge

---

## Code of Conduct

### Our Standards

- **Be respectful** and inclusive
- **Communicate constructively**
- **Focus on project goals**
- **Welcome newcomers**
- **Share knowledge freely**

### Unacceptable Behavior

- Harassment or discrimination
- Offensive language or imagery
- Personal attacks
- Spam or off-topic discussions

### Enforcement

Instances of unacceptable behavior may result in:
- Warning
- Temporary suspension
- Permanent ban from the project

Report issues to project maintainers.

---

## Recognition

Contributors who help improve our Docker images are recognized in:
- **CHANGELOG.md** for their contributions
- **GitHub contributors** section
- **Release notes** for significant contributions

---

## Contact

- **GitHub Issues**: For bugs and feature requests
- **Discussions**: For questions and community chat
- **Security**: Use private vulnerability reporting
- **Email**: For private matters

---

<div align="center">

**Thank you for contributing to TundraSoft Docker Images!**

</div>
