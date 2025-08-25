# Troubleshooting Prompt

This prompt provides systematic approaches to diagnosing and resolving common issues in FastAPI applications with PostgreSQL and Docker.

## Objective

Provide structured troubleshooting methodologies for common issues in FastAPI development, from application startup problems to production deployment issues.

## Prerequisites

**MUST** have these prerequisites:
- Basic understanding of FastAPI application structure
- Familiarity with Docker and Docker Compose
- Knowledge of PostgreSQL and SQLAlchemy
- Understanding of Python async/await patterns

**SHOULD** review these resources:
- Application logs and error messages
- Docker container logs and status
- Database connection and query logs
- Network connectivity and port configurations

## Common Issue Categories

### Application Startup Issues

#### **ISSUE**: Application won't start
**SYMPTOMS**:
- ImportError or ModuleNotFoundError
- Configuration validation errors
- Database connection failures

**DIAGNOSTIC STEPS**:
1. Check Python environment and dependencies:
   ```bash
   python --version
   pip list | grep fastapi
   poetry show
   ```

2. Verify environment variables:
   ```bash
   cat .env
   echo $DATABASE_URL
   ```

3. Test minimal application:
   ```python
   from fastapi import FastAPI
   
   app = FastAPI()
   
   @app.get("/")
   async def root():
       return {"status": "ok"}
   ```

**SOLUTIONS**:
- **IF** dependencies missing: `poetry install` or `pip install -r requirements.txt`
- **IF** environment not configured: Copy `.env.example` to `.env` and configure
- **IF** import errors: Check `PYTHONPATH` and module structure

#### **ISSUE**: Configuration validation errors
**SYMPTOMS**:
- Pydantic validation errors on startup
- Missing required environment variables
- Invalid configuration values

**DIAGNOSTIC STEPS**:
1. Validate configuration:
   ```python
   from core.config import settings
   print(settings.dict())
   ```

2. Check environment variable format:
   ```bash
   # Database URL format
   DATABASE_URL=postgresql+asyncpg://user:password@host:port/database
   
   # Required variables
   SECRET_KEY=your-secret-key
   DEBUG=true
   ```

**SOLUTIONS**:
- **ENSURE** all required environment variables are set
- **VERIFY** database URL format is correct
- **GENERATE** new secret key if needed: `python -c "import secrets; print(secrets.token_urlsafe(32))"`

### Database Issues

#### **ISSUE**: Database connection failures
**SYMPTOMS**:
- Connection timeout errors
- Authentication failures
- Database not found errors

**DIAGNOSTIC STEPS**:
1. Test database connectivity:
   ```bash
   # Test PostgreSQL connection
   psql $DATABASE_URL -c "SELECT version();"
   
   # Test from Docker
   docker-compose exec db psql -U postgres -c "SELECT version();"
   ```

2. Check database service status:
   ```bash
   docker-compose ps
   docker-compose logs db
   ```

3. Verify database configuration:
   ```python
   from sqlalchemy import create_engine, text
   from core.config import settings
   
   engine = create_engine(settings.DATABASE_URL)
   with engine.connect() as conn:
       result = conn.execute(text("SELECT 1"))
       print(result.fetchone())
   ```

**SOLUTIONS**:
- **IF** connection refused: Start PostgreSQL service `docker-compose up -d db`
- **IF** authentication fails: Check username/password in `DATABASE_URL`
- **IF** database doesn't exist: Create database `createdb yourdbname`
- **IF** network issues: Check Docker network configuration

#### **ISSUE**: Migration failures
**SYMPTOMS**:
- Alembic revision errors
- Schema mismatch errors
- Duplicate table/column errors

**DIAGNOSTIC STEPS**:
1. Check migration status:
   ```bash
   alembic current
   alembic history --verbose
   ```

2. Verify model definitions:
   ```python
   from app.models import Base
   print(Base.metadata.tables.keys())
   ```

3. Check database schema:
   ```sql
   \dt  -- List tables
   \d table_name  -- Describe table
   ```

**SOLUTIONS**:
- **IF** out of sync: `alembic stamp head` then create new migration
- **IF** conflicts: Resolve model conflicts and create merge migration
- **IF** manual changes: Revert to known state and apply migrations

### Docker Issues

#### **ISSUE**: Container startup failures
**SYMPTOMS**:
- Container exits immediately
- Port binding errors
- Volume mount issues

**DIAGNOSTIC STEPS**:
1. Check container logs:
   ```bash
   docker-compose logs app
   docker-compose logs db
   docker logs container_name
   ```

2. Verify Docker configuration:
   ```bash
   docker-compose config
   docker-compose ps
   docker system df
   ```

3. Test container interactively:
   ```bash
   docker-compose run --rm app /bin/bash
   docker-compose exec app python -c "import fastapi; print('OK')"
   ```

**SOLUTIONS**:
- **IF** port conflicts: Change port mapping in `docker-compose.yml`
- **IF** volume issues: Check file permissions and paths
- **IF** build failures: Clean build cache `docker-compose build --no-cache`

#### **ISSUE**: Performance problems in containers
**SYMPTOMS**:
- Slow application response
- High memory usage
- Container resource limits

**DIAGNOSTIC STEPS**:
1. Monitor container resources:
   ```bash
   docker stats
   docker-compose top
   ```

2. Check application metrics:
   ```bash
   docker-compose exec app python -c "
   import psutil
   print(f'CPU: {psutil.cpu_percent()}%')
   print(f'Memory: {psutil.virtual_memory().percent}%')
   "
   ```

**SOLUTIONS**:
- **ADJUST** container resource limits in `docker-compose.yml`
- **OPTIMIZE** application code and database queries
- **USE** multi-stage builds to reduce image size

### Authentication and Security Issues

#### **ISSUE**: JWT token problems
**SYMPTOMS**:
- Token verification failures
- Authentication errors
- Permission denied errors

**DIAGNOSTIC STEPS**:
1. Verify JWT configuration:
   ```python
   from core.security.jwt import decode_access_token
   
   # Test token decoding
   try:
       payload = decode_access_token(token)
       print(payload)
   except Exception as e:
       print(f"Token error: {e}")
   ```

2. Check token expiration:
   ```python
   import jwt
   from core.config import settings
   
   decoded = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
   print(f"Expires: {decoded.get('exp')}")
   ```

**SOLUTIONS**:
- **IF** secret key changed: Re-generate all tokens
- **IF** token expired: Implement refresh token logic
- **IF** algorithm mismatch: Check JWT configuration

#### **ISSUE**: CORS problems
**SYMPTOMS**:
- Browser CORS errors
- Preflight request failures
- Cross-origin request blocks

**DIAGNOSTIC STEPS**:
1. Check CORS configuration:
   ```python
   from fastapi.middleware.cors import CORSMiddleware
   
   # Verify CORS settings
   print(app.user_middleware)
   ```

2. Test CORS headers:
   ```bash
   curl -H "Origin: http://localhost:3000" \
        -H "Access-Control-Request-Method: POST" \
        -H "Access-Control-Request-Headers: X-Requested-With" \
        -X OPTIONS \
        http://localhost:8000/api/v1/users/
   ```

**SOLUTIONS**:
- **ADD** appropriate origins to CORS middleware
- **ENSURE** credentials are allowed if needed
- **VERIFY** allowed methods and headers

### Performance Issues

#### **ISSUE**: Slow API responses
**SYMPTOMS**:
- High response times
- Database query timeouts
- Memory usage spikes

**DIAGNOSTIC STEPS**:
1. Profile database queries:
   ```python
   import logging
   logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)
   ```

2. Monitor application performance:
   ```python
   import time
   from functools import wraps
   
   def timing_middleware(func):
       @wraps(func)
       async def wrapper(*args, **kwargs):
           start = time.time()
           result = await func(*args, **kwargs)
           print(f"{func.__name__}: {time.time() - start:.3f}s")
           return result
       return wrapper
   ```

3. Check resource usage:
   ```bash
   top -p $(pgrep -f uvicorn)
   htop
   ```

**SOLUTIONS**:
- **ADD** database indexes for frequently queried fields
- **IMPLEMENT** response caching with Redis
- **OPTIMIZE** N+1 query problems with eager loading
- **USE** connection pooling for database connections

#### **ISSUE**: Memory leaks
**SYMPTOMS**:
- Gradual memory increase
- Out of memory errors
- Application crashes

**DIAGNOSTIC STEPS**:
1. Profile memory usage:
   ```python
   import tracemalloc
   
   tracemalloc.start()
   # ... run application
   current, peak = tracemalloc.get_traced_memory()
   print(f"Current: {current / 1024 / 1024:.1f} MB")
   print(f"Peak: {peak / 1024 / 1024:.1f} MB")
   ```

2. Check for connection leaks:
   ```python
   from sqlalchemy import event
   from sqlalchemy.engine import Engine
   
   @event.listens_for(Engine, "connect")
   def receive_connect(dbapi_connection, connection_record):
       print("Database connection opened")
   
   @event.listens_for(Engine, "close")
   def receive_close(dbapi_connection, connection_record):
       print("Database connection closed")
   ```

**SOLUTIONS**:
- **ENSURE** database connections are properly closed
- **USE** context managers for resource management
- **IMPLEMENT** proper async session handling
- **ADD** memory monitoring and alerting

### API Testing Issues

#### **ISSUE**: Test failures
**SYMPTOMS**:
- Assertion errors in tests
- Test database issues
- Async test problems

**DIAGNOSTIC STEPS**:
1. Run specific test with verbose output:
   ```bash
   pytest tests/test_users.py::test_create_user -v -s
   pytest --tb=long
   ```

2. Check test database configuration:
   ```python
   # In conftest.py
   @pytest.fixture
   async def test_db():
       # Ensure test database is properly isolated
       pass
   ```

**SOLUTIONS**:
- **ENSURE** test database is isolated from development database
- **USE** proper async test patterns with `@pytest.mark.asyncio`
- **VERIFY** test data setup and teardown
- **CHECK** authentication in API tests

## Systematic Troubleshooting Approach

### Step 1: Gather Information
**DO** these actions:
1. Collect error messages and stack traces
2. Check application and system logs
3. Verify environment configuration
4. Test minimal reproduction case

### Step 2: Isolate the Problem
**DO** these actions:
1. Identify which component is failing
2. Test individual services separately
3. Check dependencies and connections
4. Verify configuration and environment

### Step 3: Apply Systematic Solutions
**DO** these actions:
1. Start with simplest solution first
2. Apply one change at a time
3. Test each change thoroughly
4. Document successful solutions

### Step 4: Prevent Future Issues
**DO** these actions:
1. Add monitoring and alerting
2. Improve error handling and logging
3. Create comprehensive test coverage
4. Document troubleshooting procedures

## Emergency Response Procedures

### Production Issues
**IF** production system is down:
1. **IMMEDIATE**: Check system health and logs
2. **ESCALATE**: Alert team and stakeholders
3. **ROLLBACK**: Revert to last known good state if needed
4. **INVESTIGATE**: Identify root cause systematically
5. **DOCUMENT**: Record issue and resolution steps

### Data Issues
**IF** data corruption or loss suspected:
1. **STOP**: Halt all write operations immediately
2. **BACKUP**: Create backup of current state
3. **ASSESS**: Determine extent of data issues
4. **RESTORE**: From backup if necessary
5. **INVESTIGATE**: Identify cause and prevent recurrence

## Tools and Commands Reference

### Useful Debugging Commands
```bash
# Application debugging
uvicorn main:app --reload --log-level debug
python -m pdb main.py

# Database debugging
psql $DATABASE_URL
alembic current -v
sqlalchemy-utils create_database $DATABASE_URL

# Docker debugging
docker-compose logs --tail=100 -f
docker inspect container_name
docker exec -it container_name /bin/bash

# System monitoring
htop
netstat -tulpn
lsof -i :8000
```

### Monitoring and Observability
```python
# Add request ID middleware
import uuid
from fastapi import Request

@app.middleware("http")
async def add_request_id(request: Request, call_next):
    request_id = str(uuid.uuid4())
    request.state.request_id = request_id
    response = await call_next(request)
    response.headers["X-Request-ID"] = request_id
    return response

# Structured logging
import structlog
logger = structlog.get_logger()

@app.middleware("http")
async def logging_middleware(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    
    logger.info(
        "Request completed",
        method=request.method,
        url=str(request.url),
        status_code=response.status_code,
        process_time=process_time,
        request_id=getattr(request.state, "request_id", None)
    )
    return response
```

## Quality Assurance

**VERIFY** these troubleshooting practices:
- [ ] Systematic approach to problem identification
- [ ] Comprehensive logging and monitoring
- [ ] Proper error handling and graceful degradation
- [ ] Regular backup and recovery testing
- [ ] Documentation of common issues and solutions
- [ ] Monitoring and alerting for critical issues
- [ ] Team knowledge sharing and training

This troubleshooting guide provides systematic approaches to identifying and resolving common issues in FastAPI applications, helping maintain reliable and performant systems.
