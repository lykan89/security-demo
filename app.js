// ============================================================================
// INTENTIONALLY VULNERABLE NODE.JS APPLICATION
// Demonstrates real-world vulnerability patterns caught by security tools
// ============================================================================

const express = require('express');
const crypto = require('crypto');
const os = require('os');
const path = require('path');
const fs = require('fs');

const app = express();
app.use(express.json());

// ============================================================================
// VULNERABILITY 1: SQL Injection (CWE-89)
// Risk: Data breach, unauthorized access
// ============================================================================
app.get('/user/:id', (req, res) => {
  const userId = req.params.id;
  // VULNERABLE: Direct string concatenation in SQL query
  const query = `SELECT * FROM users WHERE id = '${userId}'`;
  console.log(`Executing: ${query}`);
  
  res.json({
    query: query,
    warning: "SQL Injection vulnerability - user input not sanitized"
  });
});

// ============================================================================
// VULNERABILITY 2: Weak Cryptography (CWE-327)
// Risk: Cryptographic bypass, password recovery attacks
// ============================================================================
function hashPassword(password) {
  // VULNERABLE: MD5 is cryptographically broken
  return crypto.createHash('md5').update(password).digest('hex');
}

app.post('/register', (req, res) => {
  const { username, password } = req.body;
  const hashedPassword = hashPassword(password);
  
  res.json({
    username: username,
    passwordHash: hashedPassword,
    warning: "MD5 hashing is cryptographically broken"
  });
});

// ============================================================================
// VULNERABILITY 3: Hardcoded Credentials (CWE-798)
// Risk: Unauthorized API access, system compromise
// ============================================================================
const API_KEY = "sk-prod-1a2b3c4d5e6f7g8h9i0j"; // EXPOSED SECRET
const DB_PASSWORD = "admin123!@#"; // Hardcoded password
const PRIVATE_KEY = "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA2Z3qX..."; // Fake but pattern matches

app.post('/api/data', (req, res) => {
  // VULNERABLE: Checking API key in code
  if (req.headers['x-api-key'] === API_KEY) {
    res.json({ data: "sensitive" });
  } else {
    res.status(401).send("Unauthorized");
  }
});

// ============================================================================
// VULNERABILITY 4: Command Injection (CWE-78)
// Risk: Remote code execution (RCE), system compromise
// ============================================================================
const { exec } = require('child_process');

app.get('/ping', (req, res) => {
  const host = req.query.host;
  // VULNERABLE: Unsanitized user input passed to shell command
  exec(`ping -c 4 ${host}`, (error, stdout, stderr) => {
    res.json({
      output: stdout || stderr,
      warning: "Command injection vulnerability"
    });
  });
});

// ============================================================================
// VULNERABILITY 5: Path Traversal (CWE-22)
// Risk: Unauthorized file access, information disclosure
// ============================================================================
app.get('/file', (req, res) => {
  const filename = req.query.name;
  // VULNERABLE: No path normalization or validation
  const filepath = path.join('/uploads', filename);
  const content = fs.readFileSync(filepath, 'utf8');
  res.send(content);
});

// ============================================================================
// VULNERABILITY 6: Insecure Deserialization (CWE-502)
// Risk: Remote code execution, object injection
// ============================================================================
app.post('/deserialize', (req, res) => {
  const data = req.body.data;
  // VULNERABLE: eval() can execute arbitrary code
  const obj = eval(`(${data})`);
  res.json(obj);
});

// ============================================================================
// VULNERABILITY 7: Missing Security Headers (CWE-693)
// Risk: XSS, clickjacking, cache poisoning
// ============================================================================
app.get('/vulnerable-page', (req, res) => {
  res.send(`
    <html>
      <body>
        <h1>Vulnerable Page</h1>
        <p>This page is missing critical security headers</p>
      </body>
    </html>
  `);
});

// ============================================================================
// VULNERABILITY 8: Insufficient Logging (CWE-778)
// Risk: Undetected attacks, incident response delays
// ============================================================================
app.post('/login', (req, res) => {
  const { username, password } = req.body;
  // VULNERABLE: No logging of authentication attempts
  // No rate limiting on login attempts
  // No security event recording
  
  if (username === 'admin' && password === 'password123') {
    res.json({ token: "eyJhbGc..." });
  } else {
    res.status(401).send("Invalid credentials");
  }
});

// ============================================================================
// VULNERABILITY 9: Insecure Direct Object References (IDOR - CWE-639)
// Risk: Unauthorized data access, privilege escalation
// ============================================================================
app.get('/profile/:userId', (req, res) => {
  const userId = req.params.userId;
  // VULNERABLE: No authorization check - user can access any profile
  const profiles = {
    '1': { name: 'John', email: 'john@example.com', ssn: '123-45-6789' },
    '2': { name: 'Admin', email: 'admin@corp.com', salary: '$500000' }
  };
  
  res.json(profiles[userId] || { error: 'Not found' });
});

// ============================================================================
// VULNERABILITY 10: Unvalidated Redirects (CWE-601)
// Risk: Phishing attacks, credential theft
// ============================================================================
app.get('/redirect', (req, res) => {
  const url = req.query.url;
  // VULNERABLE: User-supplied URL not validated
  res.redirect(url);
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

// Run on port 3000
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Vulnerable app running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;
