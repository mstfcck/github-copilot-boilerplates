---
applyTo: '**'
---

# Architecture Instructions

This document provides comprehensive architectural guidance for generating OpenAPI YAML specifications that follow industry-standard patterns and best practices for API design.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** design APIs following RESTful architectural principles and constraints
- **REQUIRED** to use resource-oriented design patterns with clear hierarchies
- **SHALL** implement proper HTTP method semantics (GET, POST, PUT, PATCH, DELETE)
- **NEVER** use RPC-style operation names in URL paths (avoid `/getUser`, `/createOrder`)

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** implement consistent resource naming conventions using nouns
- **RECOMMENDED** to use nested resources for hierarchical relationships
- **ALWAYS** include proper HTTP status codes for all response scenarios
- **DO** design for statelessness with self-contained requests
- **DON'T** expose internal implementation details in API structure

### Optional Enhancements (**MAY** Consider)
- **MAY** implement HATEOAS (Hypermedia as the Engine of Application State)
- **OPTIONAL** to include advanced features like partial responses and field selection
- **USE** API versioning strategies appropriate for the use case
- **IMPLEMENT** caching strategies with appropriate cache headers
- **AVOID** premature optimization without performance requirements

## Implementation Guidance

**USE** these architectural patterns:

### Resource-Oriented Design
```yaml
paths:
  /users:
    get:
      summary: List users
      description: Retrieve a paginated list of users
  /users/{userId}:
    get:
      summary: Get user by ID
      description: Retrieve a specific user by their unique identifier
  /users/{userId}/orders:
    get:
      summary: List user orders
      description: Retrieve orders belonging to a specific user
```

### HTTP Method Usage
```yaml
paths:
  /products:
    get:
      summary: List products
      description: Retrieve all products with optional filtering
    post:
      summary: Create product
      description: Create a new product
  /products/{productId}:
    get:
      summary: Get product
      description: Retrieve a specific product
    put:
      summary: Update product
      description: Update an entire product resource
    patch:
      summary: Partially update product
      description: Update specific fields of a product
    delete:
      summary: Delete product
      description: Remove a product from the system
```

**IMPLEMENT** these structural patterns:

### Consistent Response Structures
```yaml
components:
  schemas:
    SuccessResponse:
      type: object
      required:
        - data
        - meta
      properties:
        data:
          description: The response payload
        meta:
          $ref: '#/components/schemas/Meta'
    
    ErrorResponse:
      type: object
      required:
        - error
      properties:
        error:
          $ref: '#/components/schemas/Error'
    
    Meta:
      type: object
      properties:
        timestamp:
          type: string
          format: date-time
        version:
          type: string
        pagination:
          $ref: '#/components/schemas/Pagination'
```

**ENSURE** these architectural validations:
- All endpoints follow consistent URL patterns and resource hierarchies
- HTTP methods align with their semantic meanings and side effects
- Response structures maintain consistency across the entire API
- Error handling follows standardized patterns and status codes

## Anti-Patterns

**DON'T** implement these architectural approaches:
- **RPC-style endpoints**: `/api/getUserById`, `/api/createNewOrder`
- **Verb-based URLs**: `/api/users/create`, `/api/orders/update`
- **Inconsistent nesting**: Deep nesting beyond 2-3 levels without clear hierarchy
- **Method tunneling**: Using POST for all operations regardless of semantics

**AVOID** these common mistakes:
- **Mixed architectural styles**: Combining REST with RPC patterns inconsistently
- **Poor resource modeling**: Resources that don't represent clear business entities
- **Status code misuse**: Using 200 OK for all responses regardless of operation
- **Stateful operations**: APIs that require specific operation sequences

**NEVER** do these actions:
- **Expose database structure**: Direct mapping of database tables to API resources
- **Ignore HTTP semantics**: Using incorrect methods or status codes
- **Break idempotency**: Non-idempotent operations using idempotent HTTP methods
- **Violate REST constraints**: Maintaining server-side session state

## Code Examples

### Complete Resource Design Example
```yaml
openapi: 3.1.0
info:
  title: E-commerce API
  version: 1.0.0
  description: RESTful API for e-commerce operations

paths:
  /customers:
    get:
      summary: List customers
      description: Retrieve a paginated list of customers
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
            maximum: 100
      responses:
        '200':
          description: Successfully retrieved customers
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/CustomerListResponse'
    
    post:
      summary: Create customer
      description: Create a new customer account
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateCustomerRequest'
      responses:
        '201':
          description: Customer created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/CustomerResponse'
        '400':
          description: Invalid request data
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'

  /customers/{customerId}:
    get:
      summary: Get customer by ID
      description: Retrieve a specific customer by their unique identifier
      parameters:
        - name: customerId
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: Customer found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/CustomerResponse'
        '404':
          description: Customer not found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'

components:
  schemas:
    Customer:
      type: object
      required:
        - id
        - email
        - firstName
        - lastName
        - createdAt
      properties:
        id:
          type: string
          format: uuid
          description: Unique customer identifier
        email:
          type: string
          format: email
          description: Customer email address
        firstName:
          type: string
          minLength: 1
          maxLength: 50
          description: Customer first name
        lastName:
          type: string
          minLength: 1
          maxLength: 50
          description: Customer last name
        createdAt:
          type: string
          format: date-time
          description: Account creation timestamp
```

## Validation Checklist

**MUST** verify:
- [ ] All URLs follow resource-oriented patterns with nouns
- [ ] HTTP methods align with operation semantics
- [ ] Response status codes are appropriate for each operation
- [ ] Resource hierarchies are logical and consistent
- [ ] Error responses follow standardized formats

**SHOULD** check:
- [ ] API design follows REST architectural constraints
- [ ] Pagination is implemented for collection resources
- [ ] Filtering and sorting options are provided where appropriate
- [ ] Caching headers are included for appropriate responses
- [ ] API versioning strategy is clearly defined

## References

- [REST API Design Best Practices](https://restfulapi.net/)
- [OpenAPI Specification 3.1.0](https://spec.openapis.org/oas/v3.1.0)
- [HTTP Status Codes Registry](https://www.iana.org/assignments/http-status-codes/)
- [RESTful Web APIs by Leonard Richardson](https://www.oreilly.com/library/view/restful-web-apis/9781449359713/)
