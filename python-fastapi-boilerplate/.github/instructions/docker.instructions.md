---
applyTo: '**'
---

# Docker Instructions

Comprehensive Docker containerization and deployment configuration for Python FastAPI applications with production-ready setup and PostgreSQL integration.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** use multi-stage Docker builds for optimized image size
- **REQUIRED** to implement proper health checks for container monitoring
- **SHALL** use non-root user for running application in containers
- **NEVER** include secrets or credentials in Docker images
- **MUST** implement proper signal handling for graceful shutdowns
- **REQUIRED** to use environment-specific configuration through environment variables

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** use official Python slim images as base for better security
- **RECOMMENDED** to implement Docker Compose for local development
- **ALWAYS** use proper volume mounting for persistent data
- **DO** implement container orchestration with proper resource limits
- **DON'T** run containers as root user in production
- **ALWAYS** implement proper logging configuration for containers

### Optional Enhancements (**MAY** Consider)
- **MAY** implement Kubernetes deployment manifests
- **OPTIONAL** to add container image scanning for security vulnerabilities
- **USE** Docker BuildKit for improved build performance
- **IMPLEMENT** multi-platform builds for different architectures
- **AVOID** unnecessary packages and dependencies in production images

## Implementation Guidance

**USE** these Docker configurations:

### Production Dockerfile
```dockerfile
# File: Dockerfile
# Multi-stage build for production FastAPI application

# Build stage
FROM python:3.11-slim as builder

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install poetry

# Set work directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml poetry.lock ./

# Configure poetry
RUN poetry config virtualenvs.create false

# Install dependencies
RUN poetry install --only=main --no-dev

# Production stage
FROM python:3.11-slim as production

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/app/.venv/bin:$PATH"

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set work directory
WORKDIR /app

# Copy installed packages from builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application code
COPY --chown=appuser:appuser . .

# Create necessary directories
RUN mkdir -p /app/logs && chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Expose port
EXPOSE 8000

# Run application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

### Development Dockerfile
```dockerfile
# File: Dockerfile.dev
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install poetry

# Set work directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml poetry.lock ./

# Configure poetry
RUN poetry config virtualenvs.create false

# Install all dependencies (including dev)
RUN poetry install

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Run application with reload for development
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
```

**IMPLEMENT** these Docker Compose configurations:

### Production Docker Compose
```yaml
# File: docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql+asyncpg://postgres:password@db:5432/fastapi_db
      - REDIS_URL=redis://redis:6379/0
      - SECRET_KEY=${SECRET_KEY}
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - app_logs:/app/logs
    networks:
      - app_network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=fastapi_db
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - app_network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    networks:
      - app_network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - app
    networks:
      - app_network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  app_logs:

networks:
  app_network:
    driver: bridge
```

### Development Docker Compose
```yaml
# File: docker-compose.dev.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql+asyncpg://postgres:password@db:5432/fastapi_db
      - REDIS_URL=redis://redis:6379/0
      - DEBUG=true
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - /app/__pycache__
    networks:
      - app_network

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=fastapi_db
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
    volumes:
      - postgres_dev_data:/var/lib/postgresql/data
    networks:
      - app_network

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_dev_data:/data
    networks:
      - app_network

  adminer:
    image: adminer
    ports:
      - "8080:8080"
    depends_on:
      - db
    networks:
      - app_network

volumes:
  postgres_dev_data:
  redis_dev_data:

networks:
  app_network:
    driver: bridge
```

**ENSURE** these Docker patterns:
- Multi-stage builds to minimize production image size
- Non-root user execution for security
- Proper health checks for all services
- Environment-specific configurations
- Proper volume mounting for data persistence

## Anti-Patterns

**DON'T** implement these approaches:
- Running containers as root user in production
- Including secrets or API keys in Docker images
- Using latest tags for production deployments
- Building images without proper layer caching optimization
- Ignoring container resource limits and constraints

**AVOID** these common mistakes:
- Not implementing proper health checks for containers
- Using development dependencies in production images
- Creating oversized Docker images with unnecessary packages
- Not handling container signals for graceful shutdowns
- Mixing configuration across different environments

**NEVER** do these actions:
- Store sensitive data in Docker images or containers
- Use development configurations in production containers
- Ignore container security best practices
- Deploy without proper container monitoring
- Use default passwords or credentials in production

## Code Examples

### Container Health Check Implementation
```python
# File: api/routes/health.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from core.database.connection import get_db
import redis.asyncio as redis
import os
from datetime import datetime

router = APIRouter()

@router.get("/health")
async def health_check():
    """Basic health check endpoint."""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow(),
        "version": os.getenv("APP_VERSION", "unknown")
    }

@router.get("/health/detailed")
async def detailed_health_check(db: AsyncSession = Depends(get_db)):
    """Detailed health check including dependencies."""
    health_status = {
        "status": "healthy",
        "timestamp": datetime.utcnow(),
        "checks": {}
    }
    
    # Database health check
    try:
        await db.execute(text("SELECT 1"))
        health_status["checks"]["database"] = "healthy"
    except Exception as e:
        health_status["checks"]["database"] = f"unhealthy: {str(e)}"
        health_status["status"] = "unhealthy"
    
    # Redis health check
    try:
        redis_client = redis.from_url(os.getenv("REDIS_URL"))
        await redis_client.ping()
        await redis_client.close()
        health_status["checks"]["redis"] = "healthy"
    except Exception as e:
        health_status["checks"]["redis"] = f"unhealthy: {str(e)}"
        health_status["status"] = "unhealthy"
    
    if health_status["status"] == "unhealthy":
        raise HTTPException(status_code=503, detail=health_status)
    
    return health_status
```

### Nginx Configuration for Production
```nginx
# File: nginx/nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream fastapi_app {
        server app:8000;
    }
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    server {
        listen 80;
        server_name localhost;
        
        # Redirect HTTP to HTTPS in production
        # return 301 https://$server_name$request_uri;
        
        # For development, serve directly
        location / {
            proxy_pass http://fastapi_app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Rate limiting
            limit_req zone=api burst=20 nodelay;
            
            # Timeouts
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
        }
        
        # Health check endpoint
        location /health {
            proxy_pass http://fastapi_app/health;
            access_log off;
        }
        
        # Static files (if serving from nginx)
        location /static/ {
            alias /app/static/;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # HTTPS server configuration (uncomment for production)
    # server {
    #     listen 443 ssl http2;
    #     server_name localhost;
    #     
    #     ssl_certificate /etc/nginx/ssl/cert.pem;
    #     ssl_certificate_key /etc/nginx/ssl/key.pem;
    #     
    #     location / {
    #         proxy_pass http://fastapi_app;
    #         proxy_set_header Host $host;
    #         proxy_set_header X-Real-IP $remote_addr;
    #         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #         proxy_set_header X-Forwarded-Proto https;
    #     }
    # }
}
```

### Docker Build and Deployment Scripts
```bash
#!/bin/bash
# File: scripts/build.sh

set -e

echo "Building FastAPI application..."

# Build production image
docker build -t fastapi-app:latest -f Dockerfile .

# Tag with version if provided
if [ ! -z "$1" ]; then
    docker tag fastapi-app:latest fastapi-app:$1
    echo "Tagged image as fastapi-app:$1"
fi

echo "Build completed successfully!"
```

```bash
#!/bin/bash
# File: scripts/deploy.sh

set -e

echo "Deploying FastAPI application..."

# Pull latest images
docker-compose pull

# Build and start services
docker-compose up -d --build

# Wait for services to be healthy
echo "Waiting for services to be healthy..."
sleep 30

# Check health
docker-compose exec app curl -f http://localhost:8000/health || exit 1

echo "Deployment completed successfully!"
```

### Kubernetes Deployment Configuration
```yaml
# File: k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastapi-app
  labels:
    app: fastapi-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fastapi-app
  template:
    metadata:
      labels:
        app: fastapi-app
    spec:
      containers:
      - name: fastapi-app
        image: fastapi-app:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: redis-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: fastapi-service
spec:
  selector:
    app: fastapi-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
  type: LoadBalancer
```

## Validation Checklist

**MUST** verify:
- [ ] Multi-stage Docker builds are properly configured
- [ ] Containers run as non-root user
- [ ] Health checks are implemented for all services
- [ ] Environment variables are used for configuration
- [ ] Resource limits are properly set

**SHOULD** check:
- [ ] Docker images are optimized for size and security
- [ ] Container orchestration is properly configured
- [ ] Logging and monitoring are implemented
- [ ] Backup and recovery procedures are documented
- [ ] Security scanning is integrated into build process

## References

- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [FastAPI Docker Documentation](https://fastapi.tiangolo.com/deployment/docker/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Container Security Best Practices](https://docs.docker.com/engine/security/)
