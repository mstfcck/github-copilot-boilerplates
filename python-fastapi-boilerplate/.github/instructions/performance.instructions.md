---
applyTo: '**'
---

# Performance Instructions

Performance optimization and monitoring guidelines for Python FastAPI applications with production-ready scalability and efficiency.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** implement async/await patterns for all I/O operations
- **REQUIRED** to configure proper connection pooling for database and external services
- **SHALL** implement response caching for frequently accessed data
- **NEVER** use blocking synchronous operations in async request handlers
- **MUST** implement proper error handling to prevent resource leaks
- **REQUIRED** to monitor application performance metrics and response times

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** implement Redis caching for session data and frequently accessed content
- **RECOMMENDED** to use background tasks for long-running operations
- **ALWAYS** profile application performance under realistic load conditions
- **DO** implement proper database query optimization with indexing
- **DON'T** perform expensive operations in request/response cycle
- **ALWAYS** implement rate limiting to prevent abuse and resource exhaustion

### Optional Enhancements (**MAY** Consider)
- **MAY** implement CDN integration for static asset delivery
- **OPTIONAL** to add application performance monitoring (APM) tools
- **USE** load balancing and horizontal scaling strategies
- **IMPLEMENT** database read replicas for scaling read operations
- **AVOID** premature optimization without performance measurements

## Implementation Guidance

**USE** these performance technologies:
```python
# Performance and caching dependencies
redis>=4.5.0                    # Redis caching
celery>=5.2.0                  # Background task processing
gunicorn>=20.1.0               # WSGI HTTP server
uvloop>=0.17.0                 # High-performance event loop
aiofiles>=23.0.0               # Async file operations
python-multipart>=0.0.6       # File upload handling
prometheus-client>=0.16.0      # Metrics collection
```

**IMPLEMENT** these performance patterns:

### Async Configuration and Event Loop Optimization
```python
# File: main.py
import uvloop
import asyncio
from fastapi import FastAPI
from contextlib import asynccontextmanager

# Use uvloop for better performance
asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("Starting up...")
    # Initialize Redis connections, database pools, etc.
    yield
    # Shutdown
    print("Shutting down...")
    # Clean up connections

app = FastAPI(
    title="FastAPI Performance Optimized API",
    lifespan=lifespan
)
```

### Redis Caching Implementation
```python
# File: core/cache/redis_cache.py
import json
import redis.asyncio as redis
from typing import Any, Optional, Union
from datetime import timedelta
import pickle

class RedisCache:
    def __init__(self, redis_url: str):
        self.redis = redis.from_url(redis_url, decode_responses=False)
    
    async def get(self, key: str) -> Optional[Any]:
        """Get value from cache."""
        try:
            value = await self.redis.get(key)
            if value:
                return pickle.loads(value)
            return None
        except Exception as e:
            print(f"Cache get error: {e}")
            return None
    
    async def set(
        self, 
        key: str, 
        value: Any, 
        expire: Optional[Union[int, timedelta]] = None
    ) -> bool:
        """Set value in cache with optional expiration."""
        try:
            serialized_value = pickle.dumps(value)
            if expire:
                if isinstance(expire, timedelta):
                    expire = int(expire.total_seconds())
                await self.redis.setex(key, expire, serialized_value)
            else:
                await self.redis.set(key, serialized_value)
            return True
        except Exception as e:
            print(f"Cache set error: {e}")
            return False
    
    async def delete(self, key: str) -> bool:
        """Delete key from cache."""
        try:
            result = await self.redis.delete(key)
            return result > 0
        except Exception as e:
            print(f"Cache delete error: {e}")
            return False
    
    async def exists(self, key: str) -> bool:
        """Check if key exists in cache."""
        try:
            return await self.redis.exists(key) > 0
        except Exception as e:
            print(f"Cache exists error: {e}")
            return False

# Cache decorator for functions
from functools import wraps

def cache_result(expire: int = 300):
    """Decorator to cache function results."""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Create cache key from function name and arguments
            cache_key = f"{func.__name__}:{hash(str(args) + str(kwargs))}"
            
            # Try to get from cache first
            cache = RedisCache(os.getenv("REDIS_URL"))
            cached_result = await cache.get(cache_key)
            if cached_result is not None:
                return cached_result
            
            # If not in cache, execute function and cache result
            result = await func(*args, **kwargs)
            await cache.set(cache_key, result, expire)
            return result
        return wrapper
    return decorator
```

### Background Task Processing
```python
# File: core/tasks/background_tasks.py
from celery import Celery
from core.config import settings

# Celery configuration
celery_app = Celery(
    "fastapi-app",
    broker=settings.redis_url,
    backend=settings.redis_url,
    include=["core.tasks.email_tasks", "core.tasks.data_processing"]
)

# Celery configuration
celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    worker_prefetch_multiplier=1,
    task_acks_late=True,
    worker_max_tasks_per_child=1000,
)

@celery_app.task(bind=True, autoretry_for=(Exception,), retry_kwargs={'max_retries': 3})
def send_email_task(self, email_data: dict):
    """Send email in background."""
    try:
        # Email sending logic
        print(f"Sending email to {email_data['to']}")
        # Simulate email sending
        import time
        time.sleep(2)
        return {"status": "sent", "email": email_data["to"]}
    except Exception as exc:
        print(f"Email task failed: {exc}")
        raise self.retry(countdown=60)

@celery_app.task
def process_data_task(data: dict):
    """Process data in background."""
    # Heavy data processing logic
    processed_data = {"processed": True, "original": data}
    return processed_data
```

### Database Query Optimization
```python
# File: infrastructure/database/optimized_queries.py
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload, joinedload, contains_eager
from typing import List

class OptimizedUserRepository(SQLUserRepository):
    async def get_users_with_posts_optimized(self, limit: int = 100) -> List[User]:
        """Get users with their posts using optimized loading."""
        stmt = (
            select(User)
            .options(selectinload(User.posts))  # Efficient N+1 prevention
            .limit(limit)
        )
        result = await self.db.execute(stmt)
        return result.scalars().unique().all()
    
    async def get_user_statistics(self) -> dict:
        """Get user statistics with single query."""
        stmt = select(
            func.count(User.id).label("total_users"),
            func.count(User.id).filter(User.is_active == True).label("active_users"),
            func.avg(func.extract('days', func.now() - User.created_at)).label("avg_days_since_creation")
        )
        result = await self.db.execute(stmt)
        row = result.first()
        
        return {
            "total_users": row.total_users,
            "active_users": row.active_users,
            "average_days_since_creation": float(row.avg_days_since_creation or 0)
        }
    
    async def bulk_create_users(self, users_data: List[dict]) -> List[User]:
        """Efficiently create multiple users."""
        users = [User(**user_data) for user_data in users_data]
        self.db.add_all(users)
        await self.db.commit()
        
        # Refresh all objects to get IDs
        for user in users:
            await self.db.refresh(user)
        
        return users
```

**ENSURE** these performance patterns:
- All I/O operations use async/await patterns
- Database queries are optimized with proper joins and indexing
- Caching is implemented for frequently accessed data
- Background tasks handle long-running operations
- Connection pooling is properly configured

## Anti-Patterns

**DON'T** implement these approaches:
- Using synchronous database or HTTP operations in async handlers
- Performing expensive computations during request processing
- Creating N+1 query problems with lazy loading
- Ignoring database connection pooling configuration
- Using blocking file I/O operations in request handlers

**AVOID** these common mistakes:
- Not implementing proper error handling that causes resource leaks
- Creating too many database connections without pooling
- Caching data without proper invalidation strategies
- Using inappropriate data serialization formats
- Not monitoring application performance metrics

**NEVER** do these actions:
- Block the event loop with CPU-intensive operations
- Use infinite loops or long-running operations in request handlers
- Ignore memory leaks and resource cleanup
- Deploy without load testing under realistic conditions
- Use development settings in production environments

## Code Examples

### Performance Monitoring Middleware
```python
# File: api/middleware/performance.py
import time
import logging
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
from prometheus_client import Counter, Histogram, generate_latest

# Prometheus metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')

class PerformanceMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        start_time = time.time()
        
        response = await call_next(request)
        
        process_time = time.time() - start_time
        
        # Log slow requests
        if process_time > 1.0:  # Log requests taking more than 1 second
            logging.warning(
                f"Slow request: {request.method} {request.url.path} took {process_time:.2f}s"
            )
        
        # Update metrics
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=request.url.path,
            status=response.status_code
        ).inc()
        REQUEST_DURATION.observe(process_time)
        
        # Add performance headers
        response.headers["X-Process-Time"] = str(process_time)
        
        return response

@app.get("/metrics")
async def get_metrics():
    """Expose Prometheus metrics."""
    return Response(generate_latest(), media_type="text/plain")
```

### Optimized API Response Caching
```python
# File: api/middleware/cache_middleware.py
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
import hashlib
import json

class ResponseCacheMiddleware(BaseHTTPMiddleware):
    def __init__(self, app, cache_duration: int = 300):
        super().__init__(app)
        self.cache_duration = cache_duration
        self.cache = RedisCache(os.getenv("REDIS_URL"))
    
    async def dispatch(self, request: Request, call_next):
        # Only cache GET requests
        if request.method != "GET":
            return await call_next(request)
        
        # Create cache key from URL and query parameters
        cache_key = self._create_cache_key(request)
        
        # Try to get cached response
        cached_response = await self.cache.get(cache_key)
        if cached_response:
            return Response(
                content=cached_response["body"],
                status_code=cached_response["status_code"],
                headers=cached_response["headers"],
                media_type=cached_response["media_type"]
            )
        
        # If not cached, process request
        response = await call_next(request)
        
        # Cache successful responses
        if response.status_code == 200:
            response_body = b""
            async for chunk in response.body_iterator:
                response_body += chunk
            
            cached_data = {
                "body": response_body.decode(),
                "status_code": response.status_code,
                "headers": dict(response.headers),
                "media_type": response.media_type
            }
            
            await self.cache.set(cache_key, cached_data, self.cache_duration)
            
            # Return response with cached body
            return Response(
                content=response_body,
                status_code=response.status_code,
                headers=response.headers,
                media_type=response.media_type
            )
        
        return response
    
    def _create_cache_key(self, request: Request) -> str:
        """Create cache key from request."""
        key_data = f"{request.url.path}:{str(request.query_params)}"
        return hashlib.md5(key_data.encode()).hexdigest()
```

### Optimized File Upload Handling
```python
# File: api/routes/upload.py
import aiofiles
from fastapi import APIRouter, UploadFile, File, HTTPException
from typing import List
import os
import uuid

router = APIRouter()

@router.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    """Optimized file upload with streaming."""
    if file.size > 10 * 1024 * 1024:  # 10MB limit
        raise HTTPException(status_code=413, detail="File too large")
    
    # Generate unique filename
    file_extension = file.filename.split('.')[-1] if '.' in file.filename else ''
    unique_filename = f"{uuid.uuid4()}.{file_extension}"
    file_path = f"uploads/{unique_filename}"
    
    # Ensure upload directory exists
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    
    # Stream file to disk
    async with aiofiles.open(file_path, 'wb') as f:
        while chunk := await file.read(8192):  # Read in 8KB chunks
            await f.write(chunk)
    
    return {
        "filename": unique_filename,
        "original_filename": file.filename,
        "size": file.size,
        "content_type": file.content_type
    }

@router.post("/upload-multiple")
async def upload_multiple_files(files: List[UploadFile] = File(...)):
    """Upload multiple files concurrently."""
    import asyncio
    
    async def save_file(file: UploadFile):
        # Same logic as single file upload
        pass
    
    # Process files concurrently
    tasks = [save_file(file) for file in files]
    results = await asyncio.gather(*tasks)
    
    return {"uploaded_files": results}
```

## Validation Checklist

**MUST** verify:
- [ ] All I/O operations use async/await patterns
- [ ] Database connection pooling is properly configured
- [ ] Caching is implemented for frequently accessed data
- [ ] Performance monitoring is in place
- [ ] Background tasks handle long-running operations

**SHOULD** check:
- [ ] Response times are within acceptable limits under load
- [ ] Memory usage is stable without leaks
- [ ] Database queries are optimized and indexed
- [ ] Rate limiting prevents abuse
- [ ] Static assets are properly cached

## References

- [FastAPI Performance Guide](https://fastapi.tiangolo.com/advanced/async-sql-databases/)
- [Redis Performance Best Practices](https://redis.io/docs/manual/performance/)
- [SQLAlchemy Performance Tips](https://docs.sqlalchemy.org/en/14/tutorial/engine.html#tutorial-engine)
- [Celery Best Practices](https://docs.celeryproject.org/en/stable/userguide/tasks.html#best-practices)
- [Python AsyncIO Performance](https://docs.python.org/3/library/asyncio-dev.html#asyncio-dev)
