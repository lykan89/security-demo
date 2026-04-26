# 🔧 Vulnerability Remediation Guide

Step-by-step fixes for all intentional vulnerabilities in this demo project.

---

## Application Code (app.js)

### Fix 1: SQL Injection → Use Parameterized Queries

**Vulnerable Code:**
```javascript
const query = `SELECT * FROM users WHERE id = '${userId}'`;
exec(query);
```

**Fixed Code:**
```javascript
const db = require('better-sqlite3')('users.db');
const stmt = db.prepare('SELECT * FROM users WHERE id = ?');
const user = stmt.get(userId);
```

**Tools**: `npm install better-sqlite3`

---

### Fix 2: MD5 Hashing → Use Bcrypt with Salt

**Vulnerable Code:**
```javascript
crypto.createHash('md5').update(password).digest('hex');
```

**Fixed Code:**
```javascript
const bcrypt = require('bcryptjs');

async function hashPassword(password) {
  const salt = await bcrypt.genSalt(10);  // 10 rounds
  return await bcrypt.hash(password, salt);
}

async function verifyPassword(password, hash) {
  return await bcrypt.compare(password, hash);
}
```

**Tools**: `npm install bcryptjs`

---

### Fix 3: Hardcoded Credentials → Use Environment Variables

**Vulnerable Code:**
```javascript
const API_KEY = "sk-prod-1a2b3c4d5e6f7g8h9i0j";
const DB_PASSWORD = "admin123!@#";
```

**Fixed Code:**
```javascript
// .env file (never commit to repo)
API_KEY=sk-prod-1a2b3c4d5e6f7g8h9i0j
DB_PASSWORD=admin123!@#

// In code
require('dotenv').config();
const API_KEY = process.env.API_KEY;
const DB_PASSWORD = process.env.DB_PASSWORD;

if (!API_KEY || !DB_PASSWORD) {
  throw new Error('Missing required environment variables');
}
```

**In GitHub Actions:**
```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
  DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
```

**Tools**: `npm install dotenv`

---

### Fix 4: Command Injection → Use execFile (No Shell)

**Vulnerable Code:**
```javascript
exec(`ping -c 4 ${host}`);
```

**Fixed Code:**
```javascript
const { execFile } = require('child_process');
const { promisify } = require('util');
const execFileAsync = promisify(execFile);

// Validate input first
const ipv4Regex = /^(\d{1,3}\.){3}\d{1,3}$/;
if (!ipv4Regex.test(host)) {
  throw new Error('Invalid IP address');
}

try {
  const { stdout } = await execFileAsync('ping', ['-c', '4', host]);
  res.json({ output: stdout });
} catch (error) {
  res.status(400).json({ error: 'Ping failed' });
}
```

---

### Fix 5: Path Traversal → Validate and Normalize Paths

**Vulnerable Code:**
```javascript
const filepath = path.join('/uploads', filename);
const content = fs.readFileSync(filepath, 'utf8');
```

**Fixed Code:**
```javascript
app.get('/file', (req, res) => {
  const filename = req.query.name;
  
  // Whitelist allowed filenames
  const allowedFiles = ['readme.txt', 'config.json'];
  if (!allowedFiles.includes(filename)) {
    return res.status(400).json({ error: 'Invalid filename' });
  }
  
  // Resolve and validate path
  const basePath = path.resolve('/uploads');
  const filepath = path.resolve('/uploads', filename);
  
  // Ensure path is within base directory
  if (!filepath.startsWith(basePath)) {
    return res.status(403).json({ error: 'Access denied' });
  }
  
  try {
    const content = fs.readFileSync(filepath, 'utf8');
    res.send(content);
  } catch (error) {
    res.status(404).json({ error: 'File not found' });
  }
});
```

---

### Fix 6: Insecure Deserialization → Use JSON.parse

**Vulnerable Code:**
```javascript
const obj = eval(`(${data})`);  // RCE VULNERABILITY
```

**Fixed Code:**
```javascript
app.post('/deserialize', (req, res) => {
  try {
    // JSON.parse is type-safe
    const obj = JSON.parse(req.body.data);
    
    // Validate object structure
    if (!obj.name || typeof obj.name !== 'string') {
      return res.status(400).json({ error: 'Invalid data' });
    }
    
    res.json(obj);
  } catch (error) {
    res.status(400).json({ error: 'Invalid JSON' });
  }
});
```

---

### Fix 7: Missing Security Headers → Use Helmet Middleware

**Vulnerable Code:**
```javascript
app.get('/vulnerable-page', (req, res) => {
  res.send('<html>...</html>');
});
```

**Fixed Code:**
```javascript
const helmet = require('helmet');

// Add Helmet to protect against various attacks
app.use(helmet());
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'", "'unsafe-inline'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", 'data:', 'https:'],
  },
}));
app.use(helmet.hsts({ maxAge: 31536000, includeSubDomains: true }));
app.use(helmet.frameguard({ action: 'deny' }));
```

**Tools**: `npm install helmet`

---

### Fix 8: Insufficient Logging → Add Security Event Logging

**Vulnerable Code:**
```javascript
app.post('/login', (req, res) => {
  // No logging or rate limiting
  if (username === 'admin' && password === 'password123') {
    res.json({ token: "eyJhbGc..." });
  }
});
```

**Fixed Code:**
```javascript
const rateLimit = require('express-rate-limit');
const logger = require('./logger');

// Rate limit login attempts
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 5,                     // 5 attempts
  message: 'Too many login attempts',
  standardHeaders: true,
  legacyHeaders: false,
});

app.post('/login', loginLimiter, (req, res) => {
  const { username, password } = req.body;
  
  // Log authentication attempt
  logger.security(`Login attempt: ${username}`, { ip: req.ip });
  
  if (authenticateUser(username, password)) {
    logger.security(`Login successful: ${username}`, { ip: req.ip });
    res.json({ token: generateToken(username) });
  } else {
    logger.security(`Login failed: ${username}`, { ip: req.ip, reason: 'Invalid credentials' });
    res.status(401).json({ error: 'Invalid credentials' });
  }
});
```

**Tools**: `npm install express-rate-limit winston`

---

### Fix 9: IDOR → Implement Authorization Checks

**Vulnerable Code:**
```javascript
app.get('/profile/:userId', (req, res) => {
  // No authorization check
  res.json(profiles[userId]);
});
```

**Fixed Code:**
```javascript
function requireAuth(req, res, next) {
  if (!req.user) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
}

app.get('/profile/:userId', requireAuth, (req, res) => {
  const userId = req.params.userId;
  
  // Check if user can access this profile
  if (req.user.id !== userId && !req.user.isAdmin) {
    logger.security(`Unauthorized profile access: ${req.user.id} → ${userId}`, { ip: req.ip });
    return res.status(403).json({ error: 'Forbidden' });
  }
  
  res.json(profiles[userId]);
});
```

---

### Fix 10: Unvalidated Redirects → Whitelist URLs

**Vulnerable Code:**
```javascript
app.get('/redirect', (req, res) => {
  res.redirect(req.query.url);
});
```

**Fixed Code:**
```javascript
const ALLOWED_REDIRECT_HOSTS = [
  'example.com',
  'trusted-partner.com',
  'https://subdomain.example.com'
];

app.get('/redirect', (req, res) => {
  const redirectUrl = req.query.url;
  
  if (!redirectUrl) {
    return res.status(400).json({ error: 'Redirect URL required' });
  }
  
  try {
    const url = new URL(redirectUrl);
    
    // Check if host is whitelisted
    const isAllowed = ALLOWED_REDIRECT_HOSTS.some(allowedHost => {
      return url.hostname === allowedHost || 
             url.hostname.endsWith('.' + allowedHost);
    });
    
    if (!isAllowed) {
      logger.security(`Blocked redirect attempt: ${redirectUrl}`, { ip: req.ip });
      return res.status(400).json({ error: 'Redirect not allowed' });
    }
    
    res.redirect(redirectUrl);
  } catch (error) {
    res.status(400).json({ error: 'Invalid redirect URL' });
  }
});
```

---

## Container (Dockerfile)

### Fix All Issues: Use Multi-Stage Build, Pin Versions, Run as Non-Root

**Vulnerable Dockerfile:**
```dockerfile
FROM node:14
WORKDIR /app
COPY . .
RUN npm install --production=false
ARG DB_PASSWORD=admin123!@#
ENV DB_PASSWORD=$DB_PASSWORD
USER root
CMD ["node", "app.js"]
```

**Fixed Dockerfile:**
```dockerfile
# Stage 1: Builder
FROM node:18-alpine AS builder
RUN apk add --no-cache python3 make g++
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Stage 2: Runtime (minimal)
FROM node:18-alpine
RUN apk add --no-cache tini curl
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

WORKDIR /app

# Copy only production dependencies
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .

# Security: Don't copy secrets, use environment variables
# Never include ARG in final image

USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000

# Use tini to handle signals properly
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "app.js"]
```

---

## Infrastructure (Terraform)

### Fix 1: RDS - Encrypt, Restrict Access, Use Secrets Manager

**Vulnerable:**
```hcl
resource "aws_db_instance" "vulnerable_db" {
  username = "admin"
  password = "SuperSecretPassword123!@#"  # EXPOSED
  publicly_accessible = true
  storage_encrypted = false
}
```

**Fixed:**
```hcl
# Generate random password
resource "random_password" "rds_password" {
  length  = 32
  special = true
}

# Store in AWS Secrets Manager
resource "aws_secretsmanager_secret" "rds_password" {
  name                    = "rds/prod/password"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = random_password.rds_password.result
}

# Secure RDS instance
resource "aws_db_instance" "secure_db" {
  identifier     = "prod-database"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  
  username = "admin"
  password = random_password.rds_password.result
  
  # Encryption
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn
  
  # Network security
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name = aws_db_subnet_group.rds.name
  
  # Backups & recovery
  backup_retention_period = 30
  backup_window           = "03:00-04:00"
  copy_tags_to_snapshot   = true
  
  # Monitoring
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn
  
  # Deletion protection
  deletion_protection = true
  skip_final_snapshot = false
  final_snapshot_identifier = "prod-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  tags = {
    Name        = "prod-database"
    Environment = "production"
  }
}
```

---

### Fix 2: Security Groups - Restrict to Specific IPs/Security Groups

**Vulnerable:**
```hcl
ingress {
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # OPEN
}
```

**Fixed:**
```hcl
resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "RDS database security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]  # Only from app
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # Only from internal VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}
```

---

### Fix 3: S3 Bucket - Private, Encrypted, Versioned

**Vulnerable:**
```hcl
resource "aws_s3_bucket" "vulnerable_bucket" {
  bucket = "my-vulnerable-bucket"
}

resource "aws_s3_bucket_acl" "vulnerable_bucket_acl" {
  bucket = aws_s3_bucket.vulnerable_bucket.id
  acl    = "public-read"  # PUBLIC
}
```

**Fixed:**
```hcl
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-secure-bucket-${data.aws_caller_identity.current.account_id}"
}

# Private access
resource "aws_s3_bucket_acl" "secure_bucket_acl" {
  bucket = aws_s3_bucket.secure_bucket.id
  acl    = "private"
}

# Encryption at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

# Versioning for recovery
resource "aws_s3_bucket_versioning" "secure_bucket_versioning" {
  bucket = aws_s3_bucket.secure_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Access logging
resource "aws_s3_bucket_logging" "secure_bucket_logging" {
  bucket = aws_s3_bucket.secure_bucket.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/"
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "secure_bucket_block" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy (if needed)
resource "aws_s3_bucket_policy" "secure_bucket_policy" {
  bucket = aws_s3_bucket.secure_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUnencryptedObjectUploads"
        Effect = "Deny"
        Principal = "*"
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.secure_bucket.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      }
    ]
  })
}
```

---

### Fix 4: IAM - Implement Least Privilege

**Vulnerable:**
```hcl
resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"  # FULL ACCESS
}
```

**Fixed:**
```hcl
# Role with only necessary permissions
resource "aws_iam_role" "app_role" {
  name = "app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Policy: Read from specific S3 bucket only
resource "aws_iam_role_policy" "app_s3_policy" {
  name = "app-s3-policy"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.data.arn,
          "${aws_s3_bucket.data.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.db_password.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}
```

---

### Fix 5: Terraform State - Encryption & Locking

**Vulnerable:**
```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    # Missing encrypt = true
    # Missing dynamodb_table
  }
}
```

**Fixed:**
```hcl
terraform {
  backend "s3" {
    bucket           = "my-terraform-state"
    key              = "prod/terraform.tfstate"
    region           = "us-east-1"
    encrypt          = true                    # Encrypt at rest
    dynamodb_table   = "terraform-locks"       # State locking
  }
}

# Create DynamoDB table for locking (run separately)
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "terraform-state-locks"
  }
}
```

---

## Summary: Fix Checklist

### Application
- [ ] Replace all MD5 hashing with bcrypt
- [ ] Use parameterized queries for all database access
- [ ] Move secrets to environment variables/GitHub Secrets
- [ ] Validate and sanitize all user inputs
- [ ] Add rate limiting to sensitive endpoints
- [ ] Implement comprehensive logging
- [ ] Add security headers (Helmet middleware)
- [ ] Implement proper authorization checks
- [ ] Use JSON.parse instead of eval()
- [ ] Whitelist redirect URLs

### Container
- [ ] Use specific version tags (not `latest`)
- [ ] Implement multi-stage builds
- [ ] Create non-root user
- [ ] Add health checks
- [ ] Clean up build artifacts
- [ ] Don't pass secrets as build args
- [ ] Use Alpine base images
- [ ] Add tini for signal handling

### Infrastructure
- [ ] Enable database encryption (KMS)
- [ ] Use AWS Secrets Manager for credentials
- [ ] Restrict security groups by IP/SG
- [ ] Enable S3 versioning and logging
- [ ] Block public S3 access
- [ ] Implement least privilege IAM
- [ ] Enable state file encryption
- [ ] Add state locking
- [ ] Enable CloudWatch monitoring
- [ ] Enable backup/disaster recovery

---

## Automated Remediation

Many tools can auto-remediate:

```bash
# npm audit fixes
npm audit fix
npm audit fix --force

# Docker best practices
docker run -i hadolint/hadolint < Dockerfile

# Terraform recommendations
terraform fmt -recursive

# ESLint fixes
npx eslint . --fix

# SonarQube recommendations
# (Check SonarQube dashboard for suggested fixes)
```
