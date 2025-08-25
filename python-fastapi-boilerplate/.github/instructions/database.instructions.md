---
applyTo: '**'
---

# Database Instructions

Comprehensive PostgreSQL integration and optimization guidelines for Python FastAPI applications with SQLAlchemy and Alembic.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** use SQLAlchemy 2.0+ with async support for all database operations
- **REQUIRED** to implement proper connection pooling and timeout configuration
- **SHALL** use Alembic for all database schema migrations
- **NEVER** write raw SQL without proper parameterization and validation
- **MUST** implement proper transaction management with rollback on errors
- **REQUIRED** to use environment-specific database configurations

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** implement database health checks and monitoring
- **RECOMMENDED** to use connection pooling for optimal performance
- **ALWAYS** implement proper indexing strategy for query optimization
- **DO** use database constraints for data integrity
- **DON'T** perform database operations in API route handlers directly
- **ALWAYS** implement proper error handling for database operations

### Optional Enhancements (**MAY** Consider)
- **MAY** implement read replica support for scaling read operations
- **OPTIONAL** to add database query logging and performance monitoring
- **USE** database connection pooling with pgbouncer for high-load scenarios
- **IMPLEMENT** database backup and recovery procedures
- **AVOID** unnecessary database round trips with proper eager loading

## Implementation Guidance

**USE** these database technologies:
```python
# Core database dependencies
sqlalchemy[asyncio]>=2.0.0      # Async SQLAlchemy
asyncpg>=0.28.0                 # PostgreSQL async driver
alembic>=1.11.0                 # Database migrations
psycopg2-binary>=2.9.0          # PostgreSQL sync driver (for migrations)
```

**IMPLEMENT** these database patterns:

### Database Configuration
```python
# File: core/database/config.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy.pool import NullPool
import os

# Database URL configuration
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://user:password@localhost/dbname")

# Create async engine
engine = create_async_engine(
    DATABASE_URL,
    echo=os.getenv("DEBUG", "false").lower() == "true",  # Log SQL in debug mode
    pool_size=20,  # Connection pool size
    max_overflow=0,  # Additional connections beyond pool_size
    pool_pre_ping=True,  # Validate connections before use
    pool_recycle=300,  # Recycle connections after 5 minutes
)

# Session maker for async sessions
AsyncSessionLocal = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

# Base class for all models
Base = declarative_base()
```

### Database Connection Management
```python
# File: core/database/connection.py
from sqlalchemy.ext.asyncio import AsyncSession
from core.database.config import AsyncSessionLocal

async def get_db() -> AsyncSession:
    """Dependency to get database session."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

async def get_db_session() -> AsyncSession:
    """Get database session for service layer."""
    return AsyncSessionLocal()
```

### Model Definition
```python
# File: core/models/user.py
from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from core.database.config import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    full_name = Column(String(255), nullable=True)
    hashed_password = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    is_superuser = Column(Boolean, default=False, nullable=False)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
    
    # Indexes for optimization
    __table_args__ = (
        {"comment": "User accounts table"}
    )
```

**ENSURE** these database patterns:
- All database operations use async/await patterns
- Connection pooling is properly configured
- Database sessions are properly closed and rolled back on errors
- Migrations are version controlled and reproducible
- Database constraints maintain data integrity

## Anti-Patterns

**DON'T** implement these approaches:
- Using synchronous database operations in async FastAPI handlers
- Creating database connections without proper session management
- Writing migrations that can't be rolled back safely
- Storing sensitive data without proper encryption
- Using SELECT * queries without specifying needed columns

**AVOID** these common mistakes:
- Not handling database connection timeouts and failures
- Creating N+1 query problems with improper relationship loading
- Using database transactions that are too long-running
- Not properly indexing frequently queried columns
- Mixing SQLAlchemy ORM with raw SQL without proper abstraction

**NEVER** do these actions:
- Commit raw user input to database without validation
- Use database connections across multiple request contexts
- Store passwords or secrets in plain text in database
- Ignore database migration failures in deployment
- Use production database for development or testing

## Code Examples

### Repository Implementation
```python
# File: infrastructure/database/repositories/user_repository.py
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete
from sqlalchemy.orm import selectinload
from typing import List, Optional
from core.models.user import User
from core.interfaces.repositories import UserRepository

class SQLUserRepository(UserRepository):
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def create(self, user_data: dict) -> User:
        """Create a new user."""
        user = User(**user_data)
        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)
        return user
    
    async def get_by_id(self, user_id: int) -> Optional[User]:
        """Get user by ID."""
        stmt = select(User).where(User.id == user_id)
        result = await self.db.execute(stmt)
        return result.scalar_one_or_none()
    
    async def get_by_username(self, username: str) -> Optional[User]:
        """Get user by username."""
        stmt = select(User).where(User.username == username)
        result = await self.db.execute(stmt)
        return result.scalar_one_or_none()
    
    async def get_by_email(self, email: str) -> Optional[User]:
        """Get user by email."""
        stmt = select(User).where(User.email == email)
        result = await self.db.execute(stmt)
        return result.scalar_one_or_none()
    
    async def get_all(self, skip: int = 0, limit: int = 100) -> List[User]:
        """Get all users with pagination."""
        stmt = select(User).offset(skip).limit(limit)
        result = await self.db.execute(stmt)
        return result.scalars().all()
    
    async def update(self, user_id: int, user_data: dict) -> Optional[User]:
        """Update user data."""
        stmt = (
            update(User)
            .where(User.id == user_id)
            .values(**user_data)
            .returning(User)
        )
        result = await self.db.execute(stmt)
        await self.db.commit()
        return result.scalar_one_or_none()
    
    async def delete(self, user_id: int) -> bool:
        """Delete user by ID."""
        stmt = delete(User).where(User.id == user_id)
        result = await self.db.execute(stmt)
        await self.db.commit()
        return result.rowcount > 0
    
    async def count(self) -> int:
        """Count total users."""
        stmt = select(func.count(User.id))
        result = await self.db.execute(stmt)
        return result.scalar()
```

### Migration Configuration
```python
# File: alembic/env.py
import asyncio
from logging.config import fileConfig
from sqlalchemy import pool
from sqlalchemy.engine import Connection
from sqlalchemy.ext.asyncio import async_engine_from_config
from alembic import context
from core.database.config import Base
from core.models import *  # Import all models

# Alembic Config object
config = context.config

# Interpret the config file for Python logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Target metadata for autogenerate support
target_metadata = Base.metadata

def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()

def do_run_migrations(connection: Connection) -> None:
    context.configure(connection=connection, target_metadata=target_metadata)

    with context.begin_transaction():
        context.run_migrations()

async def run_async_migrations() -> None:
    """Run migrations in 'online' mode."""
    connectable = async_engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)

    await connectable.dispose()

def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""
    asyncio.run(run_async_migrations())

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

### Database Health Check
```python
# File: api/routes/health.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from core.database.connection import get_db

router = APIRouter()

@router.get("/health/db")
async def check_database_health(db: AsyncSession = Depends(get_db)):
    """Check database connectivity and health."""
    try:
        # Simple query to test connection
        result = await db.execute(text("SELECT 1"))
        await db.commit()
        
        return {
            "status": "healthy",
            "database": "connected",
            "timestamp": datetime.utcnow()
        }
    except Exception as e:
        raise HTTPException(
            status_code=503,
            detail=f"Database health check failed: {str(e)}"
        )
```

### Complex Query Examples
```python
# File: infrastructure/database/repositories/advanced_queries.py
from sqlalchemy import select, func, and_, or_, desc
from sqlalchemy.orm import selectinload, joinedload
from datetime import datetime, timedelta

class AdvancedUserRepository(SQLUserRepository):
    async def get_users_with_activity(
        self, 
        days: int = 30, 
        skip: int = 0, 
        limit: int = 100
    ) -> List[User]:
        """Get users with recent activity."""
        cutoff_date = datetime.utcnow() - timedelta(days=days)
        
        stmt = (
            select(User)
            .where(
                and_(
                    User.is_active == True,
                    User.updated_at >= cutoff_date
                )
            )
            .order_by(desc(User.updated_at))
            .offset(skip)
            .limit(limit)
        )
        
        result = await self.db.execute(stmt)
        return result.scalars().all()
    
    async def search_users(
        self, 
        query: str, 
        skip: int = 0, 
        limit: int = 100
    ) -> List[User]:
        """Search users by username or email."""
        search_pattern = f"%{query}%"
        
        stmt = (
            select(User)
            .where(
                or_(
                    User.username.ilike(search_pattern),
                    User.email.ilike(search_pattern),
                    User.full_name.ilike(search_pattern)
                )
            )
            .order_by(User.username)
            .offset(skip)
            .limit(limit)
        )
        
        result = await self.db.execute(stmt)
        return result.scalars().all()
```

## Validation Checklist

**MUST** verify:
- [ ] All database operations use async patterns
- [ ] Connection pooling is properly configured
- [ ] Database migrations are reversible and tested
- [ ] Proper error handling for database failures
- [ ] Database sessions are properly managed

**SHOULD** check:
- [ ] Database queries are optimized with proper indexing
- [ ] Connection timeouts and retry logic are implemented
- [ ] Database health checks are configured
- [ ] Backup and recovery procedures are documented
- [ ] Performance monitoring is in place

## References

- [SQLAlchemy 2.0 Documentation](https://docs.sqlalchemy.org/en/20/)
- [Alembic Documentation](https://alembic.sqlalchemy.org/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [AsyncPG Documentation](https://magicstack.github.io/asyncpg/)
- [FastAPI Database Guide](https://fastapi.tiangolo.com/tutorial/sql-databases/)
