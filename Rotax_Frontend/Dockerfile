# Rotax Frontend - Flutter Web Docker Build
# Multi-stage build for optimized image size

# Stage 1: Build
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS build

WORKDIR /app

# Copy pubspec files first for better caching
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build for web
RUN flutter build web --release --web-renderer html && \
    # Clean cache to save space
    flutter clean && \
    rm -rf /root/.pub-cache/hosted/pub.dartlang.org/*

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy built web files
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
