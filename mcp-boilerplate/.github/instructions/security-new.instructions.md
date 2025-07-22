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
