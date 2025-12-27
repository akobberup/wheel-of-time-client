# DEPLOYMENT: Dette Docker image bygges i GitHub Actions og pushes til GHCR.
# Se deployment docs: https://github.com/akobberup/t16software-infrastructure/blob/main/DEPLOYMENT_PROCESS.md

# Multi-stage build til Flutter Web
FROM debian:bookworm-slim AS build

# Installer dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Installer Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:${PATH}"

# Aktiver web support
RUN flutter config --enable-web
RUN flutter doctor

WORKDIR /app

# Kopier pubspec files og hent dependencies (caching layer)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Kopier source code
COPY . .

# Generer code (freezed, json_serializable)
RUN dart run build_runner build --delete-conflicting-outputs

# Accept build version and time arguments
ARG BUILD_VERSION=unknown
ARG BUILD_TIME=unknown

# Build web app til production med version info og korrekt base href
RUN flutter build web --release --base-href /aarshjulet/ --dart-define=BUILD_VERSION=${BUILD_VERSION} --dart-define=BUILD_TIME="${BUILD_TIME}"

# Production stage - Nginx
FROM nginx:alpine

# Kopier custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Kopier build output fra build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1:80/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
