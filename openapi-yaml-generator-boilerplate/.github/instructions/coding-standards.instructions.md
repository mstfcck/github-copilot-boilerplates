---
applyTo: '**'
---

# Coding Standards Instructions

This document provides comprehensive coding standards and quality guidelines for generating clean, consistent, and maintainable OpenAPI YAML specifications.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** use consistent indentation (2 spaces) throughout YAML files
- **REQUIRED** to follow kebab-case for path parameters and snake_case for schema properties
- **SHALL** include comprehensive descriptions for all API components
- **NEVER** use tabs for indentation in YAML files

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** use meaningful and descriptive names for all components
- **RECOMMENDED** to include examples for all schema properties
- **ALWAYS** use consistent formatting and structure across the specification
- **DO** organize components logically with clear separation of concerns
- **DON'T** use abbreviations or unclear naming conventions

### Optional Enhancements (**MAY** Consider)
- **MAY** use vendor extensions for additional metadata
- **OPTIONAL** to include external documentation references
- **USE** consistent ordering of properties within objects
- **IMPLEMENT** standardized comment structure for complex sections
- **AVOID** overly complex nested structures

## Implementation Guidance

**USE** these naming conventions:

### Path and Parameter Naming
```yaml
# Good: kebab-case for paths
paths:
  /user-profiles/{user-id}:
    parameters:
      - name: user-id
        in: path
        required: true
        schema:
          type: string
          format: uuid
  
  /order-history:
    get:
      operationId: getUserOrderHistory
      parameters:
        - name: start-date
          in: query
          schema:
            type: string
            format: date
        - name: end-date
          in: query
          schema:
            type: string
            format: date

# Bad: inconsistent naming
paths:
  /userProfiles/{userId}:    # Mixed camelCase and kebab-case
  /user_orders:              # snake_case in path
```

### Schema Property Naming
```yaml
components:
  schemas:
    UserProfile:
      type: object
      required:
        - user_id
        - email_address
        - created_at
      properties:
        user_id:
          type: string
          format: uuid
          description: Unique identifier for the user
          example: "123e4567-e89b-12d3-a456-426614174000"
        email_address:
          type: string
          format: email
          description: User's primary email address
          example: "user@example.com"
        first_name:
          type: string
          minLength: 1
          maxLength: 50
          description: User's first name
          example: "John"
        last_name:
          type: string
          minLength: 1
          maxLength: 50
          description: User's last name
          example: "Doe"
        date_of_birth:
          type: string
          format: date
          description: User's date of birth
          example: "1990-01-01"
        created_at:
          type: string
          format: date-time
          description: Timestamp when the user account was created
          example: "2023-01-01T12:00:00Z"
        updated_at:
          type: string
          format: date-time
          description: Timestamp when the user profile was last updated
          example: "2023-01-01T12:00:00Z"
```

**IMPLEMENT** these formatting standards:

### YAML Structure and Indentation
```yaml
openapi: 3.1.0
info:
  title: User Management API
  description: |
    A comprehensive API for managing user accounts and profiles.
    
    ## Features
    - User registration and authentication
    - Profile management
    - Order history tracking
    
    ## Authentication
    This API uses OAuth 2.0 for authentication.
  version: 1.0.0
  contact:
    name: API Support Team
    email: api-support@example.com
    url: https://example.com/support
  license:
    name: MIT License
    url: https://opensource.org/licenses/MIT

servers:
  - url: https://api.example.com/v1
    description: Production server
  - url: https://staging-api.example.com/v1
    description: Staging server
  - url: https://dev-api.example.com/v1
    description: Development server

paths:
  /users:
    get:
      summary: List users
      description: |
        Retrieve a paginated list of users with optional filtering.
        
        ## Filtering
        - Use query parameters to filter results
        - Supports partial matching on name fields
        
        ## Pagination
        - Default page size is 20 items
        - Maximum page size is 100 items
      operationId: listUsers
      tags:
        - Users
      parameters:
        - name: page
          in: query
          description: Page number for pagination (1-based)
          required: false
          schema:
            type: integer
            minimum: 1
            default: 1
            example: 1
        - name: limit
          in: query
          description: Number of items per page
          required: false
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
            example: 20
        - name: search
          in: query
          description: Search term for filtering users by name or email
          required: false
          schema:
            type: string
            minLength: 2
            maxLength: 100
            example: "john"
      responses:
        '200':
          description: Successfully retrieved list of users
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
                    $ref: '#/components/schemas/PaginationInfo'
              examples:
                success_response:
                  summary: Successful response with users
                  value:
                    data:
                      - user_id: "123e4567-e89b-12d3-a456-426614174000"
                        email_address: "john.doe@example.com"
                        first_name: "John"
                        last_name: "Doe"
                        created_at: "2023-01-01T12:00:00Z"
                    pagination:
                      current_page: 1
                      page_size: 20
                      total_items: 1
                      total_pages: 1
                      has_next_page: false
                      has_previous_page: false
        '400':
          $ref: '#/components/responses/BadRequestError'
        '401':
          $ref: '#/components/responses/UnauthorizedError'
        '500':
          $ref: '#/components/responses/InternalServerError'

components:
  schemas:
    User:
      type: object
      description: User account information
      required:
        - user_id
        - email_address
        - first_name
        - last_name
        - created_at
      properties:
        user_id:
          type: string
          format: uuid
          description: Unique identifier for the user
          example: "123e4567-e89b-12d3-a456-426614174000"
        email_address:
          type: string
          format: email
          description: User's primary email address
          example: "john.doe@example.com"
        first_name:
          type: string
          minLength: 1
          maxLength: 50
          pattern: "^[a-zA-Z\\s]+$"
          description: User's first name
          example: "John"
        last_name:
          type: string
          minLength: 1
          maxLength: 50
          pattern: "^[a-zA-Z\\s]+$"
          description: User's last name
          example: "Doe"
        middle_name:
          type: string
          maxLength: 50
          pattern: "^[a-zA-Z\\s]*$"
          description: User's middle name (optional)
          example: "Michael"
        date_of_birth:
          type: string
          format: date
          description: User's date of birth (ISO 8601 format)
          example: "1990-01-15"
        phone_number:
          type: string
          pattern: "^\\+?[1-9]\\d{1,14}$"
          description: User's phone number in E.164 format
          example: "+1234567890"
        created_at:
          type: string
          format: date-time
          description: Timestamp when the user account was created
          example: "2023-01-01T12:00:00Z"
        updated_at:
          type: string
          format: date-time
          description: Timestamp when the user account was last updated
          example: "2023-01-01T12:00:00Z"
        status:
          type: string
          enum:
            - active
            - inactive
            - suspended
            - pending_verification
          description: Current status of the user account
          example: "active"

    PaginationInfo:
      type: object
      description: Pagination metadata for list responses
      required:
        - current_page
        - page_size
        - total_items
        - total_pages
        - has_next_page
        - has_previous_page
      properties:
        current_page:
          type: integer
          minimum: 1
          description: Current page number (1-based)
          example: 1
        page_size:
          type: integer
          minimum: 1
          maximum: 100
          description: Number of items per page
          example: 20
        total_items:
          type: integer
          minimum: 0
          description: Total number of items across all pages
          example: 150
        total_pages:
          type: integer
          minimum: 0
          description: Total number of pages
          example: 8
        has_next_page:
          type: boolean
          description: Whether there is a next page available
          example: true
        has_previous_page:
          type: boolean
          description: Whether there is a previous page available
          example: false

  responses:
    BadRequestError:
      description: Invalid request parameters or body
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
          examples:
            validation_error:
              summary: Field validation error
              value:
                error_code: "VALIDATION_ERROR"
                error_message: "Invalid input parameters"
                error_details:
                  - field_name: "email_address"
                    error_message: "Invalid email format"
                  - field_name: "page"
                    error_message: "Page must be a positive integer"
                timestamp: "2023-01-01T12:00:00Z"
                request_id: "req_123456789"

    UnauthorizedError:
      description: Authentication required or invalid credentials
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
          examples:
            missing_token:
              summary: Missing authentication token
              value:
                error_code: "UNAUTHORIZED"
                error_message: "Authentication token is required"
                timestamp: "2023-01-01T12:00:00Z"
                request_id: "req_123456789"

    InternalServerError:
      description: Internal server error
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
          examples:
            server_error:
              summary: Internal server error
              value:
                error_code: "INTERNAL_ERROR"
                error_message: "An unexpected error occurred"
                timestamp: "2023-01-01T12:00:00Z"
                request_id: "req_123456789"

    ErrorResponse:
      type: object
      description: Standard error response format
      required:
        - error_code
        - error_message
        - timestamp
        - request_id
      properties:
        error_code:
          type: string
          description: Machine-readable error code
          enum:
            - VALIDATION_ERROR
            - UNAUTHORIZED
            - FORBIDDEN
            - NOT_FOUND
            - CONFLICT
            - RATE_LIMITED
            - INTERNAL_ERROR
          example: "VALIDATION_ERROR"
        error_message:
          type: string
          description: Human-readable error message
          example: "Invalid input parameters"
        error_details:
          type: array
          description: Detailed error information for validation errors
          items:
            type: object
            required:
              - field_name
              - error_message
            properties:
              field_name:
                type: string
                description: Name of the field that caused the error
                example: "email_address"
              field_value:
                type: string
                description: The invalid value that was provided
                example: "invalid-email"
              error_message:
                type: string
                description: Specific error message for this field
                example: "Invalid email format"
        timestamp:
          type: string
          format: date-time
          description: Timestamp when the error occurred
          example: "2023-01-01T12:00:00Z"
        request_id:
          type: string
          description: Unique identifier for the request (for debugging)
          example: "req_123456789"
```

**ENSURE** these quality standards:
- All properties have clear, descriptive names
- Consistent indentation and formatting throughout
- Comprehensive documentation for all components
- Realistic examples that validate against schemas

## Anti-Patterns

**DON'T** implement these coding approaches:
- **Inconsistent naming**: Mixing camelCase, snake_case, and kebab-case
- **Poor indentation**: Using tabs or inconsistent spacing
- **Missing documentation**: Components without descriptions or examples
- **Unclear naming**: Abbreviated or cryptic property names

**AVOID** these common mistakes:
- **Copy-paste errors**: Inconsistent structure between similar components
- **Hardcoded values**: Using specific environment URLs in examples
- **Missing validation**: Schemas without appropriate constraints
- **Overly complex nesting**: Deep object hierarchies that are hard to understand

**NEVER** do these actions:
- **Use tabs**: Always use spaces for YAML indentation
- **Skip examples**: Leave schemas without practical examples
- **Use production data**: Include real user data in examples
- **Ignore conventions**: Deviate from established naming patterns

## Validation Checklist

**MUST** verify:
- [ ] YAML syntax is valid and properly indented (2 spaces)
- [ ] All components follow consistent naming conventions
- [ ] Descriptions are comprehensive and clear
- [ ] Examples are realistic and validate against schemas
- [ ] Error responses follow standardized format

**SHOULD** check:
- [ ] Component organization is logical and maintainable
- [ ] Documentation includes sufficient detail for developers
- [ ] Validation rules are appropriate for data types
- [ ] Enum values are comprehensive and well-documented
- [ ] Property ordering is consistent across similar schemas

## References

- [YAML Specification](https://yaml.org/spec/1.2.2/)
- [OpenAPI Style Guide](https://spec.openapis.org/oas/v3.1.0#style-guide)
- [API Design Guidelines](https://cloud.google.com/apis/design)
- [RESTful API Naming Conventions](https://restfulapi.net/resource-naming/)
