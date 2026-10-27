FROM nginxinc/nginx-unprivileged:alpine

# Security Compliance: Explicit non-root user
USER 101

COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

# Security Compliance: Add container healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 http://localhost:8080/ || exit 1