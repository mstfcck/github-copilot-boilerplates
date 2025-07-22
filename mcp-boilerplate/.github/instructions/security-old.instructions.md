---
applyTo: '**'
---
Security instructions for FastMCP and FastAPI Model Context Protocol (MCP) applications.

# Security Instructions

This document provides comprehensive security implementation guidelines for Model Context Protocol (MCP) applications using FastMCP framework and FastAPI integration.

## Requirements

### Critical Security Requirements (**MUST** Follow)
- **MUST** validate all input parameters in FastMCP tools and resources
- **REQUIRED** to implement FastAPI security dependencies for authentication
- **SHALL** use FastMCP auth providers for access control
- **MUST** sanitize outputs to prevent information disclosure
- **NEVER** execute arbitrary code or expose sensitive system information

### Strong Security Recommendations (**SHOULD** Implement)
- **SHOULD** implement OAuth 2.1 with FastAPI security utilities
- **RECOMMENDED** to use HTTPS for all FastAPI production deployments
- **ALWAYS** validate FastMCP resource access permissions
- **DO** implement rate limiting with FastAPI middleware
- **DON'T** trust client input without validation

### Optional Security Enhancements (**MAY** Consider)
- **MAY** implement JWT authentication with FastAPI JWT libraries
- **OPTIONAL** to use FastMCP proxy authentication for microservices
- **USE** FastAPI CORS middleware for cross-origin security
- **IMPLEMENT** API key authentication for FastMCP tools
- **AVOID** storing sensitive data in FastMCP resource responses

## FastMCP Security Patterns

**IMPLEMENT** these security patterns:

### Input Validation and Sanitization
```python
"""
Secure input validation for FastMCP applications.
"""
from fastmcp import FastMCP
from pydantic import BaseModel, validator, Field
from typing import List, Dict, Any, Optional
import re
import html
from datetime import datetime

mcp = FastMCP("secure-server")

class SecureDataInput(BaseModel):
    """Secure data input model with validation."""
    
    name: str = Field(..., min_length=1, max_length=100, regex=r'^[a-zA-Z0-9_\-\s]+$')
    email: Optional[str] = Field(None, regex=r'^[^@]+@[^@]+\.[^@]+$')
    age: int = Field(..., ge=0, le=150)
    data_points: List[float] = Field(..., min_items=1, max_items=1000)
    
    @validator('name')
    def sanitize_name(cls, v):
        """Sanitize name input."""
        return html.escape(v.strip())
    
    @validator('data_points')
    def validate_data_points(cls, v):
        """Validate data points for security."""
        # Check for suspicious patterns
        if any(abs(x) > 1e6 for x in v):
            raise ValueError("Data points contain suspiciously large values")
        
        # Check for NaN or infinite values
        if any(x != x or abs(x) == float('inf') for x in v):
            raise ValueError("Data points contain invalid values")
        
        return v

@mcp.tool
async def secure_data_analysis(
    input_data: SecureDataInput
) -> Dict[str, Any]:
    """
    Secure data analysis tool with comprehensive input validation.
    
    Security features:
    - Pydantic model validation
    - Input sanitization
    - Range checking
    - Output sanitization
    """
    try:
        # Process validated data
        result = {
            "name": input_data.name,  # Already sanitized
            "email_provided": input_data.email is not None,
            "age_category": "adult" if input_data.age >= 18 else "minor",
            "data_analysis": {
                "count": len(input_data.data_points),
                "mean": sum(input_data.data_points) / len(input_data.data_points),
                "min": min(input_data.data_points),
                "max": max(input_data.data_points)
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        
        # Sanitize output (remove sensitive information)
        if input_data.email:
            # Don't include full email in response
            result["email_domain"] = input_data.email.split('@')[1]
        
        return result
        
    except Exception as e:
        # Log error securely without exposing details
        print(f"Analysis error: {type(e).__name__}")
        
        # Return sanitized error
        return {
            "error": "Analysis failed due to invalid input",
            "timestamp": datetime.utcnow().isoformat()
        }

@mcp.tool
async def secure_file_processor(
    filename: str,
    content_type: str = "text/plain"
) -> Dict[str, Any]:
    """
    Secure file processing with path validation.
    
    Security features:
    - Path traversal prevention
    - File type validation
    - Size limiting
    """
    # Validate filename (prevent path traversal)
    if not re.match(r'^[a-zA-Z0-9._-]+$', filename):
        raise ValueError("Invalid filename format")
    
    if '..' in filename or '/' in filename or '\\' in filename:
        raise ValueError("Path traversal attempt detected")
    
    # Validate content type
    allowed_types = ['text/plain', 'application/json', 'text/csv']
    if content_type not in allowed_types:
        raise ValueError(f"Content type not allowed: {content_type}")
    
    # Simulate secure file processing
    return {
        "filename": html.escape(filename),
        "content_type": content_type,
        "processed": True,
        "size_limit": "1MB",
        "security_scan": "passed"
    }
```

### FastAPI Authentication Integration
```python
"""
FastAPI authentication integration with FastMCP.
"""
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastmcp import FastMCP
import jwt
from datetime import datetime, timedelta
from typing import Dict, Any, Optional
from passlib.context import CryptContext

# Security setup
security = HTTPBearer()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

SECRET_KEY = "your-secret-key"  # Use environment variable in production
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# FastAPI app with security
app = FastAPI(title="Secure MCP API")

# Create FastMCP server from FastAPI
mcp = FastMCP.from_fastapi(
    app=app,
    name="SecureHybridServer"
)

# User database (use proper database in production)
fake_users_db = {
    "admin": {
        "username": "admin",
        "email": "admin@example.com",
        "hashed_password": pwd_context.hash("secret123"),
        "permissions": ["read", "write", "admin"]
    },
    "user": {
        "username": "user",
        "email": "user@example.com",
        "hashed_password": pwd_context.hash("password"),
        "permissions": ["read"]
    }
}

class User(BaseModel):
    """User model for authentication."""
    username: str
    email: str
    permissions: List[str]

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify password against hash."""
    return pwd_context.verify(plain_password, hashed_password)

def authenticate_user(username: str, password: str) -> Optional[User]:
    """Authenticate user credentials."""
    user_data = fake_users_db.get(username)
    if not user_data or not verify_password(password, user_data["hashed_password"]):
        return None
    
    return User(
        username=user_data["username"],
        email=user_data["email"],
        permissions=user_data["permissions"]
    )

def create_access_token(data: Dict[str, Any], expires_delta: Optional[timedelta] = None):
    """Create JWT access token."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_current_user(token: str = Depends(oauth2_scheme)) -> User:
    """Get current authenticated user."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except jwt.PyJWTError:
        raise credentials_exception
    
    user_data = fake_users_db.get(username)
    if user_data is None:
        raise credentials_exception
    
    return User(
        username=user_data["username"],
        email=user_data["email"],
        permissions=user_data["permissions"]
    )

def require_permission(permission: str):
    """Dependency to require specific permission."""
    def check_permission(current_user: User = Depends(get_current_user)):
        if permission not in current_user.permissions:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions"
            )
        return current_user
    return check_permission

# Authentication endpoints
@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    """User login endpoint."""
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}

# Secure FastMCP tools with authentication
@mcp.tool
async def secure_admin_operation(
    operation: str,
    parameters: Dict[str, Any],
    current_user: User = Depends(require_permission("admin"))
) -> Dict[str, Any]:
    """
    Admin-only operation with authentication.
    
    Security features:
    - JWT authentication required
    - Admin permission check
    - User context logging
    """
    # Log operation for audit
    print(f"Admin operation '{operation}' performed by {current_user.username}")
    
    return {
        "operation": operation,
        "parameters": parameters,
        "performed_by": current_user.username,
        "timestamp": datetime.utcnow().isoformat(),
        "success": True
    }

@mcp.tool
async def secure_user_data_access(
    data_id: str,
    current_user: User = Depends(require_permission("read"))
) -> Dict[str, Any]:
    """
    User data access with authentication and authorization.
    
    Security features:
    - Authentication required
    - Read permission check
    - Data access logging
    """
    # Validate data_id format
    if not re.match(r'^[a-zA-Z0-9_-]+$', data_id):
        raise ValueError("Invalid data ID format")
    
    # Log data access for audit
    print(f"Data access '{data_id}' by {current_user.username}")
    
    # Simulate secure data retrieval
    return {
        "data_id": data_id,
        "data": {
            "title": f"Data {data_id}",
            "content": "Secure content here",
            "access_level": "user"
        },
        "accessed_by": current_user.username,
        "permissions": current_user.permissions,
        "timestamp": datetime.utcnow().isoformat()
    }
```

### Rate Limiting and Security Middleware
```python
"""
Rate limiting and security middleware for FastAPI + FastMCP.
"""
from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
import time
from collections import defaultdict, deque
from typing import Dict, Any
import asyncio

# Rate limiting storage
request_counts = defaultdict(lambda: deque())
RATE_LIMIT_REQUESTS = 100  # requests per minute
RATE_LIMIT_WINDOW = 60  # seconds

class RateLimitMiddleware:
    """Rate limiting middleware for FastAPI."""
    
    def __init__(self, app: FastAPI):
        self.app = app
    
    async def __call__(self, request: Request, call_next):
        # Get client IP
        client_ip = request.client.host
        current_time = time.time()
        
        # Clean old requests
        request_times = request_counts[client_ip]
        while request_times and current_time - request_times[0] > RATE_LIMIT_WINDOW:
            request_times.popleft()
        
        # Check rate limit
        if len(request_times) >= RATE_LIMIT_REQUESTS:
            return JSONResponse(
                status_code=429,
                content={
                    "error": "Rate limit exceeded",
                    "retry_after": RATE_LIMIT_WINDOW
                }
            )
        
        # Add current request
        request_times.append(current_time)
        
        # Process request
        response = await call_next(request)
        
        # Add security headers
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        
        return response

# Security middleware setup
def setup_security_middleware(app: FastAPI):
    """Setup comprehensive security middleware."""
    
    # CORS configuration
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["https://trusted-domain.com"],  # Specific origins only
        allow_credentials=True,
        allow_methods=["GET", "POST"],
        allow_headers=["Authorization", "Content-Type"],
    )
    
    # Trusted host middleware
    app.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=["trusted-domain.com", "api.trusted-domain.com"]
    )
    
    # Rate limiting middleware
    app.add_middleware(RateLimitMiddleware)

# FastMCP resource security
@mcp.resource("secure://config/{config_type}")
async def get_secure_config(
    config_type: str,
    current_user: User = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Secure configuration resource with access control.
    
    Security features:
    - Authentication required
    - Config type validation
    - Permission-based filtering
    """
    # Validate config type
    allowed_configs = ["public", "user", "admin"]
    if config_type not in allowed_configs:
        raise ValueError(f"Invalid config type: {config_type}")
    
    # Permission-based access control
    if config_type == "admin" and "admin" not in current_user.permissions:
        raise HTTPException(
            status_code=403,
            detail="Admin access required for this configuration"
        )
    
    # Return filtered configuration based on permissions
    base_config = {
        "server_name": "Secure MCP Server",
        "version": "1.0.0",
        "public_features": ["analysis", "reporting"]
    }
    
    if "admin" in current_user.permissions:
        base_config.update({
            "admin_features": ["user_management", "system_config"],
            "debug_mode": True,
            "internal_endpoints": ["/admin", "/metrics"]
        })
    
    if config_type == "user":
        base_config.update({
            "user_features": ["data_access", "basic_analysis"],
            "rate_limits": {"requests_per_minute": 100}
        })
    
    return {
        "config_type": config_type,
        "config": base_config,
        "accessed_by": current_user.username,
        "access_level": "admin" if "admin" in current_user.permissions else "user"
    }
```

### Secure Error Handling
```python
"""
Secure error handling for FastMCP applications.
"""
import logging
from fastmcp import FastMCP
from fastapi import HTTPException, Request
from fastapi.exception_handlers import http_exception_handler
from typing import Dict, Any
import traceback
import uuid

# Configure secure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('security.log'),
        logging.StreamHandler()
    ]
)

security_logger = logging.getLogger('security')

class SecureErrorHandler:
    """Secure error handling utility."""
    
    @staticmethod
    def log_security_event(event_type: str, details: Dict[str, Any], user_id: str = None):
        """Log security events for audit."""
        event_id = str(uuid.uuid4())
        
        security_logger.warning(
            f"SECURITY_EVENT: {event_type} | ID: {event_id} | User: {user_id} | Details: {details}"
        )
        
        return event_id
    
    @staticmethod
    def sanitize_error_message(error: Exception, is_production: bool = True) -> str:
        """Sanitize error messages for client response."""
        if is_production:
            # Generic error messages in production
            error_map = {
                ValueError: "Invalid input provided",
                PermissionError: "Access denied",
                FileNotFoundError: "Resource not found",
                ConnectionError: "Service temporarily unavailable"
            }
            
            return error_map.get(type(error), "An error occurred")
        else:
            # Detailed errors in development
            return str(error)

mcp = FastMCP("secure-error-handling-server")

@mcp.tool
async def secure_operation_with_error_handling(
    operation_type: str,
    data: Dict[str, Any],
    current_user: User = Depends(get_current_user)
) -> Dict[str, Any]:
    """
    Secure operation with comprehensive error handling.
    
    Security features:
    - Input validation
    - Secure error logging
    - Sanitized error responses
    - Audit trail
    """
    operation_id = str(uuid.uuid4())
    
    try:
        # Log operation start
        security_logger.info(
            f"OPERATION_START: {operation_type} | ID: {operation_id} | User: {current_user.username}"
        )
        
        # Validate operation type
        allowed_operations = ["analyze", "report", "export"]
        if operation_type not in allowed_operations:
            raise ValueError(f"Invalid operation type: {operation_type}")
        
        # Validate data structure
        if not isinstance(data, dict) or not data:
            raise ValueError("Data must be a non-empty dictionary")
        
        # Check for suspicious patterns
        data_str = str(data)
        suspicious_patterns = ['<script', 'javascript:', 'data:', '../', '..\\']
        
        for pattern in suspicious_patterns:
            if pattern.lower() in data_str.lower():
                # Log security incident
                SecureErrorHandler.log_security_event(
                    "SUSPICIOUS_INPUT",
                    {
                        "operation_type": operation_type,
                        "pattern_detected": pattern,
                        "operation_id": operation_id
                    },
                    current_user.username
                )
                
                raise ValueError("Suspicious input detected")
        
        # Simulate operation
        await asyncio.sleep(0.1)
        
        result = {
            "operation_id": operation_id,
            "operation_type": operation_type,
            "status": "completed",
            "result_data": {"processed": True, "item_count": len(data)},
            "performed_by": current_user.username,
            "timestamp": datetime.utcnow().isoformat()
        }
        
        # Log successful operation
        security_logger.info(
            f"OPERATION_SUCCESS: {operation_type} | ID: {operation_id} | User: {current_user.username}"
        )
        
        return result
        
    except ValueError as e:
        # Log validation error
        SecureErrorHandler.log_security_event(
            "VALIDATION_ERROR",
            {
                "operation_type": operation_type,
                "error": str(e),
                "operation_id": operation_id
            },
            current_user.username
        )
        
        raise HTTPException(
            status_code=400,
            detail=SecureErrorHandler.sanitize_error_message(e)
        )
        
    except PermissionError as e:
        # Log permission error
        SecureErrorHandler.log_security_event(
            "PERMISSION_DENIED",
            {
                "operation_type": operation_type,
                "operation_id": operation_id
            },
            current_user.username
        )
        
        raise HTTPException(
            status_code=403,
            detail="Access denied"
        )
        
    except Exception as e:
        # Log unexpected error
        error_id = str(uuid.uuid4())
        
        security_logger.error(
            f"OPERATION_ERROR: {operation_type} | ID: {operation_id} | ErrorID: {error_id} | "
            f"User: {current_user.username} | Error: {type(e).__name__}"
        )
        
        # Log full traceback securely (not exposed to client)
        security_logger.error(f"TRACEBACK: {error_id} | {traceback.format_exc()}")
        
        raise HTTPException(
            status_code=500,
            detail=f"Internal error occurred. Reference ID: {error_id}"
        )

# Custom exception handler for FastAPI
@app.exception_handler(Exception)
async def custom_exception_handler(request: Request, exc: Exception):
    """Custom exception handler with security logging."""
    error_id = str(uuid.uuid4())
    
    # Log the error securely
    security_logger.error(
        f"UNHANDLED_EXCEPTION: {error_id} | "
        f"Path: {request.url.path} | "
        f"Method: {request.method} | "
        f"Error: {type(exc).__name__}"
    )
    
    # Return generic error response
    return JSONResponse(
        status_code=500,
        content={
            "error": "An internal error occurred",
            "reference_id": error_id
        }
    )
```

## Security Best Practices

**FOLLOW** these security best practices:

### Authentication and Authorization
- Use JWT tokens with appropriate expiration times
- Implement role-based access control (RBAC)
- Use secure password hashing (bcrypt, scrypt)
- Implement proper session management
- Use OAuth 2.1 for third-party authentication

### Input Validation and Sanitization
- Validate all inputs using Pydantic models
- Sanitize outputs to prevent XSS attacks
- Implement proper encoding for special characters
- Check for path traversal attacks
- Validate file uploads and types

### Transport Security
- Use HTTPS for all production deployments
- Implement proper certificate validation
- Use secure WebSocket connections (WSS)
- Configure appropriate CORS policies
- Implement HSTS headers

### Error Handling and Logging
- Sanitize error messages for production
- Log security events for audit trails
- Implement proper exception handling
- Use correlation IDs for error tracking
- Monitor and alert on security events

### Data Protection
- Encrypt sensitive data at rest and in transit
- Implement proper key management
- Use environment variables for secrets
- Implement data masking for logs
- Follow data minimization principles

## Security Testing

**IMPLEMENT** comprehensive security testing:

### Penetration Testing
```python
"""
Security testing for FastMCP applications.
"""
import pytest
from fastapi.testclient import TestClient
from typing import Dict, Any

def test_sql_injection_protection(client: TestClient):
    """Test SQL injection protection."""
    malicious_inputs = [
        "'; DROP TABLE users; --",
        "1' OR '1'='1",
        "admin'; --",
        "1 UNION SELECT * FROM users"
    ]
    
    for malicious_input in malicious_inputs:
        response = client.post(
            "/secure-operation",
            json={"operation_type": malicious_input, "data": {}}
        )
        
        # Should return error, not execute malicious code
        assert response.status_code in [400, 422]

def test_xss_protection(client: TestClient):
    """Test XSS protection."""
    xss_payloads = [
        "<script>alert('xss')</script>",
        "javascript:alert('xss')",
        "<img src=x onerror=alert('xss')>",
        "data:text/html,<script>alert('xss')</script>"
    ]
    
    for payload in xss_payloads:
        response = client.post(
            "/secure-operation",
            json={"operation_type": "analyze", "data": {"name": payload}}
        )
        
        # Check that response doesn't contain unsanitized script
        assert "<script>" not in response.text
        assert "javascript:" not in response.text

def test_path_traversal_protection(client: TestClient):
    """Test path traversal protection."""
    traversal_attempts = [
        "../../../etc/passwd",
        "..\\..\\..\\windows\\system32\\config\\sam",
        "....//....//....//etc//passwd",
        "%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd"
    ]
    
    for attempt in traversal_attempts:
        response = client.post(
            "/secure-file-process",
            json={"filename": attempt}
        )
        
        assert response.status_code == 400

def test_rate_limiting(client: TestClient):
    """Test rate limiting functionality."""
    # Make many requests quickly
    responses = []
    for _ in range(150):  # Exceed rate limit
        response = client.get("/health")
        responses.append(response)
    
    # Some requests should be rate limited
    rate_limited = [r for r in responses if r.status_code == 429]
    assert len(rate_limited) > 0

def test_authentication_required(client: TestClient):
    """Test that authentication is required for protected endpoints."""
    response = client.post(
        "/secure-admin-operation",
        json={"operation": "test", "parameters": {}}
    )
    
    assert response.status_code == 401

def test_authorization_levels(authenticated_client: TestClient):
    """Test authorization levels."""
    # Test with user token (should fail for admin operation)
    response = authenticated_client.post(
        "/secure-admin-operation",
        json={"operation": "admin_task", "parameters": {}}
    )
    
    assert response.status_code == 403
```

## Compliance and Auditing

**MAINTAIN** security compliance:

### Audit Logging
- Log all authentication attempts
- Track privileged operations
- Monitor failed access attempts
- Record data access patterns
- Maintain audit trails for compliance

### Security Monitoring
- Implement real-time threat detection
- Monitor for suspicious patterns
- Set up alerting for security events
- Regular security assessments
- Vulnerability scanning

### Compliance Requirements
- Follow OWASP security guidelines
- Implement GDPR data protection
- Maintain SOC 2 compliance
- Regular security training
- Incident response procedures

## References

- [FastMCP Security Guide](https://gofastmcp.com/security) - Framework-specific security patterns
- [FastAPI Security](https://fastapi.tiangolo.com/tutorial/security/) - Web framework security
- [OWASP Guidelines](https://owasp.org/) - Web application security
- [MCP Instructions](./mcp.instructions.md) - Comprehensive FastMCP and FastAPI documentation
- [Testing Instructions](./testing.instructions.md) - Security testing guidelines
- **ALWAYS** validate Origin header for DNS rebinding attack prevention
- **DO** implement proper access control for resources and tools
- **DON'T** log sensitive information or credentials

### Optional Enhancements (**MAY** Consider)
- **MAY** implement advanced monitoring and audit logging
- **OPTIONAL** to add IP-based access restrictions
- **USE** content security policies for web-based interfaces
- **IMPLEMENT** encryption for sensitive data at rest
- **AVOID** exposing internal system details in error messages

## Implementation Guidance

**USE** these security patterns:

### Input Validation
```python
# Python Input Validation
import json
from typing import Any, Dict
from jsonschema import validate, ValidationError

class InputValidator:
    def __init__(self):
        self.tool_schemas = {}
    
    def validate_tool_input(self, tool_name: str, arguments: Dict[str, Any]) -> bool:
        """Validate tool input against schema"""
        if tool_name not in self.tool_schemas:
            raise ValueError(f"Unknown tool: {tool_name}")
        
        schema = self.tool_schemas[tool_name]
        try:
            validate(instance=arguments, schema=schema)
            return True
        except ValidationError as e:
            raise ValueError(f"Invalid input for {tool_name}: {e.message}")
    
    def sanitize_string(self, value: str) -> str:
        """Sanitize string input"""
        # Remove potential script injections
        dangerous_patterns = ['<script', 'javascript:', 'data:', 'vbscript:']
        sanitized = value
        for pattern in dangerous_patterns:
            sanitized = sanitized.replace(pattern, '')
        return sanitized.strip()
```

### Authentication Implementation
```typescript
// TypeScript OAuth 2.1 Implementation
interface AuthConfig {
    authorizationUrl: string;
    tokenUrl: string;
    clientId: string;
    clientSecret?: string;
    scopes: string[];
}

class MCPAuthenticator {
    private config: AuthConfig;
    private accessToken?: string;
    private refreshToken?: string;
    
    constructor(config: AuthConfig) {
        this.config = config;
    }
    
    async authenticate(): Promise<void> {
        // Implement OAuth 2.1 PKCE flow
        const codeVerifier = this.generateCodeVerifier();
        const codeChallenge = await this.generateCodeChallenge(codeVerifier);
        
        const authUrl = new URL(this.config.authorizationUrl);
        authUrl.searchParams.set('client_id', this.config.clientId);
        authUrl.searchParams.set('response_type', 'code');
        authUrl.searchParams.set('code_challenge', codeChallenge);
        authUrl.searchParams.set('code_challenge_method', 'S256');
        authUrl.searchParams.set('scope', this.config.scopes.join(' '));
        
        // Redirect user to authorization URL
        // Handle callback and exchange code for tokens
    }
    
    private generateCodeVerifier(): string {
        const array = new Uint8Array(32);
        crypto.getRandomValues(array);
        return btoa(String.fromCharCode(...array))
            .replace(/\+/g, '-')
            .replace(/\//g, '_')
            .replace(/=/g, '');
    }
    
    private async generateCodeChallenge(verifier: string): Promise<string> {
        const encoder = new TextEncoder();
        const data = encoder.encode(verifier);
        const digest = await crypto.subtle.digest('SHA-256', data);
        return btoa(String.fromCharCode(...new Uint8Array(digest)))
            .replace(/\+/g, '-')
            .replace(/\//g, '_')
            .replace(/=/g, '');
    }
}
```

### Rate Limiting
```java
// Java Rate Limiting Implementation
import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

public class MCPRateLimiter {
    private final ConcurrentHashMap<String, ClientBucket> clientBuckets = new ConcurrentHashMap<>();
    private final int maxRequestsPerMinute;
    private final Duration windowDuration;
    
    public MCPRateLimiter(int maxRequestsPerMinute) {
        this.maxRequestsPerMinute = maxRequestsPerMinute;
        this.windowDuration = Duration.ofMinutes(1);
    }
    
    public boolean isAllowed(String clientId, String operation) {
        ClientBucket bucket = clientBuckets.computeIfAbsent(clientId, k -> new ClientBucket());
        return bucket.tryConsume(operation);
    }
    
    private class ClientBucket {
        private final ConcurrentHashMap<String, OperationWindow> operations = new ConcurrentHashMap<>();
        
        public boolean tryConsume(String operation) {
            OperationWindow window = operations.computeIfAbsent(operation, k -> new OperationWindow());
            return window.tryConsume();
        }
        
        private class OperationWindow {
            private volatile Instant windowStart = Instant.now();
            private final AtomicInteger requestCount = new AtomicInteger(0);
            
            public boolean tryConsume() {
                Instant now = Instant.now();
                
                // Reset window if expired
                if (now.isAfter(windowStart.plus(windowDuration))) {
                    synchronized (this) {
                        if (now.isAfter(windowStart.plus(windowDuration))) {
                            windowStart = now;
                            requestCount.set(0);
                        }
                    }
                }
                
                // Check if under limit
                return requestCount.incrementAndGet() <= maxRequestsPerMinute;
            }
        }
    }
}
```

**IMPLEMENT** these security configurations:

### HTTP Transport Security
```python
# Python HTTP Transport Security
from aiohttp import web, ClientSession
from aiohttp.web_middlewares import cors_handler
import ssl

class SecureMCPServer:
    def __init__(self):
        self.app = web.Application()
        self.setup_security_middleware()
        self.setup_routes()
    
    def setup_security_middleware(self):
        """Setup security middleware"""
        
        async def validate_origin(request, handler):
            """Validate Origin header to prevent DNS rebinding"""
            origin = request.headers.get('Origin')
            if origin:
                allowed_origins = ['https://localhost', 'https://127.0.0.1']
                if origin not in allowed_origins:
                    raise web.HTTPForbidden(text="Invalid origin")
            return await handler(request)
        
        async def validate_auth(request, handler):
            """Validate authentication token"""
            auth_header = request.headers.get('Authorization')
            if not auth_header or not auth_header.startswith('Bearer '):
                raise web.HTTPUnauthorized(text="Missing or invalid authorization")
            
            token = auth_header[7:]  # Remove 'Bearer ' prefix
            if not self.validate_token(token):
                raise web.HTTPUnauthorized(text="Invalid token")
            
            return await handler(request)
        
        async def add_security_headers(request, handler):
            """Add security headers to responses"""
            response = await handler(request)
            response.headers['X-Content-Type-Options'] = 'nosniff'
            response.headers['X-Frame-Options'] = 'DENY'
            response.headers['X-XSS-Protection'] = '1; mode=block'
            response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
            return response
        
        self.app.middlewares.append(validate_origin)
        self.app.middlewares.append(validate_auth)
        self.app.middlewares.append(add_security_headers)
    
    def validate_token(self, token: str) -> bool:
        """Validate JWT token"""
        try:
            # Implement JWT validation
            # Verify signature, expiration, issuer, audience
            return True
        except Exception:
            return False
    
    def setup_ssl_context(self):
        """Setup SSL context for HTTPS"""
        ssl_context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
        ssl_context.load_cert_chain('path/to/cert.pem', 'path/to/key.pem')
        return ssl_context
```

### Access Control Implementation
```typescript
// TypeScript Access Control
interface AccessPolicy {
    resource: string;
    action: string;
    conditions?: Record<string, any>;
}

class MCPAccessController {
    private policies: Map<string, AccessPolicy[]> = new Map();
    
    addPolicy(clientId: string, policy: AccessPolicy): void {
        const clientPolicies = this.policies.get(clientId) || [];
        clientPolicies.push(policy);
        this.policies.set(clientId, clientPolicies);
    }
    
    async checkAccess(clientId: string, resource: string, action: string, context?: any): Promise<boolean> {
        const clientPolicies = this.policies.get(clientId) || [];
        
        for (const policy of clientPolicies) {
            if (this.policyMatches(policy, resource, action, context)) {
                return true;
            }
        }
        
        return false;
    }
    
    private policyMatches(policy: AccessPolicy, resource: string, action: string, context?: any): boolean {
        // Check resource pattern match
        if (!this.matchesPattern(policy.resource, resource)) {
            return false;
        }
        
        // Check action match
        if (policy.action !== '*' && policy.action !== action) {
            return false;
        }
        
        // Check conditions if present
        if (policy.conditions && context) {
            for (const [key, expectedValue] of Object.entries(policy.conditions)) {
                if (context[key] !== expectedValue) {
                    return false;
                }
            }
        }
        
        return true;
    }
    
    private matchesPattern(pattern: string, value: string): boolean {
        // Simple wildcard matching
        const regex = new RegExp(pattern.replace(/\*/g, '.*'));
        return regex.test(value);
    }
}
```

**ENSURE** these security validations:

### Output Sanitization
```python
# Python Output Sanitization
import html
import re
from typing import Any, Dict

class OutputSanitizer:
    def __init__(self):
        self.sensitive_patterns = [
            r'password\s*[:=]\s*[^\s]+',
            r'token\s*[:=]\s*[^\s]+',
            r'key\s*[:=]\s*[^\s]+',
            r'secret\s*[:=]\s*[^\s]+',
            r'/etc/passwd',
            r'/etc/shadow',
            r'c:\\windows\\system32'
        ]
    
    def sanitize_output(self, data: Any) -> Any:
        """Sanitize output to prevent information disclosure"""
        if isinstance(data, str):
            return self.sanitize_string(data)
        elif isinstance(data, dict):
            return {k: self.sanitize_output(v) for k, v in data.items()}
        elif isinstance(data, list):
            return [self.sanitize_output(item) for item in data]
        else:
            return data
    
    def sanitize_string(self, text: str) -> str:
        """Sanitize string to remove sensitive information"""
        sanitized = text
        
        # Remove sensitive patterns
        for pattern in self.sensitive_patterns:
            sanitized = re.sub(pattern, '[REDACTED]', sanitized, flags=re.IGNORECASE)
        
        # HTML escape if needed
        sanitized = html.escape(sanitized)
        
        return sanitized
    
    def sanitize_error_message(self, error: Exception) -> str:
        """Sanitize error messages to prevent information disclosure"""
        error_msg = str(error)
        
        # Remove file paths
        error_msg = re.sub(r'/[^\s]+', '[PATH]', error_msg)
        error_msg = re.sub(r'[A-Z]:\\[^\s]+', '[PATH]', error_msg)
        
        # Remove sensitive patterns
        for pattern in self.sensitive_patterns:
            error_msg = re.sub(pattern, '[REDACTED]', error_msg, flags=re.IGNORECASE)
        
        return error_msg
```

## Anti-Patterns

**DON'T** implement these security approaches:

### Avoid Insecure Authentication
```python
# BAD - Insecure authentication
def bad_auth_check(request):
    # NEVER use simple password comparison
    if request.headers.get('password') == 'admin123':
        return True
    
    # NEVER trust client-provided tokens without validation
    token = request.headers.get('token')
    return token is not None  # No validation
```

### Avoid Information Disclosure
```typescript
// BAD - Information disclosure
class BadErrorHandler {
    handleError(error: Error): any {
        // NEVER expose internal errors
        return {
            error: error.stack,  // Exposes internal structure
            config: this.config,  // Exposes configuration
            env: process.env     // Exposes environment variables
        };
    }
}
```

**AVOID** these common security mistakes:

### SQL Injection Vulnerabilities
```python
# BAD - SQL injection vulnerability
def bad_database_query(user_input):
    # NEVER use string concatenation for SQL queries
    query = f"SELECT * FROM users WHERE name = '{user_input}'"
    return execute_query(query)
```

### Command Injection Vulnerabilities
```java
// BAD - Command injection vulnerability
public class BadToolHandler {
    public String handleTool(String command) {
        // NEVER execute arbitrary commands
        try {
            Process process = Runtime.getRuntime().exec(command);
            return getOutput(process);
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}
```

**NEVER** do these security violations:

### Hardcoded Secrets
```python
# BAD - Hardcoded secrets
API_KEY = "sk-1234567890abcdef"  # NEVER hardcode secrets
DATABASE_PASSWORD = "password123"  # NEVER hardcode passwords

def connect_to_service():
    return ServiceClient(api_key=API_KEY)  # Security violation
```

### Inadequate Input Validation
```typescript
// BAD - Inadequate input validation
class BadInputHandler {
    async handleToolCall(toolName: string, args: any): Promise<any> {
        // NEVER trust input without validation
        return await this.tools[toolName](args);
        
        // NEVER allow arbitrary file access
        const filePath = args.path;
        return fs.readFileSync(filePath);
    }
}
```

## Code Examples

### Complete Security Implementation
```python
import asyncio
import jwt
import hashlib
import secrets
from typing import Dict, Any, Optional
from datetime import datetime, timedelta

class SecureMCPImplementation:
    def __init__(self):
        self.rate_limiter = MCPRateLimiter(100)  # 100 requests per minute
        self.access_controller = MCPAccessController()
        self.input_validator = InputValidator()
        self.output_sanitizer = OutputSanitizer()
        self.jwt_secret = secrets.token_urlsafe(32)
    
    async def secure_tool_call(self, client_id: str, tool_name: str, 
                              arguments: Dict[str, Any], auth_token: str) -> Dict[str, Any]:
        """Secure tool call with comprehensive security checks"""
        
        try:
            # 1. Validate authentication
            if not self.validate_jwt_token(auth_token):
                raise SecurityError("Invalid authentication token")
            
            # 2. Check rate limiting
            if not self.rate_limiter.is_allowed(client_id, f"tool:{tool_name}"):
                raise SecurityError("Rate limit exceeded")
            
            # 3. Validate input
            self.input_validator.validate_tool_input(tool_name, arguments)
            
            # 4. Check access control
            if not await self.access_controller.check_access(client_id, f"tool:{tool_name}", "execute"):
                raise SecurityError("Access denied")
            
            # 5. Execute tool with sanitized input
            sanitized_args = self.input_validator.sanitize_input(arguments)
            result = await self.execute_tool(tool_name, sanitized_args)
            
            # 6. Sanitize output
            sanitized_result = self.output_sanitizer.sanitize_output(result)
            
            return {
                "success": True,
                "result": sanitized_result,
                "timestamp": datetime.utcnow().isoformat()
            }
            
        except SecurityError as e:
            # Log security event
            await self.log_security_event(client_id, "SECURITY_VIOLATION", str(e))
            raise
        except Exception as e:
            # Sanitize error message
            sanitized_error = self.output_sanitizer.sanitize_error_message(e)
            return {
                "success": False,
                "error": sanitized_error,
                "timestamp": datetime.utcnow().isoformat()
            }
    
    def validate_jwt_token(self, token: str) -> bool:
        """Validate JWT token with proper verification"""
        try:
            decoded = jwt.decode(
                token,
                self.jwt_secret,
                algorithms=['HS256'],
                options={
                    'verify_signature': True,
                    'verify_exp': True,
                    'verify_iat': True,
                    'verify_aud': True,
                    'verify_iss': True
                }
            )
            
            # Additional validation
            if decoded.get('aud') != 'mcp-server':
                return False
            if decoded.get('iss') != 'mcp-auth':
                return False
            
            return True
            
        except jwt.InvalidTokenError:
            return False
    
    async def log_security_event(self, client_id: str, event_type: str, details: str):
        """Log security events for monitoring"""
        event = {
            "timestamp": datetime.utcnow().isoformat(),
            "client_id": client_id,
            "event_type": event_type,
            "details": details,
            "source_ip": "redacted"  # Don't log IP addresses
        }
        
        # Send to security monitoring system
        await self.send_to_security_monitor(event)

class SecurityError(Exception):
    """Security-related exception"""
    pass
```

## Security Testing Requirements

### Unit Tests
**MUST** test security components:
```python
import pytest
from unittest.mock import Mock, patch

class TestMCPSecurity:
    def test_input_validation(self):
        validator = InputValidator()
        
        # Test valid input
        valid_args = {"param": "safe_value"}
        assert validator.validate_tool_input("test_tool", valid_args)
        
        # Test invalid input
        invalid_args = {"param": "<script>alert('xss')</script>"}
        with pytest.raises(ValueError):
            validator.validate_tool_input("test_tool", invalid_args)
    
    def test_rate_limiting(self):
        limiter = MCPRateLimiter(2)  # 2 requests per minute
        
        # First two requests should succeed
        assert limiter.is_allowed("client1", "operation1")
        assert limiter.is_allowed("client1", "operation1")
        
        # Third request should fail
        assert not limiter.is_allowed("client1", "operation1")
    
    def test_access_control(self):
        controller = MCPAccessController()
        controller.add_policy("client1", {
            "resource": "tool:calculator",
            "action": "execute"
        })
        
        # Should allow access to calculator tool
        assert controller.check_access("client1", "tool:calculator", "execute")
        
        # Should deny access to other tools
        assert not controller.check_access("client1", "tool:file_system", "execute")
```

### Integration Tests
**MUST** test security integrations:
```python
import asyncio
import aiohttp
from aiohttp.test_utils import AioHTTPTestCase

class TestSecurityIntegration(AioHTTPTestCase):
    async def get_application(self):
        return create_secure_mcp_app()
    
    async def test_authentication_required(self):
        # Test unauthenticated request
        async with self.client.post('/mcp/tools/call') as resp:
            assert resp.status == 401
    
    async def test_origin_validation(self):
        # Test invalid origin
        headers = {'Origin': 'https://malicious.com'}
        async with self.client.post('/mcp/tools/call', headers=headers) as resp:
            assert resp.status == 403
    
    async def test_rate_limiting_integration(self):
        headers = {'Authorization': 'Bearer valid_token'}
        
        # Make requests up to limit
        for i in range(100):
            async with self.client.post('/mcp/tools/call', headers=headers) as resp:
                assert resp.status in [200, 400]  # Success or validation error
        
        # Next request should be rate limited
        async with self.client.post('/mcp/tools/call', headers=headers) as resp:
            assert resp.status == 429
```

## Validation Checklist

**MUST** verify:
- [ ] Input validation implemented for all protocol endpoints
- [ ] Authentication and authorization properly configured
- [ ] Rate limiting implemented for all operations
- [ ] Output sanitization prevents information disclosure
- [ ] HTTPS configured for production deployments
- [ ] Origin header validation prevents DNS rebinding attacks
- [ ] Error messages don't expose sensitive information
- [ ] Secrets are properly externalized and secured

**SHOULD** check:
- [ ] JWT tokens properly validated with signature verification
- [ ] Access control policies correctly implemented
- [ ] Security events logged and monitored
- [ ] Security headers configured for HTTP responses
- [ ] Input schemas strictly enforce expected data types
- [ ] File system access properly restricted
- [ ] Database queries use parameterized statements

## References

- [MCP Security Best Practices](https://modelcontextprotocol.io/introduction/specification/draft/basic/security_best_practices)
- [OAuth 2.1 Security Best Practices](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics)
- [MCP Transport Security](https://modelcontextprotocol.io/introduction/specification/draft/basic/transports)
- [OWASP Security Guidelines](https://owasp.org/www-project-top-ten/)
- [JWT Security Best Practices](https://auth0.com/blog/a-look-at-the-latest-draft-for-jwt-bcp/)
