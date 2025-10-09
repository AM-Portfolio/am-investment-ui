# Docker Deployment Guide

## Prerequisites
- Docker installed
- Docker Compose installed
- Domain name configured (for production with Traefik)

## Quick Start

### 1. Build and run locally
```bash
docker-compose up -d --build
```

### 2. Access the application
- Application: http://localhost
- Traefik Dashboard: http://localhost:8080

### 3. Stop the application
```bash
docker-compose down
```

## Production Deployment with Traefik

### 1. Configure your domain
Edit `docker-compose.yml` and replace `your-domain.com` with your actual domain.

### 2. Enable HTTPS (Optional)
Uncomment the SSL-related lines in `docker-compose.yml`:
- Let's Encrypt configuration in traefik command
- HTTPS router labels for am-investment-ui service

### 3. Set your email for Let's Encrypt
Replace `your-email@example.com` with your actual email.

### 4. Deploy
```bash
docker-compose up -d --build
```

## Commands

### Build the image
```bash
docker build -t am-investment-ui:latest .
```

### Run without Traefik
```bash
docker run -d -p 8080:80 --name am-investment-ui am-investment-ui:latest
```

### View logs
```bash
docker-compose logs -f am-investment-ui
```

### Restart services
```bash
docker-compose restart
```

### Update and rebuild
```bash
docker-compose down
docker-compose up -d --build
```

## Traefik Features
- Automatic HTTPS with Let's Encrypt
- HTTP to HTTPS redirect
- Load balancing
- Dashboard at port 8080

## Troubleshooting

### Check container status
```bash
docker-compose ps
```

### Check logs
```bash
docker-compose logs traefik
docker-compose logs am-investment-ui
```

### Remove everything and start fresh
```bash
docker-compose down -v
docker-compose up -d --build
```
