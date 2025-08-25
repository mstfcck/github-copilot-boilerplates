---
applyTo: '**'
---

# Testing Instructions

Comprehensive testing strategies and implementation guidelines for Python FastAPI applications with high coverage and reliable test suites.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** achieve minimum 90% code coverage for all production code
- **REQUIRED** to implement unit tests for all service layer methods
- **SHALL** create integration tests for all API endpoints
- **NEVER** skip testing for security-critical functionality
- **MUST** use async test patterns for all async code
- **REQUIRED** to implement database transaction rollback in tests

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** implement test fixtures for common test data
- **RECOMMENDED** to use factory pattern for test object creation
- **ALWAYS** mock external dependencies in unit tests
- **DO** implement end-to-end tests for critical user journeys
- **DON'T** use production database for testing
- **ALWAYS** test both success and failure scenarios

### Optional Enhancements (**MAY** Consider)
- **MAY** implement property-based testing with Hypothesis
- **OPTIONAL** to add performance testing with load tests
- **USE** mutation testing to verify test quality
- **IMPLEMENT** contract testing for external API integrations
- **AVOID** flaky tests that pass/fail inconsistently

## Implementation Guidance

**USE** these testing frameworks and tools:
```python
# Core testing dependencies
pytest>=7.0.0              # Main testing framework
pytest-asyncio>=0.21.0     # Async test support
pytest-cov>=4.0.0          # Coverage reporting
httpx>=0.24.0               # Async HTTP client for API testing
factory-boy>=3.2.0         # Test data factories
faker>=18.0.0               # Fake data generation
pytest-mock>=3.10.0        # Mocking utilities
```

**IMPLEMENT** these test patterns:

### Test Configuration
```python
# File: tests/conftest.py
import pytest
import asyncio
from httpx import AsyncClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from main import app
from core.database import get_db, Base
from core.config import Settings

# Test database configuration
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()

@pytest.fixture
async def db_session():
    """Create a fresh database session for each test."""
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)

@pytest.fixture
async def client(db_session):
    """Create a test client with database dependency override."""
    def override_get_db():
        try:
            yield db_session
        finally:
            db_session.close()
    
    app.dependency_overrides[get_db] = override_get_db
    
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac
    
    app.dependency_overrides.clear()
```

### Test Factories
```python
# File: tests/factories.py
import factory
from faker import Faker
from core.models.user import User
from core.schemas.user import UserCreate

fake = Faker()

class UserFactory(factory.Factory):
    class Meta:
        model = UserCreate
    
    username = factory.LazyFunction(lambda: fake.user_name())
    email = factory.LazyFunction(lambda: fake.email())
    full_name = factory.LazyFunction(lambda: fake.name())
    password = factory.LazyFunction(lambda: fake.password())

class UserModelFactory(factory.Factory):
    class Meta:
        model = User
    
    id = factory.Sequence(lambda n: n)
    username = factory.LazyFunction(lambda: fake.user_name())
    email = factory.LazyFunction(lambda: fake.email())
    full_name = factory.LazyFunction(lambda: fake.name())
    hashed_password = factory.LazyFunction(lambda: fake.sha256())
    is_active = True
```

**ENSURE** these testing patterns:
- All async functions are tested with async test methods
- Database transactions are rolled back after each test
- External API calls are mocked in unit tests
- Test data is isolated and doesn't affect other tests
- Both positive and negative test cases are covered

## Anti-Patterns

**DON'T** implement these approaches:
- Using production database or real external services in tests
- Writing tests that depend on specific execution order
- Creating tests that modify global state without cleanup
- Using hardcoded test data that becomes brittle over time
- Ignoring test failures or marking tests as "skip" without fixing

**AVOID** these common mistakes:
- Not testing error conditions and edge cases
- Creating overly complex test setup that's hard to maintain
- Using sleep() or arbitrary delays in async tests
- Testing implementation details instead of behavior
- Writing tests that are slower than necessary

**NEVER** do these actions:
- Commit failing tests to version control
- Use production API keys or secrets in test configuration
- Write tests that have side effects on external systems
- Test multiple concerns in a single test function
- Ignore code coverage drops without justification

## Code Examples

### Unit Test Examples
```python
# File: tests/unit/test_user_service.py
import pytest
from unittest.mock import Mock, AsyncMock
from core.services.user_service import UserService
from core.schemas.user import UserCreate, UserResponse
from tests.factories import UserFactory, UserModelFactory

class TestUserService:
    @pytest.fixture
    def mock_user_repository(self):
        return Mock()
    
    @pytest.fixture
    def user_service(self, mock_user_repository):
        return UserService(mock_user_repository)
    
    @pytest.mark.asyncio
    async def test_create_user_success(self, user_service, mock_user_repository):
        # Arrange
        user_data = UserFactory()
        expected_user = UserModelFactory()
        mock_user_repository.create = AsyncMock(return_value=expected_user)
        
        # Act
        result = await user_service.create_user(user_data)
        
        # Assert
        assert isinstance(result, UserResponse)
        assert result.username == expected_user.username
        mock_user_repository.create.assert_called_once()
    
    @pytest.mark.asyncio
    async def test_create_user_duplicate_username(self, user_service, mock_user_repository):
        # Arrange
        user_data = UserFactory()
        mock_user_repository.create = AsyncMock(side_effect=ValueError("Username already exists"))
        
        # Act & Assert
        with pytest.raises(ValueError, match="Username already exists"):
            await user_service.create_user(user_data)
    
    @pytest.mark.asyncio
    async def test_get_user_not_found(self, user_service, mock_user_repository):
        # Arrange
        user_id = 999
        mock_user_repository.get_by_id = AsyncMock(return_value=None)
        
        # Act
        result = await user_service.get_user(user_id)
        
        # Assert
        assert result is None
        mock_user_repository.get_by_id.assert_called_once_with(user_id)
```

### Integration Test Examples
```python
# File: tests/integration/test_user_api.py
import pytest
from httpx import AsyncClient
from tests.factories import UserFactory

class TestUserAPI:
    @pytest.mark.asyncio
    async def test_create_user_success(self, client: AsyncClient):
        # Arrange
        user_data = UserFactory()
        
        # Act
        response = await client.post(
            "/users/",
            json=user_data.dict()
        )
        
        # Assert
        assert response.status_code == 201
        data = response.json()
        assert data["username"] == user_data.username
        assert data["email"] == user_data.email
        assert "id" in data
        assert "password" not in data  # Password should not be returned
    
    @pytest.mark.asyncio
    async def test_create_user_invalid_email(self, client: AsyncClient):
        # Arrange
        user_data = UserFactory()
        user_data.email = "invalid-email"
        
        # Act
        response = await client.post(
            "/users/",
            json=user_data.dict()
        )
        
        # Assert
        assert response.status_code == 422
        assert "email" in response.json()["detail"][0]["loc"]
    
    @pytest.mark.asyncio
    async def test_get_user_success(self, client: AsyncClient):
        # Arrange - Create a user first
        user_data = UserFactory()
        create_response = await client.post("/users/", json=user_data.dict())
        user_id = create_response.json()["id"]
        
        # Act
        response = await client.get(f"/users/{user_id}")
        
        # Assert
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == user_id
        assert data["username"] == user_data.username
    
    @pytest.mark.asyncio
    async def test_get_user_not_found(self, client: AsyncClient):
        # Act
        response = await client.get("/users/999")
        
        # Assert
        assert response.status_code == 404
        assert response.json()["detail"] == "User not found"
```

### Authentication Test Examples
```python
# File: tests/integration/test_auth.py
import pytest
from httpx import AsyncClient
from tests.factories import UserFactory

class TestAuthentication:
    @pytest.mark.asyncio
    async def test_login_success(self, client: AsyncClient):
        # Arrange - Create a user
        user_data = UserFactory()
        await client.post("/users/", json=user_data.dict())
        
        # Act
        response = await client.post(
            "/auth/token",
            data={
                "username": user_data.username,
                "password": user_data.password
            }
        )
        
        # Assert
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"
    
    @pytest.mark.asyncio
    async def test_login_invalid_credentials(self, client: AsyncClient):
        # Act
        response = await client.post(
            "/auth/token",
            data={
                "username": "nonexistent",
                "password": "wrongpassword"
            }
        )
        
        # Assert
        assert response.status_code == 401
        assert "Incorrect username or password" in response.json()["detail"]
    
    @pytest.mark.asyncio
    async def test_protected_endpoint_without_token(self, client: AsyncClient):
        # Act
        response = await client.get("/users/me")
        
        # Assert
        assert response.status_code == 401
        assert "Not authenticated" in response.json()["detail"]
```

### Performance Test Examples
```python
# File: tests/performance/test_api_performance.py
import pytest
import asyncio
import time
from httpx import AsyncClient

class TestAPIPerformance:
    @pytest.mark.asyncio
    async def test_concurrent_user_creation(self, client: AsyncClient):
        """Test API performance under concurrent load."""
        
        async def create_user():
            user_data = UserFactory()
            start_time = time.time()
            response = await client.post("/users/", json=user_data.dict())
            end_time = time.time()
            return response.status_code, end_time - start_time
        
        # Create 50 concurrent requests
        tasks = [create_user() for _ in range(50)]
        results = await asyncio.gather(*tasks)
        
        # Assert all requests succeeded
        success_count = sum(1 for status, _ in results if status == 201)
        assert success_count == 50
        
        # Assert reasonable response times (under 1 second)
        response_times = [duration for _, duration in results]
        avg_response_time = sum(response_times) / len(response_times)
        assert avg_response_time < 1.0, f"Average response time too high: {avg_response_time}"
```

## Validation Checklist

**MUST** verify:
- [ ] Code coverage is above 90% for all production code
- [ ] All async functions have corresponding async tests
- [ ] Database tests use transactions that roll back
- [ ] External dependencies are properly mocked
- [ ] Both success and failure scenarios are tested

**SHOULD** check:
- [ ] Test factories are used for test data generation
- [ ] Tests are isolated and don't depend on each other
- [ ] Performance tests verify acceptable response times
- [ ] Integration tests cover all API endpoints
- [ ] Error conditions and edge cases are tested

## References

- [Pytest Documentation](https://docs.pytest.org/)
- [FastAPI Testing Guide](https://fastapi.tiangolo.com/tutorial/testing/)
- [Pytest-asyncio Documentation](https://pytest-asyncio.readthedocs.io/)
- [Factory Boy Documentation](https://factoryboy.readthedocs.io/)
- [Testing Best Practices](https://docs.python-guide.org/writing/tests/)
