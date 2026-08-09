# ─── Stage 1: Install dependencies ─────────────────────────────────
FROM node:22-alpine AS deps

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install production dependencies only
RUN npm ci --omit=dev

# ─── Stage 2: Production image ─────────────────────────────────────
FROM node:22-alpine AS production

WORKDIR /app

# Add curl for health checks
RUN apk add --no-cache curl

# Copy node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy application source
COPY package.json ./
COPY index.js ./
COPY src/ ./src/
COPY scripts/ ./scripts/
COPY migrations/ ./migrations/
COPY swagger.yaml ./

# Copy entrypoint script
COPY docker-entrypoint.sh ./
RUN chmod +x docker-entrypoint.sh

# Expose API port
EXPOSE 5001

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD curl -f http://localhost:5001/health || exit 1

# Start via entrypoint (runs migrations then starts server)
ENTRYPOINT ["./docker-entrypoint.sh"]
