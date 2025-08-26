# Microservices API Example

This example demonstrates OpenAPI specifications for a microservices architecture, showcasing service communication patterns and distributed system design.

## User Service API

```yaml
openapi: 3.1.0
info:
  title: User Service API
  description: |
    User management microservice handling authentication, authorization, 
    and user profile management in a distributed system.
  version: 2.0.0
  contact:
    name: User Service Team
    email: user-service@company.example.com

servers:
  - url: https://user-service.api.company.com/v2
    description: Production
  - url: https://user-service.staging.company.com/v2
    description: Staging

security:
  - bearerAuth: []

paths:
  /users:
    get:
      summary: List users
      description: Retrieve users with filtering and pagination
      tags: [Users]
      security:
        - bearerAuth: [admin]
      parameters:
        - $ref: '#/components/parameters/PageParam'
        - $ref: '#/components/parameters/LimitParam'
        - name: role
          in: query
          schema:
            type: array
            items:
              type: string
              enum: [admin, user, moderator]
        - name: status
          in: query
          schema:
            type: string
            enum: [active, inactive, suspended]
      responses:
        '200':
          description: User list
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserListResponse'

    post:
      summary: Create user
      description: Create a new user account
      tags: [Users]
      security:
        - bearerAuth: [admin]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: User created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserResponse'

  /users/{user_id}:
    get:
      summary: Get user by ID
      tags: [Users]
      parameters:
        - $ref: '#/components/parameters/UserIdParam'
      responses:
        '200':
          description: User details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserResponse'

  /auth/validate:
    post:
      summary: Validate token
      description: Internal endpoint for token validation by other services
      tags: [Authentication]
      security:
        - apiKey: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - token
              properties:
                token:
                  type: string
                  description: JWT token to validate
                required_permissions:
                  type: array
                  items:
                    type: string
                  description: Required permissions for the operation
      responses:
        '200':
          description: Token validation result
          content:
            application/json:
              schema:
                type: object
                properties:
                  valid:
                    type: boolean
                  user_id:
                    type: string
                    format: uuid
                  permissions:
                    type: array
                    items:
                      type: string
                  expires_at:
                    type: string
                    format: date-time

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
    
    apiKey:
      type: apiKey
      in: header
      name: X-Service-Key

  parameters:
    UserIdParam:
      name: user_id
      in: path
      required: true
      schema:
        type: string
        format: uuid
    
    PageParam:
      name: page
      in: query
      schema:
        type: integer
        minimum: 1
        default: 1
    
    LimitParam:
      name: limit
      in: query
      schema:
        type: integer
        minimum: 1
        maximum: 100
        default: 20

  schemas:
    User:
      type: object
      required:
        - id
        - email
        - username
        - role
        - status
        - created_at
      properties:
        id:
          type: string
          format: uuid
        email:
          type: string
          format: email
        username:
          type: string
          pattern: "^[a-zA-Z0-9_]{3,30}$"
        role:
          type: string
          enum: [admin, user, moderator]
        status:
          type: string
          enum: [active, inactive, suspended]
        profile:
          type: object
          properties:
            first_name:
              type: string
            last_name:
              type: string
            avatar_url:
              type: string
              format: uri
        permissions:
          type: array
          items:
            type: string
        created_at:
          type: string
          format: date-time
        updated_at:
          type: string
          format: date-time

tags:
  - name: Users
    description: User management operations
  - name: Authentication
    description: Authentication and authorization
```

## Order Service API

```yaml
openapi: 3.1.0
info:
  title: Order Service API
  description: |
    Order processing microservice handling order lifecycle management,
    inventory coordination, and payment processing integration.
  version: 1.5.0
  contact:
    name: Order Service Team
    email: order-service@company.example.com

servers:
  - url: https://order-service.api.company.com/v1
    description: Production
  - url: https://order-service.staging.company.com/v1
    description: Staging

security:
  - bearerAuth: []

paths:
  /orders:
    get:
      summary: List orders
      description: Retrieve orders for the authenticated user
      tags: [Orders]
      parameters:
        - $ref: '#/components/parameters/PageParam'
        - $ref: '#/components/parameters/LimitParam'
        - name: status
          in: query
          schema:
            type: array
            items:
              type: string
              enum: [pending, confirmed, shipped, delivered, cancelled]
        - name: date_from
          in: query
          schema:
            type: string
            format: date
        - name: date_to
          in: query
          schema:
            type: string
            format: date
      responses:
        '200':
          description: Order list
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderListResponse'

    post:
      summary: Create order
      description: Create a new order from shopping cart
      tags: [Orders]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateOrderRequest'
      responses:
        '201':
          description: Order created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderResponse'

  /orders/{order_id}:
    get:
      summary: Get order details
      tags: [Orders]
      parameters:
        - $ref: '#/components/parameters/OrderIdParam'
      responses:
        '200':
          description: Order details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderResponse'

  /orders/{order_id}/status:
    put:
      summary: Update order status
      description: Internal endpoint for status updates from other services
      tags: [Orders]
      security:
        - serviceKey: []
      parameters:
        - $ref: '#/components/parameters/OrderIdParam'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - status
                - updated_by_service
              properties:
                status:
                  type: string
                  enum: [pending, confirmed, shipped, delivered, cancelled]
                reason:
                  type: string
                  maxLength: 500
                updated_by_service:
                  type: string
                  description: Name of the service making the update
                tracking_info:
                  type: object
                  properties:
                    tracking_number:
                      type: string
                    carrier:
                      type: string
                    estimated_delivery:
                      type: string
                      format: date-time
      responses:
        '200':
          description: Status updated successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderResponse'

  /orders/events:
    post:
      summary: Process order event
      description: Handle events from other services (payment, inventory, shipping)
      tags: [Events]
      security:
        - serviceKey: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/OrderEvent'
      responses:
        '200':
          description: Event processed successfully
        '400':
          description: Invalid event data

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
    
    serviceKey:
      type: apiKey
      in: header
      name: X-Service-Key

  schemas:
    Order:
      type: object
      required:
        - id
        - user_id
        - items
        - total_amount
        - status
        - created_at
      properties:
        id:
          type: string
          format: uuid
        user_id:
          type: string
          format: uuid
        items:
          type: array
          items:
            $ref: '#/components/schemas/OrderItem'
        total_amount:
          type: number
          format: decimal
          minimum: 0
        currency:
          type: string
          pattern: "^[A-Z]{3}$"
          default: "USD"
        status:
          type: string
          enum: [pending, confirmed, shipped, delivered, cancelled]
        shipping_address:
          $ref: '#/components/schemas/Address'
        payment_method:
          type: string
          enum: [credit_card, paypal, bank_transfer]
        tracking_info:
          type: object
          properties:
            tracking_number:
              type: string
            carrier:
              type: string
            estimated_delivery:
              type: string
              format: date-time
        created_at:
          type: string
          format: date-time
        updated_at:
          type: string
          format: date-time

    OrderItem:
      type: object
      required:
        - product_id
        - quantity
        - unit_price
      properties:
        product_id:
          type: string
          format: uuid
        product_name:
          type: string
        quantity:
          type: integer
          minimum: 1
        unit_price:
          type: number
          format: decimal
          minimum: 0
        total_price:
          type: number
          format: decimal
          minimum: 0

    OrderEvent:
      type: object
      required:
        - event_type
        - order_id
        - timestamp
        - source_service
      properties:
        event_type:
          type: string
          enum: [payment_processed, payment_failed, inventory_reserved, inventory_unavailable, shipped, delivered]
        order_id:
          type: string
          format: uuid
        timestamp:
          type: string
          format: date-time
        source_service:
          type: string
        data:
          type: object
          description: Event-specific data

tags:
  - name: Orders
    description: Order management operations
  - name: Events
    description: Inter-service event handling
```

## API Gateway Configuration

```yaml
openapi: 3.1.0
info:
  title: API Gateway
  description: |
    Main API Gateway providing unified access to all microservices
    with authentication, rate limiting, and request routing.
  version: 3.0.0

servers:
  - url: https://api.company.com/v3
    description: Production Gateway
  - url: https://staging-api.company.com/v3
    description: Staging Gateway

security:
  - bearerAuth: []

paths:
  # User Service Proxied Endpoints
  /users:
    $ref: 'user-service.yaml#/paths/~1users'
  
  /users/{user_id}:
    $ref: 'user-service.yaml#/paths/~1users~1{user_id}'

  # Order Service Proxied Endpoints  
  /orders:
    $ref: 'order-service.yaml#/paths/~1orders'
    
  /orders/{order_id}:
    $ref: 'order-service.yaml#/paths/~1orders~1{order_id}'

  # Gateway-specific endpoints
  /health:
    get:
      summary: Gateway health check
      description: Check the health of the API Gateway and its connected services
      tags: [System]
      security: []
      responses:
        '200':
          description: System health status
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    enum: [healthy, degraded, unhealthy]
                  services:
                    type: object
                    additionalProperties:
                      type: object
                      properties:
                        status:
                          type: string
                          enum: [up, down, degraded]
                        response_time_ms:
                          type: number
                        last_check:
                          type: string
                          format: date-time
                  timestamp:
                    type: string
                    format: date-time

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: JWT token issued by the User Service

tags:
  - name: System
    description: System-level operations
  - name: Users
    description: User management (proxied to User Service)
  - name: Orders
    description: Order management (proxied to Order Service)
```

This microservices example demonstrates:

1. **Service Separation**: Clear boundaries between user management and order processing
2. **Inter-Service Communication**: Service-to-service authentication and event handling
3. **API Gateway Pattern**: Unified entry point with service proxying
4. **Event-Driven Architecture**: Asynchronous communication between services
5. **Security Boundaries**: Different authentication for public vs internal endpoints
6. **Service Health Monitoring**: Health check endpoints for service discovery
7. **Consistent APIs**: Standardized response formats across services
8. **Scalable Design**: Independent scaling and deployment of services
9. **Error Handling**: Service-specific error responses and handling
10. **Documentation Modularity**: Separate specs that can be composed together
