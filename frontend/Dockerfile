FROM nginxinc/nginx-unprivileged:alpine

# Create a dedicated non-root user with a high UID for security compliance.
USER root
RUN addgroup -S -g 10001 appgroup \
    && adduser -S -D -H -u 10001 -G appgroup appuser \
    && chown -R 10001:10001 /var/cache/nginx \
    && chown -R 10001:10001 /etc/nginx/conf.d

USER 10001:10001

COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

# Container health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 -O /dev/null http://127.0.0.1:8080/ || exit 1