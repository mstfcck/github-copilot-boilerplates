# Python FastAPI Boilerplate

A comprehensive Python FastAPI boilerplate project designed to accelerate web API development with AI-guided best practices.

## 🚀 Overview

This boilerplate provides a solid foundation for building production-ready FastAPI applications with:

- **Modern Python 3.11+** with advanced type hints and async/await patterns
- **Comprehensive AI-guided instructions** for different development scenarios
- **Clean Architecture** supporting scalable microservices and monolithic deployments
- **Security-first approach** with OAuth2/JWT authentication and comprehensive security middleware
- **Performance optimization** with Redis caching, connection pooling, and async patterns
- **Extensive testing strategy** with pytest, async testing, and 90%+ coverage requirements
- **Production-ready configuration** for Docker, Kubernetes, and cloud deployments

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
- [API Documentation](#api-documentation)
- [Contributing](#contributing)
- [License](#license)

## ✨ Features

### Core Features
- **FastAPI 0.110+** with automatic OpenAPI documentation and validation
- **PostgreSQL 15+** with SQLAlchemy 2.0 async support and Alembic migrations
- **Redis** for caching, session storage, and background task queuing
- **JWT Authentication** with refresh tokens and role-based access control
- **Docker Support** with multi-stage builds and development/production configurations
- **Async/Await** patterns throughout for optimal performance

### Development Features
- **AI-Guided Instructions** for common development tasks and patterns
- **Code Quality Standards** with Black, isort, flake8, and mypy
- **Testing Templates** for unit, integration, and load testing scenarios
- **Performance Optimization** guidelines and implementations
- **Security Best Practices** with detailed security configurations
- **Pre-commit Hooks** to ensure code quality and consistency

### Operational Features
- **Health Check Endpoints** with database and Redis connectivity validation
- **Monitoring and Observability** with Prometheus metrics and structured logging
- **Background Task Processing** with Celery and Redis
- **Database Connection Pooling** with configurable pool sizes and timeouts
- **Rate Limiting** and request throttling for API protection
- **CORS Configuration** for cross-origin resource sharing

## 🏗️ Architecture

This boilerplate implements Clean Architecture principles with clear separation of concerns:

```text
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Presentation  │    │   Application   │    │   Infrastructure│
│     Layer       │    │     Layer       │    │     Layer       │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│   • Routers     │───▶│   • Services    │───▶│  • Repositories │
│   • Schemas     │    │   • Use Cases   │    │  • Database     │
│   • Middleware  │    │   • Business    │    │  • External APIs│
│   • Dependencies│    │     Logic       │    │  • Cache        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Key Architectural Patterns
- **Repository Pattern** for data access abstraction
- **Service Layer** for business logic encapsulation
- **Dependency Injection** for loose coupling and testability
- **Factory Pattern** for object creation and test data
- **Observer Pattern** for event-driven architecture

## 🚀 Getting Started

### Prerequisites

- Python 3.11 or higher
- Docker and Docker Compose
- PostgreSQL 15+ (or use Docker)
- Redis 7+ (or use Docker)
- Git for version control

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/python-fastapi-boilerplate.git
   cd python-fastapi-boilerplate
   ```

2. **Set up environment**
   ```bash
   # Copy environment template
   cp .env.example .env
   
   # Edit .env with your configuration
   vim .env
   ```

3. **Install dependencies**
   ```bash
   # Install Poetry (if not already installed)
   curl -sSL https://install.python-poetry.org | python3 -
   
   # Install project dependencies
   poetry install
   
   # Activate virtual environment
   poetry shell
   ```

4. **Start services with Docker**
   ```bash
   # Start PostgreSQL and Redis
   docker-compose -f docker-compose.dev.yml up -d db redis
   
   # Run database migrations
   alembic upgrade head
   ```

5. **Run the application**
   ```bash
   uvicorn main:app --reload
   ```

6. **Access the application**
   - **API Documentation**: http://localhost:8000/docs
   - **Alternative Docs**: http://localhost:8000/redoc
   - **Health Check**: http://localhost:8000/health

## 🤖 AI-Guided Development

This project includes comprehensive AI instructions to guide development:

### Available Instructions

- **[Main Copilot Instructions](.github/copilot-instructions.md)** - Central AI development guidance
- **[Architecture Guide](.github/instructions/architecture.instructions.md)** - Clean architecture patterns and design decisions
- **[Security Guide](.github/instructions/security.instructions.md)** - Authentication, authorization, and security best practices
- **[Testing Guide](.github/instructions/testing.instructions.md)** - Comprehensive testing strategies and frameworks
- **[Database Guide](.github/instructions/database.instructions.md)** - PostgreSQL optimization and async patterns
- **[Performance Guide](.github/instructions/performance.instructions.md)** - Caching, optimization, and monitoring
- **[Docker Guide](.github/instructions/docker.instructions.md)** - Containerization and deployment
- **[API Design Guide](.github/instructions/api-design.instructions.md)** - RESTful API design principles
- **[Coding Standards](.github/instructions/coding-standards.instructions.md)** - Code quality and formatting standards

### Ready-to-Use Prompts

- **[Project Initialization](.github/prompts/project-initialization.prompt.md)** - Complete project setup guidance
- **[Feature Development](.github/prompts/feature-development.prompt.md)** - Step-by-step feature implementation
- **[API Design](.github/prompts/api-design.prompt.md)** - RESTful API design and documentation
- **[Troubleshooting](.github/prompts/troubleshooting.prompt.md)** - Common issues and systematic solutions

### Using AI Instructions

1. **Review the main instructions** in `.github/copilot-instructions.md`
2. **Choose the appropriate guide** for your development task
3. **Follow the MUST, SHOULD, and MAY guidelines** for consistent implementation
4. **Use the provided code examples** as templates for your implementation
5. **Apply the anti-patterns checklist** to avoid common mistakes

## 📁 Project Structure

```text
python-fastapi-boilerplate/
├── .github/                          # GitHub and AI configurations
│   ├── copilot-instructions.md       # Main AI development guidance
│   ├── instructions/                 # Modular instruction files
│   │   ├── architecture.instructions.md
│   │   ├── security.instructions.md
│   │   ├── testing.instructions.md
│   │   └── ...
│   └── prompts/                      # Ready-to-use AI prompts
│       ├── project-initialization.prompt.md
│       ├── feature-development.prompt.md
│       └── ...
├── docs/                             # Comprehensive documentation
│   ├── python/                       # Python-specific documentation
│   │   ├── setup.md                  # Development environment setup
│   │   ├── configuration.md          # Configuration management
│   │   └── best-practices.md         # Development best practices
│   └── api/                          # API documentation
├── app/                              # Application source code
│   ├── core/                         # Core functionality
│   │   ├── config.py                 # Configuration management
│   │   ├── security/                 # Security utilities
│   │   ├── database/                 # Database configuration
│   │   └── middleware/               # Custom middleware
│   ├── models/                       # SQLAlchemy models
│   ├── schemas/                      # Pydantic schemas
│   ├── repositories/                 # Data access layer
│   ├── services/                     # Business logic layer
│   ├── routers/                      # API route handlers
│   └── utils/                        # Utility functions
├── tests/                            # Test implementations
│   ├── unit/                         # Unit tests
│   ├── integration/                  # Integration tests
│   └── conftest.py                   # Test configuration
├── alembic/                          # Database migrations
├── docker-compose.yml                # Production Docker configuration
├── docker-compose.dev.yml            # Development Docker configuration
├── Dockerfile                        # Production Docker image
├── pyproject.toml                    # Poetry dependencies and configuration
├── .env.example                      # Environment template
└── README.md                         # This file
```

## 🛠️ Technology Stack

### Core Technologies
- **Python 3.11+** - Latest stable Python with enhanced type system
- **FastAPI 0.110+** - Modern, fast web framework for building APIs
- **SQLAlchemy 2.0+** - Async SQL toolkit and Object-Relational Mapping
- **PostgreSQL 15+** - Advanced open-source relational database
- **Redis 7+** - In-memory data structure store for caching and queuing
- **Pydantic V2** - Data validation using Python type annotations

### Development Tools
- **Poetry** - Dependency management and packaging
- **Alembic** - Database migration tool for SQLAlchemy
- **Uvicorn** - ASGI server implementation for FastAPI
- **Black** - Code formatter for consistent Python code style
- **isort** - Import statement organizer
- **flake8** - Code linting and style checking
- **mypy** - Static type checker for Python
- **pre-commit** - Git hooks for code quality assurance

### Testing Framework
- **pytest** - Testing framework with extensive plugin ecosystem
- **pytest-asyncio** - Support for testing async code
- **httpx** - Async HTTP client for API testing
- **factory-boy** - Test fixtures replacement for complex object creation
- **faker** - Library for generating fake data for testing

### Production Infrastructure
- **Docker** - Containerization platform
- **Docker Compose** - Multi-container Docker applications
- **nginx** - High-performance web server and reverse proxy
- **Celery** - Distributed task queue for background processing
- **Prometheus** - Monitoring and alerting toolkit
- **Grafana** - Analytics and monitoring platform

## ⚙️ Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

```env
# Application Configuration
APP_NAME=FastAPI Application
DEBUG=false
SECRET_KEY=your-super-secret-key-here

# Database Configuration
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/database

# Redis Configuration
REDIS_URL=redis://localhost:6379/0

# Security Configuration
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_MINUTES=10080

# CORS Configuration
BACKEND_CORS_ORIGINS=["http://localhost:3000"]
```

### Configuration Management

The application uses Pydantic Settings for robust configuration management:

- **Environment-based configuration** with validation
- **Type-safe settings** with automatic type conversion
- **Development/staging/production** environment support
- **Sensitive data protection** with proper secret management

See [Configuration Guide](docs/python/configuration.md) for detailed setup instructions.

## 🧪 Testing

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov

# Run specific test categories
pytest -m unit          # Unit tests only
pytest -m integration   # Integration tests only
pytest -m slow          # Slow tests only

# Run with verbose output
pytest -v -s
```

### Test Structure

- **Unit Tests** - Fast, isolated tests for individual components
- **Integration Tests** - Tests for component interaction and API endpoints
- **Performance Tests** - Load testing and performance validation
- **Test Fixtures** - Reusable test data and configuration
- **Factory Pattern** - Dynamic test data generation with Faker

### Testing Best Practices

- **>90% code coverage** requirement for all new features
- **Async test patterns** for testing FastAPI endpoints
- **Database isolation** with separate test database
- **Mock external dependencies** for reliable testing
- **Property-based testing** for comprehensive validation

## 🚀 Deployment

### Docker Deployment

```bash
# Build production image
docker build -t fastapi-app .

# Run with Docker Compose
docker-compose up -d

# Scale the application
docker-compose up -d --scale app=3
```

### Kubernetes Deployment

```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/

# Check deployment status
kubectl get pods
kubectl get services
```

### Environment-Specific Deployments

- **Development** - Local development with hot reload
- **Staging** - Production-like environment for testing
- **Production** - Optimized for performance and reliability
- **Cloud Deployment** - AWS, GCP, Azure with managed services

See [Deployment Guide](docs/deployment/) for detailed deployment instructions.

## 📚 API Documentation

### Interactive Documentation

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI Schema**: http://localhost:8000/openapi.json

### API Features

- **Automatic documentation** generation from code annotations
- **Interactive testing** interface with Swagger UI
- **Request/response validation** with comprehensive error handling
- **Authentication integration** with JWT token support
- **API versioning** strategy for backward compatibility

### Example API Endpoints

```bash
# Health check
GET /health

# User management
POST /api/v1/users/          # Create user
GET  /api/v1/users/          # List users
GET  /api/v1/users/{id}      # Get user by ID
PUT  /api/v1/users/{id}      # Update user
DELETE /api/v1/users/{id}    # Delete user

# Authentication
POST /api/v1/auth/login      # User login
POST /api/v1/auth/refresh    # Refresh token
POST /api/v1/auth/logout     # User logout
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Follow the coding standards and testing requirements
4. Submit a pull request with comprehensive tests

### Code Quality Standards

- **PEP 8 compliance** with Black formatting
- **Type hints** for all function signatures
- **Comprehensive documentation** with docstrings
- **Test coverage** >90% for new features
- **Security best practices** implementation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Additional Resources

- **[FastAPI Documentation](https://fastapi.tiangolo.com/)**
- **[SQLAlchemy Documentation](https://docs.sqlalchemy.org/)**
- **[PostgreSQL Documentation](https://www.postgresql.org/docs/)**
- **[Docker Documentation](https://docs.docker.com/)**
- **[Python Best Practices](https://docs.python-guide.org/)**

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [Troubleshooting Guide](.github/prompts/troubleshooting.prompt.md)
2. Review the comprehensive documentation in the `docs/` directory
3. Search existing [GitHub issues](https://github.com/your-username/python-fastapi-boilerplate/issues)
4. Create a new issue with detailed information about your problem

---

**Built with ❤️ for the Python FastAPI community**

This boilerplate is designed to accelerate your FastAPI development with proven patterns, comprehensive testing, and production-ready configurations. Happy coding! 🚀
