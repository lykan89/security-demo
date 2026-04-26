# 🔒 GitHub Actions Security Demo - Complete Setup Guide

## Project Structure

```
security-demo-repo/
├── .github/
│   └── workflows/
│       ├── security.yml              # Primary security scanning pipeline
│       └── advanced-security.yml      # Additional specialized scans
│
├── .eslintrc.json                   # ESLint security rules configuration
├── .gitignore                       # Exclude sensitive files from git
│
├── app.js                           # Vulnerable Node.js application (10 vulns)
├── package.json                     # Node dependencies (intentionally outdated)
├── Dockerfile                       # Vulnerable container config
├── main.tf                          # Vulnerable Terraform/IaC (8 vulns)
│
├── sonar-project.properties         # SonarQube configuration
├── docker-compose.yml               # Local dev environment (app + SonarQube + ZAP)
│
├── README.md                        # Quick start guide
├── SECURITY_GUIDE.md                # Detailed vulnerability explanations (this file)
├── TOP_SECURITY_PLUGINS.md          # Complete GitHub Actions security tools reference
├── REMEDIATION_GUIDE.md             # Step-by-step fixes for all vulnerabilities
└── SETUP.md                         # This file
```

## 📊 What's Included

### Vulnerable Code
- **app.js**: 10 intentional application vulnerabilities
  - SQL Injection (CWE-89)
  - Weak Cryptography (CWE-327)
  - Hardcoded Credentials (CWE-798)
  - Command Injection (CWE-78)
  - Path Traversal (CWE-22)
  - Insecure Deserialization (CWE-502)
  - Missing Security Headers (CWE-693)
  - Insufficient Logging (CWE-778)
  - Broken Access Control/IDOR (CWE-639)
  - Unvalidated Redirects (CWE-601)

- **Dockerfile**: 5 container security issues
  - Untagged base image
  - Running as root
  - Exposed secrets
  - No health check
  - No non-root user

- **main.tf**: 8 infrastructure vulnerabilities
  - Exposed RDS credentials
  - Publicly accessible databases
  - Open security groups
  - Public S3 buckets
  - No encryption
  - Overly permissive IAM
  - Unencrypted state file
  - Missing monitoring

### GitHub Actions Workflows
1. **security.yml** - Comprehensive scanning
   - npm audit (dependencies)
   - SonarQube (SAST)
   - Trivy (container + IaC)
   - TruffleHog (secrets)
   - ESLint (code quality)
   - SBOM generation

2. **advanced-security.yml** - Specialized scans
   - License compliance
   - Supply chain security
   - Snyk scanning
   - DAST (ZAP)
   - Checkov/tfsec (infrastructure)
   - Compliance checks

### Documentation
- **README.md** - Quick start (2-5 min read)
- **SECURITY_GUIDE.md** - Detailed vulnerability breakdown (30+ min read)
- **TOP_SECURITY_PLUGINS.md** - GitHub Actions security tools reference
- **REMEDIATION_GUIDE.md** - Step-by-step fixes

---

## 🚀 Quick Start (5 minutes)

### 1. Clone Repository
```bash
git clone <repo-url>
cd security-demo-repo
```

### 2. Push to GitHub
```bash
git add .
git commit -m "Add security scanning demo"
git push origin main
```

### 3. Watch Workflows
- Go to: **Actions tab** → Select `🔒 Comprehensive Security Scanning`
- Watch real-time execution of security scans

### 4. Review Findings
- Go to: **Security tab** → **Code scanning alerts**
- See vulnerabilities detected by SonarQube, Trivy, etc.

---

## 💻 Local Development (Optional)

### Prerequisites
- Docker & Docker Compose
- Node.js 18+
- Terraform (optional)
- Trivy CLI (optional)

### Setup Local Environment
```bash
# Start all services (app + SonarQube + PostgreSQL + ZAP)
docker-compose up -d

# Wait for services to start (30-60 seconds)
docker-compose logs -f

# Access services:
# - Application: http://localhost:3000
# - SonarQube: http://localhost:9000 (admin/admin)
# - ZAP: http://localhost:8080
# - PostgreSQL: localhost:5432
```

### Run Local Scans
```bash
# npm audit
npm audit

# ESLint with security
npx eslint . --format=json

# Trivy container scan
trivy image vulnerable-app:latest

# Trivy IaC scan
trivy config .

# Trivy filesystem scan
trivy fs .

# Secrets scan
trufflehog filesystem . --json

# SonarQube scan (requires running SonarQube instance)
sonar-scanner \
  -Dsonar.projectKey=vulnerable-demo \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=admin \
  -Dsonar.password=admin
```

### Cleanup
```bash
# Stop all services
docker-compose down

# Remove volumes (state cleanup)
docker-compose down -v
```

---

## 🔧 GitHub Actions Configuration

### Required: Configure GitHub Secrets (Optional but Recommended)

For local SonarQube:
```
Settings → Secrets and variables → Actions → New secret

SONAR_HOST_URL = http://localhost:9000
SONAR_TOKEN = squ_xxxxxxxxxxxxxxxxxxxx
```

For commercial services:
```
SNYK_TOKEN = xxxxxxxxxxxxx
SLACK_WEBHOOK = https://hooks.slack.com/services/...
```

### Required: Update Workflow Secrets
Edit `.github/workflows/security.yml`:
```yaml
env:
  SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL || 'http://localhost:9000' }}
  SONAR_TOKEN: ${{ secrets.SONAR_TOKEN || 'not_set' }}
```

---

## 📚 Learning Progression

### Day 1: Understanding Vulnerabilities (2 hours)
1. Read `README.md` (5 min)
2. Review `SECURITY_GUIDE.md` (45 min)
   - Understand each vulnerability
   - Learn attack patterns
3. Examine source code:
   - `app.js` - Comment explains each vulnerability
   - `Dockerfile` - Container security issues
   - `main.tf` - Infrastructure vulnerabilities

### Day 2: Security Tools (2 hours)
1. Read `TOP_SECURITY_PLUGINS.md` (30 min)
   - Understand each tool
   - Compare capabilities
2. Run GitHub Actions workflows
   - Push code to GitHub
   - Watch workflows execute
   - Review findings in Security tab

### Day 3: Remediation (3 hours)
1. Read `REMEDIATION_GUIDE.md` (60 min)
   - Step-by-step fixes
   - Code examples
   - Best practices
2. Fix vulnerabilities
   - Start with app.js
   - Fix Dockerfile
   - Update Terraform
3. Re-scan and verify fixes

### Day 4: Implementation (1+ days)
1. Apply to your projects
2. Configure workflows
3. Set branch protection rules
4. Integrate with CI/CD
5. Set up monitoring/alerting

---

## 🎯 Key Learning Outcomes

After this exercise, you'll understand:

✅ Real-world vulnerability patterns (10 application, 5 container, 8 infrastructure)  
✅ How to detect them (SAST, DAST, container scanning, secrets detection)  
✅ How to fix them (code examples + best practices)  
✅ How to automate security (GitHub Actions pipelines)  
✅ How to choose tools (when to use Trivy vs SonarQube vs ZAP)  
✅ How to integrate into CI/CD (workflows, gates, notifications)  
✅ How to manage security at scale (compliance, policies, automation)

---

## 🛠️ Customization Guide

### Add More Tools
```yaml
# In .github/workflows/security.yml

- name: Custom security tool
  run: |
    custom-tool scan .
    custom-tool report.json
```

### Configure Severity Levels
```yaml
- uses: aquasecurity/trivy-action@master
  with:
    severity: 'CRITICAL,HIGH'  # Only critical and high
    exit-code: '1'             # Fail on findings
```

### Create Security Gates
```yaml
- name: Check security gate
  run: |
    CRITICAL=$(jq '.metadata.vulnerabilities.critical' npm-audit-report.json)
    if [ "$CRITICAL" -gt 0 ]; then
      echo "❌ Critical vulnerabilities found"
      exit 1
    fi
```

### Auto-Fix Vulnerabilities
```yaml
- name: Auto-fix and push
  run: |
    npm audit fix
    git add package*.json
    git commit -m "fix: security vulnerabilities"
    git push origin HEAD
```

---

## 📊 Expected Workflow Results

When you push this code to GitHub, expect:

### Scan Results (All Finding Severities)
- 🔴 **Critical**: 5 findings (hardcoded secrets, SQL injection, weak crypto)
- 🔴 **High**: 12 findings (open security groups, exposed credentials)
- 🟡 **Medium**: 18 findings (missing headers, insufficient logging)
- 🟢 **Low**: 7 findings (code style, documentation)

### Tools Execution
- ✅ npm audit → Completes in <2 seconds
- ✅ SonarQube → Completes in 30-60 seconds
- ✅ Trivy → Completes in <5 seconds
- ✅ TruffleHog → Completes in 10-15 seconds
- ✅ ESLint → Completes in <2 seconds

### Artifacts Generated
- `npm-audit-report.json` - Dependency vulnerabilities
- `trivy-results.sarif` - Container vulnerabilities
- `trivy-iac-results.sarif` - Infrastructure issues
- `eslint-report.json` - Code quality findings
- `bom.json` - Software bill of materials

---

## 🔗 Integration with External Tools

### Slack Notifications
```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
    text: 'Security scan found ${{ job.status }}'
```

### JIRA Ticket Creation
```yaml
- name: Create JIRA issue
  uses: atlassian/gajira-create@v3
  with:
    project: SEC
    issuetype: Bug
    summary: 'Critical vulnerability detected in CI/CD'
```

### Email Alerts
```yaml
- name: Send email
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    username: ${{ secrets.EMAIL }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: '🚨 Security vulnerabilities detected'
```

---

## ⚠️ Important Reminders

**This project is intentionally vulnerable. Never deploy to production.**

Suitable for:
- ✅ Learning security patterns
- ✅ Understanding security tools
- ✅ Training development teams
- ✅ Testing CI/CD pipelines
- ✅ Demo purposes

Not suitable for:
- ❌ Production deployments
- ❌ Public-facing applications
- ❌ Systems handling real data

---

## 📖 Reference Materials

### CWE (Weakness Database)
- https://cwe.mitre.org/ - 700+ weakness types

### OWASP
- https://owasp.org/www-project-top-ten/ - Top 10 web app risks
- https://owasp.org/www-project-api-security/ - API security

### CVSS (Vulnerability Scoring)
- https://www.first.org/cvss/ - Severity scoring

### GitHub Actions Docs
- https://docs.github.com/en/actions - Official documentation
- https://github.com/actions - Official action templates

### Security Tool Documentation
- **Trivy**: https://aquasecurity.github.io/trivy/
- **SonarQube**: https://docs.sonarqube.org/
- **Snyk**: https://docs.snyk.io/
- **Checkov**: https://www.checkov.io/
- **OWASP ZAP**: https://www.zaproxy.org/

---

## 🎓 Next Steps

1. **Understand Vulnerabilities**
   - Read SECURITY_GUIDE.md thoroughly
   - Understand WHY each is vulnerable
   - Learn exploitation techniques

2. **Explore Tools**
   - Run each scanning tool locally
   - Understand how each detects vulnerabilities
   - Compare tool effectiveness

3. **Practice Remediation**
   - Fix vulnerabilities one by one
   - Re-scan and verify fixes
   - Understand best practices

4. **Implement Security**
   - Copy workflows to your projects
   - Configure for your tech stack
   - Set up notifications and gates

5. **Automate & Scale**
   - Create security policies
   - Implement automated remediation
   - Build security dashboards
   - Train your team

---

## 🤝 Contributing

Improvements welcome! Add:
- [ ] New vulnerability patterns
- [ ] Additional security tools
- [ ] Better detection configurations
- [ ] More remediation examples
- [ ] Language-specific demos
- [ ] Platform-specific examples

---

## 📝 License

MIT - Educational use only

---

## ❓ FAQ

**Q: Can I use this in production?**  
A: No. This project is intentionally vulnerable. It's for learning only.

**Q: Do I need SonarQube?**  
A: No, it's optional. GitHub's CodeQL provides similar SAST capabilities for free.

**Q: Will these tools catch all vulnerabilities?**  
A: No tool catches everything. Use defense in depth (SAST + DAST + container + secrets scanning).

**Q: How do I customize these workflows?**  
A: Edit the YAML files in `.github/workflows/` to add/remove tools or configure differently.

**Q: Can I use different languages?**  
A: Yes! Most tools support multiple languages. Adjust `language` fields in workflows.

**Q: How do I integrate with my existing CI/CD?**  
A: Copy workflow files and adjust for your setup. All tools work with GitHub Actions, Jenkins, GitLab, etc.

---

## 📞 Support

- Check documentation files in repo
- Read tool-specific documentation
- Review GitHub Actions documentation
- Open issues on GitHub

---

**Ready to learn GitHub Actions security? Start with Day 1 and work through the progression!**
