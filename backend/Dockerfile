
# Stage 1: Install production dependencies
FROM node:20-alpine AS builder

WORKDIR /app

# Apply available Alpine security updates
RUN apk update \
    && apk upgrade \
    && rm -rf /var/cache/apk/*

# Install production dependencies using the lockfile
COPY package.json package-lock.json ./
RUN npm ci --omit=dev \
    && npm cache clean --force

# Stage 2: Secure runtime image
FROM node:20-alpine AS runner

WORKDIR /app

# Apply available Alpine security updates to the runtime image
RUN apk update \
    && apk upgrade \
    && rm -rf /var/cache/apk/* \
    && rm -rf /usr/local/lib/node_modules/npm \
              /usr/local/bin/npm \
              /usr/local/bin/npx \
              /usr/local/lib/node_modules/corepack \
              /usr/local/bin/corepack \
              /opt/yarn-v1.22.22

# Run the application as a non-root user
ENV NODE_ENV=production

COPY --chown=node:node package.json package-lock.json ./
COPY --chown=node:node --from=builder /app/node_modules ./node_modules
COPY --chown=node:node server.js ./

USER node

EXPOSE 5000

# Container health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "fetch('http://127.0.0.1:5000/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

CMD ["node", "server.js"]
