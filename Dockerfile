# Stage 1: Build Flutter Web App
FROM am-flutter-base:latest AS build

# Set working directory to the root of the monorepo
WORKDIR /app

# 1. Copy ALL shared libraries/modules first (Maintains monorepo structure)
COPY am_common_ui /app/am_common_ui
COPY am-market /app/am-market

# 2. Setup the application directory
WORKDIR /app/am-investment-ui

# 3. Copy pubspec files
COPY am-investment-ui/pubspec.yaml am-investment-ui/pubspec.lock ./

# 4. Get dependencies across the board
# Flutter pub get should handle path dependencies, but we'll ensure the environment is clean
RUN flutter pub get

# 5. Copy the rest of the application source code
COPY am-investment-ui/ .

# 6. Run Build Runner (Essential for code generation if files aren't checked in)
RUN dart run build_runner build --delete-conflicting-outputs

# 7. Build the web application
# Added --verbose to debug compilation errors
RUN flutter build web --release --base-href / --no-pub --verbose

# --- Stage 2: Serve with Nginx ---
FROM nginx:alpine

# Copy the build output
COPY --from=build /app/am-investment-ui/build/web /usr/share/nginx/html

# Copy the custom nginx configuration
COPY am-investment-ui/nginx.conf /etc/nginx/conf.d/default.conf

# Fix permissions
RUN chmod -R 755 /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
