# Stage 1: Install production dependencies
FROM node:20-alpine AS builder

WORKDIR /app

RUN apk update \
    && apk upgrade \
    && rm -rf /var/cache/apk/*

COPY package.json package-lock.json ./

RUN npm ci --omit=dev \
    && npm cache clean --force

# Stage 2: Minimal runtime image
FROM node:20-alpine AS runner

WORKDIR /app

# Apply security updates and remove package managers
RUN apk update \
    && apk upgrade \
    && rm -rf /var/cache/apk/* \
    && rm -rf /usr/local/lib/node_modules/npm \
              /usr/local/bin/npm \
              /usr/local/bin/npx \
              /usr/local/lib/node_modules/corepack \
              /usr/local/bin/corepack \
              /opt/yarn-v1.22.22 \
    && addgroup -S -g 10001 appgroup \
    && adduser -S -D -H -u 10001 -G appgroup appuser

ENV NODE_ENV=production

COPY --chown=10001:10001 package.json package-lock.json ./
COPY --chown=10001:10001 --from=builder /app/node_modules ./node_modules
COPY --chown=10001:10001 server.js ./

USER 10001:10001

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "fetch('http://127.0.0.1:5000/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

CMD ["node", "server.js"]