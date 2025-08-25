# Python FastAPI Boilerplate - AI Development Assistant

A comprehensive Python FastAPI boilerplate project designed to accelerate web API development with AI-guided best practices, production-ready architecture, and comprehensive PostgreSQL integration.

## Core Principles and Guidelines

**MUST** follow these fundamental principles:
- **High Performance**: Leverage FastAPI's async capabilities and performance optimizations
- **Type Safety**: Use Python type hints throughout the codebase with Pydantic models
- **Security First**: Implement proper authentication, authorization, and data validation
- **Clean Architecture**: Follow separation of concerns with clear layer boundaries
- **Database Best Practices**: Use SQLAlchemy with proper connection pooling and migrations
- **Production Ready**: Include monitoring, logging, error handling, and deployment configurations
- **API First**: Design APIs following REST principles with comprehensive documentation
- **Testability**: Write comprehensive tests with high coverage and clear test strategies

## Technology Stack Specifications

**MUST** use these technologies:
- **Python 3.11+**: Latest stable Python version for optimal performance
- **FastAPI 0.110+**: Modern, fast web framework for building APIs
- **SQLAlchemy 2.0+**: Python SQL toolkit and Object-Relational Mapping (ORM)
- **PostgreSQL 15+**: Primary database with advanced features and performance
- **Pydantic V2**: Data validation and settings management using type annotations
- **Alembic**: Database migration tool for SQLAlchemy
- **Uvicorn**: ASGI server implementation for production deployment
- **Docker & Docker Compose**: Containerization for development and production
- **Pytest**: Testing framework with async support and comprehensive fixtures
- **Poetry**: Modern dependency management and packaging tool

## Architecture Decision Framework

**ALWAYS** consider these architectural questions:
1. **API Design**: RESTful principles, versioning strategy, and OpenAPI specification
2. **Database Strategy**: Connection pooling, query optimization, and migration patterns
3. **Security Implementation**: Authentication methods, authorization levels, and data protection
4. **Performance Optimization**: Async/await patterns, caching strategies, and query optimization
5. **Scalability Planning**: Horizontal scaling, load balancing, and microservice readiness
6. **Error Handling**: Comprehensive exception handling and user-friendly error responses
7. **Monitoring Strategy**: Application metrics, health checks, and observability
8. **Deployment Architecture**: Container orchestration, CI/CD, and environment management
9. **Integration Patterns**: External service integration and API consumption

## Development Standards

**ENSURE** all code follows these standards:
- Use type hints for all function signatures and class attributes
- Implement proper error handling with custom exceptions and HTTP status codes
- Follow PEP 8 coding standards with Black formatter and isort for imports
- Use dependency injection for service layer and repository patterns
- Implement comprehensive logging with structured logging formats
- Apply SOLID principles and clean code practices throughout

**DO** implement these patterns:
- Repository pattern for data access layer abstraction
- Service layer pattern for business logic encapsulation
- Dependency injection for loose coupling and testability
- Factory pattern for complex object creation
- Observer pattern for event-driven architecture when needed
- Request/Response models with Pydantic for API contract definition

**DON'T** implement these anti-patterns:
- Direct database access from API endpoints without service layer
- Mixing business logic with HTTP handling code
- Using synchronous database operations where async is appropriate
- Exposing internal data models directly in API responses
- Hardcoding configuration values or connection strings
- Catching all exceptions without proper handling and logging

## Quality Requirements

**MUST** include for every feature:
- Comprehensive unit tests with >90% code coverage
- Integration tests for database operations and API endpoints
- Input validation and sanitization for all user inputs
- Proper error handling with informative error messages
- Security headers and CORS configuration
- Request/response logging and performance monitoring
- Database migrations for all schema changes
- API documentation with examples and error codes

**SHOULD** consider:
- Performance benchmarking and optimization
- Caching strategies for frequently accessed data
- Rate limiting and throttling mechanisms
- Background task processing with Celery
- Advanced monitoring with metrics and alerting
- Load testing and stress testing procedures

**NICE TO HAVE**:
- GraphQL endpoint alongside REST API
- Advanced authentication with OAuth2 and JWT
- Real-time features with WebSocket support
- Advanced caching with Redis integration
- Microservice communication patterns
- Advanced deployment with Kubernetes manifests

## Sub-Instructions

Reference to modular instruction files:
- **[Architecture Guide](./instructions/architecture.instructions.md)** - Clean architecture patterns and design decisions
- **[Security Guide](./instructions/security.instructions.md)** - Authentication, authorization, and security best practices
- **[Testing Guide](./instructions/testing.instructions.md)** - Comprehensive testing strategies and frameworks
- **[Database Guide](./instructions/database.instructions.md)** - PostgreSQL integration and optimization
- **[Performance Guide](./instructions/performance.instructions.md)** - Optimization strategies and monitoring
- **[Docker Guide](./instructions/docker.instructions.md)** - Containerization and deployment configuration
- **[API Design Guide](./instructions/api-design.instructions.md)** - REST API design principles and documentation
- **[Coding Standards](./instructions/coding-standards.instructions.md)** - Code quality and formatting standards
