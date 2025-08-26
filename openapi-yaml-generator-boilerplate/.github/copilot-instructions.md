# OpenAPI YAML Generator Boilerplate - AI Development Assistant

This is a comprehensive OpenAPI YAML Generator boilerplate designed to accelerate high-quality OpenAPI specification development through AI-guided best practices and standardized generation templates.

This boilerplate provides AI agents with detailed instructions, patterns, and examples for generating production-ready OpenAPI 3.1.x YAML specifications that follow industry standards and best practices.

## Core Principles and Guidelines

**MUST** follow these fundamental principles when generating OpenAPI YAML specifications:
- **Specification Compliance**: All generated YAML **MUST** conform to OpenAPI Specification 3.1.x standards
- **RESTful Design**: APIs **MUST** follow RESTful architectural principles and HTTP semantics
- **Security-First**: Every specification **MUST** include appropriate security schemes and considerations
- **Documentation Excellence**: All endpoints **MUST** have comprehensive, clear documentation
- **Consistency**: Use consistent naming conventions, patterns, and structures throughout
- **Validation**: Generated specifications **MUST** be syntactically correct and semantically valid

## Technology Stack Specifications

**MUST** use these technologies and standards:
- **OpenAPI Specification**: Version 3.1.x (latest stable)
- **YAML Format**: RFC 1123 compliant YAML structure with proper indentation
- **JSON Schema**: Draft 2020-12 for request/response validation
- **HTTP Methods**: Standard HTTP verbs (GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS)
- **Media Types**: application/json, application/xml, text/plain, multipart/form-data
- **Security Schemes**: OAuth2, OpenID Connect, API Key, Bearer Token, Basic Auth

## Architecture Decision Framework

**ALWAYS** consider these architectural questions when generating OpenAPI specifications:
1. **API Design Pattern**: RESTful, Resource-oriented vs. RPC-style operations
2. **Resource Modeling**: How to represent entities, relationships, and collections
3. **Versioning Strategy**: Path-based, header-based, or parameter-based versioning
4. **Error Handling**: Consistent error response formats and HTTP status codes
5. **Security Architecture**: Authentication, authorization, and data protection requirements
6. **Performance Considerations**: Pagination, filtering, caching, and rate limiting
7. **Content Negotiation**: Supported media types and response formats
8. **Extensibility**: Custom headers, vendor extensions, and future-proofing
9. **Integration Patterns**: Webhook support, callback definitions, and event structures

## Development Standards

**ENSURE** all generated OpenAPI YAML follows these standards:
- **YAML Structure**: Proper indentation (2 spaces), consistent formatting, and valid syntax
- **Naming Conventions**: kebab-case for paths, camelCase for properties, PascalCase for schemas
- **Documentation Quality**: Clear descriptions, practical examples, and comprehensive coverage
- **Schema Definitions**: Reusable components, proper data types, and validation rules
- **Response Structures**: Consistent error formats, proper status codes, and complete examples

**DO** implement these patterns:
- **Resource-based URLs**: `/users/{id}`, `/orders/{orderId}/items`
- **HTTP Method Semantics**: GET for retrieval, POST for creation, PUT for updates
- **Status Code Usage**: 200 for success, 201 for creation, 400 for client errors, 500 for server errors
- **Component Reuse**: Shared schemas, parameters, and response definitions
- **Security Integration**: Proper security requirement definitions and scope management

**DON'T** implement these anti-patterns:
- **RPC-style URLs**: `/getUser`, `/createOrder`, `/updatePassword`
- **Inconsistent Naming**: Mixed case conventions or unclear property names
- **Poor Documentation**: Vague descriptions or missing examples
- **Monolithic Schemas**: Overly complex or non-reusable component definitions
- **Security Neglect**: Missing authentication or inadequate authorization schemes

## Quality Requirements

**MUST** include for every OpenAPI specification:
- **Complete Info Object**: Title, description, version, contact, license, and terms of service
- **Server Definitions**: Development, staging, and production environment URLs
- **Security Schemes**: Appropriate authentication and authorization mechanisms
- **Comprehensive Schemas**: Full request/response models with validation rules
- **Error Responses**: Standard error formats for all possible error conditions
- **Examples**: Realistic request/response examples for all endpoints

**SHOULD** consider:
- **Advanced Features**: Callbacks, webhooks, and event-driven patterns
- **Performance Optimization**: Pagination, filtering, and caching headers
- **Monitoring Integration**: Health check endpoints and operational metadata
- **Developer Experience**: Clear documentation, interactive examples, and SDK generation support

**NICE TO HAVE**:
- **Advanced Security**: Rate limiting, IP whitelisting, and threat protection
- **Analytics Integration**: Request tracking, usage metrics, and performance monitoring
- **Multi-language Support**: Internationalization headers and localized content
- **Advanced Validation**: Custom formats, business rule validation, and data constraints

## Sub-Instructions

Reference to modular instruction files:
- **[Architecture Guide](./instructions/architecture.instructions.md)**
- **[Security Guide](./instructions/security.instructions.md)**
- **[Testing Guide](./instructions/testing.instructions.md)**
- **[Coding Standards](./instructions/coding-standards.instructions.md)**
- **[YAML Formatting Guide](./instructions/yaml-formatting.instructions.md)**
- **[API Design Guide](./instructions/api-design.instructions.md)**
