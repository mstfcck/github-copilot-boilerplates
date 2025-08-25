# Feature Development Prompt

This prompt guides you through developing new features in your FastAPI application following clean architecture principles and best practices.

## Objective

Implement new features using the established patterns for models, services, controllers, and tests while maintaining code quality and security standards.

## Prerequisites

**MUST** have these prerequisites:
- Project successfully initialized and running
- Understanding of clean architecture principles
- Familiarity with FastAPI and SQLAlchemy patterns
- Knowledge of async/await patterns in Python

**SHOULD** review these resources:
- Clean Architecture principles
- Repository and Service layer patterns
- FastAPI dependency injection system
- SQLAlchemy 2.0 async patterns

## Step-by-Step Process

### Phase 1: Feature Analysis and Planning
**DO** these actions:
1. Define the feature requirements clearly
2. Identify required data models and relationships
3. Plan API endpoints following RESTful principles
4. Design service layer interactions
5. Identify security and validation requirements

**ENSURE** these validations:
- Feature scope is well-defined and bounded
- Data model relationships are properly planned
- API design follows REST conventions
- Security implications are considered

### Phase 2: Database Model Creation
**DO** these actions:
1. Create SQLAlchemy model in `app/models/`:
   ```python
   from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
   from sqlalchemy.orm import relationship
   from core.database.base import Base
   from datetime import datetime
   
   class YourModel(Base):
       __tablename__ = "your_table"
       
       id = Column(Integer, primary_key=True, index=True)
       name = Column(String, index=True, nullable=False)
       created_at = Column(DateTime, default=datetime.utcnow)
       
       # Add relationships if needed
       # related_items = relationship("RelatedModel", back_populates="your_model")
   ```

2. Create Alembic migration:
   ```bash
   alembic revision --autogenerate -m "Add your_model table"
   alembic upgrade head
   ```

**ENSURE** these validations:
- Model follows naming conventions
- Proper indexes are added for query performance
- Relationships are correctly defined
- Migration runs successfully

### Phase 3: Pydantic Schema Creation
**DO** these actions:
1. Create request/response schemas in `app/schemas/`:
   ```python
   from pydantic import BaseModel, Field
   from datetime import datetime
   from typing import Optional
   
   class YourModelBase(BaseModel):
       name: str = Field(..., min_length=1, max_length=100)
   
   class YourModelCreate(YourModelBase):
       pass
   
   class YourModelUpdate(BaseModel):
       name: Optional[str] = Field(None, min_length=1, max_length=100)
   
   class YourModelResponse(YourModelBase):
       id: int
       created_at: datetime
       
       model_config = ConfigDict(from_attributes=True)
   ```

**ENSURE** these validations:
- Proper validation rules are applied
- Response models include all necessary fields
- Base classes are used for code reuse
- Configuration allows ORM mode

### Phase 4: Repository Layer Implementation
**DO** these actions:
1. Create repository in `app/repositories/`:
   ```python
   from typing import List, Optional
   from sqlalchemy.ext.asyncio import AsyncSession
   from sqlalchemy import select
   from core.database.repository import BaseRepository
   from models.your_model import YourModel
   from schemas.your_schema import YourModelCreate, YourModelUpdate
   
   class YourModelRepository(BaseRepository[YourModel, YourModelCreate, YourModelUpdate]):
       def __init__(self, session: AsyncSession):
           super().__init__(YourModel, session)
       
       async def get_by_name(self, name: str) -> Optional[YourModel]:
           result = await self.session.execute(
               select(YourModel).where(YourModel.name == name)
           )
           return result.scalar_one_or_none()
   ```

**ENSURE** these validations:
- Repository extends BaseRepository for common operations
- Custom query methods use async/await patterns
- Proper error handling is implemented
- Type hints are comprehensive

### Phase 5: Service Layer Implementation
**DO** these actions:
1. Create service in `app/services/`:
   ```python
   from typing import List, Optional
   from sqlalchemy.ext.asyncio import AsyncSession
   from repositories.your_repository import YourModelRepository
   from schemas.your_schema import YourModelCreate, YourModelUpdate, YourModelResponse
   from core.exceptions import NotFoundException
   
   class YourModelService:
       def __init__(self, repository: YourModelRepository):
           self.repository = repository
       
       async def create(self, data: YourModelCreate) -> YourModelResponse:
           # Add business logic validation here
           db_obj = await self.repository.create(data)
           return YourModelResponse.model_validate(db_obj)
       
       async def get_by_id(self, id: int) -> YourModelResponse:
           db_obj = await self.repository.get(id)
           if not db_obj:
               raise NotFoundException(f"YourModel with id {id} not found")
           return YourModelResponse.model_validate(db_obj)
   ```

**ENSURE** these validations:
- Business logic is properly encapsulated
- Proper exception handling is implemented
- Return types use response schemas
- Service methods are focused and single-purpose

### Phase 6: Controller/Router Implementation
**DO** these actions:
1. Create router in `app/routers/`:
   ```python
   from fastapi import APIRouter, Depends, HTTPException, status
   from typing import List
   from sqlalchemy.ext.asyncio import AsyncSession
   from core.database.connection import get_db
   from core.security.dependencies import get_current_user
   from services.your_service import YourModelService
   from repositories.your_repository import YourModelRepository
   from schemas.your_schema import YourModelCreate, YourModelUpdate, YourModelResponse
   
   router = APIRouter(prefix="/your-models", tags=["your-models"])
   
   def get_your_service(db: AsyncSession = Depends(get_db)) -> YourModelService:
       repository = YourModelRepository(db)
       return YourModelService(repository)
   
   @router.post("/", response_model=YourModelResponse, status_code=status.HTTP_201_CREATED)
   async def create_your_model(
       data: YourModelCreate,
       service: YourModelService = Depends(get_your_service),
       current_user = Depends(get_current_user)
   ):
       return await service.create(data)
   ```

2. Register router in `main.py`:
   ```python
   from routers import your_router
   app.include_router(your_router.router)
   ```

**ENSURE** these validations:
- Proper HTTP status codes are used
- Authentication/authorization is applied where needed
- Error handling follows established patterns
- Router is registered with the main application

### Phase 7: Test Implementation
**DO** these actions:
1. Create unit tests in `tests/unit/`:
   ```python
   import pytest
   from unittest.mock import AsyncMock
   from services.your_service import YourModelService
   from schemas.your_schema import YourModelCreate
   
   @pytest.mark.asyncio
   async def test_create_your_model():
       # Arrange
       mock_repository = AsyncMock()
       service = YourModelService(mock_repository)
       data = YourModelCreate(name="Test Model")
       
       # Act
       result = await service.create(data)
       
       # Assert
       mock_repository.create.assert_called_once_with(data)
   ```

2. Create integration tests in `tests/integration/`:
   ```python
   import pytest
   from httpx import AsyncClient
   from main import app
   
   @pytest.mark.asyncio
   async def test_create_your_model_endpoint(async_client: AsyncClient, auth_headers):
       # Arrange
       data = {"name": "Test Model"}
       
       # Act
       response = await async_client.post("/your-models/", json=data, headers=auth_headers)
       
       # Assert
       assert response.status_code == 201
       assert response.json()["name"] == "Test Model"
   ```

**ENSURE** these validations:
- Both unit and integration tests are created
- Test coverage is comprehensive (>90%)
- Tests follow AAA pattern (Arrange, Act, Assert)
- Async patterns are properly tested

### Phase 8: Documentation and Validation
**DO** these actions:
1. Add docstrings to all methods and classes
2. Update API documentation with examples
3. Test all endpoints using Swagger UI
4. Run full test suite: `pytest`
5. Check code coverage: `pytest --cov`
6. Run linting: `flake8 .`
7. Run type checking: `mypy .`

**ENSURE** these validations:
- All new code has comprehensive documentation
- API endpoints appear correctly in Swagger UI
- All tests pass with good coverage
- Code quality tools pass without errors

## Expected Outcomes

**MUST** achieve:
- Feature implemented following clean architecture principles
- Comprehensive test coverage for new functionality
- Proper error handling and validation
- Security best practices applied
- API documentation updated and accurate

**SHOULD** produce:
- Maintainable and extensible code
- Consistent patterns with existing codebase
- Proper logging and monitoring integration
- Performance-optimized database queries

## Quality Checks

**VERIFY** these items:
- [ ] Database model follows naming conventions
- [ ] Pydantic schemas have proper validation
- [ ] Repository uses async patterns correctly
- [ ] Service layer encapsulates business logic
- [ ] Router implements proper security
- [ ] Tests provide comprehensive coverage
- [ ] Documentation is complete and accurate
- [ ] Code quality tools pass

## Common Issues and Solutions

**IF** database queries are slow:
- **THEN** add appropriate indexes to model fields
- **USE** database query profiling tools
- **CONSIDER** implementing query optimization patterns

**IF** tests are failing:
- **THEN** check async test patterns are correct
- **VERIFY** test database is properly isolated
- **ENSURE** mock objects are configured correctly

**IF** validation errors occur:
- **THEN** review Pydantic schema definitions
- **CHECK** field constraints and types
- **VERIFY** request/response model compatibility

## Follow-up Actions

**MUST** complete:
- Implement comprehensive error handling
- Add appropriate logging statements
- Update API documentation
- Create user acceptance tests

**SHOULD** consider:
- Adding caching for frequently accessed data
- Implementing rate limiting for new endpoints
- Adding monitoring and alerting
- Optimizing database queries for performance

**RECOMMENDED** next steps:
- Review code with team members
- Deploy to staging environment for testing
- Monitor performance and error rates
- Plan for future feature enhancements
