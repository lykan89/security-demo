# 🔒 GitHub Actions Security & CI/CD Hardening Demo

**Production-Grade Security Scanning in GitHub Actions**

A hands-on, intentionally vulnerable project demonstrating:
- Real-world security vulnerabilities across application, container, and infrastructure layers
- Industry-standard detection tools (SonarQube, Trivy, TruffleHog, npm audit)
- Complete GitHub Actions security scanning pipeline
- Remediation and hardening strategies

---

## 🎯 Quick Start

### 1. Clone and Explore
```bash
git clone <repo>
cd security-demo-repo
```

### 2. Understand the Vulnerabilities
- **app.js** - 10 application vulnerabilities (SQL injection, XSS, weak crypto, hardcoded secrets)
- **Dockerfile** - 5 container security issues (root user, untagged images, exposed secrets)
- **main.tf** - 8 infrastructure vulnerabilities (open security groups, exposed credentials, no encryption)

### 3. Run Local Scans (Optional)
```bash
# Setup Node
npm install

# Run npm audit
npm audit

# Run ESLint with security plugin
npm install --save-dev eslint eslint-plugin-security
npx eslint . --format=json

# Run Trivy on Dockerfile
trivy config Dockerfile
trivy config main.tf
```

### 4. Push to GitHub
```bash
git add .
git commit -m "Add security scanning demo"
git push origin main
```

### 5. Watch GitHub Actions
- Go to Actions tab
- Select `🔒 Comprehensive Security Scanning` workflow
- Watch real-time security scanning

---

## 📊 What Gets Scanned

| Layer | Tool | Vulnerabilities Detected |
|-------|------|--------------------------|
| **Application Code** | SonarQube, ESLint | SQL injection, XSS, weak crypto, hardcoded secrets, IDOR, path traversal |
| **Dependencies** | npm audit, Snyk | Known vulnerable packages, supply chain risks |
| **Container Images** | Trivy | CVEs in base images, OS vulnerabilities, misconfigurations |
| **Infrastructure** | Trivy, Checkov, tfsec | Open security groups, exposed credentials, unencrypted storage |
| **Secrets** | TruffleHog, GitLeaks | Hardcoded API keys, passwords, tokens, private keys |
| **Code Quality** | SonarQube, ESLint | Code smells, maintainability, security anti-patterns |

---

## 🛡️ Top Security Tools Used

### Tier 1: Critical (Use All)
1. **Trivy** - Container + IaC scanning (30+ CIS checks)
2. **SonarQube** - Application SAST (300+ security rules)
3. **TruffleHog** - Secrets detection (3000+ patterns)
4. **npm audit** - Dependency vulnerabilities
5. **CodeQL** - Semantic code analysis

### Tier 2: High-Value
6. **Snyk** - Comprehensive vulnerability management
7. **Checkov** - IaC policy enforcement (1000+ checks)
8. **GitLeaks** - Lightweight secrets scanning
9. **ZAP Baseline** - DAST (runtime web app scanning)
10. **tfsec** - Terraform security audit

---

## 📚 Learning Path

1. **Read SECURITY_GUIDE.md** - Understand each vulnerability
2. **Examine app.js** - Learn application attack patterns
3. **Review Dockerfile** - Container security best practices
4. **Study main.tf** - Infrastructure hardening
5. **Run workflows** - See detection in action
6. **Fix vulnerabilities** - Implement remediation
7. **Verify fixes** - Re-scan and confirm

---

## 🚀 Workflows

### Workflow 1: `security.yml`
- **Trigger**: Push, PR, daily schedule
- **Scans**:
  - npm audit (dependencies)
  - SonarQube (application code)
  - Trivy (containers + IaC)
  - TruffleHog (secrets)
  - ESLint (code quality)
  - SBOM generation

### Workflow 2: `advanced-security.yml`
- **Trigger**: Push, PR
- **Additional Scans**:
  - License compliance
  - Supply chain analysis
  - DAST (runtime scanning)
  - Permissions audit
  - Infrastructure hardening
  - Compliance checks (PCI, OWASP)

---

## 📋 Intentional Vulnerabilities

### Application (10)
- [ ] SQL Injection (CWE-89)
- [ ] Weak Cryptography (CWE-327)
- [ ] Hardcoded Credentials (CWE-798)
- [ ] Command Injection (CWE-78)
- [ ] Path Traversal (CWE-22)
- [ ] Insecure Deserialization (CWE-502)
- [ ] Missing Security Headers (CWE-693)
- [ ] Insufficient Logging (CWE-778)
- [ ] Broken Access Control (CWE-639)
- [ ] Unvalidated Redirects (CWE-601)

### Container (5)
- [ ] Untagged base image
- [ ] Running as root
- [ ] Exposed secrets in ENV
- [ ] No health check
- [ ] No non-root user

### Infrastructure (8)
- [ ] Hardcoded RDS password
- [ ] Publicly accessible database
- [ ] Open security groups
- [ ] Public S3 bucket
- [ ] No database encryption
- [ ] Overly permissive IAM
- [ ] Unencrypted state file
- [ ] No monitoring/logging

---

## 🔧 Configuration

### GitHub Secrets Required (Optional)
```bash
SONAR_HOST_URL = http://localhost:9000  # Local SonarQube
SONAR_TOKEN = squ_xxxxxxxxxxxx
SNYK_TOKEN = xxxxxxxxxxxx
```

### Local SonarQube Setup
```bash
docker run -d --name sonarqube -p 9000:9000 sonarqube:community
# Access at http://localhost:9000
# Default: admin/admin
```

---

## 📊 Expected Findings

When workflows run, expect to see:
- **Critical**: 5 findings (hardcoded secrets, SQL injection)
- **High**: 12 findings (weak crypto, open SGs, exposed credentials)
- **Medium**: 18 findings (code smells, missing headers)
- **Low**: 7 findings (logging gaps, style issues)

---

## ✅ Next Steps for Your Projects

1. **Copy workflows** to your repositories
2. **Configure secrets** for SonarQube, Snyk, etc.
3. **Set branch protection** rules (require security checks)
4. **Enable auto-remediation** for dependencies
5. **Set up notifications** (Slack, email, JIRA)
6. **Create security gates** (block on critical vulns)
7. **Automate fixes** (auto-commit security patches)

---

## 📖 References

- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **CWE List**: https://cwe.mitre.org/
- **CVSS Scoring**: https://www.first.org/cvss/
- **GitHub Actions**: https://docs.github.com/en/actions
- **Trivy**: https://aquasecurity.github.io/trivy/
- **SonarQube**: https://docs.sonarqube.org/
- **AWS Security**: https://aws.amazon.com/security/

---

## ⚠️ Important Notes

**This project is intentionally vulnerable. Never deploy to production.**

Used for:
- ✅ Learning security patterns
- ✅ Understanding tool capabilities
- ✅ Training engineers
- ✅ Testing CI/CD pipelines
- ✅ Demo purposes only

---

## 📝 License

MIT - Educational use only

---

## 🤝 Contributing

Improvements and additional vulnerabilities welcome! Submit PRs with:
- New vulnerability patterns
- Additional security tools
- Better detection configurations
- Remediation examples
