---
applyTo: '**'
---

# API Design Instructions

This document provides comprehensive API design guidance for creating well-structured, intuitive, and maintainable RESTful APIs using OpenAPI specifications.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** design APIs following RESTful principles and HTTP semantics
- **REQUIRED** to use resource-oriented design with clear hierarchical relationships
- **SHALL** implement consistent error handling and status code usage
- **NEVER** expose internal implementation details through API design

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** implement comprehensive content negotiation and media type support
- **RECOMMENDED** to include proper versioning strategy from the start
- **ALWAYS** design for scalability and performance considerations
- **DO** implement pagination for collection resources
- **DON'T** create overly complex resource hierarchies

### Optional Enhancements (**MAY** Consider)
- **MAY** implement HATEOAS for enhanced discoverability
- **OPTIONAL** to include advanced filtering and search capabilities
- **USE** caching strategies appropriate for resource types
- **IMPLEMENT** webhook support for event-driven integrations
- **AVOID** premature optimization without clear performance requirements

## Implementation Guidance

**USE** these API design patterns:

### Resource Identification and Hierarchy
```yaml
# Well-designed resource hierarchy
paths:
  # Collections (plural nouns)
  /customers:
    get:
      summary: List customers
      description: Retrieve a paginated list of customers
    post:
      summary: Create customer
      description: Create a new customer account

  # Individual resources (with ID)
  /customers/{customer_id}:
    get:
      summary: Get customer
      description: Retrieve a specific customer by ID
    put:
      summary: Update customer
      description: Update customer information (full replacement)
    patch:
      summary: Partially update customer
      description: Update specific customer fields
    delete:
      summary: Delete customer
      description: Remove customer account

  # Nested resources (representing relationships)
  /customers/{customer_id}/orders:
    get:
      summary: List customer orders
      description: Retrieve orders belonging to a specific customer
    post:
      summary: Create order
      description: Create a new order for the customer

  /customers/{customer_id}/orders/{order_id}:
    get:
      summary: Get customer order
      description: Retrieve a specific order for the customer
    
  # Independent resource access (when appropriate)
  /orders/{order_id}:
    get:
      summary: Get order
      description: Retrieve order details by order ID
    
  # Action-oriented endpoints (when REST doesn't fit)
  /orders/{order_id}/actions/cancel:
    post:
      summary: Cancel order
      description: Cancel an existing order
  
  /orders/{order_id}/actions/refund:
    post:
      summary: Refund order
      description: Process a refund for an order
```

### HTTP Method Usage and Semantics
```yaml
paths:
  /products:
    get:
      summary: List products
      description: |
        Retrieve a list of products with optional filtering and pagination.
        
        This operation is safe and idempotent - it doesn't modify server state
        and can be called multiple times with the same result.
      parameters:
        - name: category
          in: query
          description: Filter products by category
          schema:
            type: string
        - name: min_price
          in: query
          description: Minimum price filter
          schema:
            type: number
            format: decimal
        - name: max_price
          in: query
          description: Maximum price filter
          schema:
            type: number
            format: decimal
        - name: sort
          in: query
          description: Sort order for results
          schema:
            type: string
            enum: [name_asc, name_desc, price_asc, price_desc, created_asc, created_desc]
            default: created_desc
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
          description: Successfully retrieved products
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ProductListResponse'
    
    post:
      summary: Create product
      description: |
        Create a new product in the system.
        
        This operation is not idempotent - calling it multiple times
        will create multiple products (unless prevented by business rules).
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateProductRequest'
      responses:
        '201':
          description: Product created successfully
          headers:
            Location:
              description: URL of the created product
              schema:
                type: string
                format: uri
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ProductResponse'
        '400':
          description: Invalid product data
        '409':
          description: Product with same SKU already exists

  /products/{product_id}:
    get:
      summary: Get product
      description: |
        Retrieve a specific product by its ID.
        
        This operation is safe and idempotent.
      parameters:
        - name: product_id
          in: path
          required: true
          description: Unique product identifier
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: Product found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ProductResponse'
        '404':
          description: Product not found
    
    put:
      summary: Update product
      description: |
        Update a product with complete replacement of data.
        
        This operation is idempotent - calling it multiple times
        with the same data will have the same effect.
      parameters:
        - name: product_id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UpdateProductRequest'
      responses:
        '200':
          description: Product updated successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ProductResponse'
        '404':
          description: Product not found
        '400':
          description: Invalid product data
    
    patch:
      summary: Partially update product
      description: |
        Update specific fields of a product without affecting other fields.
        
        This operation is idempotent when using the same patch data.
      parameters:
        - name: product_id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/PatchProductRequest'
          application/json-patch+json:
            schema:
              type: array
              items:
                $ref: '#/components/schemas/JsonPatchOperation'
      responses:
        '200':
          description: Product updated successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ProductResponse'
        '404':
          description: Product not found
        '400':
          description: Invalid patch data
    
    delete:
      summary: Delete product
      description: |
        Remove a product from the system.
        
        This operation is idempotent - deleting a non-existent
        product returns the same result as deleting an existing one.
      parameters:
        - name: product_id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        '204':
          description: Product deleted successfully
        '404':
          description: Product not found
        '409':
          description: Cannot delete product with active orders
```

**IMPLEMENT** these content negotiation patterns:

### Media Types and Content Negotiation
```yaml
paths:
  /reports/sales:
    get:
      summary: Get sales report
      description: |
        Retrieve sales report data in various formats.
        
        Supports multiple output formats based on Accept header:
        - application/json: Structured data for programmatic use
        - text/csv: Spreadsheet-compatible format
        - application/pdf: Formatted report for printing
        - application/vnd.api+json: JSON API specification format
      parameters:
        - name: start_date
          in: query
          required: true
          schema:
            type: string
            format: date
        - name: end_date
          in: query
          required: true
          schema:
            type: string
            format: date
        - name: format
          in: query
          description: Override Accept header for format selection
          schema:
            type: string
            enum: [json, csv, pdf]
      responses:
        '200':
          description: Sales report data
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SalesReportResponse'
              examples:
                detailed_report:
                  summary: Detailed sales report
                  value:
                    report_metadata:
                      generated_at: "2023-01-01T12:00:00Z"
                      period:
                        start_date: "2023-01-01"
                        end_date: "2023-01-31"
                      total_records: 1250
                    summary:
                      total_sales: 125000.50
                      total_orders: 342
                      average_order_value: 365.50
                    sales_data:
                      - date: "2023-01-01"
                        daily_sales: 4250.00
                        order_count: 12
                      - date: "2023-01-02"
                        daily_sales: 3890.50
                        order_count: 11
            
            text/csv:
              schema:
                type: string
                format: binary
              example: |
                Date,Daily Sales,Order Count,Average Order Value
                2023-01-01,4250.00,12,354.17
                2023-01-02,3890.50,11,353.68
                2023-01-03,5120.75,15,341.38
            
            application/pdf:
              schema:
                type: string
                format: binary
              description: PDF formatted sales report
            
            application/vnd.api+json:
              schema:
                type: object
                properties:
                  data:
                    type: object
                    properties:
                      type:
                        type: string
                        example: "sales-report"
                      id:
                        type: string
                        example: "2023-01-report"
                      attributes:
                        $ref: '#/components/schemas/SalesReportData'
                  meta:
                    type: object
                    properties:
                      generated_at:
                        type: string
                        format: date-time
                      api_version:
                        type: string
        
        '400':
          description: Invalid date range or parameters
        '406':
          description: Requested format not supported
          content:
            application/json:
              schema:
                type: object
                properties:
                  error:
                    type: string
                    example: "NOT_ACCEPTABLE"
                  message:
                    type: string
                    example: "Requested content type not supported"
                  supported_types:
                    type: array
                    items:
                      type: string
                    example:
                      - "application/json"
                      - "text/csv"
                      - "application/pdf"
                      - "application/vnd.api+json"
```

### Pagination and Filtering Design
```yaml
paths:
  /users:
    get:
      summary: List users with advanced filtering
      description: |
        Retrieve users with comprehensive filtering, sorting, and pagination options.
        
        ## Filtering
        - Supports multiple filter operators
        - Allows combining multiple filters
        - Case-insensitive text matching
        
        ## Sorting
        - Multiple sort fields supported
        - Ascending/descending order per field
        - Default sort by creation date (newest first)
        
        ## Pagination
        - Cursor-based pagination for large datasets
        - Offset-based pagination for smaller datasets
        - Configurable page sizes
      parameters:
        # Filtering parameters
        - name: email
          in: query
          description: Filter by email address (exact match)
          schema:
            type: string
            format: email
        
        - name: name
          in: query
          description: Filter by name (partial match, case-insensitive)
          schema:
            type: string
        
        - name: status
          in: query
          description: Filter by user status
          schema:
            type: array
            items:
              type: string
              enum: [active, inactive, suspended, pending]
          style: form
          explode: false
        
        - name: created_after
          in: query
          description: Filter users created after this date
          schema:
            type: string
            format: date-time
        
        - name: created_before
          in: query
          description: Filter users created before this date
          schema:
            type: string
            format: date-time
        
        # Sorting parameters
        - name: sort
          in: query
          description: |
            Sort order specification. Format: field:direction,field:direction
            
            Available fields: name, email, created_at, updated_at, status
            Directions: asc, desc
            
            Examples:
            - name:asc
            - created_at:desc,name:asc
            - email:asc,status:desc
          schema:
            type: string
            default: "created_at:desc"
            pattern: "^([a-z_]+:(asc|desc))(,[a-z_]+:(asc|desc))*$"
        
        # Pagination parameters (offset-based)
        - name: page
          in: query
          description: Page number (1-based)
          schema:
            type: integer
            minimum: 1
            default: 1
        
        - name: limit
          in: query
          description: Number of items per page
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
        
        # Pagination parameters (cursor-based)
        - name: cursor
          in: query
          description: |
            Cursor for pagination (alternative to page/limit).
            Use the 'next_cursor' from previous response.
          schema:
            type: string
        
        - name: cursor_limit
          in: query
          description: Number of items when using cursor pagination
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
        
        # Field selection
        - name: fields
          in: query
          description: |
            Comma-separated list of fields to include in response.
            Reduces payload size for better performance.
          schema:
            type: array
            items:
              type: string
              enum:
                - id
                - email
                - name
                - status
                - created_at
                - updated_at
                - profile
                - preferences
          style: form
          explode: false
      
      responses:
        '200':
          description: Successfully retrieved users
          content:
            application/json:
              schema:
                type: object
                required:
                  - data
                  - meta
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/UserSummary'
                  meta:
                    type: object
                    required:
                      - pagination
                      - filters_applied
                    properties:
                      pagination:
                        oneOf:
                          - $ref: '#/components/schemas/OffsetPagination'
                          - $ref: '#/components/schemas/CursorPagination'
                      filters_applied:
                        type: object
                        description: Summary of filters applied to the query
                      sort_applied:
                        type: string
                        description: Sort order that was applied
                      total_count:
                        type: integer
                        description: Total number of users (may be approximate for large datasets)
              
              examples:
                offset_pagination:
                  summary: Response with offset-based pagination
                  value:
                    data:
                      - id: "123e4567-e89b-12d3-a456-426614174000"
                        email: "john.doe@example.com"
                        name: "John Doe"
                        status: "active"
                        created_at: "2023-01-01T12:00:00Z"
                      - id: "987fcdeb-51d2-43ba-9876-543210987654"
                        email: "jane.smith@example.com"
                        name: "Jane Smith"
                        status: "active"
                        created_at: "2023-01-02T10:30:00Z"
                    meta:
                      pagination:
                        type: "offset"
                        current_page: 1
                        page_size: 20
                        total_pages: 15
                        total_items: 300
                        has_previous: false
                        has_next: true
                        links:
                          first: "/users?page=1&limit=20"
                          next: "/users?page=2&limit=20"
                          last: "/users?page=15&limit=20"
                      filters_applied:
                        status: ["active"]
                      sort_applied: "created_at:desc"
                      total_count: 300
                
                cursor_pagination:
                  summary: Response with cursor-based pagination
                  value:
                    data:
                      - id: "123e4567-e89b-12d3-a456-426614174000"
                        email: "john.doe@example.com"
                        name: "John Doe"
                        status: "active"
                        created_at: "2023-01-01T12:00:00Z"
                    meta:
                      pagination:
                        type: "cursor"
                        page_size: 20
                        has_previous: false
                        has_next: true
                        cursors:
                          previous: null
                          next: "eyJjcmVhdGVkX2F0IjoiMjAyMy0wMS0wMVQxMjowMDowMFoiLCJpZCI6IjEyM2U0NTY3LWU4OWItMTJkMy1hNDU2LTQyNjYxNDE3NDAwMCJ9"
                        links:
                          next: "/users?cursor=eyJjcmVhdGVkX2F0IjoiMjAyMy0wMS0wMVQxMjowMDowMFoiLCJpZCI6IjEyM2U0NTY3LWU4OWItMTJkMy1hNDU2LTQyNjYxNDE3NDAwMCJ9&cursor_limit=20"
```

**ENSURE** these design validations:
- Clear resource hierarchies and relationships
- Appropriate HTTP method usage with proper semantics
- Comprehensive error handling with meaningful status codes
- Consistent response structures across all endpoints

## Anti-Patterns

**DON'T** implement these API design approaches:
- **RPC-style URLs**: `/api/getUserById?id=123` instead of `/users/123`
- **Verb-based resources**: `/createUser`, `/updateUser` instead of proper HTTP methods
- **Inconsistent response formats**: Different error structures across endpoints
- **Ignoring HTTP semantics**: Using POST for read operations or GET for state changes

**AVOID** these common mistakes:
- **Over-nesting resources**: Deep hierarchies like `/customers/{id}/orders/{id}/items/{id}/reviews/{id}`
- **Inconsistent naming**: Mixing singular/plural forms or different casing styles
- **Poor error messages**: Generic errors without actionable information
- **Missing status codes**: Using only 200 and 500 status codes

**NEVER** do these actions:
- **Expose internal IDs**: Database primary keys or internal identifiers in URLs
- **Break idempotency**: Non-idempotent operations using idempotent HTTP methods
- **Ignore content types**: Not supporting proper content negotiation
- **Skip versioning**: Designing APIs without consideration for future changes

## Validation Checklist

**MUST** verify:
- [ ] All resources follow RESTful design principles
- [ ] HTTP methods are used correctly with proper semantics
- [ ] Status codes are appropriate for each response scenario
- [ ] Error responses provide actionable information
- [ ] Resource hierarchies are logical and intuitive

**SHOULD** check:
- [ ] Pagination is implemented for collection resources
- [ ] Filtering and sorting options are comprehensive
- [ ] Content negotiation supports appropriate media types
- [ ] API versioning strategy is clearly defined
- [ ] Performance considerations are addressed in design

## References

- [RESTful API Design Best Practices](https://restfulapi.net/)
- [HTTP Semantics (RFC 9110)](https://httpwg.org/specs/rfc9110.html)
- [JSON API Specification](https://jsonapi.org/)
- [Google API Design Guide](https://cloud.google.com/apis/design)
