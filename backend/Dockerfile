# Stage 1: Build dependencies
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Runtime image (Secure & Minimal)
FROM node:20-alpine AS runner
WORKDIR /app

# DevSecOps: Run as non-root user for least privilege security
USER node

COPY --chown=node:node package*.json ./
COPY --chown=node:node --from=builder /app/node_modules ./node_modules
COPY --chown=node:node server.js ./

EXPOSE 5000

# Security Compliance: Add container healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 http://localhost:5000/health || exit 1

CMD ["node", "server.js"]