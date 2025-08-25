---
applyTo: '**'
---

# Coding Standards Instructions

Comprehensive code quality, formatting, and style guidelines for Python FastAPI applications following industry best practices and PEP standards.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** follow PEP 8 Python style guide for all code formatting
- **REQUIRED** to use type hints for all function signatures and variables
- **SHALL** implement proper docstrings following Google or NumPy style
- **NEVER** use mutable default arguments in function definitions
- **MUST** use consistent naming conventions throughout the codebase
- **REQUIRED** to implement proper error handling and logging

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** use Black formatter for automatic code formatting
- **RECOMMENDED** to use isort for import statement organization
- **ALWAYS** implement comprehensive logging with appropriate levels
- **DO** use meaningful variable and function names that express intent
- **DON'T** use magic numbers or hardcoded values without constants
- **ALWAYS** write self-documenting code with clear structure

### Optional Enhancements (**MAY** Consider)
- **MAY** use pre-commit hooks for automated code quality checks
- **OPTIONAL** to implement additional linting tools like pylint or flake8
- **USE** type checking tools like mypy for static analysis
- **IMPLEMENT** code complexity analysis with tools like radon
- **AVOID** overly complex functions; prefer composition over complexity

## Implementation Guidance

**USE** these development tools:
```python
# Development dependencies for code quality
black>=23.0.0               # Code formatter
isort>=5.12.0              # Import sorter
flake8>=6.0.0              # Linting
mypy>=1.0.0                # Type checking
pre-commit>=3.0.0          # Git hooks
bandit>=1.7.0              # Security linting
pytest-cov>=4.0.0         # Coverage reporting
```

**IMPLEMENT** these coding standards:

### Type Hints and Annotations
```python
# File: core/services/example_service.py
from typing import List, Optional, Dict, Any, Union
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from core.models.user import User
from core.schemas.user import UserCreate, UserResponse

class UserService:
    """Service class for user-related operations."""
    
    def __init__(self, db: AsyncSession) -> None:
        """Initialize service with database session.
        
        Args:
            db: Async database session
        """
        self.db = db
    
    async def create_user(
        self, 
        user_data: UserCreate,
        created_by: Optional[int] = None
    ) -> UserResponse:
        """Create a new user.
        
        Args:
            user_data: User creation data
            created_by: ID of user creating this user (optional)
            
        Returns:
            Created user response
            
        Raises:
            ValueError: If username already exists
            DatabaseError: If database operation fails
        """
        # Implementation here
        pass
    
    async def get_users_by_criteria(
        self,
        criteria: Dict[str, Any],
        limit: int = 100,
        offset: int = 0
    ) -> List[UserResponse]:
        """Get users matching specified criteria.
        
        Args:
            criteria: Search criteria dictionary
            limit: Maximum number of results
            offset: Number of results to skip
            
        Returns:
            List of matching users
        """
        # Implementation here
        pass
```

### Proper Error Handling and Logging
```python
# File: core/services/enhanced_user_service.py
import logging
from typing import Optional
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from core.exceptions import UserNotFoundError, UserAlreadyExistsError

logger = logging.getLogger(__name__)

class UserService:
    """Enhanced user service with proper error handling and logging."""
    
    async def create_user(self, user_data: UserCreate) -> UserResponse:
        """Create a new user with comprehensive error handling."""
        logger.info(f"Creating user with username: {user_data.username}")
        
        try:
            # Check if user already exists
            existing_user = await self._get_user_by_username(user_data.username)
            if existing_user:
                logger.warning(f"Attempt to create duplicate user: {user_data.username}")
                raise UserAlreadyExistsError(f"User {user_data.username} already exists")
            
            # Create user
            user = await self.user_repository.create(user_data.dict())
            logger.info(f"Successfully created user with ID: {user.id}")
            
            return UserResponse.from_orm(user)
            
        except IntegrityError as e:
            logger.error(f"Database integrity error creating user: {e}")
            await self.db.rollback()
            raise UserAlreadyExistsError("User with this email or username already exists")
            
        except SQLAlchemyError as e:
            logger.error(f"Database error creating user: {e}")
            await self.db.rollback()
            raise DatabaseError("Failed to create user due to database error")
            
        except Exception as e:
            logger.error(f"Unexpected error creating user: {e}")
            await self.db.rollback()
            raise ServiceError("Failed to create user")
    
    async def _get_user_by_username(self, username: str) -> Optional[User]:
        """Private method to get user by username."""
        try:
            return await self.user_repository.get_by_username(username)
        except SQLAlchemyError as e:
            logger.error(f"Database error fetching user by username: {e}")
            return None
```

### Constants and Configuration
```python
# File: core/constants.py
"""Application constants and configuration values."""

# HTTP Status Messages
HTTP_STATUS_MESSAGES = {
    400: "Bad Request",
    401: "Unauthorized", 
    403: "Forbidden",
    404: "Not Found",
    422: "Validation Error",
    500: "Internal Server Error"
}

# Pagination Constants
DEFAULT_PAGE_SIZE = 20
MAX_PAGE_SIZE = 100
MIN_PAGE_SIZE = 1

# User Constants
MIN_USERNAME_LENGTH = 3
MAX_USERNAME_LENGTH = 50
MIN_PASSWORD_LENGTH = 8
MAX_PASSWORD_LENGTH = 128

# Cache Constants
DEFAULT_CACHE_TTL = 300  # 5 minutes
USER_CACHE_TTL = 600     # 10 minutes
SESSION_CACHE_TTL = 3600  # 1 hour

# Database Constants
MAX_CONNECTION_POOL_SIZE = 20
CONNECTION_TIMEOUT = 30
QUERY_TIMEOUT = 60

# File Upload Constants
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
ALLOWED_FILE_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.gif', '.pdf', '.txt'}
UPLOAD_DIRECTORY = 'uploads'
```

**ENSURE** these coding patterns:
- Consistent indentation (4 spaces, no tabs)
- Maximum line length of 88 characters (Black default)
- Proper import organization with isort
- Comprehensive type hints for all functions
- Clear and descriptive variable names

## Anti-Patterns

**DON'T** implement these approaches:
- Using global variables for mutable state
- Creating functions with more than 5-7 parameters
- Using bare except clauses without specific exception handling
- Mixing different naming conventions within the same module
- Creating deeply nested code structures (more than 4 levels)

**AVOID** these common mistakes:
- Using mutable default arguments (lists, dicts) in function definitions
- Not handling exceptions appropriately at the right abstraction level
- Using string formatting methods inconsistently across the codebase
- Creating overly complex list comprehensions that hurt readability
- Not following consistent import ordering and grouping

**NEVER** do these actions:
- Ignore type checking warnings without proper justification
- Use `# type: ignore` comments without explanation
- Commit code without proper formatting and linting
- Use print statements for logging in production code
- Leave TODO or FIXME comments without tracking issues

## Code Examples

### Proper Function Documentation
```python
# File: core/utils/validation.py
from typing import List, Dict, Any, Optional
import re

def validate_email(email: str) -> bool:
    """Validate email address format.
    
    Args:
        email: Email address to validate
        
    Returns:
        True if email is valid, False otherwise
        
    Example:
        >>> validate_email("user@example.com")
        True
        >>> validate_email("invalid-email")
        False
    """
    email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(email_pattern, email))

def validate_password_strength(password: str) -> Dict[str, Any]:
    """Validate password strength and return detailed feedback.
    
    Args:
        password: Password to validate
        
    Returns:
        Dictionary containing validation results with keys:
        - is_valid (bool): Whether password meets all requirements
        - score (int): Password strength score (0-5)
        - feedback (List[str]): List of feedback messages
        - requirements_met (Dict[str, bool]): Which requirements are met
        
    Example:
        >>> result = validate_password_strength("MySecure123!")
        >>> result['is_valid']
        True
        >>> result['score']
        5
    """
    requirements = {
        'min_length': len(password) >= MIN_PASSWORD_LENGTH,
        'has_uppercase': bool(re.search(r'[A-Z]', password)),
        'has_lowercase': bool(re.search(r'[a-z]', password)),
        'has_digit': bool(re.search(r'\d', password)),
        'has_special': bool(re.search(r'[!@#$%^&*(),.?":{}|<>]', password))
    }
    
    score = sum(requirements.values())
    is_valid = score >= 4  # Require at least 4 out of 5 criteria
    
    feedback = []
    if not requirements['min_length']:
        feedback.append(f"Password must be at least {MIN_PASSWORD_LENGTH} characters long")
    if not requirements['has_uppercase']:
        feedback.append("Password must contain at least one uppercase letter")
    if not requirements['has_lowercase']:
        feedback.append("Password must contain at least one lowercase letter")
    if not requirements['has_digit']:
        feedback.append("Password must contain at least one digit")
    if not requirements['has_special']:
        feedback.append("Password must contain at least one special character")
    
    return {
        'is_valid': is_valid,
        'score': score,
        'feedback': feedback,
        'requirements_met': requirements
    }
```

### Custom Exception Classes
```python
# File: core/exceptions.py
"""Custom exception classes for the application."""

class BaseAppException(Exception):
    """Base exception class for all application exceptions."""
    
    def __init__(self, message: str, error_code: Optional[str] = None) -> None:
        self.message = message
        self.error_code = error_code
        super().__init__(self.message)

class ValidationError(BaseAppException):
    """Raised when data validation fails."""
    pass

class UserNotFoundError(BaseAppException):
    """Raised when a requested user is not found."""
    
    def __init__(self, user_identifier: Union[str, int]) -> None:
        message = f"User {user_identifier} not found"
        super().__init__(message, "USER_NOT_FOUND")

class UserAlreadyExistsError(BaseAppException):
    """Raised when attempting to create a user that already exists."""
    
    def __init__(self, username: str) -> None:
        message = f"User {username} already exists"
        super().__init__(message, "USER_ALREADY_EXISTS")

class DatabaseError(BaseAppException):
    """Raised when database operations fail."""
    
    def __init__(self, message: str = "Database operation failed") -> None:
        super().__init__(message, "DATABASE_ERROR")

class ServiceError(BaseAppException):
    """Raised when service layer operations fail."""
    
    def __init__(self, message: str = "Service operation failed") -> None:
        super().__init__(message, "SERVICE_ERROR")
```

### Configuration Files
```python
# File: pyproject.toml
[tool.black]
line-length = 88
target-version = ['py311']
include = '\.pyi?$'
extend-exclude = '''
/(
  # directories
  \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | _build
  | buck-out
  | build
  | dist
)/
'''

[tool.isort]
profile = "black"
multi_line_output = 3
include_trailing_comma = true
force_grid_wrap = 0
use_parentheses = true
ensure_newline_before_comments = true
line_length = 88
known_first_party = ["core", "api", "infrastructure"]
known_third_party = ["fastapi", "sqlalchemy", "pydantic"]

[tool.mypy]
python_version = "3.11"
check_untyped_defs = true
disallow_any_generics = true
disallow_incomplete_defs = true
disallow_untyped_defs = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_return_any = true
strict_equality = true

[[tool.mypy.overrides]]
module = "tests.*"
disallow_untyped_defs = false

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "--strict-markers",
    "--strict-config",
    "--cov=core",
    "--cov=api",
    "--cov=infrastructure",
    "--cov-report=term-missing",
    "--cov-report=html",
    "--cov-fail-under=90"
]

[tool.bandit]
exclude_dirs = ["tests", "venv", ".venv"]
skips = ["B101", "B601"]  # Skip assert_used and shell_injection_process_subprocess

[tool.coverage.run]
source = ["core", "api", "infrastructure"]
omit = [
    "*/tests/*",
    "*/venv/*",
    "*/.venv/*",
    "*/migrations/*"
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "if self.debug:",
    "if settings.DEBUG",
    "raise AssertionError",
    "raise NotImplementedError",
    "if 0:",
    "if __name__ == .__main__.:",
    "class .*\\bProtocol\\):",
    "@(abc\\.)?abstractmethod"
]
```

### Pre-commit Configuration
```yaml
# File: .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-json
      - id: check-toml
      - id: check-merge-conflict
      - id: debug-statements

  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black
        language_version: python3.11

  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
        args: ["--profile", "black"]

  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
        additional_dependencies: [flake8-docstrings, flake8-typing-imports]
        args: [--max-line-length=88, --extend-ignore=E203,W503]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.3.0
    hooks:
      - id: mypy
        additional_dependencies: [types-all]
        args: [--ignore-missing-imports]

  - repo: https://github.com/pycqa/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: ["-c", "pyproject.toml"]
        additional_dependencies: ["bandit[toml]"]
```

## Validation Checklist

**MUST** verify:
- [ ] All code follows PEP 8 formatting standards
- [ ] Type hints are provided for all function signatures
- [ ] Proper docstrings are written for all public functions
- [ ] Error handling is implemented consistently
- [ ] Naming conventions are followed throughout

**SHOULD** check:
- [ ] Code is automatically formatted with Black
- [ ] Imports are organized with isort
- [ ] Linting passes without warnings
- [ ] Type checking passes with mypy
- [ ] Pre-commit hooks are configured and working

## References

- [PEP 8 Style Guide](https://peps.python.org/pep-0008/)
- [Python Type Hints](https://docs.python.org/3/library/typing.html)
- [Black Code Formatter](https://black.readthedocs.io/)
- [isort Documentation](https://pycqa.github.io/isort/)
- [mypy Type Checker](https://mypy.readthedocs.io/)
