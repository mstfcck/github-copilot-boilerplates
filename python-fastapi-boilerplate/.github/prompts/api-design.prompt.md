# API Design Prompt

This prompt guides you through designing robust, RESTful APIs in FastAPI with proper documentation, validation, and error handling.

## Objective

Design and implement well-structured APIs that follow REST principles, include comprehensive documentation, and provide excellent developer experience.

## Prerequisites

**MUST** have these prerequisites:
- Understanding of REST API principles
- Familiarity with FastAPI features and capabilities
- Knowledge of HTTP status codes and methods
- Understanding of API security patterns

**SHOULD** review these resources:
- [REST API Design Best Practices](https://restfulapi.net/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [OpenAPI Specification](https://swagger.io/specification/)
- [HTTP Status Codes](https://httpstatuses.com/)

## Step-by-Step Process

### Phase 1: API Resource Planning
**DO** these actions:
1. Identify the main resources in your domain
2. Define resource relationships and hierarchies
3. Plan URL structure following REST conventions
4. Determine required HTTP methods for each resource
5. Design resource representations (request/response models)

**ENSURE** these validations:
- Resources are clearly defined and bounded
- URL structure is logical and hierarchical
- HTTP methods align with their semantic meaning
- Resource relationships are properly modeled

### Phase 2: URL Structure Design
**DO** these actions:
1. Design resource URLs following REST patterns:
   ```python
   # Collection and item patterns
   GET    /api/v1/users              # List all users
   POST   /api/v1/users              # Create new user
   GET    /api/v1/users/{id}         # Get specific user
   PUT    /api/v1/users/{id}         # Update entire user
   PATCH  /api/v1/users/{id}         # Partial user update
   DELETE /api/v1/users/{id}         # Delete user
   
   # Nested resources
   GET    /api/v1/users/{id}/posts   # Get user's posts
   POST   /api/v1/users/{id}/posts   # Create post for user
   ```

2. Implement versioning strategy:
   ```python
   # URL versioning (recommended)
   /api/v1/users
   /api/v2/users
   
   # Header versioning (alternative)
   Accept: application/vnd.api.v1+json
   ```

**ENSURE** these validations:
- URLs are intuitive and predictable
- Consistent naming conventions are used
- Versioning strategy is implemented
- Resource hierarchies are logical

### Phase 3: Request/Response Model Design
**DO** these actions:
1. Create comprehensive Pydantic models:
   ```python
   from pydantic import BaseModel, Field, EmailStr, validator
   from typing import Optional, List
   from datetime import datetime
   from enum import Enum
   
   class UserStatus(str, Enum):
       ACTIVE = "active"
       INACTIVE = "inactive"
       SUSPENDED = "suspended"
   
   class UserBase(BaseModel):
       email: EmailStr = Field(..., description="User's email address")
       full_name: str = Field(..., min_length=1, max_length=100, description="User's full name")
       status: UserStatus = Field(default=UserStatus.ACTIVE, description="User account status")
   
   class UserCreate(UserBase):
       password: str = Field(..., min_length=8, max_length=100, description="User's password")
       
       @validator('password')
       def validate_password(cls, v):
           # Add password complexity validation
           if not any(c.isupper() for c in v):
               raise ValueError('Password must contain at least one uppercase letter')
           return v
   
   class UserUpdate(BaseModel):
       email: Optional[EmailStr] = Field(None, description="User's email address")
       full_name: Optional[str] = Field(None, min_length=1, max_length=100, description="User's full name")
       status: Optional[UserStatus] = Field(None, description="User account status")
   
   class UserResponse(UserBase):
       id: int = Field(..., description="User's unique identifier")
       created_at: datetime = Field(..., description="User creation timestamp")
       updated_at: Optional[datetime] = Field(None, description="Last update timestamp")
       
       model_config = ConfigDict(from_attributes=True)
   
   class UserListResponse(BaseModel):
       users: List[UserResponse] = Field(..., description="List of users")
       total: int = Field(..., description="Total number of users")
       page: int = Field(..., description="Current page number")
       per_page: int = Field(..., description="Items per page")
   ```

**ENSURE** these validations:
- Models have comprehensive validation rules
- Field descriptions are clear and helpful
- Proper type hints are used throughout
- Response models match database structure

### Phase 4: Router Implementation with Documentation
**DO** these actions:
1. Create well-documented router endpoints:
   ```python
   from fastapi import APIRouter, Depends, HTTPException, status, Query
   from fastapi.responses import JSONResponse
   from typing import List, Optional
   
   router = APIRouter(
       prefix="/api/v1/users",
       tags=["users"],
       responses={
           404: {"description": "User not found"},
           422: {"description": "Validation error"}
       }
   )
   
   @router.get(
       "/",
       response_model=UserListResponse,
       status_code=status.HTTP_200_OK,
       summary="List all users",
       description="Retrieve a paginated list of all users with optional filtering and sorting",
       responses={
           200: {
               "description": "Successful response",
               "content": {
                   "application/json": {
                       "example": {
                           "users": [
                               {
                                   "id": 1,
                                   "email": "user@example.com",
                                   "full_name": "John Doe",
                                   "status": "active",
                                   "created_at": "2023-01-01T00:00:00Z",
                                   "updated_at": "2023-01-01T00:00:00Z"
                               }
                           ],
                           "total": 1,
                           "page": 1,
                           "per_page": 10
                       }
                   }
               }
           }
       }
   )
   async def list_users(
       page: int = Query(1, ge=1, description="Page number"),
       per_page: int = Query(10, ge=1, le=100, description="Items per page"),
       status: Optional[UserStatus] = Query(None, description="Filter by user status"),
       search: Optional[str] = Query(None, description="Search by name or email"),
       service: UserService = Depends(get_user_service),
       current_user = Depends(get_current_user)
   ):
       """
       Retrieve a paginated list of users with optional filtering.
       
       - **page**: Page number (starts from 1)
       - **per_page**: Number of items per page (1-100)
       - **status**: Filter users by status
       - **search**: Search users by name or email
       """
       return await service.list_users(page, per_page, status, search)
   ```

**ENSURE** these validations:
- Comprehensive OpenAPI documentation is provided
- Response examples are included
- Query parameters have proper validation
- Error responses are documented

### Phase 5: Error Handling Implementation
**DO** these actions:
1. Create standardized error responses:
   ```python
   from fastapi import HTTPException, Request
   from fastapi.responses import JSONResponse
   from pydantic import BaseModel
   from typing import Optional, Dict, Any
   
   class ErrorResponse(BaseModel):
       error: str
       message: str
       details: Optional[Dict[str, Any]] = None
       timestamp: datetime
       path: str
   
   class APIError(Exception):
       def __init__(self, status_code: int, error: str, message: str, details: Optional[Dict] = None):
           self.status_code = status_code
           self.error = error
           self.message = message
           self.details = details
   
   @app.exception_handler(APIError)
   async def api_error_handler(request: Request, exc: APIError):
       return JSONResponse(
           status_code=exc.status_code,
           content=ErrorResponse(
               error=exc.error,
               message=exc.message,
               details=exc.details,
               timestamp=datetime.utcnow(),
               path=str(request.url.path)
           ).dict()
       )
   ```

2. Implement validation error handling:
   ```python
   from fastapi.exceptions import RequestValidationError
   
   @app.exception_handler(RequestValidationError)
   async def validation_exception_handler(request: Request, exc: RequestValidationError):
       return JSONResponse(
           status_code=422,
           content=ErrorResponse(
               error="VALIDATION_ERROR",
               message="Request validation failed",
               details={"errors": exc.errors()},
               timestamp=datetime.utcnow(),
               path=str(request.url.path)
           ).dict()
       )
   ```

**ENSURE** these validations:
- Consistent error response format
- Appropriate HTTP status codes
- Helpful error messages for developers
- No sensitive information in error responses

### Phase 6: Authentication and Authorization
**DO** these actions:
1. Implement endpoint-level security:
   ```python
   from core.security.dependencies import get_current_user, require_roles
   
   @router.post("/", response_model=UserResponse)
   async def create_user(
       data: UserCreate,
       service: UserService = Depends(get_user_service),
       current_user = Depends(require_roles(["admin"]))
   ):
       return await service.create_user(data)
   
   @router.get("/{user_id}", response_model=UserResponse)
   async def get_user(
       user_id: int,
       service: UserService = Depends(get_user_service),
       current_user = Depends(get_current_user)
   ):
       # Check if user can access this resource
       if current_user.id != user_id and not current_user.is_admin:
           raise HTTPException(status_code=403, detail="Access denied")
       return await service.get_user(user_id)
   ```

**ENSURE** these validations:
- Authentication is applied to protected endpoints
- Authorization logic is implemented correctly
- Security dependencies are reusable
- Proper error responses for auth failures

### Phase 7: API Testing and Validation
**DO** these actions:
1. Create comprehensive API tests:
   ```python
   import pytest
   from httpx import AsyncClient
   from main import app
   
   @pytest.mark.asyncio
   async def test_create_user(async_client: AsyncClient, admin_auth_headers):
       # Test successful creation
       user_data = {
           "email": "test@example.com",
           "full_name": "Test User",
           "password": "SecurePass123"
       }
       
       response = await async_client.post(
           "/api/v1/users/",
           json=user_data,
           headers=admin_auth_headers
       )
       
       assert response.status_code == 201
       assert response.json()["email"] == user_data["email"]
   
   @pytest.mark.asyncio
   async def test_create_user_validation_error(async_client: AsyncClient, admin_auth_headers):
       # Test validation error
       invalid_data = {
           "email": "invalid-email",
           "full_name": "",
           "password": "weak"
       }
       
       response = await async_client.post(
           "/api/v1/users/",
           json=invalid_data,
           headers=admin_auth_headers
       )
       
       assert response.status_code == 422
       assert "VALIDATION_ERROR" in response.json()["error"]
   ```

2. Test API documentation:
   ```python
   @pytest.mark.asyncio
   async def test_openapi_schema(async_client: AsyncClient):
       response = await async_client.get("/openapi.json")
       assert response.status_code == 200
       
       schema = response.json()
       assert "paths" in schema
       assert "/api/v1/users/" in schema["paths"]
   ```

**ENSURE** these validations:
- All endpoints are thoroughly tested
- Both success and error scenarios are covered
- Authentication and authorization are tested
- API documentation is validated

### Phase 8: Performance and Optimization
**DO** these actions:
1. Implement pagination for list endpoints:
   ```python
   from fastapi import Query
   from typing import Optional
   
   async def list_users(
       page: int = Query(1, ge=1, le=1000),
       per_page: int = Query(10, ge=1, le=100),
       service: UserService = Depends(get_user_service)
   ):
       return await service.list_users_paginated(page, per_page)
   ```

2. Add response caching where appropriate:
   ```python
   from fastapi_cache.decorator import cache
   
   @router.get("/{user_id}")
   @cache(expire=300)  # Cache for 5 minutes
   async def get_user(user_id: int):
       return await service.get_user(user_id)
   ```

3. Implement request/response compression:
   ```python
   from fastapi.middleware.gzip import GZipMiddleware
   
   app.add_middleware(GZipMiddleware, minimum_size=1000)
   ```

**ENSURE** these validations:
- Large result sets are paginated
- Caching is implemented for read-heavy endpoints
- Response sizes are optimized
- Database queries are efficient

## Expected Outcomes

**MUST** achieve:
- RESTful API design following industry standards
- Comprehensive OpenAPI documentation
- Proper error handling and validation
- Secure authentication and authorization
- Thorough testing coverage

**SHOULD** produce:
- Intuitive and predictable API interface
- Excellent developer experience
- High performance with proper caching
- Comprehensive API documentation
- Consistent error handling patterns

## Quality Checks

**VERIFY** these items:
- [ ] URLs follow REST conventions
- [ ] HTTP methods are used correctly
- [ ] Response models are comprehensive
- [ ] Error handling is consistent
- [ ] Authentication is properly implemented
- [ ] API documentation is complete
- [ ] Performance is optimized
- [ ] Tests cover all scenarios

## Common Issues and Solutions

**IF** API responses are slow:
- **THEN** implement pagination for large datasets
- **ADD** database indexes for frequently queried fields
- **USE** response caching for read-heavy endpoints

**IF** validation errors are unclear:
- **THEN** improve error messages in Pydantic models
- **ADD** custom validators with descriptive messages
- **ENSURE** error responses include helpful details

**IF** API documentation is incomplete:
- **THEN** add comprehensive docstrings to all endpoints
- **INCLUDE** response examples in OpenAPI schema
- **DOCUMENT** all possible error responses

## Follow-up Actions

**MUST** complete:
- Implement rate limiting for public endpoints
- Add comprehensive monitoring and logging
- Create API versioning strategy
- Implement proper CORS configuration

**SHOULD** consider:
- Adding API key authentication for external clients
- Implementing webhook support for event notifications
- Creating SDK for common programming languages
- Adding API analytics and usage tracking

**RECOMMENDED** next steps:
- Deploy API to staging environment
- Conduct security testing and penetration testing
- Gather feedback from API consumers
- Plan for future API evolution and versioning
