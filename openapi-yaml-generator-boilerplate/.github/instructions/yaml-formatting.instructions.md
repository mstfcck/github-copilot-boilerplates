---
applyTo: '**'
---

# YAML Formatting Instructions

This document provides comprehensive YAML formatting guidelines specifically for OpenAPI specifications, ensuring consistent, readable, and maintainable YAML structure.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** use exactly 2 spaces for indentation throughout all YAML files
- **REQUIRED** to maintain consistent line breaks and spacing patterns
- **SHALL** follow proper YAML scalar and collection formatting rules
- **NEVER** use tabs for indentation or mixing spaces and tabs

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** use block scalar style for multi-line descriptions
- **RECOMMENDED** to maintain consistent property ordering within objects
- **ALWAYS** use consistent quoting rules for strings
- **DO** align related properties for better readability
- **DON'T** exceed 120 characters per line when possible

### Optional Enhancements (**MAY** Consider)
- **MAY** use YAML anchors and aliases for repeated structures
- **OPTIONAL** to include meaningful comments for complex sections
- **USE** consistent formatting for arrays and objects
- **IMPLEMENT** logical grouping of related properties
- **AVOID** overly dense formatting that reduces readability

## Implementation Guidance

**USE** these YAML formatting patterns:

### Indentation and Structure
```yaml
# Correct: 2-space indentation
openapi: 3.1.0
info:
  title: Example API
  description: |
    This is a multi-line description that demonstrates
    proper YAML formatting for OpenAPI specifications.
    
    It includes multiple paragraphs and maintains
    proper indentation throughout.
  version: 1.0.0
  contact:
    name: API Support
    email: support@example.com
    url: https://example.com/support

servers:
  - url: https://api.example.com/v1
    description: Production server
  - url: https://staging.example.com/v1
    description: Staging server

# Incorrect: Inconsistent indentation
openapi: 3.1.0
info:
   title: Example API              # 3 spaces
  description: Bad formatting      # 2 spaces
    version: 1.0.0                # 4 spaces
```

### String Formatting and Escaping
```yaml
# String handling examples
components:
  schemas:
    UserPreferences:
      type: object
      properties:
        # Simple strings (no quotes needed)
        username:
          type: string
          example: john_doe
        
        # Strings with special characters (quotes recommended)
        display_name:
          type: string
          example: "John O'Doe"
        
        # Strings with YAML special characters (quotes required)
        search_query:
          type: string
          example: "name: John AND status: active"
        
        # Multi-line descriptions using literal block scalar
        bio:
          type: string
          description: |
            User's biographical information.
            
            This field supports markdown formatting:
            - **Bold text**
            - *Italic text*
            - [Links](https://example.com)
            
            Maximum length is 1000 characters.
          example: |
            Software engineer with 10+ years experience.
            
            Specializes in:
            - API design
            - Microservices architecture
            - Cloud platforms
        
        # Folded block scalar for long single-line text
        terms_acceptance:
          type: string
          description: >
            This is a long description that would normally
            be on multiple lines but should be treated as
            a single line with spaces replacing line breaks.
          example: "I agree to the terms and conditions as specified in the user agreement document."
```

### Array and Object Formatting
```yaml
# Array formatting patterns
paths:
  /users/{user_id}:
    get:
      summary: Get user by ID
      tags:
        - Users
        - Public API
      parameters:
        - name: user_id
          in: path
          required: true
          schema:
            type: string
            format: uuid
        - name: include_profile
          in: query
          required: false
          schema:
            type: boolean
            default: false
        - name: fields
          in: query
          description: Comma-separated list of fields to include
          required: false
          schema:
            type: array
            items:
              type: string
              enum:
                - id
                - username
                - email
                - profile
                - preferences
                - created_at
                - updated_at
          style: form
          explode: false
      responses:
        '200':
          description: User information retrieved successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserResponse'
        '404':
          description: User not found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
```

**IMPLEMENT** these YAML best practices:

### Consistent Property Ordering
```yaml
# Recommended property order for OpenAPI objects
components:
  schemas:
    Product:
      # 1. type (for schemas)
      type: object
      
      # 2. title/summary
      title: Product Information
      
      # 3. description
      description: |
        Represents a product in the e-commerce system.
        
        Products have various attributes including pricing,
        inventory, and categorization information.
      
      # 4. required fields
      required:
        - id
        - name
        - price
        - category_id
      
      # 5. properties (alphabetically ordered for consistency)
      properties:
        category_id:
          type: string
          format: uuid
          description: Reference to the product category
          example: "550e8400-e29b-41d4-a716-446655440000"
        
        created_at:
          type: string
          format: date-time
          description: Product creation timestamp
          example: "2023-01-01T12:00:00Z"
        
        description:
          type: string
          maxLength: 2000
          description: Detailed product description
          example: "High-quality wireless headphones with noise cancellation"
        
        id:
          type: string
          format: uuid
          description: Unique product identifier
          example: "123e4567-e89b-12d3-a456-426614174000"
        
        images:
          type: array
          description: Product image URLs
          maxItems: 10
          items:
            type: string
            format: uri
            example: "https://example.com/images/product1.jpg"
        
        inventory_count:
          type: integer
          minimum: 0
          description: Current inventory quantity
          example: 150
        
        name:
          type: string
          minLength: 1
          maxLength: 100
          description: Product name or title
          example: "Wireless Noise-Cancelling Headphones"
        
        price:
          type: number
          format: decimal
          minimum: 0
          multipleOf: 0.01
          description: Product price in USD
          example: 299.99
        
        sku:
          type: string
          pattern: "^[A-Z0-9-]+$"
          description: Stock Keeping Unit identifier
          example: "WH-NC-001"
        
        tags:
          type: array
          description: Product tags for categorization
          maxItems: 20
          items:
            type: string
            minLength: 1
            maxLength: 30
          example:
            - "electronics"
            - "audio"
            - "wireless"
        
        updated_at:
          type: string
          format: date-time
          description: Last update timestamp
          example: "2023-01-01T12:00:00Z"
        
        weight:
          type: number
          minimum: 0
          description: Product weight in kilograms
          example: 0.5
```

### Response and Error Formatting
```yaml
# Comprehensive response formatting
paths:
  /products:
    post:
      summary: Create new product
      description: |
        Creates a new product in the system.
        
        ## Validation Rules
        - Product name must be unique within the category
        - Price must be a positive decimal value
        - SKU must follow the company format: [A-Z0-9-]+
        
        ## Response Behavior
        - Returns 201 with the created product on success
        - Returns 400 for validation errors
        - Returns 409 for duplicate SKU conflicts
      
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateProductRequest'
            examples:
              standard_product:
                summary: Standard product creation
                value:
                  name: "Wireless Mouse"
                  description: "Ergonomic wireless mouse with USB receiver"
                  price: 29.99
                  category_id: "550e8400-e29b-41d4-a716-446655440000"
                  sku: "WM-ERG-001"
                  inventory_count: 100
                  weight: 0.15
                  tags:
                    - "electronics"
                    - "computer-accessories"
              
              premium_product:
                summary: Premium product with multiple images
                value:
                  name: "Professional Studio Headphones"
                  description: "High-end studio monitoring headphones"
                  price: 599.99
                  category_id: "550e8400-e29b-41d4-a716-446655440000"
                  sku: "PSH-PRO-001"
                  inventory_count: 25
                  weight: 0.8
                  images:
                    - "https://example.com/images/psh-pro-001-front.jpg"
                    - "https://example.com/images/psh-pro-001-side.jpg"
                    - "https://example.com/images/psh-pro-001-back.jpg"
                  tags:
                    - "electronics"
                    - "audio"
                    - "professional"
      
      responses:
        '201':
          description: Product created successfully
          headers:
            Location:
              description: URL of the created product
              schema:
                type: string
                format: uri
              example: "/products/123e4567-e89b-12d3-a456-426614174000"
            
            X-Rate-Limit-Remaining:
              description: Number of requests remaining in the current window
              schema:
                type: integer
              example: 99
          
          content:
            application/json:
              schema:
                type: object
                required:
                  - data
                  - meta
                properties:
                  data:
                    $ref: '#/components/schemas/Product'
                  meta:
                    type: object
                    required:
                      - created_at
                      - version
                    properties:
                      created_at:
                        type: string
                        format: date-time
                        description: Response generation timestamp
                      version:
                        type: string
                        description: API version used
                        example: "1.0.0"
              
              examples:
                created_product:
                  summary: Successfully created product
                  value:
                    data:
                      id: "123e4567-e89b-12d3-a456-426614174000"
                      name: "Wireless Mouse"
                      description: "Ergonomic wireless mouse with USB receiver"
                      price: 29.99
                      category_id: "550e8400-e29b-41d4-a716-446655440000"
                      sku: "WM-ERG-001"
                      inventory_count: 100
                      weight: 0.15
                      tags:
                        - "electronics"
                        - "computer-accessories"
                      created_at: "2023-01-01T12:00:00Z"
                      updated_at: "2023-01-01T12:00:00Z"
                    meta:
                      created_at: "2023-01-01T12:00:01Z"
                      version: "1.0.0"
        
        '400':
          description: Invalid request data
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ValidationErrorResponse'
              examples:
                validation_errors:
                  summary: Multiple validation errors
                  value:
                    error:
                      code: "VALIDATION_ERROR"
                      message: "Request contains invalid data"
                      details:
                        - field: "name"
                          code: "REQUIRED"
                          message: "Product name is required"
                        - field: "price"
                          code: "INVALID_FORMAT"
                          message: "Price must be a positive decimal value"
                          provided_value: "-10.50"
                        - field: "sku"
                          code: "INVALID_PATTERN"
                          message: "SKU must match pattern: [A-Z0-9-]+"
                          provided_value: "wm_erg_001"
                    meta:
                      request_id: "req_123456789abcdef"
                      timestamp: "2023-01-01T12:00:00Z"
                      validation_rules_version: "1.2.0"
        
        '409':
          description: Conflict - duplicate SKU
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ConflictErrorResponse'
              examples:
                duplicate_sku:
                  summary: SKU already exists
                  value:
                    error:
                      code: "DUPLICATE_SKU"
                      message: "A product with this SKU already exists"
                      conflicting_resource:
                        type: "product"
                        id: "987fcdeb-51d2-43ba-9876-543210987654"
                        sku: "WM-ERG-001"
                    meta:
                      request_id: "req_123456789abcdef"
                      timestamp: "2023-01-01T12:00:00Z"
```

**ENSURE** these formatting validations:
- Consistent 2-space indentation throughout
- Proper YAML scalar and collection syntax
- Logical property ordering and grouping
- Appropriate use of block scalars for multi-line content

## Anti-Patterns

**DON'T** implement these formatting approaches:
- **Tab indentation**: Using tabs instead of spaces
- **Inconsistent spacing**: Mixing different indentation levels
- **Poor line breaks**: Inconsistent or illogical line breaking
- **Mixed quoting styles**: Inconsistent string quoting patterns

**AVOID** these common mistakes:
- **Overly long lines**: Lines exceeding 120-150 characters
- **Dense formatting**: Insufficient whitespace for readability
- **Inconsistent array formatting**: Mixing flow and block styles inappropriately
- **Poor property ordering**: Random organization of object properties

**NEVER** do these actions:
- **Mix tabs and spaces**: Always use spaces consistently
- **Skip validation**: Use invalid YAML syntax
- **Ignore alignment**: Misalign related properties
- **Use complex anchors**: Overuse YAML anchors and aliases

## Validation Checklist

**MUST** verify:
- [ ] All indentation uses exactly 2 spaces
- [ ] YAML syntax is valid and parseable
- [ ] String quoting is consistent and appropriate
- [ ] Multi-line descriptions use proper block scalars
- [ ] Property ordering is logical and consistent

**SHOULD** check:
- [ ] Line length stays within reasonable limits (120-150 chars)
- [ ] Related properties are grouped logically
- [ ] Whitespace enhances readability
- [ ] Array and object formatting is consistent
- [ ] Comments are used effectively for complex sections

## References

- [YAML Specification 1.2](https://yaml.org/spec/1.2.2/)
- [YAML Best Practices](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html)
- [OpenAPI Style Guide](https://spec.openapis.org/oas/v3.1.0#style-guide)
- [YAML Lint Tools](https://yamllint.readthedocs.io/)
