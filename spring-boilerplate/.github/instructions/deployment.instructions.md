---
applyTo: '**'
---

# Spring Deployment Instructions

This document provides comprehensive deployment guidelines and strategies for Spring Boot applications across different environments and platforms.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** implement environment-specific configuration management
- **REQUIRED** to use secure secret management for sensitive data
- **SHALL** implement proper health checks and monitoring endpoints
- **NEVER** hardcode sensitive information in application code
- **MUST** use HTTPS in production environments
- **REQUIRED** to implement proper logging and monitoring
- **SHALL** follow 12-factor app principles for cloud deployment

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** use containerization (Docker) for consistent deployments
- **RECOMMENDED** to implement blue-green or rolling deployment strategies
- **ALWAYS** use infrastructure as code (IaC) for environment provisioning
- **DO** implement automated CI/CD pipelines
- **ALWAYS** backup data before production deployments
- **DO** implement proper database migration strategies
- **DON'T** deploy directly to production without staging validation

### Optional Enhancements (**MAY** Consider)
- **MAY** implement service mesh for microservices deployments
- **OPTIONAL** to use advanced deployment strategies (canary, A/B testing)
- **USE** cloud-native services for scalability and reliability
- **IMPLEMENT** advanced monitoring and alerting systems
- **AVOID** vendor lock-in by using portable technologies

## Implementation Guidance

**USE** these environment configurations:
- **Development**: Local development with embedded databases
- **Testing**: Automated testing with in-memory databases
- **Staging**: Production-like environment for final validation
- **Production**: Optimized for performance, security, and reliability

**IMPLEMENT** these deployment strategies:
- **Blue-Green Deployment**: Zero-downtime deployments
- **Rolling Deployment**: Gradual replacement of instances
- **Canary Deployment**: Gradual traffic shifting to new versions
- **A/B Testing**: Feature flag-based deployments

**ENSURE** proper configuration management:
```yaml
# application.yml
spring:
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:dev}
  config:
    import: optional:configserver:${CONFIG_SERVER_URL:}

---
# application-dev.yml
spring:
  config:
    activate:
      on-profile: dev
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
    username: sa
    password: password
  jpa:
    show-sql: true
    hibernate:
      ddl-auto: create-drop

---
# application-prod.yml
spring:
  config:
    activate:
      on-profile: prod
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}
    hikari:
      minimum-idle: 5
      maximum-pool-size: 20
      connection-timeout: 20000
      idle-timeout: 300000
  jpa:
    show-sql: false
    hibernate:
      ddl-auto: validate
```

## Anti-Patterns

**DON'T** hardcode environment-specific values:
```java
// BAD - Hardcoded values
String dbUrl = "jdbc:mysql://localhost:3306/mydb"; // NEVER hardcode
String apiKey = "abc123"; // NEVER hardcode secrets
```

**AVOID** deploying without proper testing:
```bash
# BAD - Direct production deployment
mvn package && java -jar target/app.jar # NEVER deploy without testing
```

**NEVER** ignore security configurations:
```yaml
# BAD - Insecure configuration
security:
  basic:
    enabled: false # NEVER disable security in production
```

## Code Examples

### Proper Configuration Management
```java
@Configuration
@ConfigurationProperties(prefix = "app")
@Data
@Validated
public class AppConfig {
    
    @NotBlank
    private String name;
    
    @NotNull
    @Valid
    private Database database;
    
    @NotNull
    @Valid
    private Security security;
    
    @NotNull
    @Valid
    private External external;
    
    @Data
    @Validated
    public static class Database {
        @NotBlank
        private String url;
        
        @NotBlank
        private String username;
        
        @NotBlank
        private String password;
        
        @Min(1)
        @Max(100)
        private int maxPoolSize = 10;
    }
    
    @Data
    @Validated
    public static class Security {
        @NotBlank
        private String jwtSecret;
        
        @Min(300)
        @Max(86400)
        private int tokenExpirationSeconds = 3600;
    }
    
    @Data
    @Validated
    public static class External {
        @NotBlank
        private String apiUrl;
        
        @NotBlank
        private String apiKey;
        
        @Min(1000)
        @Max(60000)
        private int timeoutMs = 5000;
    }
}
```

### Proper Health Checks
```java
@Component
public class DatabaseHealthIndicator implements HealthIndicator {
    
    private final DataSource dataSource;
    
    public DatabaseHealthIndicator(DataSource dataSource) {
        this.dataSource = dataSource;
    }
    
    @Override
    public Health health() {
        try (Connection connection = dataSource.getConnection()) {
            if (connection.isValid(1)) {
                return Health.up()
                    .withDetail("database", "Available")
                    .withDetail("validationQuery", "SELECT 1")
                    .build();
            }
        } catch (SQLException e) {
            return Health.down()
                .withDetail("database", "Unavailable")
                .withDetail("error", e.getMessage())
                .build();
        }
        
        return Health.down()
            .withDetail("database", "Connection validation failed")
            .build();
    }
}

@Component
public class ExternalServiceHealthIndicator implements HealthIndicator {
    
    private final RestTemplate restTemplate;
    private final AppConfig appConfig;
    
    public ExternalServiceHealthIndicator(RestTemplate restTemplate, AppConfig appConfig) {
        this.restTemplate = restTemplate;
        this.appConfig = appConfig;
    }
    
    @Override
    public Health health() {
        try {
            ResponseEntity<String> response = restTemplate.getForEntity(
                appConfig.getExternal().getApiUrl() + "/health", String.class);
            
            if (response.getStatusCode().is2xxSuccessful()) {
                return Health.up()
                    .withDetail("externalService", "Available")
                    .withDetail("responseTime", System.currentTimeMillis())
                    .build();
            }
        } catch (Exception e) {
            return Health.down()
                .withDetail("externalService", "Unavailable")
                .withDetail("error", e.getMessage())
                .build();
        }
        
        return Health.down()
            .withDetail("externalService", "Health check failed")
            .build();
    }
}
```

### Proper Actuator Configuration
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
      base-path: /actuator
  endpoint:
    health:
      show-details: when-authorized
      show-components: always
    info:
      enabled: true
  health:
    livenessstate:
      enabled: true
    readinessstate:
      enabled: true
  metrics:
    export:
      prometheus:
        enabled: true
  info:
    env:
      enabled: true
    git:
      enabled: true
    build:
      enabled: true
```

### Dockerfile Example
```dockerfile
# Multi-stage build for optimal image size
FROM openjdk:17-jdk-slim as builder

WORKDIR /app
COPY pom.xml .
COPY src ./src
COPY mvnw .
COPY .mvn ./.mvn

# Build the application
RUN chmod +x mvnw && ./mvnw clean package -DskipTests

# Production stage
FROM openjdk:17-jre-slim

# Create non-root user
RUN groupadd -r spring && useradd -r -g spring spring

# Set working directory
WORKDIR /app

# Copy jar file
COPY --from=builder /app/target/*.jar app.jar

# Change ownership to spring user
RUN chown -R spring:spring /app

# Switch to non-root user
USER spring

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Docker Compose Example
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - DATABASE_URL=jdbc:postgresql://db:5432/myapp
      - DATABASE_USERNAME=myapp
      - DATABASE_PASSWORD=secret
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      - db
      - redis
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=myapp
      - POSTGRES_PASSWORD=secret
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U myapp"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  postgres_data:
```

### Kubernetes Deployment Example
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-app
  labels:
    app: spring-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: spring-app
  template:
    metadata:
      labels:
        app: spring-app
    spec:
      containers:
      - name: spring-app
        image: your-registry/spring-app:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "k8s"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
        - name: DATABASE_USERNAME
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: username
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /actuator/health/liveness
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        startupProbe:
          httpGet:
            path: /actuator/health/liveness
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
          failureThreshold: 30

---
apiVersion: v1
kind: Service
metadata:
  name: spring-app-service
spec:
  selector:
    app: spring-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

## Validation Checklist

**MUST** verify:
- [ ] Environment-specific configurations are properly managed
- [ ] Sensitive data is stored securely (not in code)
- [ ] Health checks and monitoring endpoints are implemented
- [ ] HTTPS is enabled for production environments
- [ ] Database migrations are properly managed
- [ ] Backup and recovery procedures are in place
- [ ] Security configurations are properly set

**SHOULD** check:
- [ ] Containerization is implemented for consistent deployments
- [ ] CI/CD pipelines are automated and tested
- [ ] Infrastructure as code (IaC) is used for environment provisioning
- [ ] Load balancing and auto-scaling are configured
- [ ] Monitoring and alerting systems are in place
- [ ] Disaster recovery procedures are documented and tested

## References

- [Spring Boot Deployment Guide](https://docs.spring.io/spring-boot/docs/current/reference/html/deployment.html)
- [12-Factor App Methodology](https://12factor.net/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Kubernetes Deployment Guide](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)
- [Prometheus Monitoring](https://prometheus.io/docs/introduction/overview/)
