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
- **USE** semantic search capabilities to find relevant code patterns and documentation
- **IMPLEMENT** Context7 integration for up-to-date Spring documentation access

**DO** implement these patterns:
- Repository pattern for data access
- Service layer for business logic
- DTO pattern for data transfer
- Builder pattern for complex object creation
- Factory pattern where appropriate
- **Semantic search patterns** for finding relevant implementation examples
- **Context7 integration** for accessing current Spring Boot documentation

**DON'T** do these anti-patterns:
- Field injection (use constructor injection)
- God classes or methods
- Tight coupling between layers
- Exposing internal implementation details
- Ignoring exception handling
- **Relying solely on outdated documentation** without Context7 verification

## Code Quality Requirements

**MUST** include for every feature:
- Unit tests with minimum 80% code coverage
- Integration tests for critical paths
- API documentation with OpenAPI annotations
- Proper logging at appropriate levels
- Input validation and error handling
- Security considerations
- **Semantic search validation** to ensure implementation follows current best practices
- **Context7 documentation verification** for up-to-date Spring Boot guidance

**SHOULD** consider:
- Performance optimization
- Caching strategies
- Database optimization
- Monitoring and observability
- Documentation updates
- **Using semantic search** to find relevant code patterns across the codebase
- **Leveraging Context7** for the latest Spring Boot documentation and examples

**NICE TO HAVE**:
- Load testing scenarios
- Security testing
- Performance benchmarks
- Advanced monitoring dashboards
- **Automated semantic search integration** in CI/CD pipelines
- **Context7 MCP server** setup for development teams

## AI-Assisted Development

**MUST** leverage AI tools effectively:
- **USE** semantic search to find relevant code patterns and implementations
- **IMPLEMENT** Context7 MCP server for accessing up-to-date Spring Boot documentation
- **ENSURE** AI-generated code follows established patterns found through semantic search
- **VALIDATE** AI suggestions against current Spring Boot best practices via Context7

**ALWAYS** when using AI assistance:
- Append 'use context7' to prompts for Spring Boot-specific queries
- Use semantic search to find similar implementations in the codebase
- Verify AI-generated code against current Spring Boot documentation
- Cross-reference patterns found through semantic search with Context7 documentation

**Context7 Integration Commands:**
```bash
# For Spring Boot specific queries
Create a Spring Boot REST controller with proper exception handling. use context7

# For Spring Security implementation
Implement JWT authentication with Spring Security 6.x. use library /springframework/spring-security for current docs

# For Spring Data JPA queries
Create JPA repository with custom queries and pagination. use context7
```

## Other Considerations

For specific implementation guidance, refer to the specialized instructions in the `.github/instructions/` directory.

**MUST** use `./docs` to investigate the project's functional and non-functional requirements, architectural decisions, and design patterns.

**MUST** use this document as a living guide to ensure all contributions align with the project's architectural vision and coding standards. Regularly review and update these guidelines as the project evolves and new best practices emerge.

**MUST** use the `.github/prompts/project-initialization.prompt.md` to understand the project's setup and configuration.

**ALWAYS** leverage semantic search and Context7 integration:
- Use semantic search to find relevant code patterns before implementing new features
- Verify implementation approaches against current Spring Boot documentation via Context7
- Cross-reference patterns found in the codebase with official Spring Boot guidelines
- Keep Context7 MCP server updated for the latest Spring Boot versions

## Sub-Instructions

Reference to specialized instruction files:
- **[Architecture Guide](./instructions/architecture.instructions.md)** - Includes semantic search architectural patterns
- **[Security Guide](./instructions/security.instructions.md)** - Security best practices with Context7 integration
- **[Testing Guide](./instructions/testing.instructions.md)** - Testing strategies with semantic search validation
- **[Performance Guide](./instructions/performance.instructions.md)** - Performance optimization with current Spring Boot practices
- **[Data Persistence Guide](./instructions/data-persistence.instructions.md)** - JPA patterns with semantic search examples
