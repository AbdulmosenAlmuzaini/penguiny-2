# Stage 1: Build the Flutter web app
FROM ghcr.io/cirruslabs/flutter:3.22.3 AS builder

WORKDIR /app

# Copy pubspec.yaml first to leverage Docker layer caching
COPY pubspec.yaml ./
RUN flutter pub get

# Copy the rest of the project source
COPY . .

# Build the web application
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy the build output from the builder stage to Nginx
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

