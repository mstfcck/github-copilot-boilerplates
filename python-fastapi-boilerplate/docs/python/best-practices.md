# FastAPI Best Practices Guide

This guide outlines proven best practices for developing robust, maintainable, and scalable FastAPI applications.

## Project Structure Best Practices

### Recommended Directory Organization

```text
app/
├── core/                          # Core functionality
│   ├── __init__.py
│   ├── config.py                  # Configuration management
│   ├── security/                  # Security utilities
│   │   ├── __init__.py
│   │   ├── jwt.py                 # JWT handling
│   │   ├── password.py            # Password utilities
│   │   └── dependencies.py        # Security dependencies
│   ├── database/                  # Database configuration
│   │   ├── __init__.py
│   │   ├── base.py                # Base model class
│   │   ├── connection.py          # Database connection
│   │   └── repository.py          # Base repository pattern
│   └── middleware/                # Custom middleware
│       ├── __init__.py
│       ├── cors.py
│       ├── security.py
│       └── logging.py
├── models/                        # SQLAlchemy models
│   ├── __init__.py
│   ├── user.py
│   └── mixins.py                  # Common model mixins
├── schemas/                       # Pydantic schemas
│   ├── __init__.py
│   ├── user.py
│   └── common.py                  # Common schema patterns
├── repositories/                  # Data access layer
│   ├── __init__.py
│   ├── user.py
│   └── base.py                    # Base repository
├── services/                      # Business logic layer
│   ├── __init__.py
│   ├── user.py
│   └── auth.py
├── routers/                       # API route handlers
│   ├── __init__.py
│   ├── user.py
│   └── auth.py
├── utils/                         # Utility functions
│   ├── __init__.py
│   ├── email.py
│   └── helpers.py
└── exceptions/                    # Custom exceptions
    ├── __init__.py
    └── custom.py
```

## Code Organization Patterns

### 1. Dependency Injection Pattern

```python
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession
from core.database.connection import get_db
from repositories.user import UserRepository
from services.user import UserService

# Repository dependency
def get_user_repository(db: AsyncSession = Depends(get_db)) -> UserRepository:
    return UserRepository(db)

# Service dependency
def get_user_service(
    repository: UserRepository = Depends(get_user_repository)
) -> UserService:
    return UserService(repository)

# Usage in router
@router.post("/users/", response_model=UserResponse)
async def create_user(
    user_data: UserCreate,
    service: UserService = Depends(get_user_service),
    current_user: User = Depends(get_current_user)
):
    return await service.create_user(user_data)
```

### 2. Repository Pattern Implementation

```python
from typing import Generic, TypeVar, Type, List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete
from sqlalchemy.orm import selectinload
from pydantic import BaseModel

ModelType = TypeVar("ModelType")
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)

class BaseRepository(Generic[ModelType, CreateSchemaType, UpdateSchemaType]):
    def __init__(self, model: Type[ModelType], session: AsyncSession):
        self.model = model
        self.session = session

    async def get(self, id: int) -> Optional[ModelType]:
        result = await self.session.execute(
            select(self.model).where(self.model.id == id)
        )
        return result.scalar_one_or_none()

    async def get_multi(
        self, 
        skip: int = 0, 
        limit: int = 100,
        filters: dict = None
    ) -> List[ModelType]:
        query = select(self.model)
        
        if filters:
            for key, value in filters.items():
                if hasattr(self.model, key):
                    query = query.where(getattr(self.model, key) == value)
        
        query = query.offset(skip).limit(limit)
        result = await self.session.execute(query)
        return result.scalars().all()

    async def create(self, obj_in: CreateSchemaType) -> ModelType:
        obj_data = obj_in.dict() if hasattr(obj_in, 'dict') else obj_in
        db_obj = self.model(**obj_data)
        self.session.add(db_obj)
        await self.session.commit()
        await self.session.refresh(db_obj)
        return db_obj

    async def update(self, id: int, obj_in: UpdateSchemaType) -> Optional[ModelType]:
        update_data = obj_in.dict(exclude_unset=True)
        
        await self.session.execute(
            update(self.model)
            .where(self.model.id == id)
            .values(**update_data)
        )
        await self.session.commit()
        
        return await self.get(id)

    async def delete(self, id: int) -> bool:
        result = await self.session.execute(
            delete(self.model).where(self.model.id == id)
        )
        await self.session.commit()
        return result.rowcount > 0
```

### 3. Service Layer Pattern

```python
from typing import List, Optional
from fastapi import HTTPException, status
from repositories.user import UserRepository
from schemas.user import UserCreate, UserUpdate, UserResponse
from core.security.password import hash_password, verify_password

class UserService:
    def __init__(self, repository: UserRepository):
        self.repository = repository

    async def create_user(self, user_data: UserCreate) -> UserResponse:
        # Business logic validation
        existing_user = await self.repository.get_by_email(user_data.email)
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User with this email already exists"
            )
        
        # Hash password
        user_data.password = hash_password(user_data.password)
        
        # Create user
        db_user = await self.repository.create(user_data)
        return UserResponse.model_validate(db_user)

    async def get_user(self, user_id: int) -> UserResponse:
        db_user = await self.repository.get(user_id)
        if not db_user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        return UserResponse.model_validate(db_user)

    async def update_user(self, user_id: int, user_data: UserUpdate) -> UserResponse:
        # Verify user exists
        existing_user = await self.repository.get(user_id)
        if not existing_user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Update password if provided
        if user_data.password:
            user_data.password = hash_password(user_data.password)
        
        db_user = await self.repository.update(user_id, user_data)
        return UserResponse.model_validate(db_user)

    async def list_users(
        self, 
        skip: int = 0, 
        limit: int = 100,
        filters: dict = None
    ) -> List[UserResponse]:
        users = await self.repository.get_multi(skip, limit, filters)
        return [UserResponse.model_validate(user) for user in users]
```

## API Design Best Practices

### 1. Router Organization

```python
from fastapi import APIRouter, Depends, status
from typing import List

router = APIRouter(
    prefix="/api/v1/users",
    tags=["users"],
    dependencies=[Depends(get_current_user)],  # Global auth for all endpoints
    responses={404: {"description": "Not found"}}
)

@router.get(
    "/",
    response_model=List[UserResponse],
    status_code=status.HTTP_200_OK,
    summary="List users",
    description="Retrieve a paginated list of users with optional filtering"
)
async def list_users(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Maximum number of records to return"),
    service: UserService = Depends(get_user_service)
):
    return await service.list_users(skip=skip, limit=limit)

@router.post(
    "/",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create user",
    description="Create a new user account"
)
async def create_user(
    user_data: UserCreate,
    service: UserService = Depends(get_user_service),
    current_user: User = Depends(require_admin)  # Admin only
):
    return await service.create_user(user_data)
```

### 2. Response Model Patterns

```python
from pydantic import BaseModel, Field
from typing import Optional, List, Generic, TypeVar
from datetime import datetime

T = TypeVar('T')

class BaseResponse(BaseModel):
    """Base response model with common fields"""
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    model_config = ConfigDict(from_attributes=True)

class PaginatedResponse(BaseModel, Generic[T]):
    """Generic paginated response"""
    items: List[T]
    total: int
    page: int
    per_page: int
    pages: int
    
    @classmethod
    def create(
        cls,
        items: List[T],
        total: int,
        page: int,
        per_page: int
    ) -> "PaginatedResponse[T]":
        pages = (total + per_page - 1) // per_page
        return cls(
            items=items,
            total=total,
            page=page,
            per_page=per_page,
            pages=pages
        )

class ErrorResponse(BaseModel):
    """Standardized error response"""
    error: str
    message: str
    details: Optional[dict] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)
```

### 3. Input Validation Patterns

```python
from pydantic import BaseModel, Field, validator, root_validator
from typing import Optional
import re

class UserCreate(BaseModel):
    email: str = Field(..., max_length=255, description="User email address")
    password: str = Field(..., min_length=8, max_length=128, description="User password")
    full_name: str = Field(..., min_length=1, max_length=100, description="User full name")
    phone: Optional[str] = Field(None, max_length=20, description="Phone number")

    @validator('email')
    def validate_email(cls, v):
        # Custom email validation
        email_regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_regex, v):
            raise ValueError('Invalid email format')
        return v.lower()

    @validator('password')
    def validate_password(cls, v):
        # Password complexity validation
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain at least one uppercase letter')
        if not re.search(r'[a-z]', v):
            raise ValueError('Password must contain at least one lowercase letter')
        if not re.search(r'\d', v):
            raise ValueError('Password must contain at least one digit')
        return v

    @validator('phone')
    def validate_phone(cls, v):
        if v and not re.match(r'^\+?1?\d{9,15}$', v):
            raise ValueError('Invalid phone number format')
        return v

    @root_validator
    def validate_user_data(cls, values):
        # Cross-field validation
        email = values.get('email')
        full_name = values.get('full_name')
        
        if email and full_name and email.split('@')[0].lower() == full_name.lower():
            raise ValueError('Email username cannot be the same as full name')
        
        return values
```

## Error Handling Best Practices

### 1. Custom Exception Hierarchy

```python
from fastapi import HTTPException, status

class AppException(Exception):
    """Base application exception"""
    def __init__(self, message: str, details: dict = None):
        self.message = message
        self.details = details or {}
        super().__init__(self.message)

class ValidationError(AppException):
    """Validation error exception"""
    pass

class NotFoundError(AppException):
    """Resource not found exception"""
    pass

class ConflictError(AppException):
    """Resource conflict exception"""
    pass

class UnauthorizedError(AppException):
    """Unauthorized access exception"""
    pass

class ForbiddenError(AppException):
    """Forbidden access exception"""
    pass

# Exception handlers
from fastapi import Request
from fastapi.responses import JSONResponse

@app.exception_handler(NotFoundError)
async def not_found_handler(request: Request, exc: NotFoundError):
    return JSONResponse(
        status_code=status.HTTP_404_NOT_FOUND,
        content={
            "error": "NOT_FOUND",
            "message": exc.message,
            "details": exc.details,
            "path": str(request.url.path)
        }
    )

@app.exception_handler(ValidationError)
async def validation_error_handler(request: Request, exc: ValidationError):
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "error": "VALIDATION_ERROR",
            "message": exc.message,
            "details": exc.details,
            "path": str(request.url.path)
        }
    )
```

### 2. Graceful Error Responses

```python
from contextlib import asynccontextmanager
from sqlalchemy.exc import IntegrityError
import logging

logger = logging.getLogger(__name__)

@asynccontextmanager
async def handle_database_errors():
    """Context manager for handling database errors"""
    try:
        yield
    except IntegrityError as e:
        logger.error(f"Database integrity error: {e}")
        if "unique constraint" in str(e).lower():
            raise ConflictError("Resource already exists")
        elif "foreign key constraint" in str(e).lower():
            raise ValidationError("Referenced resource does not exist")
        else:
            raise AppException("Database operation failed")
    except Exception as e:
        logger.error(f"Unexpected database error: {e}")
        raise AppException("Internal server error")

# Usage in service
async def create_user(self, user_data: UserCreate) -> UserResponse:
    async with handle_database_errors():
        db_user = await self.repository.create(user_data)
        return UserResponse.model_validate(db_user)
```

## Security Best Practices

### 1. Authentication Implementation

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from core.config import settings

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> User:
    """Extract and validate user from JWT token"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(
            credentials.credentials, 
            settings.SECRET_KEY, 
            algorithms=["HS256"]
        )
        user_id: int = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user_repo = UserRepository(db)
    user = await user_repo.get(user_id)
    if user is None:
        raise credentials_exception
    
    return user

def require_roles(required_roles: List[str]):
    """Dependency to require specific roles"""
    def role_dependency(current_user: User = Depends(get_current_user)):
        if not any(role in current_user.roles for role in required_roles):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions"
            )
        return current_user
    return role_dependency

# Usage
@router.delete("/{user_id}")
async def delete_user(
    user_id: int,
    current_user: User = Depends(require_roles(["admin"]))
):
    # Admin-only endpoint
    pass
```

### 2. Input Sanitization

```python
import bleach
from typing import Optional

def sanitize_html(text: Optional[str]) -> Optional[str]:
    """Sanitize HTML content"""
    if not text:
        return text
    
    allowed_tags = ['p', 'br', 'strong', 'em', 'u', 'ol', 'ul', 'li']
    allowed_attributes = {}
    
    return bleach.clean(text, tags=allowed_tags, attributes=allowed_attributes)

def sanitize_filename(filename: str) -> str:
    """Sanitize file names"""
    import re
    # Remove dangerous characters
    safe_filename = re.sub(r'[^\w\s.-]', '', filename)
    # Limit length
    return safe_filename[:255]

class ContentCreate(BaseModel):
    title: str = Field(..., max_length=200)
    content: str = Field(..., max_length=10000)
    
    @validator('content')
    def sanitize_content(cls, v):
        return sanitize_html(v)
    
    @validator('title')
    def sanitize_title(cls, v):
        return bleach.clean(v, tags=[], strip=True)
```

## Performance Best Practices

### 1. Database Optimization

```python
from sqlalchemy.orm import selectinload, joinedload
from sqlalchemy import Index

# Eager loading relationships
async def get_user_with_posts(self, user_id: int) -> Optional[User]:
    result = await self.session.execute(
        select(User)
        .options(selectinload(User.posts))  # Avoid N+1 queries
        .where(User.id == user_id)
    )
    return result.scalar_one_or_none()

# Proper indexing in models
class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    
    # Composite index for common queries
    __table_args__ = (
        Index('ix_user_email_status', 'email', 'status'),
    )

# Pagination with count optimization
async def get_users_paginated(
    self, 
    skip: int, 
    limit: int
) -> tuple[List[User], int]:
    # Get items
    items_query = select(User).offset(skip).limit(limit)
    items_result = await self.session.execute(items_query)
    items = items_result.scalars().all()
    
    # Get count (only if needed)
    if skip == 0 and len(items) < limit:
        total = len(items)
    else:
        count_query = select(func.count(User.id))
        count_result = await self.session.execute(count_query)
        total = count_result.scalar()
    
    return items, total
```

### 2. Caching Strategies

```python
from functools import wraps
import json
import hashlib
from typing import Any, Callable

def cache_key_generator(*args, **kwargs) -> str:
    """Generate cache key from function arguments"""
    key_data = {"args": args, "kwargs": kwargs}
    key_string = json.dumps(key_data, sort_keys=True, default=str)
    return hashlib.md5(key_string.encode()).hexdigest()

def cached_repository_method(expire: int = 300):
    """Decorator for caching repository methods"""
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        async def wrapper(self, *args, **kwargs):
            cache_key = f"{func.__name__}:{cache_key_generator(*args, **kwargs)}"
            
            # Try to get from cache
            cached_result = await self.cache.get(cache_key)
            if cached_result:
                return json.loads(cached_result)
            
            # Get from database
            result = await func(self, *args, **kwargs)
            
            # Cache the result
            if result:
                await self.cache.setex(
                    cache_key, 
                    expire, 
                    json.dumps(result, default=str)
                )
            
            return result
        return wrapper
    return decorator

# Usage in repository
class UserRepository(BaseRepository):
    def __init__(self, session: AsyncSession, cache: Redis):
        super().__init__(User, session)
        self.cache = cache
    
    @cached_repository_method(expire=600)  # Cache for 10 minutes
    async def get_user_profile(self, user_id: int) -> Optional[dict]:
        user = await self.get(user_id)
        if user:
            return {
                "id": user.id,
                "email": user.email,
                "full_name": user.full_name,
                "created_at": user.created_at.isoformat()
            }
        return None
```

### 3. Background Tasks

```python
from fastapi import BackgroundTasks
from celery import Celery
import smtplib
from email.mime.text import MIMEText

# Celery setup
celery_app = Celery(
    "worker",
    broker="redis://localhost:6379/0",
    backend="redis://localhost:6379/0"
)

@celery_app.task
def send_email_task(to_email: str, subject: str, body: str):
    """Background task for sending emails"""
    # Email sending logic
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['To'] = to_email
    msg['From'] = settings.SMTP_USER
    
    with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT) as server:
        server.starttls()
        server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
        server.send_message(msg)

# FastAPI background tasks for light operations
def log_user_activity(user_id: int, action: str):
    """Log user activity"""
    logger.info(f"User {user_id} performed action: {action}")

@router.post("/users/{user_id}/activate")
async def activate_user(
    user_id: int,
    background_tasks: BackgroundTasks,
    service: UserService = Depends(get_user_service)
):
    user = await service.activate_user(user_id)
    
    # Add background task
    background_tasks.add_task(log_user_activity, user_id, "activate")
    
    # Send email asynchronously with Celery
    send_email_task.delay(
        user.email,
        "Account Activated",
        "Your account has been activated successfully."
    )
    
    return user
```

## Testing Best Practices

### 1. Test Structure

```python
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from main import app
from core.database.connection import get_db
from tests.utils import override_get_db

@pytest.fixture
async def async_client():
    """Create async test client"""
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac

@pytest.fixture
async def test_db():
    """Create test database session"""
    async with override_get_db() as session:
        yield session

@pytest.fixture
async def auth_headers(test_db: AsyncSession):
    """Create authenticated user and return headers"""
    # Create test user
    user = await create_test_user(test_db)
    
    # Generate token
    token = create_access_token({"sub": str(user.id)})
    
    return {"Authorization": f"Bearer {token}"}

# Test example
@pytest.mark.asyncio
async def test_create_user(async_client: AsyncClient, auth_headers: dict):
    user_data = {
        "email": "test@example.com",
        "password": "TestPass123",
        "full_name": "Test User"
    }
    
    response = await async_client.post(
        "/api/v1/users/",
        json=user_data,
        headers=auth_headers
    )
    
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == user_data["email"]
    assert "password" not in data  # Ensure password is not returned
```

### 2. Factory Pattern for Test Data

```python
from faker import Faker
from typing import Optional

fake = Faker()

class UserFactory:
    @staticmethod
    async def create_user(
        db: AsyncSession,
        email: Optional[str] = None,
        password: Optional[str] = None,
        **kwargs
    ) -> User:
        user_data = {
            "email": email or fake.email(),
            "password": password or "TestPass123",
            "full_name": fake.name(),
            "phone": fake.phone_number(),
            **kwargs
        }
        
        user_repo = UserRepository(db)
        return await user_repo.create(UserCreate(**user_data))

    @staticmethod
    def build_user_data(**kwargs) -> dict:
        """Build user data without saving to database"""
        return {
            "email": fake.email(),
            "password": "TestPass123",
            "full_name": fake.name(),
            "phone": fake.phone_number(),
            **kwargs
        }

# Usage in tests
@pytest.mark.asyncio
async def test_user_operations(test_db: AsyncSession):
    # Create test user
    user = await UserFactory.create_user(test_db, email="specific@email.com")
    
    # Use in test
    assert user.email == "specific@email.com"
```

This guide provides comprehensive best practices for building maintainable, secure, and performant FastAPI applications.
