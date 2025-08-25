---
applyTo: '**'
---

# Architecture Instructions

Comprehensive architecture guidance for Python FastAPI applications following clean architecture principles and modern design patterns.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** implement layered architecture with clear separation of concerns
- **REQUIRED** to use dependency injection for service and repository layers
- **SHALL** follow repository pattern for all database interactions
- **NEVER** mix business logic with HTTP handling or database access code

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** implement service layer for business logic encapsulation
- **RECOMMENDED** to use factory pattern for complex object creation
- **ALWAYS** define clear interfaces between architectural layers
- **DO** implement request/response models for API contract definition
- **DON'T** create circular dependencies between modules

### Optional Enhancements (**MAY** Consider)
- **MAY** implement event-driven architecture for complex workflows
- **OPTIONAL** to add CQRS pattern for read/write separation
- **USE** domain-driven design principles for complex business domains
- **IMPLEMENT** hexagonal architecture for maximum testability
- **AVOID** over-engineering simple CRUD operations

## Implementation Guidance

**USE** these architectural layers:
```
├── api/                    # Presentation Layer
│   ├── routes/            # HTTP route handlers
│   ├── dependencies/      # FastAPI dependency injection
│   └── middleware/        # Request/response middleware
├── core/                  # Application Core
│   ├── models/           # Domain models and entities
│   ├── schemas/          # Pydantic request/response schemas
│   ├── services/         # Business logic services
│   └── interfaces/       # Abstract interfaces
├── infrastructure/        # Infrastructure Layer
│   ├── database/         # Database connections and repositories
│   ├── external/         # External service integrations
│   └── cache/           # Caching implementations
└── tests/                # Test Layer
    ├── unit/            # Unit tests
    ├── integration/     # Integration tests
    └── fixtures/        # Test fixtures and factories
```

**IMPLEMENT** these patterns:

```python
# Repository Pattern Example
from abc import ABC, abstractmethod
from typing import List, Optional
from sqlalchemy.orm import Session

class UserRepository(ABC):
    @abstractmethod
    async def create(self, user_data: dict) -> User:
        pass
    
    @abstractmethod
    async def get_by_id(self, user_id: int) -> Optional[User]:
        pass
    
    @abstractmethod
    async def get_all(self, skip: int = 0, limit: int = 100) -> List[User]:
        pass

class SQLUserRepository(UserRepository):
    def __init__(self, db: Session):
        self.db = db
    
    async def create(self, user_data: dict) -> User:
        # Implementation
        pass
```

```python
# Service Layer Pattern Example
from typing import List, Optional
from core.interfaces.repositories import UserRepository
from core.schemas.user import UserCreate, UserResponse

class UserService:
    def __init__(self, user_repository: UserRepository):
        self.user_repository = user_repository
    
    async def create_user(self, user_data: UserCreate) -> UserResponse:
        # Business logic validation
        user = await self.user_repository.create(user_data.dict())
        return UserResponse.from_orm(user)
    
    async def get_user(self, user_id: int) -> Optional[UserResponse]:
        user = await self.user_repository.get_by_id(user_id)
        return UserResponse.from_orm(user) if user else None
```

**ENSURE** these validations:
- All database operations go through repository interfaces
- Business logic is contained within service classes
- API routes only handle HTTP concerns and delegate to services
- Dependencies are injected rather than imported directly
- Domain models are separate from database models

## Anti-Patterns

**DON'T** implement these approaches:
- Direct database queries in API route handlers
- Business logic mixed with HTTP request/response handling
- Tight coupling between layers without clear interfaces
- Global state or singletons for stateful operations
- Mixing ORM models with API response models

**AVOID** these common mistakes:
- Creating circular imports between modules
- Using global database connections instead of dependency injection
- Implementing business logic in Pydantic model validators
- Exposing internal implementation details in public interfaces
- Creating god classes that handle multiple responsibilities

**NEVER** do these actions:
- Access database directly from API endpoints
- Put business logic in database model methods
- Create dependencies on specific implementation details
- Use mutable global state for configuration
- Mix synchronous and asynchronous code patterns inappropriately

## Code Examples

### Directory Structure Implementation
```python
# File: core/interfaces/repositories.py
from abc import ABC, abstractmethod
from typing import List, Optional, Generic, TypeVar

T = TypeVar('T')

class BaseRepository(ABC, Generic[T]):
    @abstractmethod
    async def create(self, entity_data: dict) -> T:
        pass
    
    @abstractmethod
    async def get_by_id(self, entity_id: int) -> Optional[T]:
        pass
    
    @abstractmethod
    async def update(self, entity_id: int, entity_data: dict) -> T:
        pass
    
    @abstractmethod
    async def delete(self, entity_id: int) -> bool:
        pass
```

### Dependency Injection Setup
```python
# File: api/dependencies/database.py
from fastapi import Depends
from sqlalchemy.orm import Session
from infrastructure.database.connection import get_db
from infrastructure.database.repositories import SQLUserRepository
from core.services.user_service import UserService

def get_user_repository(db: Session = Depends(get_db)) -> SQLUserRepository:
    return SQLUserRepository(db)

def get_user_service(
    user_repo: SQLUserRepository = Depends(get_user_repository)
) -> UserService:
    return UserService(user_repo)
```

### Clean API Route Implementation
```python
# File: api/routes/users.py
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from core.services.user_service import UserService
from core.schemas.user import UserCreate, UserResponse
from api.dependencies.database import get_user_service

router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_data: UserCreate,
    user_service: UserService = Depends(get_user_service)
):
    try:
        return await user_service.create_user(user_data)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    user_service: UserService = Depends(get_user_service)
):
    user = await user_service.get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
```

## Validation Checklist

**MUST** verify:
- [ ] Clear separation between API, service, and repository layers
- [ ] All database access goes through repository interfaces
- [ ] Business logic is contained in service classes
- [ ] Dependencies are injected using FastAPI's dependency system
- [ ] No circular imports between modules

**SHOULD** check:
- [ ] Interfaces are defined for all major components
- [ ] Error handling is consistent across all layers
- [ ] Configuration is externalized and environment-specific
- [ ] Logging is implemented at appropriate levels
- [ ] Performance considerations are addressed

## References

- [FastAPI Dependency Injection](https://fastapi.tiangolo.com/tutorial/dependencies/)
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
- [Dependency Inversion Principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle)
