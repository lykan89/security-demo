# 🏆 Top-Value GitHub Actions Security Plugins

Complete reference guide for industry-standard security tools in GitHub Actions.

---

## TIER 1: CRITICAL (Implement All)

### 1. 🐳 **Trivy** - Container & IaC Scanner
**Repository**: `aquasecurity/trivy-action`  
**Purpose**: Fast, accurate vulnerability scanning for containers, Kubernetes, Terraform, CloudFormation  
**Coverage**: CVEs, misconfigurations, secrets, OS packages  
**Speed**: <5 seconds for typical images  

**Usage**:
```yaml
- uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'image'
    image-ref: 'myapp:latest'
    format: 'sarif'
    output: 'trivy-results.sarif'
    severity: 'CRITICAL,HIGH'
    exit-code: '1'

# For IaC (Terraform/CloudFormation)
- uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'config'
    scan-ref: '.'
    format: 'sarif'
```

**Why Critical**: 
- Catches 80% of infrastructure vulnerabilities
- 0 false positives (database-backed)
- Blocks supply chain attacks (malicious base images)
- Free, open-source, industry standard

**Detection**: Base image vulnerabilities, misconfigurations, exposed ports, overly permissive rules

---

### 2. 🔬 **SonarQube** - SAST (Static Analysis)
**Repository**: `SonarSource/sonarqube-scan-action`  
**Purpose**: Comprehensive static code analysis for security & quality  
**Coverage**: 300+ security rules, 200+ code smells  
**Languages**: JavaScript, Python, Java, C#, Go, C/C++, TypeScript, etc.  

**Usage**:
```yaml
- uses: SonarSource/sonarqube-scan-action@master
  env:
    SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  with:
    args: >
      -Dsonar.projectKey=my-project
      -Dsonar.sources=src/
      -Dsonar.exclusions=**/node_modules/**

- uses: SonarSource/sonarqube-quality-gate-action@master
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

**Why Critical**:
- Catches 70% of application vulnerabilities pre-deploy
- Most comprehensive ruleset (300+ security patterns)
- Integrates with quality gates (blocks merges)
- Community Edition free forever
- Enterprise option for advanced features

**Detection**: SQL injection, XSS, weak crypto, hardcoded secrets, IDOR, path traversal, deserialization, race conditions

---

### 3. 🔐 **TruffleHog** - Secrets Detection
**Repository**: `trufflesecurity/trufflehog`  
**Purpose**: Find secrets, API keys, tokens in codebase  
**Detection**: 3000+ secret patterns (AWS, GitHub, Stripe, private keys, OAuth, etc.)  
**Speed**: Scans full git history  

**Usage**:
```yaml
- uses: trufflesecurity/trufflehog@main
  with:
    path: ./
    base: main
    head: HEAD
    extra_args: --json

# Advanced: Custom patterns
- with:
    path: ./
    base: main
    head: HEAD
    extra_args: >
      --debug
      --json
      --max-depth=3
```

**Why Critical**:
- Prevents credential leaks to public repositories
- Scans entire git history (catches stale secrets)
- 3000+ built-in patterns (comprehensive)
- Can prevent security incidents before they happen
- Enterprise: Verifies which credentials are still active

**Detection**: AWS keys, GitHub tokens, Slack webhooks, private keys, database passwords, API keys, OAuth tokens

---

### 4. 📦 **npm audit** - Dependency Scanning
**Built-in to npm**  
**Purpose**: Identify known vulnerabilities in npm packages  
**Coverage**: CVE database, severity levels (critical, high, moderate, low)  

**Usage**:
```yaml
- name: Run npm audit
  run: npm audit --json > npm-audit.json

- name: Check for vulnerabilities
  run: npm audit --audit-level=moderate

- name: Auto-fix vulnerabilities
  run: npm audit fix

# Force fix (major versions)
- run: npm audit fix --force
```

**Why Critical**:
- Fastest vulnerability detection (milliseconds)
- Database of 1M+ known vulnerabilities
- Built into npm (no setup)
- Standard in all Node.js projects
- Can auto-fix (npm audit fix)

**Detection**: Known vulnerable npm packages, outdated versions, supply chain risks

---

### 5. 📊 **CodeQL (GitHub's Advanced Security)**
**Repository**: `github/codeql-action`  
**Purpose**: Semantic code analysis engine (free with GitHub)  
**Coverage**: 300+ security patterns  
**Languages**: JavaScript, Python, Java, C#, C/C++, Go, Ruby  

**Usage**:
```yaml
- uses: github/codeql-action/init@v2
  with:
    languages: javascript

- uses: github/codeql-action/autobuild@v2

- uses: github/codeql-action/analyze@v2
  with:
    category: "code-scanning"
```

**Why Critical**:
- Free with GitHub (no license cost)
- Integrates natively into security tab
- Semantic analysis (not regex-based)
- 300+ rules covering OWASP Top 10
- Automatic configuration

**Detection**: SQL injection, XSS, use-after-free, race conditions, OS command injection, pointer-dereference

---

## TIER 2: HIGH-VALUE (Use for Production Apps)

### 6. 🔍 **Snyk** - Comprehensive Vulnerability Management
**Repository**: `snyk/actions/node`, `snyk/actions/docker`  
**Purpose**: Dependencies + containers + IaC (all in one)  
**Commercial**: Paid, but fast vulnerability disclosure  
**SLA**: Vulnerabilities reported before public disclosure  

**Usage**:
```yaml
- uses: snyk/actions/node@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    args: --severity-threshold=high

# Auto-generate fix PRs
- uses: snyk/actions/python-3.9@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    command: monitor
```

**Why High-Value**:
- Comprehensive (dependencies + container + IaC)
- Faster disclosure (SLA-based)
- Auto-generates fix PRs (remediation)
- Enterprise: Advanced features (policies, gates)
- Good for mission-critical apps

**Detection**: Same as npm audit + container + IaC + advanced behavioral detection

---

### 7. 🏗️ **Checkov** - IaC Policy Enforcement
**Repository**: `bridgecrewio/checkov-action`  
**Purpose**: Terraform, CloudFormation, Kubernetes security policies  
**Coverage**: 1000+ policies (CIS benchmarks, AWS best practices)  

**Usage**:
```yaml
- uses: bridgecrewio/checkov-action@master
  with:
    directory: .
    framework: terraform,kubernetes,dockerfile
    output_format: sarif
    output_file_path: report.sarif
    soft_fail: false
    quiet: false
    check: 'CKV_AWS_34'  # Specific check
```

**Why High-Value**:
- 1000+ policies (most comprehensive for IaC)
- CIS benchmarks built-in
- Cloud-agnostic (AWS, Azure, GCP, Kubernetes)
- SARIF output (GitHub integration)
- Very configurable

**Detection**: Open security groups, exposed credentials, unencrypted storage, overly permissive IAM, missing logging

---

### 8. 🔑 **GitLeaks** - Lightweight Secrets Scanning
**Repository**: `gitleaks/gitleaks-action`  
**Purpose**: Alternative to TruffleHog (faster, simpler)  
**Detection**: 140+ secret patterns  

**Usage**:
```yaml
- uses: gitleaks/gitleaks-action@v2
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

# Custom config
- uses: gitleaks/gitleaks-action@v2
  with:
    config-path: .gitleaks.toml
```

**Why High-Value**:
- Minimal configuration needed
- Very fast (optimized)
- Good for getting started
- Can use custom rules
- Good balance of detection vs false positives

**Detection**: AWS keys, GitHub tokens, Slack webhooks, private keys, passwords, API keys

---

### 9. 🧪 **OWASP ZAP Baseline** - DAST (Runtime Testing)
**Repository**: `zaproxy/action-baseline`  
**Purpose**: Dynamic testing against running web application  
**Coverage**: XSS, SQL injection, CSRF, SSL issues (at runtime)  

**Usage**:
```yaml
- name: Start application
  run: npm start &

- uses: zaproxy/action-baseline@v0.7.0
  with:
    target: 'http://localhost:3000'
    rules_file_name: '.zap/rules.tsv'
    cmd_options: '-a'
    allow_issue_writing: false

# Advanced with config
- uses: zaproxy/action-full-scan@v0.4.0
  with:
    target: 'https://example.com'
    rules_file_name: '.zap/rules.tsv'
    cmd_options: '-a'
```

**Why High-Value**:
- Catches runtime vulnerabilities (static analysis misses)
- Tests actual application behavior
- Can find logic flaws
- Integration testing + security testing
- OWASP maintained (trusted)

**Detection**: XSS, CSRF, SQL injection (at runtime), insecure cookies, missing headers, SSL/TLS issues, URL redirection

---

### 10. 🔧 **tfsec** - Terraform Security Audit
**Repository**: `aquasecurity/tfsec-action`  
**Purpose**: Terraform-specific security checks  
**Coverage**: 500+ security best practices  
**Speed**: <2 seconds for typical Terraform  

**Usage**:
```yaml
- uses: aquasecurity/tfsec-action@v1.0.0
  with:
    working_directory: '.'
    version: v1.28.0
    args: '--format sarif --out tfsec-results.sarif'

# With custom config
- uses: aquasecurity/tfsec-action@v1.0.0
  with:
    working_directory: 'terraform/'
    tfsec_args: '--custom-check-dir /custom-checks'
```

**Why High-Value**:
- Terraform-specific (better than generic IaC)
- 500+ checks (comprehensive)
- Very fast (<2s)
- AWS, Azure, GCP, Kubernetes
- Simple to configure

**Detection**: Hard-coded credentials, insecure defaults, missing encryption, overly permissive access, unencrypted data

---

## TIER 3: SPECIALIZED (Use as Needed)

| Tool | Repository | Purpose | Best For |
|------|-----------|---------|----------|
| **Dependabot** | Built-in GitHub | Auto-updates dependencies | Continuous security |
| **SARIF Upload** | `github/codeql-action` | Aggregates scan results | Unified view of all findings |
| **Super-Linter** | `github/super-linter` | Multi-language linting | Code quality across languages |
| **Scorecards** | `ossf/scorecard-action` | Supply chain security | OSS projects, SLSA compliance |
| **CycloneDX** | `CycloneDX/gh-node-module-generatebom` | SBOM generation | Compliance, audits, license tracking |
| **License Checker** | npm-license-checker | License compliance | Legal risk management |
| **Docker Scout** | Built-in Docker | Image scanning | Docker-native scanning |
| **Prowler** | `prowler-cloud/prowler` | AWS/Azure audit | Cloud compliance (CIS, PCI, HIPAA) |
| **CloudSploit** | Custom GitHub Action | AWS security | AWS-specific resource audit |
| **Terrascan** | `tenable/terrascan` | IaC scanning | Generic IaC (Terraform, K8s, etc.) |
| **Hadolint** | `hadolint/hadolint-action` | Dockerfile linting | Container build best practices |
| **Grype** | `anchore/grype-action` | Vulnerability DB | Container vulnerability scanning |

---

## 📊 Comparison Matrix

| Tool | Cost | Speed | Accuracy | Language Support | Easy Setup |
|------|------|-------|----------|-----------------|-----------|
| Trivy | Free | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Multi | ⭐⭐⭐⭐⭐ |
| SonarQube | Free (CE) | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Multi | ⭐⭐⭐ |
| TruffleHog | Free | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | N/A | ⭐⭐⭐⭐ |
| npm audit | Free | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | JS only | ⭐⭐⭐⭐⭐ |
| CodeQL | Free | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Multi | ⭐⭐⭐ |
| Snyk | Paid | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Multi | ⭐⭐⭐⭐ |
| Checkov | Free | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | IaC | ⭐⭐⭐⭐ |
| GitLeaks | Free | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | N/A | ⭐⭐⭐⭐⭐ |
| ZAP | Free | ⭐⭐⭐ | ⭐⭐⭐⭐ | N/A (runtime) | ⭐⭐⭐ |
| tfsec | Free | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | TF only | ⭐⭐⭐⭐⭐ |

---

## 🔗 Integration Patterns

### Pattern 1: Fail on Critical
```yaml
- name: Check critical vulnerabilities
  run: |
    if grep '"severity":"CRITICAL"' results.json > /dev/null; then
      echo "❌ Critical vulnerabilities found"
      exit 1
    fi
```

### Pattern 2: Auto-Remediate
```yaml
- name: Auto-fix vulnerabilities
  run: |
    npm audit fix
    git add package*.json
    git commit -m "fix: security vulnerabilities"
    git push origin $GITHUB_HEAD_REF
```

### Pattern 3: Create Issues
```yaml
- name: Create security issue
  uses: actions/github-script@v7
  if: failure()
  with:
    script: |
      github.rest.issues.create({
        owner: context.repo.owner,
        repo: context.repo.repo,
        title: '🚨 Security vulnerabilities detected',
        body: 'Critical security findings in CI/CD scan'
      })
```

### Pattern 4: Notify Team
```yaml
- name: Send Slack notification
  uses: 8398a7/action-slack@v3
  if: always()
  with:
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
    text: 'Security scan: ${{ job.status }}'
```

---

## 🎯 Implementation Checklist

- [ ] Enable Trivy for container scanning
- [ ] Set up SonarQube (cloud or local)
- [ ] Add TruffleHog for secrets detection
- [ ] Configure npm audit in pipeline
- [ ] Enable GitHub Code Scanning (CodeQL)
- [ ] Add branch protection rules
- [ ] Set up Slack notifications
- [ ] Create security issue templates
- [ ] Document remediation workflow
- [ ] Train team on security tools
- [ ] Establish SLA for vulnerability fixes
- [ ] Automate dependency updates
- [ ] Create security dashboard
- [ ] Audit tool configurations monthly
- [ ] Review and update security policies

---

## 📚 Resources

- **GitHub Actions Documentation**: https://docs.github.com/en/actions
- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **CWE/CVSS**: https://cwe.mitre.org/, https://www.first.org/cvss/
- **Tool Documentation**:
  - Trivy: https://aquasecurity.github.io/trivy/
  - SonarQube: https://docs.sonarqube.org/
  - Snyk: https://docs.snyk.io/
  - Checkov: https://www.checkov.io/
