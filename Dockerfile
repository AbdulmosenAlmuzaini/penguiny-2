# Stage 1: Build the Flutter Web application
FROM debian:stable-slim AS build-env

# Install dependencies needed for Flutter
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Clone the stable branch of Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter

# Set paths
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run doctor and pre-download binaries
RUN flutter doctor -v

# Set working directory
WORKDIR /app

# Copy dependency files first
COPY pubspec.yaml ./
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Run pub get again to ensure all files are synced, and build web
RUN flutter pub get && flutter build web --release

# Stage 2: Serve using Nginx
FROM nginx:alpine

# Copy the build output to Nginx's default public directory
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port 80 for Railway
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
