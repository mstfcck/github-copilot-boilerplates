---
applyTo: '**'
---

# Security Instructions

This document provides comprehensive security guidance for generating OpenAPI YAML specifications that implement robust authentication, authorization, and data protection mechanisms.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** implement appropriate authentication mechanisms for all non-public endpoints
- **REQUIRED** to define security schemes in the components section
- **SHALL** use HTTPS for all production API communications
- **NEVER** expose sensitive information in query parameters or URL paths
- **NEVER** store credentials, API keys, or tokens in the OpenAPI specification

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** implement OAuth 2.0 or OpenID Connect for modern authentication
- **RECOMMENDED** to use scoped permissions for fine-grained access control
- **ALWAYS** validate and sanitize all input parameters and request bodies
- **DO** implement rate limiting and throttling for API protection
- **DON'T** use basic authentication for production systems without additional security

### Optional Enhancements (**MAY** Consider)
- **MAY** implement API key rotation mechanisms
- **OPTIONAL** to include security headers and CORS configuration
- **USE** JWT tokens with appropriate expiration times
- **IMPLEMENT** IP whitelisting for sensitive operations
- **AVOID** overly permissive CORS policies

## Implementation Guidance

**USE** these security schemes:

### OAuth 2.0 Authorization Code Flow
```yaml
components:
  securitySchemes:
    oauth2:
      type: oauth2
      description: OAuth 2.0 authorization code flow
      flows:
        authorizationCode:
          authorizationUrl: https://auth.example.com/oauth/authorize
          tokenUrl: https://auth.example.com/oauth/token
          scopes:
            read: Read access to resources
            write: Write access to resources
            admin: Administrative access
            user:profile: Access to user profile information
            orders:read: Read access to orders
            orders:write: Write access to orders
```

### JWT Bearer Token Authentication
```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: JWT token-based authentication
```

### API Key Authentication
```yaml
components:
  securitySchemes:
    apiKey:
      type: apiKey
      in: header
      name: X-API-Key
      description: API key for service authentication
    
    queryApiKey:
      type: apiKey
      in: query
      name: api_key
      description: API key passed as query parameter (not recommended for production)
```

**IMPLEMENT** these security patterns:

### Endpoint-Level Security Requirements
```yaml
paths:
  /public/health:
    get:
      summary: Health check endpoint
      description: Public endpoint for service health monitoring
      security: []  # No authentication required
      responses:
        '200':
          description: Service is healthy

  /users/profile:
    get:
      summary: Get user profile
      description: Retrieve the authenticated user's profile
      security:
        - oauth2: [read, user:profile]
        - bearerAuth: []
      responses:
        '200':
          description: User profile data
        '401':
          description: Authentication required
        '403':
          description: Insufficient permissions

  /admin/users:
    get:
      summary: List all users (admin only)
      description: Administrative endpoint to list all users
      security:
        - oauth2: [admin]
      responses:
        '200':
          description: List of users
        '401':
          description: Authentication required
        '403':
          description: Admin access required
```

### Security Response Headers
```yaml
components:
  responses:
    SecureResponse:
      description: Secure response with security headers
      headers:
        X-Content-Type-Options:
          schema:
            type: string
            enum: [nosniff]
          description: Prevents MIME type sniffing
        X-Frame-Options:
          schema:
            type: string
            enum: [DENY, SAMEORIGIN]
          description: Controls frame embedding
        X-XSS-Protection:
          schema:
            type: string
            enum: ["1; mode=block"]
          description: XSS protection header
        Strict-Transport-Security:
          schema:
            type: string
          description: HTTPS enforcement
          example: "max-age=31536000; includeSubDomains"
```

**ENSURE** these security validations:
- All sensitive endpoints require appropriate authentication
- Security schemes are properly defined and referenced
- Scopes and permissions are granular and well-defined
- Error responses don't leak sensitive information

## Anti-Patterns

**DON'T** implement these security approaches:
- **Plain text credentials**: Never include actual passwords, keys, or tokens in specs
- **Overly broad scopes**: Using single scope for all operations
- **Inconsistent security**: Some endpoints secure, others not without clear rationale
- **Sensitive data exposure**: Including PII or secrets in examples or descriptions

**AVOID** these common mistakes:
- **HTTP for production**: Using unencrypted connections for sensitive data
- **Query parameter secrets**: Passing tokens or keys in URL query strings
- **Missing security requirements**: Leaving endpoints without security definitions
- **Weak authentication**: Using deprecated or insecure authentication methods

**NEVER** do these actions:
- **Hardcode credentials**: Include actual API keys, tokens, or passwords
- **Expose internal systems**: Reference internal infrastructure in specifications
- **Skip input validation**: Missing validation on security-critical parameters
- **Ignore error scenarios**: Not defining proper error responses for security failures

## Code Examples

### Complete Security Implementation
```yaml
openapi: 3.1.0
info:
  title: Secure API Example
  version: 1.0.0
  description: Example API with comprehensive security implementation

servers:
  - url: https://api.example.com/v1
    description: Production server (HTTPS only)

security:
  - oauth2: [read]  # Default security requirement

paths:
  /auth/token:
    post:
      summary: Obtain access token
      description: Exchange credentials for access token
      security: []  # Public endpoint for authentication
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - grant_type
              properties:
                grant_type:
                  type: string
                  enum: [authorization_code, refresh_token]
                code:
                  type: string
                  description: Authorization code (for authorization_code grant)
                refresh_token:
                  type: string
                  description: Refresh token (for refresh_token grant)
      responses:
        '200':
          description: Token issued successfully
          content:
            application/json:
              schema:
                type: object
                required:
                  - access_token
                  - token_type
                  - expires_in
                properties:
                  access_token:
                    type: string
                    description: The access token
                  token_type:
                    type: string
                    enum: [Bearer]
                  expires_in:
                    type: integer
                    description: Token expiration time in seconds
                  refresh_token:
                    type: string
                    description: Refresh token for token renewal
                  scope:
                    type: string
                    description: Granted scopes
        '400':
          description: Invalid request
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SecurityError'
        '401':
          description: Invalid credentials
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SecurityError'

  /secure-data:
    get:
      summary: Access secure data
      description: Retrieve sensitive data requiring authentication
      security:
        - oauth2: [read, sensitive:read]
        - bearerAuth: []
      parameters:
        - name: X-Request-ID
          in: header
          required: true
          schema:
            type: string
            format: uuid
          description: Unique request identifier for audit trails
      responses:
        '200':
          description: Secure data retrieved successfully
          headers:
            X-Rate-Limit-Remaining:
              schema:
                type: integer
              description: Number of requests remaining in rate limit window
            X-Rate-Limit-Reset:
              schema:
                type: integer
              description: Rate limit reset time (Unix timestamp)
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: string
                    description: The secure data (masked in examples)
                    example: "[REDACTED]"
                  metadata:
                    type: object
                    properties:
                      accessLevel:
                        type: string
                        enum: [read, write, admin]
                      lastAccessed:
                        type: string
                        format: date-time
        '401':
          $ref: '#/components/responses/UnauthorizedError'
        '403':
          $ref: '#/components/responses/ForbiddenError'
        '429':
          $ref: '#/components/responses/RateLimitError'

components:
  securitySchemes:
    oauth2:
      type: oauth2
      description: OAuth 2.0 with PKCE support
      flows:
        authorizationCode:
          authorizationUrl: https://auth.example.com/oauth/authorize
          tokenUrl: https://auth.example.com/oauth/token
          refreshUrl: https://auth.example.com/oauth/refresh
          scopes:
            read: Read access to resources
            write: Write access to resources
            admin: Administrative privileges
            sensitive:read: Access to sensitive data
            sensitive:write: Modify sensitive data
            
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: JWT Bearer token authentication
      
  responses:
    UnauthorizedError:
      description: Authentication required
      headers:
        WWW-Authenticate:
          schema:
            type: string
          description: Authentication challenge
          example: 'Bearer realm="api", error="invalid_token"'
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/SecurityError'
            
    ForbiddenError:
      description: Insufficient permissions
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/SecurityError'
            
    RateLimitError:
      description: Rate limit exceeded
      headers:
        Retry-After:
          schema:
            type: integer
          description: Seconds to wait before retrying
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/SecurityError'
            
  schemas:
    SecurityError:
      type: object
      required:
        - error
        - error_description
      properties:
        error:
          type: string
          description: Error code
          enum:
            - invalid_request
            - invalid_client
            - invalid_grant
            - unauthorized_client
            - unsupported_grant_type
            - invalid_scope
            - access_denied
            - rate_limit_exceeded
        error_description:
          type: string
          description: Human-readable error description
        error_uri:
          type: string
          format: uri
          description: URI to documentation about the error
```

## Validation Checklist

**MUST** verify:
- [ ] All security schemes are properly defined in components
- [ ] Security requirements are applied to appropriate endpoints
- [ ] HTTPS is used for all production servers
- [ ] No sensitive information is exposed in the specification
- [ ] Authentication and authorization errors are properly handled

**SHOULD** check:
- [ ] Rate limiting is implemented for API protection
- [ ] Scopes are granular and follow principle of least privilege
- [ ] Security headers are included in responses
- [ ] Input validation is specified for all parameters
- [ ] Audit trails and monitoring capabilities are considered

## References

- [OAuth 2.0 Security Best Practices](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics)
- [OpenAPI Security Scheme Object](https://spec.openapis.org/oas/v3.1.0#security-scheme-object)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [JWT Security Best Practices](https://datatracker.ietf.org/doc/html/rfc8725)
