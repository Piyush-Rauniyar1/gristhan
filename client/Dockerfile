# ─── Stage 1: Build the React app ──────────────────────────────────
FROM node:22-alpine AS build

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install all dependencies (including devDependencies for build)
RUN npm ci

# Copy application source
COPY index.html ./
COPY vite.config.js ./
COPY eslint.config.js ./
COPY public/ ./public/
COPY src/ ./src/

# Build arguments for Vite environment variables
ARG VITE_API_URL=""
ARG VITE_STRIPE_PUBLIC_KEY=""
ARG VITE_KHALTI_PUBLIC_KEY=""

# Set them as env vars so Vite inlines them during build
ENV VITE_API_URL=$VITE_API_URL
ENV VITE_STRIPE_PUBLIC_KEY=$VITE_STRIPE_PUBLIC_KEY
ENV VITE_KHALTI_PUBLIC_KEY=$VITE_KHALTI_PUBLIC_KEY

# Build for production
RUN npm run build

# ─── Stage 2: Serve with Nginx ─────────────────────────────────────
FROM nginx:alpine AS production

# Remove default Nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built assets from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
