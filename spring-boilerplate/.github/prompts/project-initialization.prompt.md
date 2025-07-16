# Spring Project Initialization Assistant

Your goal is to help developers initialize a new Spring Boot project based on the requirements they provide.

Follow the project initialization process step-by-step, ensuring that you gather all necessary information to create or update a well-structured and maintainable Spring Boot project whether it is a new project or an existing one.

## Project Discovery Questions

Ask the following questions to understand the project requirements:

### 1. Architecture Type
- What type of application architecture do you want to build?
  - Monolithic application (single deployable unit)
  - Microservices architecture (multiple independent services)
  - Cloud-native application (optimized for cloud platforms)
  - Serverless application (function-based)

### 2. Technology Stack
- Which database do you plan to use?
  - PostgreSQL (recommended for production)
  - MySQL/MariaDB
  - H2 (for development/testing)
  - MongoDB (document database)
  - Other (please specify)

- Do you need caching?
  - Redis (recommended)
  - In-memory caching
  - No caching needed

- Authentication method:
  - JWT tokens (stateless)
  - Session-based (stateful)
  - OAuth2/OpenID Connect
  - Custom authentication

### 3. Features and Integrations
- Which features do you need?
  - REST API endpoints
  - File upload/download
  - Email notifications
  - Real-time messaging (WebSocket)
  - Scheduled tasks
  - Background job processing

- External integrations:
  - Third-party APIs
  - Message queues (RabbitMQ, Apache Kafka)
  - Payment processing
  - Cloud services (AWS, Azure, GCP)

### 4. Deployment and Environment
- Deployment target:
  - Local development
  - Docker containers
  - Kubernetes cluster
  - Cloud platforms (AWS, Azure, GCP)
  - Traditional servers

- Expected load:
  - Low (< 100 users)
  - Medium (100-1000 users)
  - High (1000+ users)

## Project Structure Generation

Based on the answers, generate the appropriate project structure following these patterns using the templates provided: [Project Structure](../instructions/project-structure.instructions.md)

## Dependencies and Configuration

Generate the appropriate `pom.xml` dependencies based on requirements:

### Core Dependencies (Always Include)
```xml
<dependencies>
    <!-- Spring Boot Starters -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    
    <!-- Documentation -->
    <dependency>
        <groupId>org.springdoc</groupId>
        <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    </dependency>
</dependencies>
```

### Conditional Dependencies
Add based on requirements:
- PostgreSQL: `postgresql` driver
- Redis: `spring-boot-starter-data-redis`
- MongoDB: `spring-boot-starter-data-mongodb`
- Email: `spring-boot-starter-mail`
- WebSocket: `spring-boot-starter-websocket`
- Cloud: Spring Cloud dependencies

## Configuration Files

Generate environment-specific configuration files:

### application.yml
```yaml
spring:
  application:
    name: ${PROJECT_NAME}
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:dev}
  
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}

server:
  port: ${PORT:8080}

app:
  security:
    jwt:
      secret: ${JWT_SECRET}
      expiration: ${JWT_EXPIRATION:86400000}
```

## Development Guidelines

Provide specific guidance based on the chosen architecture:

### For Monolithic Applications:
- Use package-by-feature structure
- Implement proper layered architecture
- Use Spring profiles for different environments
- Focus on modular design within the monolith

### For Microservices:
- Each service should have its own database
- Implement service discovery (Eureka, Consul)
- Use API Gateway for external communication
- Implement circuit breakers and retry mechanisms
- Plan for distributed tracing and monitoring

### For Cloud-Native:
- Follow 12-factor app principles
- Implement health checks and metrics
- Use externalized configuration
- Plan for auto-scaling and resilience

## Next Steps

After project initialization, recommend:

1. **Setup Development Environment**
   - Configure IDE settings
   - Set up local database
   - Configure environment variables

2. **Implement Core Features**
   - Start with authentication/authorization
   - Create basic CRUD operations
   - Add input validation and error handling

3. **Testing Strategy**
   - Write unit tests for services
   - Add integration tests for repositories
   - Create API contract tests

4. **Documentation**
   - Update README with setup instructions
   - Document API endpoints with OpenAPI
   - Create development guidelines

5. **CI/CD Pipeline**
   - Set up automated testing
   - Configure deployment pipeline
   - Implement code quality checks

Remember to follow the coding standards and best practices defined in the repository instructions!
