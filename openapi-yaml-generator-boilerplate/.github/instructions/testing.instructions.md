---
applyTo: '**'
---

# Testing Instructions

This document provides comprehensive testing guidance for OpenAPI YAML specifications, including validation strategies, testing approaches, and quality assurance practices.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** validate all generated OpenAPI YAML files against the OpenAPI 3.1.x schema
- **REQUIRED** to include realistic examples for all request and response schemas
- **SHALL** test all defined endpoints with appropriate test cases
- **NEVER** deploy specifications without proper validation and testing

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** implement contract testing between API specifications and implementations
- **RECOMMENDED** to use automated validation tools in CI/CD pipelines
- **ALWAYS** test error scenarios and edge cases
- **DO** validate examples against their corresponding schemas
- **DON'T** rely solely on syntax validation without semantic testing

### Optional Enhancements (**MAY** Consider)
- **MAY** implement property-based testing for schema validation
- **OPTIONAL** to include performance testing scenarios in specifications
- **USE** mock servers generated from OpenAPI specifications for testing
- **IMPLEMENT** automated regression testing for specification changes
- **AVOID** manual testing only for complex API specifications

## Implementation Guidance

**USE** these validation approaches:

### Schema Validation Tools
```yaml
# Example of validation configuration
validation:
  tools:
    - name: "OpenAPI Validator"
      command: "swagger-codegen validate -i openapi.yaml"
    - name: "Spectral Linting"
      command: "spectral lint openapi.yaml"
    - name: "Redoc CLI"
      command: "redoc-cli validate openapi.yaml"
```

### Example Validation Rules
```yaml
# Spectral configuration for OpenAPI validation
extends: ["spectral:oas"]
rules:
  operation-description: true
  operation-operationId: true
  operation-summary: true
  parameter-description: true
  schema-description: true
  info-contact: true
  info-description: true
  info-license: true
  no-$ref-siblings: true
  typed-enum: true
  oas3-examples-value-or-externalValue: true
```

**IMPLEMENT** these testing patterns:

### Request/Response Example Testing
```yaml
paths:
  /users:
    post:
      summary: Create user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
            examples:
              valid_user:
                summary: Valid user creation request
                value:
                  firstName: "John"
                  lastName: "Doe"
                  email: "john.doe@example.com"
                  age: 30
              minimal_user:
                summary: Minimal required fields
                value:
                  firstName: "Jane"
                  lastName: "Smith"
                  email: "jane.smith@example.com"
      responses:
        '201':
          description: User created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserResponse'
              examples:
                created_user:
                  summary: Successfully created user
                  value:
                    id: "123e4567-e89b-12d3-a456-426614174000"
                    firstName: "John"
                    lastName: "Doe"
                    email: "john.doe@example.com"
                    age: 30
                    createdAt: "2023-01-01T12:00:00Z"
                    status: "active"
        '400':
          description: Invalid request data
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
              examples:
                validation_error:
                  summary: Field validation error
                  value:
                    error: "VALIDATION_ERROR"
                    message: "Invalid input data"
                    details:
                      - field: "email"
                        message: "Invalid email format"
                      - field: "age"
                        message: "Age must be between 18 and 120"
                duplicate_email:
                  summary: Duplicate email error
                  value:
                    error: "DUPLICATE_EMAIL"
                    message: "User with this email already exists"
```

### Contract Testing Specification
```yaml
# Example contract testing scenarios
x-contract-tests:
  scenarios:
    - name: "Create User Happy Path"
      operation: "POST /users"
      request:
        example: "valid_user"
      expectedResponse:
        status: 201
        example: "created_user"
    
    - name: "Create User Validation Error"
      operation: "POST /users"
      request:
        body:
          firstName: ""
          lastName: "Doe"
          email: "invalid-email"
          age: 17
      expectedResponse:
        status: 400
        schema: "#/components/schemas/ErrorResponse"
    
    - name: "Get User Not Found"
      operation: "GET /users/{userId}"
      parameters:
        userId: "00000000-0000-0000-0000-000000000000"
      expectedResponse:
        status: 404
        schema: "#/components/schemas/ErrorResponse"
```

**ENSURE** these testing validations:
- All examples validate against their corresponding schemas
- Error responses cover all possible error conditions
- Request/response pairs are consistent and realistic
- Security requirements are properly tested

## Anti-Patterns

**DON'T** implement these testing approaches:
- **Syntax-only validation**: Only checking YAML syntax without semantic validation
- **Unrealistic examples**: Using placeholder data that doesn't represent real usage
- **Missing error cases**: Not defining examples for error scenarios
- **Incomplete coverage**: Testing only happy path scenarios

**AVOID** these common mistakes:
- **Schema-example mismatch**: Examples that don't validate against their schemas
- **Inconsistent data types**: Mixed data types across similar examples
- **Missing edge cases**: Not testing boundary conditions and limits
- **Outdated examples**: Examples that don't reflect current API behavior

**NEVER** do these actions:
- **Skip validation**: Deploying specifications without proper validation
- **Ignore warnings**: Dismissing linting warnings without investigation
- **Hardcode test data**: Using production data in testing examples
- **Manual-only testing**: Relying solely on manual validation processes

## Code Examples

### Comprehensive Testing Schema
```yaml
openapi: 3.1.0
info:
  title: User Management API
  version: 1.0.0
  description: API for user management with comprehensive testing examples

paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            minimum: 1
            default: 1
          examples:
            first_page:
              value: 1
              summary: First page
            middle_page:
              value: 5
              summary: Middle page
        - name: limit
          in: query
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
          examples:
            default_limit:
              value: 20
              summary: Default page size
            small_page:
              value: 5
              summary: Small page size
            large_page:
              value: 100
              summary: Maximum page size
      responses:
        '200':
          description: List of users
          content:
            application/json:
              schema:
                type: object
                required:
                  - data
                  - pagination
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  pagination:
                    $ref: '#/components/schemas/Pagination'
              examples:
                users_list:
                  summary: Successful user list response
                  value:
                    data:
                      - id: "123e4567-e89b-12d3-a456-426614174000"
                        firstName: "John"
                        lastName: "Doe"
                        email: "john.doe@example.com"
                        createdAt: "2023-01-01T12:00:00Z"
                      - id: "987fcdeb-51d2-43ba-9876-543210987654"
                        firstName: "Jane"
                        lastName: "Smith"
                        email: "jane.smith@example.com"
                        createdAt: "2023-01-02T10:30:00Z"
                    pagination:
                      page: 1
                      limit: 20
                      total: 2
                      hasNext: false
                empty_list:
                  summary: Empty user list
                  value:
                    data: []
                    pagination:
                      page: 1
                      limit: 20
                      total: 0
                      hasNext: false
        '400':
          description: Invalid query parameters
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
              examples:
                invalid_page:
                  summary: Invalid page parameter
                  value:
                    error: "INVALID_PARAMETER"
                    message: "Page must be a positive integer"
                    details:
                      - field: "page"
                        value: "0"
                        message: "Page must be greater than 0"
                invalid_limit:
                  summary: Invalid limit parameter
                  value:
                    error: "INVALID_PARAMETER"
                    message: "Limit exceeds maximum allowed value"
                    details:
                      - field: "limit"
                        value: "150"
                        message: "Limit must not exceed 100"

components:
  schemas:
    User:
      type: object
      required:
        - id
        - firstName
        - lastName
        - email
        - createdAt
      properties:
        id:
          type: string
          format: uuid
          description: Unique user identifier
          example: "123e4567-e89b-12d3-a456-426614174000"
        firstName:
          type: string
          minLength: 1
          maxLength: 50
          pattern: "^[a-zA-Z\\s]+$"
          description: User's first name
          example: "John"
        lastName:
          type: string
          minLength: 1
          maxLength: 50
          pattern: "^[a-zA-Z\\s]+$"
          description: User's last name
          example: "Doe"
        email:
          type: string
          format: email
          description: User's email address
          example: "john.doe@example.com"
        age:
          type: integer
          minimum: 18
          maximum: 120
          description: User's age
          example: 30
        createdAt:
          type: string
          format: date-time
          description: Account creation timestamp
          example: "2023-01-01T12:00:00Z"
        updatedAt:
          type: string
          format: date-time
          description: Last update timestamp
          example: "2023-01-01T12:00:00Z"

    Pagination:
      type: object
      required:
        - page
        - limit
        - total
        - hasNext
      properties:
        page:
          type: integer
          minimum: 1
          description: Current page number
          example: 1
        limit:
          type: integer
          minimum: 1
          maximum: 100
          description: Items per page
          example: 20
        total:
          type: integer
          minimum: 0
          description: Total number of items
          example: 42
        hasNext:
          type: boolean
          description: Whether there are more pages
          example: true

    ErrorResponse:
      type: object
      required:
        - error
        - message
      properties:
        error:
          type: string
          description: Error code
          enum:
            - VALIDATION_ERROR
            - NOT_FOUND
            - UNAUTHORIZED
            - FORBIDDEN
            - INTERNAL_ERROR
            - INVALID_PARAMETER
          example: "VALIDATION_ERROR"
        message:
          type: string
          description: Human-readable error message
          example: "Invalid input data"
        details:
          type: array
          description: Detailed error information
          items:
            type: object
            required:
              - field
              - message
            properties:
              field:
                type: string
                description: Field that caused the error
                example: "email"
              value:
                type: string
                description: Invalid value that was provided
                example: "invalid-email"
              message:
                type: string
                description: Specific error message for this field
                example: "Invalid email format"

# Testing configuration
x-testing-config:
  validation:
    tools:
      - swagger-validator
      - spectral
      - openapi-generator-cli
  examples:
    validate-all: true
    required-fields: true
  contract-testing:
    enabled: true
    mock-server: true
    test-generation: true
```

## Validation Checklist

**MUST** verify:
- [ ] OpenAPI specification validates against OpenAPI 3.1.x schema
- [ ] All examples validate against their corresponding schemas
- [ ] Error responses are defined for all possible error conditions
- [ ] Request/response examples are realistic and complete
- [ ] Security requirements are properly tested

**SHOULD** check:
- [ ] Contract tests cover all major API operations
- [ ] Edge cases and boundary conditions are tested
- [ ] Automated validation is integrated into CI/CD pipeline
- [ ] Mock servers can be generated from the specification
- [ ] Performance and load testing scenarios are considered

## References

- [OpenAPI Specification Validation](https://spec.openapis.org/oas/v3.1.0)
- [Spectral OpenAPI Linting](https://meta.stoplight.io/docs/spectral)
- [Contract Testing with Pact](https://docs.pact.io/)
- [OpenAPI Generator Testing](https://openapi-generator.tech/)
