# OpenAPI Best Practices

This document outlines best practices for creating high-quality OpenAPI specifications that are maintainable, scalable, and developer-friendly.

## General Principles

### 1. Design-First Approach
- Start with the API specification before implementation
- Use the specification as a contract between teams
- Generate documentation and client code from the specification

### 2. Resource-Oriented Design
- Use nouns for resource names, not verbs
- Organize endpoints around resources and their relationships
- Apply RESTful principles consistently

### 3. Comprehensive Documentation
- Include clear descriptions for all operations and schemas
- Provide realistic examples for all request and response objects
- Document error conditions and their resolution

## Naming Conventions

### URLs and Paths
```yaml
# Good
/users
/users/{user_id}
/users/{user_id}/orders

# Bad
/getUsers
/user/{id}
/getUserOrders/{userId}
```

### Schema Properties
```yaml
# Good - snake_case for properties
user_id: string
email_address: string
created_at: string

# Bad - mixed conventions
userId: string
emailAddress: string
createdAt: string
```

### Operation IDs
```yaml
# Good - descriptive and consistent
operationId: listUsers
operationId: getUserById
operationId: createUser

# Bad - unclear or inconsistent
operationId: getUsers
operationId: user
operationId: newUser
```

## HTTP Methods and Status Codes

### Method Usage
- **GET**: Retrieve data (safe and idempotent)
- **POST**: Create new resources or non-idempotent operations
- **PUT**: Update entire resources (idempotent)
- **PATCH**: Partial updates (idempotent)
- **DELETE**: Remove resources (idempotent)

### Status Codes
- **200**: Successful GET, PUT, PATCH operations
- **201**: Successful resource creation
- **204**: Successful operation with no content
- **400**: Client error (validation, malformed request)
- **401**: Authentication required
- **403**: Authorization failed
- **404**: Resource not found
- **409**: Conflict (duplicate resource)
- **422**: Unprocessable entity (semantic errors)
- **500**: Internal server error

## Security Implementation

### Authentication Schemes
```yaml
components:
  securitySchemes:
    # OAuth 2.0 for user authentication
    oauth2:
      type: oauth2
      flows:
        authorizationCode:
          authorizationUrl: https://auth.example.com/oauth/authorize
          tokenUrl: https://auth.example.com/oauth/token
          scopes:
            read: Read access
            write: Write access
    
    # API key for service authentication
    apiKey:
      type: apiKey
      in: header
      name: X-API-Key
    
    # JWT Bearer tokens
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

### Security Best Practices
- Always use HTTPS in production
- Implement appropriate authentication for all non-public endpoints
- Use scoped permissions for fine-grained access control
- Include security requirements at operation level
- Document security requirements clearly

## Error Handling

### Consistent Error Format
```yaml
components:
  schemas:
    ErrorResponse:
      type: object
      required:
        - error
        - message
        - timestamp
      properties:
        error:
          type: string
          description: Machine-readable error code
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
            properties:
              field:
                type: string
                example: "email"
              message:
                type: string
                example: "Invalid email format"
        timestamp:
          type: string
          format: date-time
          example: "2023-01-01T12:00:00Z"
        request_id:
          type: string
          description: Unique request identifier
          example: "req_123456789"
```

## Pagination and Filtering

### Offset-Based Pagination
```yaml
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
              type: object
              properties:
                page: { type: integer }
                limit: { type: integer }
                total: { type: integer }
                has_next: { type: boolean }
```

### Filtering Parameters
```yaml
parameters:
  - name: status
    in: query
    description: Filter by status
    schema:
      type: array
      items:
        type: string
        enum: [active, inactive, pending]
  - name: created_after
    in: query
    description: Filter by creation date
    schema:
      type: string
      format: date-time
```

## Versioning Strategies

### URL Path Versioning
```yaml
servers:
  - url: https://api.example.com/v1
    description: Version 1
  - url: https://api.example.com/v2
    description: Version 2
```

### Header Versioning
```yaml
parameters:
  - name: API-Version
    in: header
    schema:
      type: string
      enum: ["1.0", "2.0"]
      default: "2.0"
```

## Performance Considerations

### Field Selection
```yaml
parameters:
  - name: fields
    in: query
    description: Comma-separated list of fields to include
    schema:
      type: string
      example: "id,name,email"
```

### Caching Headers
```yaml
responses:
  '200':
    headers:
      Cache-Control:
        schema:
          type: string
        example: "public, max-age=3600"
      ETag:
        schema:
          type: string
        example: '"abc123"'
```

## Documentation Quality

### Descriptions
- Use clear, concise language
- Explain business context and use cases
- Include examples and edge cases
- Document relationships between resources

### Examples
- Provide realistic, representative data
- Include both successful and error scenarios
- Ensure examples validate against schemas
- Use consistent data across related examples

### Tags and Organization
```yaml
tags:
  - name: Users
    description: User account management
  - name: Orders
    description: Order processing and management
  - name: Authentication
    description: Authentication and authorization
```

## Common Anti-Patterns to Avoid

### URL Design
- Don't use verbs in URLs (`/getUser` → `/users/{id}`)
- Don't expose implementation details (`/api/v1/database/users`)
- Don't use inconsistent naming (`/user` vs `/users`)

### Response Design
- Don't return different structures for the same endpoint
- Don't include irrelevant data in responses
- Don't use generic error messages without context

### Schema Design
- Don't create overly complex nested structures
- Don't use unclear or abbreviated property names
- Don't forget to include validation constraints

This document serves as a comprehensive guide for creating high-quality OpenAPI specifications that are maintainable, scalable, and developer-friendly.
