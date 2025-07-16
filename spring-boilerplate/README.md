# Spring Boilerplate

A comprehensive Spring Boot boilerplate project designed to accelerate enterprise-grade application development with AI-guided best practices, SOLID principles, and modern software engineering approaches.

## 🚀 Overview

This boilerplate provides a solid foundation for building Spring Boot applications with:

- **Enterprise-ready architecture** following industry best practices
- **Comprehensive AI-guided instructions** for different development scenarios
- **Modular design patterns** supporting monolithic and microservices architectures
- **Security-first approach** with Spring Security 6.x
- **Performance optimization** with caching, connection pooling, and async processing
- **Extensive testing strategy** with unit, integration, and E2E tests
- **Production-ready configuration** for different environments

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [AI-Guided Development](#ai-guided-development)
- [Project Structure](#project-structure)
- [Technology Stack](#technology-stack)
- [Configuration](#configuration)
- [Testing](#testing)
- [Deployment](#deployment)

## ✨ Features

### Core Features
- **RESTful API Design** with OpenAPI 3 documentation
- **JWT Authentication** with refresh token support
- **Role-based Authorization** with method-level security
- **Input Validation** with Bean Validation and custom validators
- **Exception Handling** with global exception handler
- **Pagination and Filtering** for list endpoints
- **Caching Strategy** with Redis integration
- **File Upload/Download** with configurable storage

### Development Features
- **AI-Guided Instructions** for common development tasks
- **Code Quality Standards** with comprehensive guidelines
- **Testing Templates** for different testing scenarios
- **Performance Optimization** guidelines and implementations
- **Security Best Practices** with detailed security configurations
- **Database Design Patterns** with JPA and Hibernate optimizations

### Operational Features
- **Health Checks** with custom health indicators
- **Metrics and Monitoring** with Micrometer and Prometheus
- **Logging Configuration** with structured logging
- **Environment-specific Configurations** for dev, test, staging, and production
- **Docker Support** with multi-stage builds
- **CI/CD Ready** with GitHub Actions workflows

## 🏗️ Architecture

This boilerplate supports multiple architectural patterns:

### Monolithic Architecture
- **Layered Architecture**: Controller → Service → Repository → Domain
- **Package by Feature**: Organized by business domains
- **Modular Design**: Clear separation of concerns

### Microservices Architecture
- **Service Boundaries**: Clear domain-driven design
- **API Gateway**: Centralized routing and security
- **Service Discovery**: Dynamic service registration
- **Circuit Breaker**: Resilience patterns

### Cloud-Native Architecture
- **12-Factor App**: Following cloud-native principles
- **External Configuration**: Environment-based configuration
- **Health Checks**: Kubernetes-ready health endpoints
- **Observability**: Metrics, logging, and tracing

## 🚀 Getting Started

### Prerequisites

- **Java 17** or higher
- **Maven 3.6+** or **Gradle 7+**
- **Docker** (optional, for containerized development)
- **PostgreSQL** (for production) or **H2** (for development)
- **Redis** (optional, for caching)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/spring-boilerplate.git
   cd spring-boilerplate
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Run with Maven**
   ```bash
   mvn spring-boot:run
   ```

4. **Access the application**
   - API: http://localhost:8080/api/v1
   - Swagger UI: http://localhost:8080/swagger-ui.html
   - H2 Console: http://localhost:8080/h2-console (dev profile)

### Docker Setup

1. **Build and run with Docker Compose**
   ```bash
   docker-compose up -d
   ```

2. **Access services**
   - Application: http://localhost:8080
   - PostgreSQL: localhost:5432
   - Redis: localhost:6379

## 🤖 AI-Guided Development

This project includes comprehensive AI instructions to guide development:

### Available Instructions

- **[Architecture Guide](.github/instructions/architecture.instructions.md)**: Choose the right architecture for your needs
- **[Security Guide](.github/instructions/security.instructions.md)**: Implement robust security measures
- **[Testing Guide](.github/instructions/testing.instructions.md)**: Comprehensive testing strategies
- **[API Design Guide](.github/instructions/api-design.instructions.md)**: RESTful API best practices
- **[Data Persistence Guide](.github/instructions/data-persistence.instructions.md)**: Database and JPA optimization
- **[Configuration Guide](.github/instructions/configuration.instructions.md)**: Environment and application configuration

### Available Prompts

- **[Project Initialization](.github/prompts/project-initialization.prompt.md)**: Set up new projects
- **[API Design Assistant](.github/prompts/api-design.prompt.md)**: Design RESTful APIs

### Using AI Instructions

1. **Review the main instructions** in [copilot-instructions.md](.github/copilot-instructions.md)
2. **Choose the appropriate guide** based on your development task
3. **Follow the MUST, SHOULD, and NICE TO HAVE** guidelines
4. **Use the provided code examples** as templates
5. **Apply the anti-patterns checklist** to avoid common mistakes

## 📁 Project Structure

**MUST** use the project structure in [project-structure.instructions.md](.github/instructions/project-structure.instructions.md)

## 🛠️ Technology Stack

### Core Technologies
- **Java 17+**: Modern Java features and performance
- **Spring Boot 3.x**: Latest Spring Boot with native compilation support
- **Spring Security 6.x**: Comprehensive security framework
- **Spring Data JPA**: Simplified data access with Hibernate
- **Maven**: Dependency management and build tool

### Database
- **PostgreSQL**: Primary production database
- **H2**: In-memory database for development and testing
- **Flyway**: Database migration management
- **HikariCP**: High-performance connection pooling

### Documentation and API
- **OpenAPI 3**: API documentation and specification
- **Springdoc**: Automatic API documentation generation
- **Swagger UI**: Interactive API documentation

### Testing
- **JUnit 5**: Modern testing framework
- **Mockito**: Mocking framework for unit tests
- **Testcontainers**: Integration testing with real databases
- **Spring Boot Test**: Comprehensive testing support

### Monitoring and Observability
- **Micrometer**: Application metrics
- **Prometheus**: Metrics collection
- **Logback**: Structured logging
- **Spring Boot Actuator**: Health checks and monitoring

### Caching and Performance
- **Redis**: Distributed caching and session storage
- **Spring Cache**: Caching abstraction
- **Async Processing**: Non-blocking operations

## ⚙️ Configuration

### Environment Profiles

| Profile | Purpose | Database | Features |
|---------|---------|----------|----------|
| `dev` | Development | H2 (in-memory) | Debug logging, H2 console |
| `test` | Testing | H2 (in-memory) | Fast startup, minimal logging |
| `staging` | Staging | PostgreSQL | Production-like environment |
| `prod` | Production | PostgreSQL | Optimized performance, security |

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `SPRING_PROFILES_ACTIVE` | Active Spring profile | `dev` | No |
| `DATABASE_URL` | Database connection URL | - | Yes (prod) |
| `DATABASE_USERNAME` | Database username | - | Yes (prod) |
| `DATABASE_PASSWORD` | Database password | - | Yes (prod) |
| `JWT_SECRET` | JWT signing secret | - | Yes |
| `REDIS_HOST` | Redis server host | `localhost` | No |
| `REDIS_PORT` | Redis server port | `6379` | No |

### Configuration Files

- **application.yml**: Base configuration
- **application-{profile}.yml**: Environment-specific overrides
- **config/**: External configuration files

## 🧪 Testing

### Testing Strategy

The project follows a comprehensive testing pyramid:

- **Unit Tests (70%)**: Fast, isolated tests for individual components
- **Integration Tests (20%)**: Test component interactions
- **End-to-End Tests (10%)**: Test complete user workflows

### Running Tests

```bash
# Run all tests
mvn test

# Run only unit tests
mvn test -Dtest="*UnitTest"

# Run only integration tests
mvn test -Dtest="*IntegrationTest"

# Run with coverage report
mvn test jacoco:report
```

### Test Coverage

- **Minimum Coverage**: 80% overall
- **Service Layer**: 90% coverage required
- **Repository Layer**: 95% coverage required
- **Controller Layer**: 85% coverage required

## 🚀 Deployment

### Local Deployment

```bash
# Build JAR
mvn clean package

# Run JAR
java -jar target/spring-boilerplate-1.0.0.jar
```

### Docker Deployment

```bash
# Build image
docker build -t spring-boilerplate .

# Run container
docker run -p 8080:8080 spring-boilerplate
```

### Docker Compose

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f app
```

### Production Considerations

- **Environment Variables**: Use secure secret management
- **Database**: Configure connection pooling and monitoring
- **Caching**: Set up Redis cluster for high availability
- **Monitoring**: Configure Prometheus and Grafana
- **Logging**: Centralize logs with ELK stack or similar
- **Security**: Enable HTTPS and security headers

### Development Workflow

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Follow** the coding standards in the AI instructions
4. **Write** tests for new functionality
5. **Ensure** all tests pass (`mvn test`)
6. **Commit** changes (`git commit -m 'Add amazing feature'`)
7. **Push** to branch (`git push origin feature/amazing-feature`)
8. **Create** a Pull Request

### Code Quality

- Follow the **SOLID principles** and **Clean Code** practices
- Maintain **minimum 80% test coverage**
- Use the **AI instructions** for guidance
- Follow **conventional commit** messages
- Update **documentation** for new features

## 🙏 Acknowledgments

- **Spring Team**: For the excellent Spring Framework
- **Spring Boot**: For simplifying Spring application development
- **Spring Security**: For comprehensive security features
- **OpenAPI Initiative**: For API specification standards
- **Contributors**: Thanks to all contributors who help improve this project

## 📞 Support

- **Documentation**: Check the `.github/instructions/` directory
- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas
- **AI Guidance**: Use the provided prompts and instructions for development guidance

---

**Happy Coding!** 🎉

Remember to follow the AI-guided instructions in the `.github/instructions/` directory for best practices and detailed implementation guidance.
