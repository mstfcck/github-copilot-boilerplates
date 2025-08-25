---
applyTo: '**'
---

# Security Instructions

Comprehensive security implementation guidelines for Python FastAPI applications with production-ready authentication, authorization, and data protection.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** implement proper authentication for all protected endpoints
- **REQUIRED** to validate and sanitize all user inputs
- **SHALL** use HTTPS in production with proper TLS configuration
- **NEVER** store passwords in plain text or log sensitive information
- **MUST** implement proper CORS configuration for browser security
- **REQUIRED** to use environment variables for all secrets and API keys

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** implement JWT-based authentication with refresh tokens
- **RECOMMENDED** to use bcrypt for password hashing with proper salt
- **ALWAYS** implement rate limiting for authentication endpoints
- **DO** use OAuth2 with scopes for fine-grained authorization
- **DON'T** expose internal error details to external users
- **ALWAYS** implement proper session management and logout

### Optional Enhancements (**MAY** Consider)
- **MAY** implement multi-factor authentication (MFA)
- **OPTIONAL** to add API key authentication for service-to-service calls
- **USE** security headers like HSTS, CSP, and X-Frame-Options
- **IMPLEMENT** audit logging for security-critical operations
- **AVOID** custom cryptographic implementations

## Implementation Guidance

**USE** these security patterns:
```python
# OAuth2 with Password Bearer
from fastapi.security import OAuth2PasswordBearer
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta

# Password hashing configuration
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# OAuth2 scheme
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# JWT configuration
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
```

**IMPLEMENT** these authentication patterns:

```python
# User authentication service
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
from typing import Optional

class AuthService:
    def __init__(self):
        self.pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
        self.secret_key = os.getenv("SECRET_KEY")
        self.algorithm = "HS256"
    
    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        return self.pwd_context.verify(plain_password, hashed_password)
    
    def get_password_hash(self, password: str) -> str:
        return self.pwd_context.hash(password)
    
    def create_access_token(self, data: dict, expires_delta: Optional[timedelta] = None):
        to_encode = data.copy()
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(minutes=15)
        to_encode.update({"exp": expire})
        encoded_jwt = jwt.encode(to_encode, self.secret_key, algorithm=self.algorithm)
        return encoded_jwt
    
    def verify_token(self, token: str) -> Optional[str]:
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
            username: str = payload.get("sub")
            if username is None:
                return None
            return username
        except JWTError:
            return None
```

```python
# Authorization dependencies
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from core.services.auth_service import AuthService
from core.services.user_service import UserService

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/token")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    auth_service: AuthService = Depends(get_auth_service),
    user_service: UserService = Depends(get_user_service)
):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    username = auth_service.verify_token(token)
    if username is None:
        raise credentials_exception
    
    user = await user_service.get_user_by_username(username)
    if user is None:
        raise credentials_exception
    
    return user

async def get_current_active_user(
    current_user: User = Depends(get_current_user)
):
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user
```

**ENSURE** these validations:
- All passwords are hashed using bcrypt with proper salt
- JWT tokens have appropriate expiration times
- Sensitive data is never logged or exposed in error messages
- CORS is configured appropriately for your frontend domains
- Input validation prevents injection attacks

## Anti-Patterns

**DON'T** implement these approaches:
- Storing passwords in plain text or using weak hashing algorithms
- Using hardcoded secrets or API keys in source code
- Implementing custom authentication without proven libraries
- Exposing detailed error messages that reveal system information
- Using HTTP instead of HTTPS for authentication endpoints

**AVOID** these common mistakes:
- Not validating JWT token expiration properly
- Allowing unlimited login attempts without rate limiting
- Storing sensitive information in JWT payloads
- Using weak or predictable secret keys
- Not implementing proper session invalidation on logout

**NEVER** do these actions:
- Log user passwords or authentication tokens
- Store API keys or secrets in version control
- Use deprecated or known vulnerable cryptographic functions
- Allow SQL injection or XSS vulnerabilities
- Trust user input without proper validation and sanitization

## Code Examples

### Complete Authentication Implementation
```python
# File: core/schemas/auth.py
from pydantic import BaseModel, EmailStr

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class UserLogin(BaseModel):
    username: str
    password: str

class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    full_name: Optional[str] = None
```

### Input Validation and Sanitization
```python
# File: core/validators/security.py
import re
from typing import str
from pydantic import validator

class SecureBaseModel(BaseModel):
    @validator('*', pre=True)
    def prevent_xss(cls, v):
        if isinstance(v, str):
            # Remove potentially dangerous HTML/JS
            v = re.sub(r'<[^>]*>', '', v)
            # Remove script tags
            v = re.sub(r'javascript:', '', v, flags=re.IGNORECASE)
        return v

class UserInput(SecureBaseModel):
    username: str
    email: EmailStr
    
    @validator('username')
    def validate_username(cls, v):
        if not re.match(r'^[a-zA-Z0-9_]+$', v):
            raise ValueError('Username must contain only letters, numbers, and underscores')
        if len(v) < 3 or len(v) > 50:
            raise ValueError('Username must be between 3 and 50 characters')
        return v
```

### Security Middleware
```python
# File: api/middleware/security.py
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse
import time
from collections import defaultdict
from typing import Dict

class RateLimitMiddleware(BaseHTTPMiddleware):
    def __init__(self, app, calls: int = 100, period: int = 60):
        super().__init__(app)
        self.calls = calls
        self.period = period
        self.requests: Dict[str, list] = defaultdict(list)
    
    async def dispatch(self, request: Request, call_next):
        client_ip = request.client.host
        now = time.time()
        
        # Clean old requests
        self.requests[client_ip] = [
            req_time for req_time in self.requests[client_ip]
            if now - req_time < self.period
        ]
        
        # Check rate limit
        if len(self.requests[client_ip]) >= self.calls:
            return JSONResponse(
                status_code=429,
                content={"detail": "Rate limit exceeded"}
            )
        
        # Add current request
        self.requests[client_ip].append(now)
        
        response = await call_next(request)
        return response

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        
        # Add security headers
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        
        return response
```

### Environment Configuration
```python
# File: core/config.py
from pydantic import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    # Security settings
    secret_key: str
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7
    
    # Database settings
    database_url: str
    
    # CORS settings
    cors_origins: list = ["http://localhost:3000"]
    
    # Rate limiting
    rate_limit_calls: int = 100
    rate_limit_period: int = 60
    
    class Config:
        env_file = ".env"

settings = Settings()
```

## Validation Checklist

**MUST** verify:
- [ ] All passwords are properly hashed with bcrypt
- [ ] JWT tokens are properly validated and have expiration
- [ ] All user inputs are validated and sanitized
- [ ] Secrets are stored in environment variables
- [ ] HTTPS is enforced in production
- [ ] CORS is properly configured

**SHOULD** check:
- [ ] Rate limiting is implemented for authentication endpoints
- [ ] Security headers are properly set
- [ ] Audit logging is implemented for critical operations
- [ ] Error messages don't expose sensitive information
- [ ] Session management and logout work correctly

## References

- [FastAPI Security Documentation](https://fastapi.tiangolo.com/tutorial/security/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OAuth2 Specification](https://oauth.net/2/)
- [JWT Best Practices](https://auth0.com/blog/a-look-at-the-latest-draft-for-jwt-bcp/)
- [Python Cryptographic Authority](https://cryptography.io/)
