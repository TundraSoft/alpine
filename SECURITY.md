# Security

## 🔒 Our commitment to security

We take security seriously. This repository implements comprehensive, automated security scanning to protect against vulnerabilities, secrets exposure, and security threats. Our multi-layered security approach includes container scanning, code analysis, dependency checking, and continuous monitoring.

We strive to keep every version updated with the latest security patches, however, it becomes quite chaotic and problematic to do so. Our primary focus is always on the latest version as typically these patches are available readily for the latest version.

**Security is everyone's responsibility.** We encourage all contributors to:
- Report security issues responsibly using GitHub's private vulnerability reporting
- Review security scan results before merging pull requests  
- Keep dependencies updated and follow security best practices
- Never commit secrets, passwords, or sensitive information

For critical security vulnerabilities, please use GitHub's private vulnerability reporting feature.

---

## Automated tools used

### 1. Trivy (Container & Dependency Scanner)
- **Purpose**: Scans Docker images and filesystems for vulnerabilities
- **Coverage**: Container images, dependencies, OS packages
- **Runs**: After build completion, on-demand (manual trigger), and daily
- **Results**: Available in GitHub Security tab

### 2. CodeQL (Code Security Analysis)
- **Purpose**: Identifies security vulnerabilities in code
- **Coverage**: JavaScript, Python, and other supported languages
- **Runs**: After build completion, on-demand (manual trigger), and daily
- **Results**: Available in GitHub Security tab

### 3. GitLeaks (Secret Scanner)
- **Purpose**: Detects secrets, passwords, and API keys
- **Coverage**: Git history, current files, commits
- **Runs**: Early in build workflow (as backup) and on manual/scheduled security scans
- **Results**: Fails build if secrets found

### 4. Grype (Vulnerability Scanner)
- **Purpose**: Alternative container vulnerability scanner
- **Coverage**: Container images, OS packages
- **Runs**: After build completion, on-demand (manual trigger), and daily
- **Results**: Available in GitHub Security tab

### 5. Semgrep (SAST Scanner)
- **Purpose**: Static Application Security Testing
- **Coverage**: Security patterns, code quality, secrets
- **Runs**: After build completion, on-demand (manual trigger), and daily
- **Results**: Available in GitHub Security tab

### 6. Licensee (License Compliance)
- **Purpose**: Detects and validates open source licenses
- **Coverage**: Project licenses, dependency licenses
- **Runs**: After build completion, on-demand (manual trigger), and daily
- **Results**: Available in workflow summary
