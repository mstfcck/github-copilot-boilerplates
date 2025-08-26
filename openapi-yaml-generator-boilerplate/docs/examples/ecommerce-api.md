# Complete E-commerce API Example

This example demonstrates a comprehensive OpenAPI specification for an e-commerce platform, showcasing best practices for complex API design.

```yaml
openapi: 3.1.0
info:
  title: E-commerce Platform API
  description: |
    Comprehensive REST API for an e-commerce platform supporting customer management,
    product catalog, order processing, and payment handling.
    
    ## Features
    - Customer account management with authentication
    - Product catalog with categories and inventory
    - Shopping cart and order processing
    - Payment integration with multiple providers
    - Administrative functions for store management
    
    ## Authentication
    This API uses OAuth 2.0 for customer authentication and API keys for administrative access.
    
    ## Rate Limiting
    - Public endpoints: 1000 requests per hour
    - Authenticated endpoints: 5000 requests per hour
    - Administrative endpoints: 10000 requests per hour
  
  version: 2.1.0
  contact:
    name: E-commerce API Support
    email: api-support@ecommerce.example.com
    url: https://developer.ecommerce.example.com
  license:
    name: MIT
    url: https://opensource.org/licenses/MIT
  
  termsOfService: https://ecommerce.example.com/terms

servers:
  - url: https://api.ecommerce.example.com/v2
    description: Production server
  - url: https://staging-api.ecommerce.example.com/v2
    description: Staging server
  - url: https://dev-api.ecommerce.example.com/v2
    description: Development server

security:
  - oauth2: [read]

paths:
  # Customer Management
  /customers:
    get:
      summary: List customers
      description: Retrieve a paginated list of customers with optional filtering
      tags: [Customers]
      security:
        - oauth2: [admin]
      parameters:
        - $ref: '#/components/parameters/PageParam'
        - $ref: '#/components/parameters/LimitParam'
        - name: search
          in: query
          description: Search customers by name or email
          schema:
            type: string
            minLength: 2
        - name: status
          in: query
          description: Filter by customer status
          schema:
            type: array
            items:
              type: string
              enum: [active, inactive, suspended]
      responses:
        '200':
          description: Successfully retrieved customers
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/CustomerListResponse'
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'
    
    post:
      summary: Create customer
      description: Register a new customer account
      tags: [Customers]
      security: []  # Public registration
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateCustomerRequest'
      responses:
        '201':
          description: Customer created successfully
          headers:
            Location:
              description: URL of the created customer
              schema:
                type: string
                format: uri
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/CustomerResponse'
        '400':
          $ref: '#/components/responses/BadRequest'
        '409':
          description: Email address already exists
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'

  /customers/{customer_id}:
    get:
      summary: Get customer by ID
      description: Retrieve detailed customer information
      tags: [Customers]
      security:
        - oauth2: [read]
      parameters:
        - $ref: '#/components/parameters/CustomerIdParam'
      responses:
        '200':
          description: Customer information
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/CustomerResponse'
        '404':
          $ref: '#/components/responses/NotFound'
    
    put:
      summary: Update customer
      description: Update customer information (full replacement)
      tags: [Customers]
      security:
        - oauth2: [write]
      parameters:
        - $ref: '#/components/parameters/CustomerIdParam'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UpdateCustomerRequest'
      responses:
        '200':
          description: Customer updated successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/CustomerResponse'
        '400':
          $ref: '#/components/responses/BadRequest'
        '404':
          $ref: '#/components/responses/NotFound'

  # Product Management
  /products:
    get:
      summary: List products
      description: Retrieve products with filtering, sorting, and pagination
      tags: [Products]
      parameters:
        - $ref: '#/components/parameters/PageParam'
        - $ref: '#/components/parameters/LimitParam'
        - name: category_id
          in: query
          description: Filter by category
          schema:
            type: string
            format: uuid
        - name: min_price
          in: query
          description: Minimum price filter
          schema:
            type: number
            format: decimal
            minimum: 0
        - name: max_price
          in: query
          description: Maximum price filter
          schema:
            type: number
            format: decimal
            minimum: 0
        - name: in_stock
          in: query
          description: Filter by availability
          schema:
            type: boolean
        - name: sort
          in: query
          description: Sort order
          schema:
            type: string
            enum: [name_asc, name_desc, price_asc, price_desc, created_asc, created_desc]
            default: created_desc
      responses:
        '200':
          description: Product list retrieved successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ProductListResponse'
              examples:
                with_products:
                  summary: Response with products
                  value:
                    data:
                      - id: "123e4567-e89b-12d3-a456-426614174000"
                        name: "Wireless Headphones"
                        description: "High-quality wireless headphones"
                        price: 199.99
                        category_id: "cat-electronics"
                        in_stock: true
                        inventory_count: 50
                    pagination:
                      page: 1
                      limit: 20
                      total: 1
                      has_next: false

  /products/{product_id}:
    get:
      summary: Get product by ID
      description: Retrieve detailed product information including reviews
      tags: [Products]
      parameters:
        - $ref: '#/components/parameters/ProductIdParam'
        - name: include_reviews
          in: query
          description: Include customer reviews in response
          schema:
            type: boolean
            default: false
      responses:
        '200':
          description: Product details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ProductDetailResponse'

  # Shopping Cart
  /customers/{customer_id}/cart:
    get:
      summary: Get customer's cart
      description: Retrieve current shopping cart contents
      tags: [Shopping Cart]
      security:
        - oauth2: [read]
      parameters:
        - $ref: '#/components/parameters/CustomerIdParam'
      responses:
        '200':
          description: Cart contents
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/CartResponse'
    
    post:
      summary: Add item to cart
      description: Add a product to the customer's shopping cart
      tags: [Shopping Cart]
      security:
        - oauth2: [write]
      parameters:
        - $ref: '#/components/parameters/CustomerIdParam'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/AddToCartRequest'
      responses:
        '200':
          description: Item added to cart
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/CartResponse'
        '400':
          description: Invalid request (insufficient inventory, etc.)

  # Order Management
  /orders:
    post:
      summary: Create order
      description: Create a new order from customer's cart
      tags: [Orders]
      security:
        - oauth2: [write]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateOrderRequest'
      responses:
        '201':
          description: Order created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderResponse'

  /orders/{order_id}:
    get:
      summary: Get order by ID
      description: Retrieve order details including items and payment status
      tags: [Orders]
      security:
        - oauth2: [read]
      parameters:
        - $ref: '#/components/parameters/OrderIdParam'
      responses:
        '200':
          description: Order details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderResponse'

  /orders/{order_id}/actions/cancel:
    post:
      summary: Cancel order
      description: Cancel an existing order if cancellation is allowed
      tags: [Orders]
      security:
        - oauth2: [write]
      parameters:
        - $ref: '#/components/parameters/OrderIdParam'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                reason:
                  type: string
                  description: Reason for cancellation
                  maxLength: 500
      responses:
        '200':
          description: Order cancelled successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderResponse'
        '409':
          description: Order cannot be cancelled
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'

components:
  securitySchemes:
    oauth2:
      type: oauth2
      flows:
        authorizationCode:
          authorizationUrl: https://auth.ecommerce.example.com/oauth/authorize
          tokenUrl: https://auth.ecommerce.example.com/oauth/token
          scopes:
            read: Read access to customer data
            write: Write access to customer data
            admin: Administrative access
    
    apiKey:
      type: apiKey
      in: header
      name: X-API-Key
      description: API key for service-to-service communication

  parameters:
    CustomerIdParam:
      name: customer_id
      in: path
      required: true
      description: Unique customer identifier
      schema:
        type: string
        format: uuid
    
    ProductIdParam:
      name: product_id
      in: path
      required: true
      description: Unique product identifier
      schema:
        type: string
        format: uuid
    
    OrderIdParam:
      name: order_id
      in: path
      required: true
      description: Unique order identifier
      schema:
        type: string
        format: uuid
    
    PageParam:
      name: page
      in: query
      description: Page number (1-based)
      schema:
        type: integer
        minimum: 1
        default: 1
    
    LimitParam:
      name: limit
      in: query
      description: Number of items per page
      schema:
        type: integer
        minimum: 1
        maximum: 100
        default: 20

  schemas:
    Customer:
      type: object
      required:
        - id
        - email
        - first_name
        - last_name
        - created_at
      properties:
        id:
          type: string
          format: uuid
          description: Unique customer identifier
        email:
          type: string
          format: email
          description: Customer email address
        first_name:
          type: string
          minLength: 1
          maxLength: 50
          description: Customer first name
        last_name:
          type: string
          minLength: 1
          maxLength: 50
          description: Customer last name
        phone:
          type: string
          pattern: "^\\+?[1-9]\\d{1,14}$"
          description: Customer phone number
        date_of_birth:
          type: string
          format: date
          description: Customer date of birth
        status:
          type: string
          enum: [active, inactive, suspended]
          description: Customer account status
        created_at:
          type: string
          format: date-time
          description: Account creation timestamp
        updated_at:
          type: string
          format: date-time
          description: Last update timestamp

    CreateCustomerRequest:
      type: object
      required:
        - email
        - password
        - first_name
        - last_name
      properties:
        email:
          type: string
          format: email
        password:
          type: string
          minLength: 8
          description: Customer password (minimum 8 characters)
        first_name:
          type: string
          minLength: 1
          maxLength: 50
        last_name:
          type: string
          minLength: 1
          maxLength: 50
        phone:
          type: string
          pattern: "^\\+?[1-9]\\d{1,14}$"
        date_of_birth:
          type: string
          format: date

    CustomerResponse:
      type: object
      required:
        - data
      properties:
        data:
          $ref: '#/components/schemas/Customer'

    CustomerListResponse:
      type: object
      required:
        - data
        - pagination
      properties:
        data:
          type: array
          items:
            $ref: '#/components/schemas/Customer'
        pagination:
          $ref: '#/components/schemas/Pagination'

    Product:
      type: object
      required:
        - id
        - name
        - price
        - category_id
        - in_stock
      properties:
        id:
          type: string
          format: uuid
        name:
          type: string
          minLength: 1
          maxLength: 200
        description:
          type: string
          maxLength: 2000
        price:
          type: number
          format: decimal
          minimum: 0
          multipleOf: 0.01
        category_id:
          type: string
          format: uuid
        sku:
          type: string
          pattern: "^[A-Z0-9-]+$"
        in_stock:
          type: boolean
        inventory_count:
          type: integer
          minimum: 0
        images:
          type: array
          items:
            type: string
            format: uri
          maxItems: 10

    Pagination:
      type: object
      required:
        - page
        - limit
        - total
        - has_next
      properties:
        page:
          type: integer
          minimum: 1
        limit:
          type: integer
          minimum: 1
        total:
          type: integer
          minimum: 0
        has_next:
          type: boolean

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
        message:
          type: string
          description: Human-readable error message
        details:
          type: array
          items:
            type: object
            properties:
              field:
                type: string
              message:
                type: string
        timestamp:
          type: string
          format: date-time
        request_id:
          type: string

  responses:
    BadRequest:
      description: Invalid request data
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    
    Unauthorized:
      description: Authentication required
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    
    Forbidden:
      description: Insufficient permissions
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    
    NotFound:
      description: Resource not found
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'

tags:
  - name: Customers
    description: Customer account management
  - name: Products
    description: Product catalog and inventory
  - name: Shopping Cart
    description: Shopping cart operations
  - name: Orders
    description: Order processing and management
  - name: Payments
    description: Payment processing
  - name: Admin
    description: Administrative functions
```

This comprehensive example demonstrates:

1. **Complete API Structure**: All major components of an e-commerce system
2. **Security Implementation**: OAuth2 for customers, API keys for services
3. **Resource Relationships**: Proper modeling of customers, products, carts, and orders
4. **Comprehensive Documentation**: Clear descriptions and realistic examples
5. **Error Handling**: Consistent error responses with detailed information
6. **Validation**: Appropriate constraints and format specifications
7. **Pagination**: Standard pagination for list endpoints
8. **Action Endpoints**: Non-CRUD operations like order cancellation
9. **Reusable Components**: Shared schemas, parameters, and responses
10. **Production Readiness**: Headers, status codes, and operational considerations
