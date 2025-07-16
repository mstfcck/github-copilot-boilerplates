---
applyTo: '**'
---

# Spring Project Structure Guide

**MUST** follow this structure for all Spring Boot projects to ensure consistency and maintainability. This structure is designed to support both monolithic and microservices architectures.

**MUST** use the following project structure templates based on the chosen architecture wheter it is a monolithic or microservices architecture and existing project or new project.

**MUST** ask developers to choose between a monolithic or microservices architecture before generating the project structure.

**MUST** ask developers to follow the provided project structure templates to ensure continuity and ease of understanding across the codebase.

## Monolithic Project Structure

```
spring-boilerplate/
├── .github/
│   ├── copilot-instructions.md          # Main AI instructions
│   ├── instructions/                    # Specialized guides
│   │   ├── architecture.instructions.md
│   │   ├── security.instructions.md
│   │   ├── testing.instructions.md
│   │   ├── api-design.instructions.md
│   │   ├── data-persistence.instructions.md
│   │   └── configuration.instructions.md
│   │   └── project-structure.instructions.md
│   └── prompts/                         # Reusable prompts
│       ├── project-initialization.prompt.md
│       └── api-design.prompt.md
├── src/
│   ├── main/
│   │   ├── java/com/example/springboilerplate/
│   │   │   ├── SpringBoilerplateApplication.java
│   │   │   ├── config/                  # Configuration classes
│   │   │   ├── controller/              # REST controllers
│   │   │   ├── service/                 # Business logic
│   │   │   ├── repository/              # Data access
│   │   │   ├── domain/                  # JPA entities
│   │   │   ├── dto/                     # Data transfer objects
│   │   │   │   └── validator/           # Request validators
│   │   │   ├── exception/               # Custom exception classes
│   │   │   ├── handler/                 # Handlers
│   │   │   ├── security/                # Security components
│   │   │   ├── util/                    # Utility classes
│   │   └── resources/
│   │       ├── application.yml          # Main configuration
│   │       ├── application-dev.yml      # Development config
│   │       ├── application-prod.yml     # Production config
│   │       └── db/migration/            # Flyway migrations
│   └── test/                            # Test classes
├── docker/                              # Docker configurations
├── docs/                                # Documentation
├── scripts/                             # Utility scripts
├── .gitignore                           # Git ignore rules
├── docker-compose.yml                   # Docker Compose setup
├── pom.xml                              # Maven configuration
└── README.md                            # This file
```

## Microservices Project Structure

```
spring-boilerplate/
├── .github/
│   ├── copilot-instructions.md          # Main AI instructions
│   ├── instructions/                    # Specialized guides
│   │   ├── architecture.instructions.md
│   │   ├── security.instructions.md
│   │   ├── testing.instructions.md
│   │   ├── api-design.instructions.md
│   │   ├── data-persistence.instructions.md
│   │   └── configuration.instructions.md
│   │   └── project-structure.instructions.md
│   └── prompts/                         # Reusable prompts
│       ├── project-initialization.prompt.md
│       └── api-design.prompt.md
├── gateway/
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       │   └── com/
│   │       │       └── example/
│   │       │           └── gateway/
│   │       │               └── GatewayApplication.java
│   │       └── resources/
│   │           └── application.yml
│   └── pom.xml
├── account-service/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── com/
│   │   │   │       └── example/
│   │   │   │           └── accountservice/
│   │   │   │               ├── AccountServiceApplication.java
│   │   │   │               ├── config/
│   │   │   │               │   └── SecurityConfig.java
│   │   │   │               ├── controller/
│   │   │   │               │   └── AccountController.java
│   │   │   │               ├── service/
│   │   │   │               │   └── AccountService.java
│   │   │   │               ├── repository/
│   │   │   │               │   └── AccountRepository.java
│   │   │   │               ├── domain/
│   │   │   │               │   └── Account.java
│   │   │   │               ├── dto/
│   │   │   │               │   └── AccountRequest.java
│   │   │   │               │   └── AccountResponse.java
│   │   │   │               │   └── validator/
│   │   │   │               │       └── AccountRequestValidator.java
│   │   │   │               ├── exception/
│   │   │   │               │   └── CustomException.java
│   │   │   │               ├── handler/
│   │   │   │               │   └── GlobalExceptionHandler.java
│   │   │   │               ├── security/
│   │   │   │               │   └── JwtTokenProvider.java
│   │   │   │               ├── util/
│   │   │   │               │   └── AccountMapper.java
│   │   │   │               └── client/
│   │   │   │                   └── UserServiceClient.java
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   │       └── java/
│   │           └── com/
│   │               └── example/
│   │                   └── accountservice/
│   │                       └── AccountServiceTests.java
│   └── pom.xml
├── transaction-service/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── com/
│   │   │   │       └── example/
│   │   │   │           └── transactionservice/
│   │   │   │               ├── TransactionServiceApplication.java
│   │   │   │               ├── controller/
│   │   │   │               │   └── TransactionController.java
│   │   │   │               ├── service/
│   │   │   │               │   └── TransactionService.java
│   │   │   │               ├── repository/
│   │   │   │               │   └── TransactionRepository.java
│   │   │   │               ├── domain/
│   │   │   │               │   └── Transaction.java
│   │   │   │               ├── dto/
│   │   │   │               │   └── TransactionRequest.java
│   │   │   │               │   └── TransactionResponse.java
│   │   │   │               │   └── validator/
│   │   │   │               │       └── TransactionRequestValidator.java
│   │   │   │               ├── util/
│   │   │   │               │   └── TransactionMapper.java
│   │   │   │               └── client/
│   │   │   │                   ├── AccountServiceClient.java
│   │   │   │                   └── UserServiceClient.java
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   └── pom.xml
├── user-service/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── com/
│   │   │   │       └── example/
│   │   │   │           └── userservice/
│   │   │   │               ├── UserServiceApplication.java
│   │   │   │               ├── controller/
│   │   │   │               │   └── UserController.java
│   │   │   │               └── service/
│   │   │   │                   └── UserService.java
│   │   │   │               ├── repository/
│   │   │   │               │   └── UserRepository.java
│   │   │   │               ├── domain/
│   │   │   │               │   └── User.java
│   │   │   │               ├── dto/
│   │   │   │               │   └── UserRequest.java
│   │   │   │               │   └── UserResponse.java
│   │   │   │               │   └── validator/
│   │   │   │               │       └── UserRequestValidator.java
│   │   │   │               ├── util/
│   │   │   │               │   └── UserMapper.java
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   └── pom.xml
├── discovery-service/
│   └── (Service discovery implementation)
├── config-service/
│   └── (Configuration server implementation)
├── docker-compose.yml
└── pom.xml (Parent POM)
```
