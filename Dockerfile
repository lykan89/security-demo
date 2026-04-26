# ============================================================================
# INTENTIONALLY VULNERABLE DOCKERFILE
# Demonstrates container security anti-patterns caught by tools like Trivy
# ============================================================================

# VULNERABILITY 1: Untagged base image (CWE-1104)
# Risk: Unpredictable behavior, unknown vulnerabilities, supply chain attacks
# Best practice: Always pin specific version
FROM node:14

# VULNERABILITY 2: Running as root (CWE-269)
# Risk: Privilege escalation, container escape, full system compromise
# Best practice: Create non-root user with minimal privileges
# (This Dockerfile DOES NOT create a non-root user - intentional)

WORKDIR /app

# VULNERABILITY 3: Copying package files without separation
# Risk: Cache invalidation, rebuilding entire image on code changes
COPY . .

# VULNERABILITY 4: Installing packages without cache cleanup
# Risk: Bloated images, unnecessary attack surface
RUN npm install --production=false && \
    npm cache clean --force

# VULNERABILITY 5: Exposing sensitive build args in layers
# Risk: Secrets visible in image history and layer metadata
ARG DB_PASSWORD=admin123!@#
ARG API_KEY=sk-prod-1a2b3c4d5e6f7g8h9i0j
ENV DB_PASSWORD=$DB_PASSWORD
ENV API_KEY=$API_KEY

# VULNERABILITY 6: No health check
# Risk: Undetected service failures, cascading failures in orchestration
# (Missing HEALTHCHECK instruction)

# VULNERABILITY 7: Running application as root
# Risk: Privilege escalation, full container compromise
USER root

EXPOSE 3000

# VULNERABILITY 8: No security scanning integration
# VULNERABILITY 9: Using CMD instead of ENTRYPOINT
# Risk: Command override attacks
CMD ["node", "app.js"]

# ============================================================================
# FIXED VERSION (for reference - shows best practices)
# ============================================================================

# FROM node:14-alpine AS base
# RUN apk add --no-cache tini
# 
# FROM base AS builder
# WORKDIR /app
# COPY package*.json ./
# RUN npm ci --only=production && npm cache clean --force
# 
# FROM base AS runtime
# RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
# WORKDIR /app
# COPY --from=builder /app/node_modules ./node_modules
# COPY --chown=nodejs:nodejs . .
# USER nodejs
# HEALTHCHECK --interval=30s --timeout=3s CMD node healthcheck.js
# ENTRYPOINT ["/sbin/tini", "--"]
# CMD ["node", "app.js"]
