# Simple Blog API Example

This example demonstrates a straightforward OpenAPI specification for a blog platform, showcasing basic REST patterns and best practices.

```yaml
openapi: 3.1.0
info:
  title: Simple Blog API
  description: |
    A clean and simple REST API for a blog platform with posts, comments, and user management.
    
    This API demonstrates basic CRUD operations, authentication, and content management
    following RESTful principles and OpenAPI best practices.
  
  version: 1.0.0
  contact:
    name: Blog API Team
    email: api@blog.example.com
  license:
    name: Apache 2.0
    url: https://www.apache.org/licenses/LICENSE-2.0.html

servers:
  - url: https://api.blog.example.com/v1
    description: Production server
  - url: https://staging-api.blog.example.com/v1
    description: Staging server

security:
  - bearerAuth: []

paths:
  /health:
    get:
      summary: Health check
      description: Check API health status
      tags: [System]
      security: []
      responses:
        '200':
          description: API is healthy
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    enum: [healthy]
                  timestamp:
                    type: string
                    format: date-time

  /auth/login:
    post:
      summary: User login
      description: Authenticate user and receive access token
      tags: [Authentication]
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - email
                - password
              properties:
                email:
                  type: string
                  format: email
                password:
                  type: string
                  minLength: 6
      responses:
        '200':
          description: Login successful
          content:
            application/json:
              schema:
                type: object
                properties:
                  access_token:
                    type: string
                  token_type:
                    type: string
                    enum: [Bearer]
                  expires_in:
                    type: integer
                    description: Token expiration in seconds
        '401':
          description: Invalid credentials
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'

  /posts:
    get:
      summary: List blog posts
      description: Retrieve a list of blog posts with pagination
      tags: [Posts]
      security: []
      parameters:
        - name: page
          in: query
          description: Page number
          schema:
            type: integer
            minimum: 1
            default: 1
        - name: limit
          in: query
          description: Number of posts per page
          schema:
            type: integer
            minimum: 1
            maximum: 50
            default: 10
        - name: author
          in: query
          description: Filter by author username
          schema:
            type: string
        - name: tag
          in: query
          description: Filter by tag
          schema:
            type: string
      responses:
        '200':
          description: List of blog posts
          content:
            application/json:
              schema:
                type: object
                properties:
                  posts:
                    type: array
                    items:
                      $ref: '#/components/schemas/PostSummary'
                  pagination:
                    $ref: '#/components/schemas/Pagination'
              examples:
                sample_posts:
                  summary: Sample blog posts
                  value:
                    posts:
                      - id: 1
                        title: "Getting Started with OpenAPI"
                        excerpt: "Learn how to design APIs with OpenAPI specification..."
                        author:
                          id: 1
                          username: "johndoe"
                          display_name: "John Doe"
                        tags: ["openapi", "api-design"]
                        published_at: "2024-01-15T10:30:00Z"
                        read_time_minutes: 5
                    pagination:
                      page: 1
                      limit: 10
                      total: 1
                      total_pages: 1

    post:
      summary: Create blog post
      description: Create a new blog post
      tags: [Posts]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreatePostRequest'
      responses:
        '201':
          description: Post created successfully
          headers:
            Location:
              description: URL of the created post
              schema:
                type: string
                format: uri
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Post'
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'

  /posts/{post_id}:
    get:
      summary: Get post by ID
      description: Retrieve a specific blog post with full content
      tags: [Posts]
      security: []
      parameters:
        - $ref: '#/components/parameters/PostIdParam'
      responses:
        '200':
          description: Blog post details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Post'
        '404':
          $ref: '#/components/responses/NotFound'

    put:
      summary: Update post
      description: Update an existing blog post (author only)
      tags: [Posts]
      parameters:
        - $ref: '#/components/parameters/PostIdParam'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UpdatePostRequest'
      responses:
        '200':
          description: Post updated successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Post'
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'
        '404':
          $ref: '#/components/responses/NotFound'

    delete:
      summary: Delete post
      description: Delete a blog post (author only)
      tags: [Posts]
      parameters:
        - $ref: '#/components/parameters/PostIdParam'
      responses:
        '204':
          description: Post deleted successfully
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'
        '404':
          $ref: '#/components/responses/NotFound'

  /posts/{post_id}/comments:
    get:
      summary: Get post comments
      description: Retrieve comments for a specific post
      tags: [Comments]
      security: []
      parameters:
        - $ref: '#/components/parameters/PostIdParam'
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
          description: List of comments
          content:
            application/json:
              schema:
                type: object
                properties:
                  comments:
                    type: array
                    items:
                      $ref: '#/components/schemas/Comment'
                  pagination:
                    $ref: '#/components/schemas/Pagination'

    post:
      summary: Add comment
      description: Add a comment to a blog post
      tags: [Comments]
      parameters:
        - $ref: '#/components/parameters/PostIdParam'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - content
              properties:
                content:
                  type: string
                  minLength: 1
                  maxLength: 1000
                  description: Comment content
      responses:
        '201':
          description: Comment added successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Comment'
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '404':
          $ref: '#/components/responses/NotFound'

  /users/me:
    get:
      summary: Get current user profile
      description: Get the authenticated user's profile information
      tags: [Users]
      responses:
        '200':
          description: User profile information
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '401':
          $ref: '#/components/responses/Unauthorized'

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: JWT token for authenticated requests

  parameters:
    PostIdParam:
      name: post_id
      in: path
      required: true
      description: Unique post identifier
      schema:
        type: integer
        minimum: 1

  schemas:
    User:
      type: object
      required:
        - id
        - username
        - email
        - display_name
        - created_at
      properties:
        id:
          type: integer
          description: Unique user identifier
        username:
          type: string
          pattern: "^[a-zA-Z0-9_]{3,30}$"
          description: Unique username
        email:
          type: string
          format: email
          description: User email address
        display_name:
          type: string
          minLength: 1
          maxLength: 100
          description: Display name
        bio:
          type: string
          maxLength: 500
          description: User biography
        avatar_url:
          type: string
          format: uri
          description: Profile picture URL
        created_at:
          type: string
          format: date-time
          description: Account creation date

    PostSummary:
      type: object
      required:
        - id
        - title
        - excerpt
        - author
        - published_at
      properties:
        id:
          type: integer
          description: Unique post identifier
        title:
          type: string
          minLength: 1
          maxLength: 200
          description: Post title
        excerpt:
          type: string
          maxLength: 300
          description: Post excerpt or summary
        author:
          $ref: '#/components/schemas/Author'
        tags:
          type: array
          items:
            type: string
            pattern: "^[a-z0-9-]+$"
          maxItems: 10
          description: Post tags
        published_at:
          type: string
          format: date-time
          description: Publication date
        read_time_minutes:
          type: integer
          minimum: 1
          description: Estimated reading time in minutes

    Post:
      allOf:
        - $ref: '#/components/schemas/PostSummary'
        - type: object
          required:
            - content
            - updated_at
          properties:
            content:
              type: string
              minLength: 1
              description: Full post content (Markdown)
            updated_at:
              type: string
              format: date-time
              description: Last update date
            comment_count:
              type: integer
              minimum: 0
              description: Number of comments

    Author:
      type: object
      required:
        - id
        - username
        - display_name
      properties:
        id:
          type: integer
        username:
          type: string
        display_name:
          type: string
        avatar_url:
          type: string
          format: uri

    Comment:
      type: object
      required:
        - id
        - content
        - author
        - created_at
      properties:
        id:
          type: integer
          description: Unique comment identifier
        content:
          type: string
          description: Comment content
        author:
          $ref: '#/components/schemas/Author'
        created_at:
          type: string
          format: date-time
          description: Comment creation date
        updated_at:
          type: string
          format: date-time
          description: Last update date

    CreatePostRequest:
      type: object
      required:
        - title
        - content
      properties:
        title:
          type: string
          minLength: 1
          maxLength: 200
        content:
          type: string
          minLength: 1
          description: Post content in Markdown format
        excerpt:
          type: string
          maxLength: 300
          description: Optional excerpt (auto-generated if not provided)
        tags:
          type: array
          items:
            type: string
            pattern: "^[a-z0-9-]+$"
          maxItems: 10
        published:
          type: boolean
          default: false
          description: Whether to publish immediately

    UpdatePostRequest:
      type: object
      properties:
        title:
          type: string
          minLength: 1
          maxLength: 200
        content:
          type: string
          minLength: 1
        excerpt:
          type: string
          maxLength: 300
        tags:
          type: array
          items:
            type: string
            pattern: "^[a-z0-9-]+$"
          maxItems: 10
        published:
          type: boolean

    Pagination:
      type: object
      required:
        - page
        - limit
        - total
        - total_pages
      properties:
        page:
          type: integer
          minimum: 1
          description: Current page number
        limit:
          type: integer
          minimum: 1
          description: Items per page
        total:
          type: integer
          minimum: 0
          description: Total number of items
        total_pages:
          type: integer
          minimum: 0
          description: Total number of pages

    ErrorResponse:
      type: object
      required:
        - error
        - message
      properties:
        error:
          type: string
          description: Error code
        message:
          type: string
          description: Error message
        details:
          type: object
          description: Additional error details
        timestamp:
          type: string
          format: date-time

  responses:
    BadRequest:
      description: Bad request
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
          example:
            error: "validation_error"
            message: "Invalid input data"
            timestamp: "2024-01-15T10:30:00Z"

    Unauthorized:
      description: Unauthorized
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
          example:
            error: "unauthorized"
            message: "Authentication required"
            timestamp: "2024-01-15T10:30:00Z"

    Forbidden:
      description: Forbidden
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
          example:
            error: "forbidden"
            message: "Insufficient permissions"
            timestamp: "2024-01-15T10:30:00Z"

    NotFound:
      description: Not found
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
          example:
            error: "not_found"
            message: "Resource not found"
            timestamp: "2024-01-15T10:30:00Z"

tags:
  - name: System
    description: System health and status
  - name: Authentication
    description: User authentication
  - name: Posts
    description: Blog post management
  - name: Comments
    description: Comment management
  - name: Users
    description: User profile management
```

This simple example demonstrates:

1. **Basic CRUD Operations**: Create, read, update, delete for posts
2. **Authentication**: JWT bearer token authentication
3. **Resource Relationships**: Posts have authors and comments
4. **Pagination**: Standard pagination for list endpoints
5. **Validation**: Input validation with constraints
6. **Error Handling**: Consistent error response structure
7. **Public and Protected Endpoints**: Mixed security requirements
8. **Reusable Components**: Shared schemas and responses
9. **Clear Documentation**: Helpful descriptions and examples
10. **RESTful Design**: Proper HTTP methods and status codes
