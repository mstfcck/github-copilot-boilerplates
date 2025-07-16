# Spring Boilerplate - AI Development Assistant

This is a comprehensive Spring Boilerplate project designed to accelerate enterprise-grade Spring application development with AI-guided best practices.

Using this boilerplate, you can set up a new Spring Boot project or enhance an existing one by following the architectural guidelines, coding standards, and development practices outlined in this document.

## Core Principles and Guidelines

**MUST** follow these fundamental software engineering principles:
- **SOLID Principles**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **DRY (Don't Repeat Yourself)**: Eliminate code duplication through proper abstraction
- **KISS (Keep It Simple, Stupid)**: Prefer simple solutions over complex ones
- **YAGNI (You Aren't Gonna Need It)**: Don't implement features until they are actually needed
- **Clean Code**: Write self-documenting, readable, and maintainable code

## Technology Stack Specifications

**MUST** use these technologies and frameworks:
- **Java 17+** as the minimum version with modern language features
- **Spring Boot 3.x** with latest stable version
- **Spring Security 6.x** for authentication and authorization
- **Spring Data JPA** with Hibernate for data persistence
- **Maven** as the build tool (NOT Gradle unless explicitly requested)
- **JUnit 5** and **Mockito** for testing
- **SLF4J with Logback** for logging
- **OpenAPI 3** with Springdoc for API documentation

## Architecture Decision Framework

When developing features, **ALWAYS** ask these questions to guide architecture decisions:

1. **What is the target deployment architecture?**
   - Monolithic application
   - Microservices architecture
   - Cloud-native application
   - Serverless functions

2. **What are the scalability requirements?**
   - Expected user load
   - Data volume
   - Performance requirements
   - Geographic distribution

3. **What are the integration requirements?**
   - External APIs
   - Message queues
   - Databases
   - Third-party services

## Development Standards

**ENSURE** all code follows these standards:
- Use Spring Boot's auto-configuration where possible
- Implement proper exception handling with custom exception classes
- Follow RESTful API design principles
- Use appropriate HTTP status codes and response formats
- Implement comprehensive input validation
- Follow proper layered architecture (Controller → Service → Repository)
- Use dependency injection properly with constructor injection preferred
- Implement proper security measures (authentication, authorization, input sanitization)

**DO** implement these patterns:
- Repository pattern for data access
- Service layer for business logic
- DTO pattern for data transfer
- Builder pattern for complex object creation
- Factory pattern where appropriate

**DON'T** do these anti-patterns:
- Field injection (use constructor injection)
- God classes or methods
- Tight coupling between layers
- Exposing internal implementation details
- Ignoring exception handling

## Code Quality Requirements

**MUST** include for every feature:
- Unit tests with minimum 80% code coverage
- Integration tests for critical paths
- API documentation with OpenAPI annotations
- Proper logging at appropriate levels
- Input validation and error handling
- Security considerations

**SHOULD** consider:
- Performance optimization
- Caching strategies
- Database optimization
- Monitoring and observability
- Documentation updates

**NICE TO HAVE**:
- Load testing scenarios
- Security testing
- Performance benchmarks
- Advanced monitoring dashboards

## Other Considerations

For specific implementation guidance, refer to the specialized instructions in the `.github/instructions/` directory.

**MUST** use `./docs` to investigate the project's functional and non-functional requirements, architectural decisions, and design patterns.

**MUST** use this document as a living guide to ensure all contributions align with the project's architectural vision and coding standards. Regularly review and update these guidelines as the project evolves and new best practices emerge.

**MUST** use the `.github/prompts/project-initialization.prompt.md` to understand the project's setup and configuration.
