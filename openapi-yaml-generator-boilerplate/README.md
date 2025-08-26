# OpenAPI YAML Generator Boilerplate

A comprehensive OpenAPI YAML Generator boilerplate designed to accelerate high-quality API specification development with AI-guided best practices and standardized generation templates.

## 🚀 Overview

This boilerplate provides AI agents and developers with detailed instructions, patterns, and examples for generating production-ready OpenAPI 3.1.x YAML specifications that follow industry standards and best practices.

- **AI-Optimized Instructions** specifically designed for GitHub Copilot and AI-assisted development
- **Production-Ready Standards** following OpenAPI 3.1.x specification and HTTP semantics
- **Comprehensive Guidelines** covering architecture, security, testing, and API design
- **Quality Assurance** with validation checklists and automated testing strategies
- **Consistent Patterns** ensuring maintainable and scalable API specifications
- **Real-World Examples** demonstrating practical implementation scenarios

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [AI-Guided Development](#ai-guided-development)
- [Project Structure](#project-structure)
- [Technology Stack](#technology-stack)
- [Usage Examples](#usage-examples)
- [Quality Assurance](#quality-assurance)
- [Best Practices](#best-practices)
- [Contributing](#contributing)

## ✨ Features

### Core Features
- **OpenAPI 3.1.x Compliance** with full specification support
- **RESTful API Design** following industry best practices
- **Comprehensive Security** with OAuth2, JWT, and API key patterns
- **Advanced Validation** using JSON Schema Draft 2020-12
- **Multi-format Support** for JSON, XML, and other media types

### Development Features
- **AI-Guided Instructions** optimized for GitHub Copilot
- **Modular Architecture** with specialized instruction files
- **Code Quality Standards** with consistent naming and formatting
- **Testing Templates** for validation and contract testing
- **Error Handling Patterns** with standardized response formats

### Operational Features
- **Production-Ready Configurations** for multiple environments
- **Performance Optimization** guidelines and implementation patterns
- **Monitoring Integration** with health checks and operational endpoints
- **Deployment Strategies** supporting various infrastructure patterns

## 🏗️ Architecture

The boilerplate follows a modular architecture with specialized instruction files:

```
OpenAPI YAML Generator
├── Core Principles
│   ├── RESTful Design
│   ├── Security-First Approach
│   └── Documentation Excellence
├── Technical Standards
│   ├── YAML Formatting
│   ├── Schema Design
│   └── API Patterns
└── Quality Assurance
    ├── Validation
    ├── Testing
    └── Performance
```

### Design Principles

1. **Resource-Oriented Design**: APIs are designed around resources and their relationships
2. **HTTP Semantic Compliance**: Proper use of HTTP methods and status codes
3. **Security by Design**: Comprehensive security implementation from the start
4. **Developer Experience**: Clear documentation and practical examples
5. **Maintainability**: Consistent patterns and modular structure

## 🚀 Getting Started

### Prerequisites

- Understanding of OpenAPI Specification 3.1.x
- Knowledge of RESTful API design principles
- Familiarity with YAML syntax and formatting
- Basic understanding of HTTP protocols and status codes

### Quick Start

1. **Review the main AI instructions**
   ```bash
   cat .github/copilot-instructions.md
   ```

2. **Choose your generation approach**
   - Use the comprehensive [OpenAPI Generator Prompt](.github/prompts/openapi-generator.prompt.md)
   - Start with [Project Initialization](.github/prompts/project-initialization.prompt.md)

3. **Follow the instruction modules**
   - [Architecture Guidelines](.github/instructions/architecture.instructions.md)
   - [Security Implementation](.github/instructions/security.instructions.md)
   - [API Design Patterns](.github/instructions/api-design.instructions.md)

4. **Validate your specification**
   ```bash
   # Example validation commands
   swagger-codegen validate -i openapi.yaml
   spectral lint openapi.yaml
   ```

## 🤖 AI-Guided Development

This project includes comprehensive AI instructions to guide development:

### Available Instructions

- **[Main AI Instructions](.github/copilot-instructions.md)** - Core principles and guidelines
- **[Architecture Guide](.github/instructions/architecture.instructions.md)** - API design patterns and structure
- **[Security Guide](.github/instructions/security.instructions.md)** - Authentication and authorization
- **[Testing Guide](.github/instructions/testing.instructions.md)** - Validation and quality assurance
- **[Coding Standards](.github/instructions/coding-standards.instructions.md)** - Code quality and consistency
- **[YAML Formatting](.github/instructions/yaml-formatting.instructions.md)** - Proper YAML structure
- **[API Design](.github/instructions/api-design.instructions.md)** - RESTful design principles

### Available Prompts

- **[OpenAPI Generator](.github/prompts/openapi-generator.prompt.md)** - Complete specification generation
- **[Project Initialization](.github/prompts/project-initialization.prompt.md)** - Project setup and planning

### Using AI Instructions

1. **Start with Requirements Analysis**
   - Understand your API domain and business requirements
   - Identify resources and their relationships
   - Define security and compliance needs

2. **Choose Appropriate Guidelines**
   - Follow architecture patterns for your use case
   - Apply security requirements based on your needs
   - Use testing strategies appropriate for your environment

3. **Apply Quality Standards**
   - Follow **MUST**, **SHOULD**, and **NICE TO HAVE** guidelines
   - Use provided code examples as templates
   - Apply anti-patterns checklist to avoid common mistakes

4. **Validate and Iterate**
   - Use validation checklists in each instruction file
   - Test examples against their schemas
   - Review for consistency and completeness

## 📁 Project Structure

```
openapi-yaml-generator-boilerplate/
├── .github/                                    # AI instructions and prompts
│   ├── copilot-instructions.md                # Main AI development guidance
│   ├── instructions/                          # Modular instruction files
│   │   ├── architecture.instructions.md       # Architecture patterns
│   │   ├── security.instructions.md           # Security implementation
│   │   ├── testing.instructions.md            # Testing strategies
│   │   ├── coding-standards.instructions.md   # Code quality standards
│   │   ├── yaml-formatting.instructions.md    # YAML structure guidelines
│   │   ├── api-design.instructions.md         # RESTful design patterns
│   │   └── gitignore.instructions.md          # Version control patterns
│   └── prompts/                               # Ready-to-use AI prompts
│       ├── openapi-generator.prompt.md        # Complete spec generation
│       └── project-initialization.prompt.md   # Project setup guidance
├── docs/                                      # Documentation and examples
│   ├── openapi/                              # OpenAPI-specific documentation
│   └── examples/                             # Implementation examples
├── README.md                                 # This file
└── .gitignore                                # Version control exclusions
```

## 💻 Technology Stack

### Core Technologies
- **OpenAPI Specification**: 3.1.x (latest stable)
- **YAML**: RFC 1123 compliant formatting with 2-space indentation
- **JSON Schema**: Draft 2020-12 for validation
- **HTTP/HTTPS**: Standard protocols with proper semantic usage

### Supported Features
- **Authentication**: OAuth2, OpenID Connect, JWT Bearer, API Key, Basic Auth
- **Media Types**: application/json, application/xml, text/plain, multipart/form-data
- **HTTP Methods**: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS
- **Validation**: Comprehensive schema validation and constraint checking

### Development Tools
- **Validation**: Swagger Validator, Spectral, OpenAPI Generator CLI
- **Documentation**: Redoc, SwaggerUI, Stoplight Studio
- **Testing**: Contract testing, mock servers, automated validation
- **Code Generation**: Client SDKs, server stubs, documentation

## 📖 Usage Examples

### Basic API Specification

```yaml
openapi: 3.1.0
info:
  title: User Management API
  description: |
    RESTful API for managing user accounts and profiles.
    
    ## Features
    - User registration and authentication
    - Profile management
    - Account security
  version: 1.0.0
  contact:
    name: API Support
    email: api-support@example.com

servers:
  - url: https://api.example.com/v1
    description: Production server

paths:
  /users:
    get:
      summary: List users
      description: Retrieve a paginated list of users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            minimum: 1
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
      responses:
        '200':
          description: Successfully retrieved users
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  pagination:
                    $ref: '#/components/schemas/Pagination'

components:
  schemas:
    User:
      type: object
      required:
        - id
        - email
        - firstName
        - lastName
      properties:
        id:
          type: string
          format: uuid
          example: "123e4567-e89b-12d3-a456-426614174000"
        email:
          type: string
          format: email
          example: "user@example.com"
        firstName:
          type: string
          example: "John"
        lastName:
          type: string
          example: "Doe"
```

### Security Implementation

```yaml
components:
  securitySchemes:
    oauth2:
      type: oauth2
      flows:
        authorizationCode:
          authorizationUrl: https://auth.example.com/oauth/authorize
          tokenUrl: https://auth.example.com/oauth/token
          scopes:
            read: Read access to resources
            write: Write access to resources
            admin: Administrative access

security:
  - oauth2: [read]

paths:
  /admin/users:
    get:
      summary: Administrative user listing
      security:
        - oauth2: [admin]
      responses:
        '200':
          description: Admin user data
        '403':
          description: Insufficient permissions
```

## 🔍 Quality Assurance

### Validation Checklist

**MUST** verify:
- [ ] OpenAPI specification validates against 3.1.x schema
- [ ] All endpoints follow RESTful design principles
- [ ] HTTP methods and status codes are semantically correct
- [ ] Security schemes are properly implemented
- [ ] Examples validate against their schemas

**SHOULD** check:
- [ ] Documentation is comprehensive and clear
- [ ] Error handling is consistent across endpoints
- [ ] Performance considerations are addressed
- [ ] Naming conventions are applied consistently
- [ ] YAML formatting follows 2-space indentation standard

### Testing Strategies

1. **Schema Validation**: Ensure all examples validate against schemas
2. **Contract Testing**: Verify API contracts with consumers
3. **Security Testing**: Validate authentication and authorization
4. **Performance Testing**: Check response times and throughput
5. **Integration Testing**: Test with real implementations

### Tools and Automation

```bash
# Validation tools
swagger-codegen validate -i openapi.yaml
spectral lint openapi.yaml --ruleset .spectral.yml
redoc-cli validate openapi.yaml

# Testing tools
postman collection import openapi.yaml
insomnia import openapi.yaml
curl -X POST "$(swagger-codegen generate -i openapi.yaml -g mock-server)"
```

## 📚 Best Practices

### API Design
- Use resource-oriented URLs with nouns
- Apply HTTP methods semantically
- Implement consistent error response formats
- Include comprehensive pagination for collections
- Design for backward compatibility

### Security
- Always use HTTPS for production
- Implement proper authentication and authorization
- Use scoped permissions for fine-grained access
- Include rate limiting and input validation
- Never expose sensitive data in URLs

### Documentation
- Write clear, actionable descriptions
- Include realistic examples for all operations
- Document error scenarios comprehensively
- Provide integration guides and tutorials
- Keep documentation synchronized with implementation

### Performance
- Design efficient resource representations
- Implement appropriate caching strategies
- Use pagination for large collections
- Consider field selection for large objects
- Monitor and optimize based on usage patterns

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- Code of conduct
- Development process
- Submitting improvements
- Reporting issues
- Adding new instruction modules

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Follow the instruction format standards
4. Test with AI agents (GitHub Copilot recommended)
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Resources

- [OpenAPI Specification 3.1.0](https://spec.openapis.org/oas/v3.1.0)
- [HTTP Semantics (RFC 9110)](https://httpwg.org/specs/rfc9110.html)
- [JSON Schema Draft 2020-12](https://json-schema.org/draft/2020-12/schema)
- [RESTful API Design Best Practices](https://restfulapi.net/)
- [API Security Best Practices](https://owasp.org/www-project-api-security/)

## 📞 Support

For questions, issues, or contributions:

- Create an issue in the repository
- Contact the maintainers
- Join our community discussions
- Check the documentation for detailed guidance

---

**Happy API Designing!** 🚀
