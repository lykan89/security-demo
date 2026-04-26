# 🔒 GitHub Actions Security & CI/CD Hardening Guide

## Overview

This repository is an **intentionally vulnerable demo** project designed to teach:
1. Real security vulnerabilities and their patterns
2. How GitHub Actions detects them using industry tools
3. How to implement comprehensive security scanning
4. How to remediate and hardening best practices

**WARNING**: This project contains security vulnerabilities by design. Never deploy this code to production.

---

## Part 1: Understanding the Vulnerabilities

### Application Vulnerabilities (app.js)

#### 1. SQL Injection (CWE-89)
```javascript
const query = `SELECT * FROM users WHERE id = '${userId}'`;  // VULNERABLE
```
**Attack**: User sends `' OR '1'='1` bypassing authentication
**Tool Detection**: SonarQube, ESLint with security plugins
**Fix**: Use parameterized queries
```javascript
const query = db.prepare('SELECT * FROM users WHERE id = ?').get(userId);
```

#### 2. Weak Cryptography (CWE-327)
```javascript
crypto.createHash('md5').update(password).digest('hex');  // BROKEN
```
**Attack**: Rainbow tables, precomputed hash lookups
**Tool Detection**: SonarQube, npmAudit
**Fix**: Use bcrypt with salt
```javascript
const bcrypt = require('bcryptjs');
const hash = await bcrypt.hash(password, 10);
```

#### 3. Hardcoded Credentials (CWE-798)
```javascript
const API_KEY = "sk-prod-1a2b3c4d5e6f7g8h9i0j";
const DB_PASSWORD = "admin123!@#";
```
**Attack**: Credentials extracted from source code, git history
**Tool Detection**: TruffleHog, GitLeaks, Snyk
**Fix**: Use environment variables and GitHub Secrets
```javascript
const API_KEY = process.env.API_KEY;  // Loaded from GitHub Secrets
```

#### 4. Command Injection (CWE-78)
```javascript
exec(`ping -c 4 ${host}`);  // VULNERABLE
```
**Attack**: User sends `8.8.8.8; rm -rf /`
**Tool Detection**: SonarQube, Snyk
**Fix**: Input validation and exec with array
```javascript
const { execFile } = require('child_process');
execFile('ping', ['-c', '4', host]);  // Safer - no shell
```

#### 5. Path Traversal (CWE-22)
```javascript
const filepath = path.join('/uploads', filename);  // VULNERABLE
fs.readFileSync(filepath);
```
**Attack**: User sends `../../etc/passwd`
**Tool Detection**: SonarQube, Snyk
**Fix**: Validate and normalize
```javascript
const resolved = path.resolve('/uploads', filename);
if (!resolved.startsWith('/uploads')) throw new Error('Invalid path');
```

#### 6. Insecure Deserialization (CWE-502)
```javascript
eval(`(${data})`);  // RCE VULNERABILITY
```
**Attack**: Arbitrary code execution
**Tool Detection**: SonarQube, all SAST tools
**Fix**: JSON.parse with validation
```javascript
const obj = JSON.parse(data);  // Type-safe
```

#### 7. Missing Security Headers (CWE-693)
```javascript
res.send('<html>...</html>');  // Missing headers
```
**Attack**: XSS, clickjacking, MIME-sniffing
**Tool Detection**: DAST (ZAP), runtime checks
**Fix**: Use Helmet middleware
```javascript
const helmet = require('helmet');
app.use(helmet());  // Adds security headers
```

#### 8. Insufficient Logging (CWE-778)
```javascript
app.post('/login', (req, res) => {
  // No logging of authentication attempts
  // No rate limiting
  // No security event recording
});
```
**Attack**: Undetected brute force, account takeover
**Tool Detection**: Manual code review, SAST
**Fix**: Implement logging and rate limiting
```javascript
const rateLimit = require('express-rate-limit');
const loginLimiter = rateLimit({ windowMs: 15*60*1000, max: 5 });
app.post('/login', loginLimiter, (req, res) => {
  logger.security(`Login attempt: ${username}`);
});
```

#### 9. Insecure Direct Object References (CWE-639)
```javascript
app.get('/profile/:userId', (req, res) => {
  // No authorization check
  res.json(profiles[userId]);
});
```
**Attack**: User accesses other users' data by guessing IDs
**Tool Detection**: DAST, manual review
**Fix**: Implement access control
```javascript
if (req.user.id !== userId && !req.user.isAdmin) {
  return res.status(403).send('Forbidden');
}
```

#### 10. Unvalidated Redirects (CWE-601)
```javascript
res.redirect(req.query.url);  // VULNERABLE
```
**Attack**: Phishing via trusted domain redirect
**Tool Detection**: SonarQube
**Fix**: Whitelist URLs
```javascript
const allowedDomains = ['example.com', 'trusted.com'];
const url = new URL(redirectUrl);
if (!allowedDomains.includes(url.hostname)) {
  return res.status(400).send('Invalid redirect');
}
```

---

### Container Vulnerabilities (Dockerfile)

#### Issues:
1. **Untagged base image** - `node:14` pulls latest, no reproducibility
2. **Running as root** - Container compromise = full system access
3. **Secrets in ENV** - Visible in `docker history`
4. **No health check** - Undetected service failures
5. **No non-root user** - Privilege escalation risk

#### Detected by:
- **Trivy**: Container vulnerability scanner
- **Snyk Container**: Supply chain risks
- **Docker Scout**: Built-in image analysis

---

### Infrastructure Vulnerabilities (main.tf)

#### 1. Exposed RDS Credentials (CWE-798)
```hcl
password = "SuperSecretPassword123!@#"  # HARDCODED
publicly_accessible = true              # EXPOSED TO WORLD
storage_encrypted = false               # NO ENCRYPTION
```
**Tool Detection**: Trivy, Checkov, tfsec, Snyk IaC
**Fix**: Use AWS Secrets Manager + Terraform state encryption

#### 2. Open Security Groups (CWE-732)
```hcl
ingress {
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # OPEN TO WORLD
}
```
**Tool Detection**: Trivy, Checkov, CloudSploit
**Fix**: Restrict to specific IPs/security groups

#### 3. Public S3 Bucket (CWE-732)
```hcl
acl = "public-read"  # ANYONE CAN READ
```
**Tool Detection**: Trivy, Checkov, ScoutSuite, CloudMapper
**Fix**: Use private ACL + bucket policies

#### 4. Overly Permissive IAM (CWE-284)
```hcl
policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
```
**Tool Detection**: Trivy, CloudSploit, Snyk IaC
**Fix**: Implement least privilege

#### 5. No State Encryption
```hcl
backend "s3" {
  encrypt = true                    # MISSING
  dynamodb_table = "tf-locks"       # MISSING
}
```
**Tool Detection**: Checkov, tfsec
**Fix**: Enable encryption and state locking

---

## Part 2: GitHub Actions Security Tools

### ⭐ TOP-VALUE SECURITY PLUGINS FOR GITHUB ACTIONS

#### **TIER 1: CRITICAL (Use All)**

##### 1. **Trivy (aquasecurity/trivy-action)**
- **Purpose**: Container and IaC vulnerability scanning
- **Covers**: Docker images, Kubernetes, Terraform, CloudFormation, Helm
- **Severity**: Detects CVEs with CVSS scores
- **Speed**: Fast (<5 seconds for images)
- **SBOM**: Generates software bill of materials
```yaml
- uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'myapp:latest'
    format: 'sarif'
    output: 'trivy-results.sarif'
```
**Why**: Industry standard, covers 80% of infrastructure risks

---

##### 2. **SonarQube (SonarSource/sonarqube-scan-action)**
- **Purpose**: SAST (Static Application Security Testing)
- **Covers**: SQL injection, XSS, crypto, hardcoded secrets, code smells
- **Languages**: JS, Python, Java, C#, Go, C/C++, etc.
- **Community Edition**: Free and open-source
- **Enterprise**: Advanced rules, gate enforcement
```yaml
- uses: SonarSource/sonarqube-scan-action@master
  env:
    SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```
**Why**: Catches 70% of application vulnerabilities before runtime

---

##### 3. **TruffleHog (trufflesecurity/trufflehog)**
- **Purpose**: Secrets detection (credentials, API keys, tokens)
- **Detection**: 3000+ secret patterns including:
  - AWS keys, GitHub tokens, Stripe API keys
  - Private keys, database credentials
  - OAuth tokens, Slack webhooks
```yaml
- uses: trufflesecurity/trufflehog@main
  with:
    path: ./
    base: main
    head: HEAD
```
**Why**: Prevents credential leaks to public repos

---

##### 4. **npm audit (Built-in)**
- **Purpose**: Dependency vulnerability scanning
- **Covers**: Known vulnerabilities in npm packages
- **Speed**: <2 seconds
- **Severity Levels**: Critical, High, Moderate, Low
```yaml
- run: npm audit --audit-level=moderate
```
**Why**: Catches known vulnerable packages

---

##### 5. **GitHub Code Scanning (github/codeql-action)**
- **Purpose**: CodeQL engine - semantic code analysis
- **Covers**: JS, Python, Java, C#, C/C++, Go, Ruby
- **Rules**: 300+ security patterns
- **Integration**: Native GitHub security tab
```yaml
- uses: github/codeql-action/analyze@v2
```
**Why**: Free with GitHub, integrates into UI naturally

---

#### **TIER 2: HIGH-VALUE (Use for Critical Apps)**

##### 6. **Snyk (snyk/actions/node)**
- **Purpose**: Dependencies + container + IaC vulnerabilities
- **SLA**: Faster vulnerability disclosure
- **Commercial**: Paid but excellent
- **Fix**: Auto-generates fix PRs
```yaml
- uses: snyk/actions/node@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```
**Why**: Comprehensive + automatic remediation

---

##### 7. **Checkov (bridgecrewio/checkov-action)**
- **Purpose**: IaC scanning (Terraform, CloudFormation, Kubernetes)
- **Coverage**: 1000+ policies for CIS benchmarks
- **Severity**: HIGH/MEDIUM/LOW
```yaml
- uses: bridgecrewio/checkov-action@master
  with:
    framework: terraform
```
**Why**: Best for AWS/Azure/GCP infrastructure

---

##### 8. **GitLeaks (gitleaks/gitleaks-action)**
- **Purpose**: Secrets scanning (alternative to TruffleHog)
- **Detection**: 140+ secret patterns
- **Speed**: Very fast
```yaml
- uses: gitleaks/gitleaks-action@v2
```
**Why**: Minimal config, good for getting started

---

##### 9. **OWASP ZAP (zaproxy/action-baseline)**
- **Purpose**: DAST (Dynamic Application Security Testing)
- **Covers**: Web app runtime vulnerabilities
- **Scans**: XSS, CSRF, SQLi at runtime
- **Baseline**: Runs against live app
```yaml
- uses: zaproxy/action-baseline@v0.7.0
  with:
    target: 'http://localhost:3000'
```
**Why**: Catches runtime vulnerabilities

---

##### 10. **tfsec (aquasecurity/tfsec-action)**
- **Purpose**: Terraform static analysis
- **Checks**: 500+ security best practices
- **Speed**: <2 seconds
```yaml
- uses: aquasecurity/tfsec-action@v1.0.0
  with:
    working_directory: '.'
```
**Why**: Terraform-specific, no learning curve

---

#### **TIER 3: SPECIALIZED (Use as Needed)**

| Tool | Purpose | Best For |
|------|---------|----------|
| **Dependabot** | Auto-updates vulnerable deps | Continuous security |
| **Super-Linter** | Multi-language linting | Code quality enforcement |
| **SARIF Upload** | Aggregates results to GitHub | Unified security tab |
| **Scorecards** | Supply chain security | OSS projects |
| **CycloneDX** | SBOM generation | Compliance & audits |
| **License Checker** | License compliance | Legal risk management |
| **Docker Scout** | Built-in image scanning | Container security |
| **CloudSploit** | AWS security auditing | Cloud resource review |
| **Prowler** | AWS/Azure security audit | Compliance (CIS, PCI) |

---

## Part 3: How to Run This Demo

### Step 1: Set Up Local SonarQube (Optional but Recommended)

```bash
# Using Docker
docker run -d --name sonarqube -p 9000:9000 sonarqube:community

# Access at http://localhost:9000
# Default credentials: admin/admin

# Generate token in UI and add to GitHub:
# Settings → Developer settings → Personal access tokens
```

### Step 2: Configure GitHub Secrets

```bash
# Go to: Repository → Settings → Secrets and variables → Actions

# Required secrets:
SONAR_HOST_URL=http://localhost:9000
SONAR_TOKEN=squ_xxxxxxxxxxxxxxxxxxxx
SNYK_TOKEN=xxxxxxxxxxxxxxxxxxxx
```

### Step 3: Push to GitHub

```bash
git add .
git commit -m "Add security scanning demo"
git push origin main
```

### Step 4: Watch Workflows Run

```
Actions tab → Select workflow → Watch scans execute
```

### Step 5: Review Results

- **Security Tab** → View all detected vulnerabilities
- **Artifacts** → Download detailed reports
- **Pull Request Comments** → Security feedback on PR

---

## Part 4: Remediation Guide

### Fix Application Code

```bash
# 1. Replace md5 with bcrypt
npm install bcryptjs

# 2. Use parameterized queries
npm install pg

# 3. Add security middleware
npm install helmet express-rate-limit

# 4. Validate inputs
npm install joi yup

# 5. Scan with npm audit
npm audit fix
npm audit fix --force  # For major version changes
```

### Fix Dockerfile

```dockerfile
FROM node:18-alpine
RUN apk add --no-cache tini
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY --from=builder /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .
USER nodejs
HEALTHCHECK --interval=30s CMD node healthcheck.js
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "app.js"]
```

### Fix Terraform

```hcl
# 1. Use AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "rds-password"
}

# 2. Reference secret in RDS
resource "aws_db_instance" "secure_db" {
  password = random_password.db.result
  storage_encrypted = true
  publicly_accessible = false
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
}

# 3. Encrypt state
terraform {
  backend "s3" {
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# 4. Restrict security groups
ingress {
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  security_groups = [aws_security_group.app.id]
}
```

---

## Part 5: Best Practices

### 1. Shift Left Security
- Scan in development (pre-commit hooks)
- Fail fast in CI (block on critical)
- Automate remediation

### 2. Defense in Depth
- Never rely on single tool
- Use SAST + DAST + container scanning
- Add secrets scanning + dependency checking

### 3. Supply Chain Security
- Pin container base image versions
- Lock npm versions with npm-shrinkwrap.json
- Verify package signatures (npm audit signatures)

### 4. Secret Management
- Use GitHub Secrets for API keys
- Rotate credentials regularly
- Never commit .env files
- Use AWS Secrets Manager for production

### 5. Access Control
- Implement least privilege in IAM
- Use GitHub OIDC for AWS access (no long-lived keys)
- Audit GitHub Actions permissions

### 6. Monitoring & Alerting
- Set branch protection rules
- Require security checks to pass
- Auto-open issues for high-severity findings
- Send Slack notifications on critical vulns

---

## Part 6: Advanced Configuration

### Enforce Security Gates

```yaml
# Fail workflow if vulnerabilities found
- name: Check security gate
  run: |
    CRITICAL=$(jq '.metadata.vulnerabilities.critical' npm-audit-report.json)
    if [ "$CRITICAL" -gt 0 ]; then
      echo "❌ Critical vulnerabilities found"
      exit 1
    fi
```

### Auto-Remediate Pull Requests

```yaml
- name: Auto-fix vulnerabilities
  run: |
    npm audit fix
    git config user.email "security-bot@example.com"
    git add package*.json
    git commit -m "fix: security vulnerabilities"
    git push
```

### Create Security Report Dashboard

```yaml
- name: Generate HTML report
  run: |
    cat > report.html << 'EOF'
    <html>
    <h1>Security Scan Report</h1>
    <!-- Embed SARIF, Trivy, SonarQube results -->
    </html>
```

---

## Part 7: Integration with Other Tools

### Slack Notifications
```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Security scan: ${{ job.status }}'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Jira Ticket Creation
```yaml
- name: Create JIRA issue
  uses: atlassian/gajira-create@v3
  with:
    project: SEC
    issuetype: Bug
    summary: 'Critical vulnerability detected'
```

### Email Alerts
```yaml
- name: Send email
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: '🚨 Security vulnerabilities detected'
```

---

## Conclusion

This demo provides:
- ✅ Hands-on vulnerability patterns
- ✅ Real security tools in GitHub Actions
- ✅ Practical remediation examples
- ✅ Production-ready configurations

**Next Steps:**
1. Understand each vulnerability deeply
2. Run tools and observe detection
3. Implement fixes
4. Automate scanning in your projects
5. Build security into your culture

---

## References

- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **CWE/CVSS**: https://cwe.mitre.org/, https://www.first.org/cvss/
- **Trivy Docs**: https://aquasecurity.github.io/trivy/
- **SonarQube**: https://docs.sonarqube.org/
- **GitHub Actions**: https://docs.github.com/en/actions
- **Terraform Security**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
