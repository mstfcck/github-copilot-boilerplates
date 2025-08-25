---
applyTo: '**'
---

# API Design Instructions

Comprehensive REST API design principles and implementation guidelines for Python FastAPI applications with OpenAPI documentation and best practices.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** follow RESTful API design principles and HTTP standards
- **REQUIRED** to implement proper HTTP status codes for all responses
- **SHALL** use consistent naming conventions for endpoints and resources
- **NEVER** expose internal implementation details in API responses
- **MUST** implement proper request/response validation with Pydantic models
- **REQUIRED** to provide comprehensive API documentation with examples

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** implement API versioning strategy for backward compatibility
- **RECOMMENDED** to use HATEOAS principles for discoverability
- **ALWAYS** implement proper error handling with standardized error responses
- **DO** use appropriate HTTP methods (GET, POST, PUT, DELETE, PATCH)
- **DON'T** use verbs in URL paths; use nouns with HTTP methods
- **ALWAYS** implement pagination for list endpoints

### Optional Enhancements (**MAY** Consider)
- **MAY** implement GraphQL endpoint alongside REST API
- **OPTIONAL** to add API rate limiting and throttling
- **USE** content negotiation for different response formats
- **IMPLEMENT** API caching headers for performance optimization
- **AVOID** exposing sensitive data in error messages

## Implementation Guidance

**USE** these API design patterns:

### Resource-Based URL Structure
```
# Good URL patterns
GET    /api/v1/users                    # List users
POST   /api/v1/users                    # Create user
GET    /api/v1/users/{id}               # Get specific user
PUT    /api/v1/users/{id}               # Update user (full)
PATCH  /api/v1/users/{id}               # Update user (partial)
DELETE /api/v1/users/{id}               # Delete user

GET    /api/v1/users/{id}/posts         # Get user's posts
POST   /api/v1/users/{id}/posts         # Create post for user

# Avoid these patterns
GET    /api/v1/getUser/{id}             # Don't use verbs
POST   /api/v1/createUser               # Don't use verbs
GET    /api/v1/user-posts/{id}          # Use consistent naming
```

**IMPLEMENT** these API patterns:

### Pydantic Models for Request/Response
```python
# File: core/schemas/user.py
from pydantic import BaseModel, EmailStr, Field, ConfigDict
from typing import Optional, List
from datetime import datetime

class UserBase(BaseModel):
    username: str = Field(..., min_length=3, max_length=50, description="Unique username")
    email: EmailStr = Field(..., description="User email address")
    full_name: Optional[str] = Field(None, max_length=255, description="User's full name")

class UserCreate(UserBase):
    password: str = Field(..., min_length=8, description="User password")

class UserUpdate(BaseModel):
    username: Optional[str] = Field(None, min_length=3, max_length=50)
    email: Optional[EmailStr] = None
    full_name: Optional[str] = Field(None, max_length=255)
    is_active: Optional[bool] = None

class UserResponse(UserBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: int = Field(..., description="User ID")
    is_active: bool = Field(..., description="Whether user is active")
    created_at: datetime = Field(..., description="User creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")

class UserList(BaseModel):
    users: List[UserResponse]
    total: int = Field(..., description="Total number of users")
    page: int = Field(..., description="Current page number")
    page_size: int = Field(..., description="Number of items per page")
    total_pages: int = Field(..., description="Total number of pages")
```

### Standardized Error Responses
```python
# File: core/schemas/error.py
from pydantic import BaseModel
from typing import Optional, Dict, Any

class ErrorDetail(BaseModel):
    field: str
    message: str
    code: Optional[str] = None

class ErrorResponse(BaseModel):
    error: str = Field(..., description="Error type")
    message: str = Field(..., description="Human-readable error message")
    details: Optional[List[ErrorDetail]] = Field(None, description="Detailed error information")
    request_id: Optional[str] = Field(None, description="Request tracking ID")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="Error timestamp")

class ValidationErrorResponse(ErrorResponse):
    error: str = "validation_error"
    details: List[ErrorDetail]

class NotFoundErrorResponse(ErrorResponse):
    error: str = "not_found"
    resource: str = Field(..., description="Resource that was not found")
```

**ENSURE** these API patterns:
- Consistent HTTP status codes across all endpoints
- Proper request/response validation with clear error messages
- Comprehensive API documentation with examples
- Pagination for all list endpoints
- Proper authentication and authorization

## Anti-Patterns

**DON'T** implement these approaches:
- Using verbs in URL paths instead of proper HTTP methods
- Returning different response structures for similar operations
- Exposing internal database IDs without proper validation
- Using inconsistent naming conventions across endpoints
- Implementing custom status codes instead of standard HTTP codes

**AVOID** these common mistakes:
- Not implementing proper pagination for large datasets
- Returning sensitive information in error messages
- Using inconsistent date/time formats across endpoints
- Not providing proper API documentation and examples
- Implementing breaking changes without proper versioning

**NEVER** do these actions:
- Expose internal implementation details in API responses
- Use non-standard HTTP methods for standard operations
- Return different error formats across different endpoints
- Ignore content-type headers and request validation
- Implement endpoints without proper authentication where needed

## Code Examples

### Complete API Route Implementation
```python
# File: api/routes/users.py
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional
from core.schemas.user import UserCreate, UserUpdate, UserResponse, UserList
from core.schemas.error import ErrorResponse, NotFoundErrorResponse
from core.services.user_service import UserService
from api.dependencies.database import get_user_service
from api.dependencies.auth import get_current_active_user

router = APIRouter(
    prefix="/api/v1/users",
    tags=["users"],
    responses={
        404: {"model": NotFoundErrorResponse},
        422: {"model": ValidationErrorResponse},
        500: {"model": ErrorResponse}
    }
)

@router.get(
    "/",
    response_model=UserList,
    summary="List users",
    description="Retrieve a paginated list of users with optional filtering"
)
async def list_users(
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(20, ge=1, le=100, description="Items per page"),
    search: Optional[str] = Query(None, description="Search in username or email"),
    is_active: Optional[bool] = Query(None, description="Filter by active status"),
    user_service: UserService = Depends(get_user_service),
    current_user: User = Depends(get_current_active_user)
):
    """
    Retrieve users with pagination and optional filtering.
    
    - **page**: Page number (starts from 1)
    - **page_size**: Number of items per page (max 100)
    - **search**: Search term for username or email
    - **is_active**: Filter by user active status
    """
    try:
        users, total = await user_service.get_users_paginated(
            page=page,
            page_size=page_size,
            search=search,
            is_active=is_active
        )
        
        total_pages = (total + page_size - 1) // page_size
        
        return UserList(
            users=users,
            total=total,
            page=page,
            page_size=page_size,
            total_pages=total_pages
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve users"
        )

@router.post(
    "/",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create user",
    description="Create a new user account"
)
async def create_user(
    user_data: UserCreate,
    user_service: UserService = Depends(get_user_service)
):
    """
    Create a new user account.
    
    - **username**: Unique username (3-50 characters)
    - **email**: Valid email address
    - **password**: Password (minimum 8 characters)
    - **full_name**: Optional full name
    """
    try:
        return await user_service.create_user(user_data)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create user"
        )

@router.get(
    "/{user_id}",
    response_model=UserResponse,
    summary="Get user",
    description="Retrieve a specific user by ID"
)
async def get_user(
    user_id: int,
    user_service: UserService = Depends(get_user_service),
    current_user: User = Depends(get_current_active_user)
):
    """Retrieve a specific user by ID."""
    user = await user_service.get_user(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User with ID {user_id} not found"
        )
    return user

@router.put(
    "/{user_id}",
    response_model=UserResponse,
    summary="Update user",
    description="Update user information (full update)"
)
async def update_user(
    user_id: int,
    user_data: UserUpdate,
    user_service: UserService = Depends(get_user_service),
    current_user: User = Depends(get_current_active_user)
):
    """Update user information with full update."""
    try:
        updated_user = await user_service.update_user(user_id, user_data)
        if not updated_user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with ID {user_id} not found"
            )
        return updated_user
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.delete(
    "/{user_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete user",
    description="Delete a user account"
)
async def delete_user(
    user_id: int,
    user_service: UserService = Depends(get_user_service),
    current_user: User = Depends(get_current_active_user)
):
    """Delete a user account."""
    success = await user_service.delete_user(user_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User with ID {user_id} not found"
        )
```

### API Versioning Implementation
```python
# File: api/versions.py
from fastapi import APIRouter
from api.v1 import users as users_v1
from api.v1 import auth as auth_v1

# API v1 router
api_v1_router = APIRouter(prefix="/api/v1")
api_v1_router.include_router(users_v1.router)
api_v1_router.include_router(auth_v1.router)

# Future API v2 router
api_v2_router = APIRouter(prefix="/api/v2")
# api_v2_router.include_router(users_v2.router)

# Main API router
def create_api_router():
    router = APIRouter()
    router.include_router(api_v1_router)
    # router.include_router(api_v2_router)
    return router
```

### OpenAPI Documentation Configuration
```python
# File: main.py
from fastapi import FastAPI
from fastapi.openapi.utils import get_openapi

def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    
    openapi_schema = get_openapi(
        title="FastAPI Boilerplate API",
        version="1.0.0",
        description="""
        A comprehensive FastAPI boilerplate with production-ready features.
        
        ## Features
        
        * **Authentication**: JWT-based authentication with refresh tokens
        * **User Management**: Complete user CRUD operations
        * **PostgreSQL**: Async database operations with SQLAlchemy
        * **Caching**: Redis-based caching for performance
        * **Monitoring**: Health checks and performance metrics
        
        ## Authentication
        
        All protected endpoints require a valid JWT token in the Authorization header:
        ```
        Authorization: Bearer <your-token>
        ```
        
        Get your token by calling the `/auth/token` endpoint with valid credentials.
        """,
        routes=app.routes,
        servers=[
            {"url": "http://localhost:8000", "description": "Development server"},
            {"url": "https://api.example.com", "description": "Production server"},
        ]
    )
    
    # Add security schemes
    openapi_schema["components"]["securitySchemes"] = {
        "BearerAuth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT"
        }
    }
    
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app = FastAPI(
    title="FastAPI Boilerplate",
    description="Production-ready FastAPI application",
    version="1.0.0",
    openapi_url="/api/v1/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc"
)

app.openapi = custom_openapi
```

### Content Negotiation Implementation
```python
# File: api/middleware/content_negotiation.py
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
import json
import xml.etree.ElementTree as ET

class ContentNegotiationMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        
        # Check Accept header for content negotiation
        accept_header = request.headers.get("accept", "application/json")
        
        if "application/xml" in accept_header and hasattr(response, "body"):
            # Convert JSON response to XML if requested
            try:
                if response.media_type == "application/json":
                    json_data = json.loads(response.body)
                    xml_data = self.dict_to_xml(json_data)
                    
                    return Response(
                        content=xml_data,
                        status_code=response.status_code,
                        headers=dict(response.headers),
                        media_type="application/xml"
                    )
            except Exception:
                pass  # Fall back to original response
        
        return response
    
    def dict_to_xml(self, data: dict, root_name: str = "response") -> str:
        """Convert dictionary to XML string."""
        root = ET.Element(root_name)
        self._build_xml_element(root, data)
        return ET.tostring(root, encoding="unicode")
    
    def _build_xml_element(self, parent, data):
        """Recursively build XML elements."""
        if isinstance(data, dict):
            for key, value in data.items():
                element = ET.SubElement(parent, key)
                self._build_xml_element(element, value)
        elif isinstance(data, list):
            for item in data:
                element = ET.SubElement(parent, "item")
                self._build_xml_element(element, item)
        else:
            parent.text = str(data)
```

## Validation Checklist

**MUST** verify:
- [ ] All endpoints follow RESTful conventions
- [ ] Proper HTTP status codes are used consistently
- [ ] Request/response validation is implemented with Pydantic
- [ ] Comprehensive API documentation is provided
- [ ] Error responses follow standardized format

**SHOULD** check:
- [ ] API versioning strategy is implemented
- [ ] Pagination is implemented for list endpoints
- [ ] Rate limiting is configured appropriately
- [ ] Content negotiation is supported where needed
- [ ] Authentication/authorization is properly implemented

## References

- [REST API Design Best Practices](https://restfulapi.net/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/tutorial/)
- [OpenAPI Specification](https://swagger.io/specification/)
- [HTTP Status Codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)
- [API Design Guidelines](https://cloud.google.com/apis/design/)
