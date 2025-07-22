---
applyTo: '**'
---
Performance instructions for FastMCP and FastAPI Model Context Protocol (MCP) applications.

# Performance Instructions

This document provides performance optimization guidelines for Model Context Protocol (MCP) applications using FastMCP framework and FastAPI integration.

## Requirements

### Critical Performance Requirements (**MUST** Follow)
- **MUST** use async/await patterns for all I/O operations in FastMCP
- **REQUIRED** to implement proper connection pooling for database operations
- **SHALL** optimize FastMCP tool execution time for <1 second response
- **MUST** implement FastAPI async dependencies for database connections
- **NEVER** block the event loop with synchronous operations

### Strong Performance Recommendations (**SHOULD** Implement)
- **SHOULD** cache frequently accessed resources using FastMCP resource caching
- **RECOMMENDED** to use FastAPI dependency injection for shared services
- **ALWAYS** implement proper error handling to prevent performance degradation
- **DO** use FastMCP server composition for microservice architectures
- **DON'T** perform expensive computations in MCP tool decorators

### Optional Performance Enhancements (**MAY** Consider)
- **MAY** implement FastAPI middleware for request/response optimization
- **OPTIONAL** to use Redis caching for cross-request state
- **USE** FastMCP proxy patterns for distributed performance
- **IMPLEMENT** OpenAPI-based client optimization via FastAPI integration
- **AVOID** premature optimization without performance profiling

## FastMCP Performance Patterns

**IMPLEMENT** these performance optimizations:

### Async FastMCP Tool Implementation
```python
"""
High-performance FastMCP tool implementation.
"""
from fastmcp import FastMCP
import asyncio
import aiohttp
from typing import List, Dict, Any, Optional
from concurrent.futures import ThreadPoolExecutor
import time

mcp = FastMCP("performance-optimized-server")

# Thread pool for CPU-intensive operations
executor = ThreadPoolExecutor(max_workers=4)

@mcp.tool
async def fast_data_processing(
    data: List[Dict[str, Any]],
    batch_size: int = 100,
    use_parallel: bool = True
) -> Dict[str, Any]:
    """
    High-performance data processing with batch optimization.
    
    Performance optimizations:
    - Async processing with configurable batch sizes
    - Parallel processing for CPU-intensive operations
    - Memory-efficient streaming for large datasets
    """
    start_time = time.time()
    
    if use_parallel and len(data) > batch_size:
        # Process in parallel batches
        batches = [data[i:i + batch_size] for i in range(0, len(data), batch_size)]
        
        async def process_batch(batch):
            # Offload CPU-intensive work to thread pool
            loop = asyncio.get_event_loop()
            return await loop.run_in_executor(executor, _cpu_intensive_processing, batch)
        
        # Process batches concurrently
        results = await asyncio.gather(*[process_batch(batch) for batch in batches])
        
        # Combine results
        final_result = _combine_results(results)
    else:
        # Process sequentially for small datasets
        final_result = _cpu_intensive_processing(data)
    
    processing_time = time.time() - start_time
    
    return {
        "result": final_result,
        "performance": {
            "processing_time": processing_time,
            "items_processed": len(data),
            "throughput": len(data) / processing_time if processing_time > 0 else 0,
            "batches_used": len(data) // batch_size + 1 if use_parallel else 1
        }
    }

def _cpu_intensive_processing(data: List[Dict[str, Any]]) -> Dict[str, Any]:
    """CPU-intensive processing function."""
    # Simulate complex computation
    result = {"count": len(data), "sum": sum(item.get("value", 0) for item in data)}
    return result

def _combine_results(results: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Combine batch processing results."""
    total_count = sum(r["count"] for r in results)
    total_sum = sum(r["sum"] for r in results)
    return {"count": total_count, "sum": total_sum}

@mcp.tool
async def optimized_external_api_call(
    urls: List[str],
    timeout: float = 5.0,
    max_concurrent: int = 10
) -> List[Dict[str, Any]]:
    """
    Optimized external API calls with connection pooling and concurrency control.
    
    Performance optimizations:
    - Connection pooling with aiohttp
    - Configurable concurrency limits
    - Timeout management
    - Error handling without blocking other requests
    """
    connector = aiohttp.TCPConnector(
        limit=max_concurrent,
        limit_per_host=5,
        ttl_dns_cache=300,
        use_dns_cache=True
    )
    
    timeout_config = aiohttp.ClientTimeout(total=timeout)
    
    async with aiohttp.ClientSession(
        connector=connector,
        timeout=timeout_config
    ) as session:
        
        semaphore = asyncio.Semaphore(max_concurrent)
        
        async def fetch_url(url: str) -> Dict[str, Any]:
            async with semaphore:
                try:
                    start_time = time.time()
                    async with session.get(url) as response:
                        data = await response.json()
                        response_time = time.time() - start_time
                        
                        return {
                            "url": url,
                            "status": response.status,
                            "data": data,
                            "response_time": response_time,
                            "success": True
                        }
                except asyncio.TimeoutError:
                    return {
                        "url": url,
                        "error": "timeout",
                        "success": False
                    }
                except Exception as e:
                    return {
                        "url": url,
                        "error": str(e),
                        "success": False
                    }
        
        results = await asyncio.gather(*[fetch_url(url) for url in urls])
        return results
```

### FastMCP Resource Caching
```python
"""
High-performance resource caching with FastMCP.
"""
from fastmcp import FastMCP
import asyncio
from typing import Dict, Any, Optional
import time
from functools import lru_cache
import json

mcp = FastMCP("cached-resource-server")

# In-memory cache with TTL
_resource_cache: Dict[str, Dict[str, Any]] = {}
_cache_timestamps: Dict[str, float] = {}
CACHE_TTL = 300  # 5 minutes

async def get_cached_resource(
    resource_id: str,
    fetch_func,
    ttl: int = CACHE_TTL
) -> Dict[str, Any]:
    """
    Generic caching mechanism for FastMCP resources.
    
    Args:
        resource_id: Unique identifier for the resource
        fetch_func: Async function to fetch the resource if not cached
        ttl: Time-to-live for cached data in seconds
    
    Returns:
        Cached or freshly fetched resource data
    """
    current_time = time.time()
    
    # Check if we have valid cached data
    if (resource_id in _resource_cache and 
        resource_id in _cache_timestamps and
        current_time - _cache_timestamps[resource_id] < ttl):
        
        return _resource_cache[resource_id]
    
    # Fetch fresh data
    fresh_data = await fetch_func()
    
    # Update cache
    _resource_cache[resource_id] = fresh_data
    _cache_timestamps[resource_id] = current_time
    
    return fresh_data

@mcp.resource("perf://data/{data_type}")
async def get_performance_data(data_type: str) -> Dict[str, Any]:
    """
    High-performance data resource with intelligent caching.
    
    Caches expensive database queries and external API calls.
    """
    
    async def fetch_data():
        # Simulate expensive data fetching
        await asyncio.sleep(0.1)  # Simulate database query
        
        if data_type == "analytics":
            return {
                "type": data_type,
                "metrics": {
                    "requests_per_minute": 150,
                    "average_response_time": 0.8,
                    "error_rate": 0.02
                },
                "timestamp": time.time()
            }
        elif data_type == "system":
            return {
                "type": data_type,
                "system": {
                    "cpu_usage": 15.5,
                    "memory_usage": 45.2,
                    "disk_usage": 30.1
                },
                "timestamp": time.time()
            }
        else:
            return {
                "type": data_type,
                "error": "Unknown data type",
                "timestamp": time.time()
            }
    
    # Use different TTL based on data type
    ttl = 60 if data_type == "system" else 300  # System data changes more frequently
    
    return await get_cached_resource(
        f"performance_data_{data_type}",
        fetch_data,
        ttl
    )

@lru_cache(maxsize=128)
def expensive_computation(input_data: str) -> str:
    """
    CPU-intensive computation with LRU caching.
    
    Uses functools.lru_cache for pure function memoization.
    """
    # Simulate expensive computation
    result = hash(input_data * 1000) % 10000
    return f"computed_{result}"

@mcp.resource("compute://cached/{input_value}")
async def get_computed_result(input_value: str) -> Dict[str, Any]:
    """
    Resource that uses computational caching.
    """
    start_time = time.time()
    
    # Use cached computation
    result = expensive_computation(input_value)
    
    computation_time = time.time() - start_time
    
    return {
        "input": input_value,
        "result": result,
        "computation_time": computation_time,
        "cached": computation_time < 0.001  # Likely cached if very fast
    }
```

### FastAPI + FastMCP Performance Integration
```python
"""
High-performance FastAPI + FastMCP integration patterns.
"""
from fastapi import FastAPI, Depends, BackgroundTasks
from fastmcp import FastMCP
import asyncio
from typing import Dict, Any, List, Optional
import time
from contextlib import asynccontextmanager
import aioredis
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

# Performance-optimized FastAPI app
@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    FastAPI lifespan management for resource optimization.
    """
    # Startup: Initialize connection pools and caches
    app.state.redis = await aioredis.from_url("redis://localhost:6379")
    app.state.db_engine = create_async_engine(
        "postgresql+asyncpg://user:pass@localhost/db",
        pool_size=20,
        max_overflow=30,
        pool_pre_ping=True
    )
    app.state.db_session = sessionmaker(
        app.state.db_engine,
        class_=AsyncSession,
        expire_on_commit=False
    )
    
    yield
    
    # Shutdown: Close connections
    await app.state.redis.close()
    await app.state.db_engine.dispose()

app = FastAPI(
    title="High-Performance MCP API",
    lifespan=lifespan
)

# Create FastMCP server from FastAPI with optimizations
mcp = FastMCP.from_fastapi(
    app=app,
    name="PerformanceOptimizedServer",
    httpx_client_kwargs={
        "timeout": 30.0,
        "limits": {"max_keepalive_connections": 20, "max_connections": 100}
    }
)

# Dependency injection for optimized database access
async def get_db_session() -> AsyncSession:
    """Get database session from connection pool."""
    async with app.state.db_session() as session:
        yield session

async def get_redis_client():
    """Get Redis client for caching."""
    return app.state.redis

@mcp.tool
async def optimized_database_query(
    query_type: str,
    parameters: Dict[str, Any],
    use_cache: bool = True,
    db_session: AsyncSession = Depends(get_db_session),
    redis_client = Depends(get_redis_client)
) -> Dict[str, Any]:
    """
    Optimized database query with caching and connection pooling.
    
    Performance features:
    - Connection pooling via dependency injection
    - Redis caching for frequently accessed data
    - Query optimization and batching
    """
    cache_key = f"query_{query_type}_{hash(str(parameters))}"
    
    # Check cache first
    if use_cache:
        cached_result = await redis_client.get(cache_key)
        if cached_result:
            return {
                "data": json.loads(cached_result),
                "cached": True,
                "query_time": 0
            }
    
    # Execute database query
    start_time = time.time()
    
    # Simulate optimized database query
    await asyncio.sleep(0.05)  # Simulate query time
    
    result_data = {
        "query_type": query_type,
        "parameters": parameters,
        "results": [{"id": i, "value": f"result_{i}"} for i in range(10)],
        "count": 10
    }
    
    query_time = time.time() - start_time
    
    # Cache the result
    if use_cache:
        await redis_client.setex(
            cache_key,
            300,  # 5 minute TTL
            json.dumps(result_data)
        )
    
    return {
        "data": result_data,
        "cached": False,
        "query_time": query_time
    }

@app.middleware("http")
async def performance_middleware(request, call_next):
    """
    Performance monitoring middleware.
    """
    start_time = time.time()
    
    response = await call_next(request)
    
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    
    # Log slow requests
    if process_time > 1.0:
        print(f"Slow request: {request.url.path} took {process_time:.2f}s")
    
    return response

@app.get("/health")
async def health_check():
    """
    High-performance health check endpoint.
    """
    return {
        "status": "healthy",
        "timestamp": time.time(),
        "version": "1.0.0"
    }

# Background task for performance optimization
@mcp.tool
async def schedule_background_processing(
    task_data: Dict[str, Any],
    background_tasks: BackgroundTasks
) -> Dict[str, str]:
    """
    Schedule background processing to avoid blocking requests.
    """
    
    def process_in_background(data: Dict[str, Any]):
        """Background processing function."""
        # Simulate heavy processing
        time.sleep(2)
        print(f"Background processing completed for: {data.get('id', 'unknown')}")
    
    background_tasks.add_task(process_in_background, task_data)
    
    return {
        "message": "Task scheduled for background processing",
        "task_id": task_data.get("id", "unknown"),
        "status": "queued"
    }
```

## Performance Monitoring

**IMPLEMENT** comprehensive performance monitoring:

### FastMCP Performance Metrics
```python
"""
Performance monitoring for FastMCP applications.
"""
from fastmcp import FastMCP
import time
import asyncio
from typing import Dict, Any, List
from collections import defaultdict, deque
import statistics

class PerformanceMonitor:
    """FastMCP performance monitoring utility."""
    
    def __init__(self, max_samples: int = 1000):
        self.max_samples = max_samples
        self.tool_metrics = defaultdict(lambda: deque(maxlen=max_samples))
        self.resource_metrics = defaultdict(lambda: deque(maxlen=max_samples))
        self.error_counts = defaultdict(int)
    
    def record_tool_execution(self, tool_name: str, duration: float, success: bool):
        """Record tool execution metrics."""
        self.tool_metrics[tool_name].append({
            "duration": duration,
            "timestamp": time.time(),
            "success": success
        })
        
        if not success:
            self.error_counts[f"tool_{tool_name}"] += 1
    
    def record_resource_access(self, resource_uri: str, duration: float, success: bool):
        """Record resource access metrics."""
        self.resource_metrics[resource_uri].append({
            "duration": duration,
            "timestamp": time.time(),
            "success": success
        })
        
        if not success:
            self.error_counts[f"resource_{resource_uri}"] += 1
    
    def get_performance_summary(self) -> Dict[str, Any]:
        """Get comprehensive performance summary."""
        summary = {
            "tools": {},
            "resources": {},
            "errors": dict(self.error_counts),
            "timestamp": time.time()
        }
        
        # Tool performance summary
        for tool_name, metrics in self.tool_metrics.items():
            if metrics:
                durations = [m["duration"] for m in metrics if m["success"]]
                if durations:
                    summary["tools"][tool_name] = {
                        "avg_duration": statistics.mean(durations),
                        "median_duration": statistics.median(durations),
                        "min_duration": min(durations),
                        "max_duration": max(durations),
                        "total_calls": len(metrics),
                        "success_rate": sum(1 for m in metrics if m["success"]) / len(metrics)
                    }
        
        # Resource performance summary
        for resource_uri, metrics in self.resource_metrics.items():
            if metrics:
                durations = [m["duration"] for m in metrics if m["success"]]
                if durations:
                    summary["resources"][resource_uri] = {
                        "avg_duration": statistics.mean(durations),
                        "median_duration": statistics.median(durations),
                        "total_accesses": len(metrics),
                        "success_rate": sum(1 for m in metrics if m["success"]) / len(metrics)
                    }
        
        return summary

# Global performance monitor
performance_monitor = PerformanceMonitor()

def performance_tracked_tool(func):
    """Decorator to add performance tracking to FastMCP tools."""
    async def wrapper(*args, **kwargs):
        start_time = time.time()
        success = True
        
        try:
            result = await func(*args, **kwargs)
            return result
        except Exception as e:
            success = False
            raise
        finally:
            duration = time.time() - start_time
            performance_monitor.record_tool_execution(
                func.__name__,
                duration,
                success
            )
    
    return wrapper

# Usage example
mcp = FastMCP("performance-monitored-server")

@mcp.tool
@performance_tracked_tool
async def monitored_analysis_tool(data: List[float]) -> Dict[str, Any]:
    """Analysis tool with performance monitoring."""
    await asyncio.sleep(0.1)  # Simulate processing
    
    return {
        "mean": sum(data) / len(data),
        "count": len(data),
        "processing_time": 0.1
    }

@mcp.resource("perf://metrics")
async def get_performance_metrics() -> Dict[str, Any]:
    """Get current performance metrics."""
    return performance_monitor.get_performance_summary()
```

## Optimization Guidelines

**FOLLOW** these performance optimization guidelines:

### Memory Management
- Use generators for large data processing in FastMCP tools
- Implement proper cleanup in async context managers
- Monitor memory usage with FastAPI middleware
- Use weak references for caches when appropriate

### Concurrency Optimization
- Limit concurrent FastMCP tool executions with semaphores
- Use asyncio.gather() for parallel processing
- Implement backpressure mechanisms for high-throughput scenarios
- Use FastAPI dependency injection for shared resources

### Database Performance
- Use connection pooling with SQLAlchemy async engines
- Implement query batching for multiple operations
- Use Redis for session storage and caching
- Optimize database queries with proper indexing

### Network Optimization
- Configure appropriate timeouts for external API calls
- Use HTTP/2 when possible for FastAPI applications
- Implement request/response compression
- Use CDN for static assets in hybrid applications

### Caching Strategies
- Implement multi-level caching (memory + Redis)
- Use cache-aside pattern for frequently accessed data
- Set appropriate TTL based on data volatility
- Monitor cache hit rates and adjust strategies

## Performance Testing

**IMPLEMENT** comprehensive performance testing:

### Load Testing FastMCP Tools
```python
"""
Load testing for FastMCP tools.
"""
import asyncio
import time
from fastmcp import FastMCP, Client
from typing import List, Dict, Any

async def load_test_tool(
    server: FastMCP,
    tool_name: str,
    tool_args: Dict[str, Any],
    concurrent_requests: int = 10,
    total_requests: int = 100
) -> Dict[str, Any]:
    """
    Load test a specific FastMCP tool.
    
    Args:
        server: FastMCP server instance
        tool_name: Name of the tool to test
        tool_args: Arguments to pass to the tool
        concurrent_requests: Number of concurrent requests
        total_requests: Total number of requests to make
    
    Returns:
        Performance test results
    """
    start_time = time.time()
    successes = 0
    failures = 0
    response_times = []
    
    semaphore = asyncio.Semaphore(concurrent_requests)
    
    async def make_request():
        nonlocal successes, failures
        
        async with semaphore:
            request_start = time.time()
            try:
                async with Client(server) as client:
                    await client.call_tool(tool_name, tool_args)
                
                response_time = time.time() - request_start
                response_times.append(response_time)
                successes += 1
                
            except Exception as e:
                failures += 1
                print(f"Request failed: {e}")
    
    # Create all requests
    tasks = [make_request() for _ in range(total_requests)]
    
    # Execute all requests
    await asyncio.gather(*tasks)
    
    total_time = time.time() - start_time
    
    return {
        "tool_name": tool_name,
        "total_requests": total_requests,
        "concurrent_requests": concurrent_requests,
        "successes": successes,
        "failures": failures,
        "total_time": total_time,
        "requests_per_second": total_requests / total_time,
        "avg_response_time": sum(response_times) / len(response_times) if response_times else 0,
        "min_response_time": min(response_times) if response_times else 0,
        "max_response_time": max(response_times) if response_times else 0
    }

# Usage example
async def run_performance_tests():
    """Run comprehensive performance tests."""
    server = FastMCP("test-server")
    
    # Add test tool
    @server.tool
    async def test_tool(data: List[int]) -> Dict[str, Any]:
        await asyncio.sleep(0.01)  # Simulate processing
        return {"result": sum(data)}
    
    # Run load test
    results = await load_test_tool(
        server,
        "test_tool",
        {"data": [1, 2, 3, 4, 5]},
        concurrent_requests=20,
        total_requests=1000
    )
    
    print(f"Performance Test Results: {results}")

if __name__ == "__main__":
    asyncio.run(run_performance_tests())
```

## Benchmarking Standards

**MAINTAIN** these performance benchmarks:

### Response Time Targets
- FastMCP tool execution: < 1 second average
- Resource access: < 500ms average
- FastAPI endpoints: < 200ms average
- Database queries: < 100ms average

### Throughput Targets
- FastMCP tools: > 100 requests/second
- FastAPI endpoints: > 500 requests/second
- Database operations: > 1000 queries/second
- Cache operations: > 10,000 operations/second

### Resource Utilization
- CPU usage: < 70% under normal load
- Memory usage: < 80% of available memory
- Database connections: < 80% of pool size
- Network bandwidth: Monitor and optimize based on usage

## References

- [FastMCP Performance Guide](https://gofastmcp.com/performance) - Framework-specific optimizations
- [FastAPI Performance](https://fastapi.tiangolo.com/advanced/performance/) - Web framework optimization
- [MCP Instructions](./mcp.instructions.md) - Comprehensive FastMCP and FastAPI documentation
- [Architecture Instructions](./architecture.instructions.md) - FastMCP architecture patterns
- [Coding Standards](./coding-standards.instructions.md) - FastMCP coding standards
- **ALWAYS** monitor performance metrics in production
- **DO** implement proper resource cleanup and memory management
- **DON'T** create unnecessary object instances in hot paths

### Optional Enhancements (**MAY** Consider)
- **MAY** implement adaptive rate limiting based on server load
- **OPTIONAL** to use compression for large message payloads
- **USE** profiling tools to identify performance bottlenecks
- **IMPLEMENT** advanced caching strategies (Redis, Memcached)
- **AVOID** premature optimization without proper measurements

## Performance Architecture Patterns

### Asynchronous Processing
**PURPOSE**: Maximize concurrency and resource utilization
**IMPLEMENTATION**: Use async/await patterns for all I/O operations

```python
# Python Async Performance Pattern
import asyncio
import aiohttp
from typing import List, Dict, Any
from mcp.server import Server
import mcp.types as types

class PerformantMCPServer:
    def __init__(self, max_concurrent_requests: int = 100):
        self.server = Server("performant-mcp-server")
        self.semaphore = asyncio.Semaphore(max_concurrent_requests)
        self.session = None
        self.cache = {}
        self.cache_ttl = 300  # 5 minutes
    
    async def initialize(self):
        """Initialize async resources"""
        connector = aiohttp.TCPConnector(
            limit=100,  # Connection pool size
            limit_per_host=30,
            ttl_dns_cache=300,
            use_dns_cache=True
        )
        self.session = aiohttp.ClientSession(
            connector=connector,
            timeout=aiohttp.ClientTimeout(total=30)
        )
    
    async def fetch_resource_async(self, url: str) -> Dict[str, Any]:
        """Fetch resource asynchronously with connection pooling"""
        async with self.semaphore:
            # Check cache first
            cache_key = f"resource:{url}"
            if cache_key in self.cache:
                cached_data, timestamp = self.cache[cache_key]
                if asyncio.get_event_loop().time() - timestamp < self.cache_ttl:
                    return cached_data
            
            # Fetch from source
            async with self.session.get(url) as response:
                if response.status == 200:
                    data = await response.json()
                    # Cache the result
                    self.cache[cache_key] = (data, asyncio.get_event_loop().time())
                    return data
                else:
                    raise ValueError(f"HTTP {response.status}: {await response.text()}")
    
    async def process_batch_resources(self, urls: List[str]) -> List[Dict[str, Any]]:
        """Process multiple resources concurrently"""
        tasks = [self.fetch_resource_async(url) for url in urls]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Handle exceptions gracefully
        processed_results = []
        for result in results:
            if isinstance(result, Exception):
                processed_results.append({"error": str(result)})
            else:
                processed_results.append(result)
        
        return processed_results
    
    async def cleanup(self):
        """Cleanup resources"""
        if self.session:
            await self.session.close()
```

```typescript
// TypeScript Async Performance Pattern
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { Resource, Tool } from '@modelcontextprotocol/sdk/types.js';

class PerformantMCPServer {
    private server: Server;
    private cache: Map<string, { data: any; timestamp: number }>;
    private readonly cacheTTL = 300000; // 5 minutes
    private readonly maxConcurrentRequests = 100;
    private semaphore: number = 0;
    
    constructor() {
        this.server = new Server(
            {
                name: "performant-mcp-server",
                version: "1.0.0"
            },
            {
                capabilities: {
                    resources: { subscribe: true },
                    tools: {},
                    prompts: {}
                }
            }
        );
        
        this.cache = new Map();
        this.setupResourceHandlers();
    }
    
    private async acquireSemaphore(): Promise<void> {
        while (this.semaphore >= this.maxConcurrentRequests) {
            await new Promise(resolve => setTimeout(resolve, 10));
        }
        this.semaphore++;
    }
    
    private releaseSemaphore(): void {
        this.semaphore--;
    }
    
    private setupResourceHandlers(): void {
        this.server.setRequestHandler(
            { method: "resources/list" },
            async (request) => {
                const resources = await this.listResourcesOptimized();
                return { resources };
            }
        );
        
        this.server.setRequestHandler(
            { method: "resources/read" },
            async (request, extra) => {
                const { uri } = request.params;
                const content = await this.readResourceOptimized(uri);
                return { contents: [content] };
            }
        );
    }
    
    private async listResourcesOptimized(): Promise<Resource[]> {
        const cacheKey = 'resources:list';
        const cached = this.cache.get(cacheKey);
        
        if (cached && Date.now() - cached.timestamp < this.cacheTTL) {
            return cached.data;
        }
        
        await this.acquireSemaphore();
        try {
            // Simulate resource discovery
            const resources = await this.discoverResources();
            
            // Cache the result
            this.cache.set(cacheKey, {
                data: resources,
                timestamp: Date.now()
            });
            
            return resources;
        } finally {
            this.releaseSemaphore();
        }
    }
    
    private async readResourceOptimized(uri: string): Promise<any> {
        const cacheKey = `resource:${uri}`;
        const cached = this.cache.get(cacheKey);
        
        if (cached && Date.now() - cached.timestamp < this.cacheTTL) {
            return cached.data;
        }
        
        await this.acquireSemaphore();
        try {
            const content = await this.fetchResourceContent(uri);
            
            // Cache the result
            this.cache.set(cacheKey, {
                data: content,
                timestamp: Date.now()
            });
            
            return content;
        } finally {
            this.releaseSemaphore();
        }
    }
    
    private async discoverResources(): Promise<Resource[]> {
        // Simulate async resource discovery
        return new Promise(resolve => {
            setTimeout(() => {
                resolve([
                    {
                        uri: "performance://resource/1",
                        name: "Performance Resource 1",
                        description: "A high-performance resource"
                    }
                ]);
            }, 10);
        });
    }
    
    private async fetchResourceContent(uri: string): Promise<any> {
        // Simulate async content fetching
        return new Promise(resolve => {
            setTimeout(() => {
                resolve({
                    uri,
                    text: `Content for ${uri}`,
                    mimeType: "text/plain"
                });
            }, 50);
        });
    }
}
```

### Connection Pooling and Resource Management
**PURPOSE**: Optimize database and external service connections
**IMPLEMENTATION**: Use connection pools with proper configuration

```java
// Java Connection Pool Performance Pattern
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.time.Duration;
import java.time.Instant;

@Component
public class PerformantMCPServer {
    private final ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();
    private final ConcurrentHashMap<String, CachedResource> cache = new ConcurrentHashMap<>();
    private final Duration cacheTTL = Duration.ofMinutes(5);
    private final int maxConcurrentRequests = 100;
    private final Semaphore semaphore = new Semaphore(maxConcurrentRequests);
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    
    public CompletableFuture<List<Resource>> listResourcesAsync() {
        return CompletableFuture.supplyAsync(() -> {
            String cacheKey = "resources:list";
            
            // Check local cache first
            CachedResource cached = cache.get(cacheKey);
            if (cached != null && cached.isValid(cacheTTL)) {
                return (List<Resource>) cached.getData();
            }
            
            // Check Redis cache
            List<Resource> resources = (List<Resource>) redisTemplate.opsForValue().get(cacheKey);
            if (resources != null) {
                cache.put(cacheKey, new CachedResource(resources, Instant.now()));
                return resources;
            }
            
            // Fetch from database
            try {
                semaphore.acquire();
                resources = jdbcTemplate.query(
                    "SELECT uri, name, description FROM resources WHERE active = true",
                    (rs, rowNum) -> new Resource(
                        rs.getString("uri"),
                        rs.getString("name"),
                        rs.getString("description")
                    )
                );
                
                // Cache the result
                cache.put(cacheKey, new CachedResource(resources, Instant.now()));
                redisTemplate.opsForValue().set(cacheKey, resources, Duration.ofMinutes(10));
                
                return resources;
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw new RuntimeException("Request interrupted", e);
            } finally {
                semaphore.release();
            }
        }, executor);
    }
    
    public CompletableFuture<ResourceContent> readResourceAsync(String uri) {
        return CompletableFuture.supplyAsync(() -> {
            String cacheKey = "resource:" + uri;
            
            // Check local cache first
            CachedResource cached = cache.get(cacheKey);
            if (cached != null && cached.isValid(cacheTTL)) {
                return (ResourceContent) cached.getData();
            }
            
            // Check Redis cache
            ResourceContent content = (ResourceContent) redisTemplate.opsForValue().get(cacheKey);
            if (content != null) {
                cache.put(cacheKey, new CachedResource(content, Instant.now()));
                return content;
            }
            
            // Fetch from database
            try {
                semaphore.acquire();
                content = jdbcTemplate.queryForObject(
                    "SELECT uri, content, mime_type FROM resource_contents WHERE uri = ?",
                    new Object[]{uri},
                    (rs, rowNum) -> new ResourceContent(
                        rs.getString("uri"),
                        rs.getString("content"),
                        rs.getString("mime_type")
                    )
                );
                
                // Cache the result
                cache.put(cacheKey, new CachedResource(content, Instant.now()));
                redisTemplate.opsForValue().set(cacheKey, content, Duration.ofMinutes(10));
                
                return content;
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw new RuntimeException("Request interrupted", e);
            } finally {
                semaphore.release();
            }
        }, executor);
    }
    
    private static class CachedResource {
        private final Object data;
        private final Instant timestamp;
        
        public CachedResource(Object data, Instant timestamp) {
            this.data = data;
            this.timestamp = timestamp;
        }
        
        public boolean isValid(Duration ttl) {
            return Duration.between(timestamp, Instant.now()).compareTo(ttl) < 0;
        }
        
        public Object getData() {
            return data;
        }
    }
}
```

### Streaming and Chunked Processing
**PURPOSE**: Handle large resources efficiently without memory exhaustion
**IMPLEMENTATION**: Use streaming APIs for large content transfer

```python
# Python Streaming Performance Pattern
import asyncio
from typing import AsyncIterator, List
import aiofiles
from mcp.server import Server
import mcp.types as types

class StreamingMCPServer:
    def __init__(self):
        self.server = Server("streaming-mcp-server")
        self.setup_streaming_handlers()
    
    def setup_streaming_handlers(self):
        @self.server.read_resource()
        async def read_resource_streaming(uri: str) -> types.ResourceContents:
            if uri.startswith("stream://"):
                return await self.read_large_resource_streaming(uri)
            else:
                return await self.read_small_resource(uri)
    
    async def read_large_resource_streaming(self, uri: str) -> types.ResourceContents:
        """Handle large resources using streaming"""
        file_path = uri.replace("stream://", "")
        
        # Check file size
        import os
        file_size = os.path.getsize(file_path)
        
        if file_size > 10 * 1024 * 1024:  # 10MB threshold
            # Use streaming for large files
            content = await self.stream_file_content(file_path)
            return types.TextResourceContents(
                uri=uri,
                text=content,
                mimeType="text/plain"
            )
        else:
            # Use regular reading for small files
            async with aiofiles.open(file_path, 'r') as f:
                content = await f.read()
            return types.TextResourceContents(
                uri=uri,
                text=content,
                mimeType="text/plain"
            )
    
    async def stream_file_content(self, file_path: str, chunk_size: int = 8192) -> str:
        """Stream large file content in chunks"""
        content_chunks = []
        
        async with aiofiles.open(file_path, 'r') as f:
            while True:
                chunk = await f.read(chunk_size)
                if not chunk:
                    break
                content_chunks.append(chunk)
                
                # Yield control to prevent blocking
                await asyncio.sleep(0)
        
        return ''.join(content_chunks)
    
    async def process_large_dataset(self, dataset_uri: str) -> AsyncIterator[types.ResourceContents]:
        """Process large datasets in chunks"""
        chunk_size = 1000
        offset = 0
        
        while True:
            # Fetch chunk from database or API
            chunk_data = await self.fetch_data_chunk(dataset_uri, offset, chunk_size)
            
            if not chunk_data:
                break
            
            # Process chunk
            processed_chunk = await self.process_data_chunk(chunk_data)
            
            # Yield processed chunk
            yield types.TextResourceContents(
                uri=f"{dataset_uri}?offset={offset}&limit={chunk_size}",
                text=processed_chunk,
                mimeType="application/json"
            )
            
            offset += chunk_size
            
            # Yield control to prevent blocking
            await asyncio.sleep(0)
    
    async def fetch_data_chunk(self, uri: str, offset: int, limit: int) -> List[dict]:
        """Fetch data chunk from source"""
        # Simulate database query
        await asyncio.sleep(0.01)  # Simulate I/O
        return [{"id": i, "data": f"item_{i}"} for i in range(offset, offset + limit)]
    
    async def process_data_chunk(self, chunk: List[dict]) -> str:
        """Process data chunk"""
        # Simulate processing
        await asyncio.sleep(0.01)
        return json.dumps(chunk)
```

## Caching Strategies

### Multi-Level Caching
**IMPLEMENT** hierarchical caching for optimal performance:

```python
# Python Multi-Level Cache Implementation
import asyncio
import json
from typing import Optional, Any, Dict
from dataclasses import dataclass
from datetime import datetime, timedelta
import redis.asyncio as redis
from functools import wraps

@dataclass
class CacheEntry:
    data: Any
    timestamp: datetime
    ttl: timedelta
    
    def is_valid(self) -> bool:
        return datetime.now() - self.timestamp < self.ttl

class MultiLevelCache:
    def __init__(self, redis_url: str = "redis://localhost:6379"):
        self.memory_cache: Dict[str, CacheEntry] = {}
        self.redis_client = redis.from_url(redis_url)
        self.memory_cache_size = 1000
        self.default_ttl = timedelta(minutes=5)
    
    async def get(self, key: str) -> Optional[Any]:
        """Get value from cache (memory -> Redis -> None)"""
        # Check memory cache first
        if key in self.memory_cache:
            entry = self.memory_cache[key]
            if entry.is_valid():
                return entry.data
            else:
                del self.memory_cache[key]
        
        # Check Redis cache
        try:
            redis_value = await self.redis_client.get(key)
            if redis_value:
                data = json.loads(redis_value)
                # Store in memory cache
                self.memory_cache[key] = CacheEntry(
                    data=data,
                    timestamp=datetime.now(),
                    ttl=self.default_ttl
                )
                return data
        except Exception as e:
            print(f"Redis error: {e}")
        
        return None
    
    async def set(self, key: str, value: Any, ttl: Optional[timedelta] = None) -> None:
        """Set value in both memory and Redis caches"""
        ttl = ttl or self.default_ttl
        
        # Store in memory cache
        self.memory_cache[key] = CacheEntry(
            data=value,
            timestamp=datetime.now(),
            ttl=ttl
        )
        
        # Evict old entries if memory cache is full
        if len(self.memory_cache) > self.memory_cache_size:
            # Remove oldest entries
            oldest_keys = sorted(
                self.memory_cache.keys(),
                key=lambda k: self.memory_cache[k].timestamp
            )[:100]  # Remove 100 oldest
            
            for old_key in oldest_keys:
                del self.memory_cache[old_key]
        
        # Store in Redis
        try:
            await self.redis_client.setex(
                key,
                int(ttl.total_seconds()),
                json.dumps(value, default=str)
            )
        except Exception as e:
            print(f"Redis error: {e}")
    
    async def invalidate(self, key: str) -> None:
        """Invalidate cache entry"""
        if key in self.memory_cache:
            del self.memory_cache[key]
        
        try:
            await self.redis_client.delete(key)
        except Exception as e:
            print(f"Redis error: {e}")
    
    async def invalidate_pattern(self, pattern: str) -> None:
        """Invalidate cache entries matching pattern"""
        # Invalidate memory cache
        keys_to_remove = [k for k in self.memory_cache.keys() if pattern in k]
        for key in keys_to_remove:
            del self.memory_cache[key]
        
        # Invalidate Redis cache
        try:
            keys = await self.redis_client.keys(pattern)
            if keys:
                await self.redis_client.delete(*keys)
        except Exception as e:
            print(f"Redis error: {e}")

# Cache decorator
def cached(ttl: timedelta = timedelta(minutes=5)):
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Create cache key
            cache_key = f"{func.__name__}:{hash(str(args) + str(kwargs))}"
            
            # Try to get from cache
            cached_result = await cache.get(cache_key)
            if cached_result is not None:
                return cached_result
            
            # Execute function
            result = await func(*args, **kwargs)
            
            # Store in cache
            await cache.set(cache_key, result, ttl)
            
            return result
        return wrapper
    return decorator

# Usage example
cache = MultiLevelCache()

@cached(ttl=timedelta(minutes=10))
async def get_expensive_resource(uri: str) -> dict:
    """Expensive resource operation with caching"""
    # Simulate expensive operation
    await asyncio.sleep(1)
    return {"uri": uri, "data": "expensive_data"}
```

## Performance Monitoring

### Metrics Collection
**IMPLEMENT** comprehensive performance metrics:

```python
# Python Performance Metrics Collection
import asyncio
import time
import psutil
from typing import Dict, Any
from dataclasses import dataclass
from collections import defaultdict, deque
import logging

@dataclass
class PerformanceMetrics:
    request_count: int = 0
    total_response_time: float = 0.0
    error_count: int = 0
    cpu_usage: float = 0.0
    memory_usage: float = 0.0
    active_connections: int = 0
    cache_hits: int = 0
    cache_misses: int = 0

class PerformanceMonitor:
    def __init__(self, window_size: int = 60):
        self.metrics = PerformanceMetrics()
        self.window_size = window_size
        self.response_times = deque(maxlen=window_size)
        self.request_rates = deque(maxlen=window_size)
        self.error_rates = deque(maxlen=window_size)
        self.start_time = time.time()
        self.last_update = time.time()
        
    def record_request(self, response_time: float, success: bool = True):
        """Record request metrics"""
        self.metrics.request_count += 1
        self.metrics.total_response_time += response_time
        self.response_times.append(response_time)
        
        if not success:
            self.metrics.error_count += 1
        
        # Update rates
        current_time = time.time()
        if current_time - self.last_update >= 1.0:  # Update every second
            self.update_rates()
            self.last_update = current_time
    
    def record_cache_hit(self):
        """Record cache hit"""
        self.metrics.cache_hits += 1
    
    def record_cache_miss(self):
        """Record cache miss"""
        self.metrics.cache_misses += 1
    
    def update_system_metrics(self):
        """Update system resource metrics"""
        self.metrics.cpu_usage = psutil.cpu_percent(interval=0.1)
        self.metrics.memory_usage = psutil.virtual_memory().percent
    
    def update_rates(self):
        """Update request and error rates"""
        current_time = time.time()
        time_window = min(current_time - self.start_time, self.window_size)
        
        if time_window > 0:
            request_rate = self.metrics.request_count / time_window
            error_rate = self.metrics.error_count / time_window
            
            self.request_rates.append(request_rate)
            self.error_rates.append(error_rate)
    
    def get_avg_response_time(self) -> float:
        """Get average response time"""
        if self.response_times:
            return sum(self.response_times) / len(self.response_times)
        return 0.0
    
    def get_p95_response_time(self) -> float:
        """Get 95th percentile response time"""
        if self.response_times:
            sorted_times = sorted(self.response_times)
            index = int(len(sorted_times) * 0.95)
            return sorted_times[index] if index < len(sorted_times) else sorted_times[-1]
        return 0.0
    
    def get_cache_hit_rate(self) -> float:
        """Get cache hit rate"""
        total_requests = self.metrics.cache_hits + self.metrics.cache_misses
        if total_requests > 0:
            return self.metrics.cache_hits / total_requests
        return 0.0
    
    def get_error_rate(self) -> float:
        """Get error rate"""
        if self.metrics.request_count > 0:
            return self.metrics.error_count / self.metrics.request_count
        return 0.0
    
    def get_current_metrics(self) -> Dict[str, Any]:
        """Get current performance metrics"""
        self.update_system_metrics()
        
        return {
            "request_count": self.metrics.request_count,
            "avg_response_time": self.get_avg_response_time(),
            "p95_response_time": self.get_p95_response_time(),
            "error_rate": self.get_error_rate(),
            "cache_hit_rate": self.get_cache_hit_rate(),
            "cpu_usage": self.metrics.cpu_usage,
            "memory_usage": self.metrics.memory_usage,
            "active_connections": self.metrics.active_connections,
            "uptime": time.time() - self.start_time
        }

# Performance monitoring decorator
def monitor_performance(monitor: PerformanceMonitor):
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            start_time = time.time()
            success = True
            
            try:
                result = await func(*args, **kwargs)
                return result
            except Exception as e:
                success = False
                raise
            finally:
                response_time = time.time() - start_time
                monitor.record_request(response_time, success)
        
        return wrapper
    return decorator

# Usage example
performance_monitor = PerformanceMonitor()

@monitor_performance(performance_monitor)
async def handle_mcp_request(request: dict) -> dict:
    """Handle MCP request with performance monitoring"""
    # Process request
    await asyncio.sleep(0.1)  # Simulate work
    return {"status": "success", "data": "processed"}
```

## Performance Testing and Benchmarking

### Load Testing
**IMPLEMENT** comprehensive load testing:

```python
# Python Load Testing Script
import asyncio
import time
import aiohttp
import json
from typing import List, Dict, Any
from dataclasses import dataclass
import statistics

@dataclass
class LoadTestResult:
    total_requests: int
    successful_requests: int
    failed_requests: int
    avg_response_time: float
    min_response_time: float
    max_response_time: float
    p95_response_time: float
    p99_response_time: float
    requests_per_second: float
    error_rate: float

class MCPLoadTester:
    def __init__(self, base_url: str, concurrent_users: int = 10):
        self.base_url = base_url
        self.concurrent_users = concurrent_users
        self.session = None
        self.results = []
    
    async def setup(self):
        """Setup test environment"""
        connector = aiohttp.TCPConnector(
            limit=self.concurrent_users * 2,
            limit_per_host=self.concurrent_users * 2
        )
        self.session = aiohttp.ClientSession(
            connector=connector,
            timeout=aiohttp.ClientTimeout(total=30)
        )
    
    async def teardown(self):
        """Cleanup test environment"""
        if self.session:
            await self.session.close()
    
    async def make_request(self, method: str, params: dict = None) -> Dict[str, Any]:
        """Make single MCP request"""
        request_data = {
            "jsonrpc": "2.0",
            "method": method,
            "id": 1,
            "params": params or {}
        }
        
        start_time = time.time()
        try:
            async with self.session.post(
                f"{self.base_url}/mcp",
                json=request_data
            ) as response:
                response_time = time.time() - start_time
                
                if response.status == 200:
                    data = await response.json()
                    return {
                        "success": True,
                        "response_time": response_time,
                        "data": data
                    }
                else:
                    return {
                        "success": False,
                        "response_time": response_time,
                        "error": f"HTTP {response.status}"
                    }
        except Exception as e:
            response_time = time.time() - start_time
            return {
                "success": False,
                "response_time": response_time,
                "error": str(e)
            }
    
    async def run_user_simulation(self, user_id: int, duration: int) -> List[Dict[str, Any]]:
        """Simulate single user load"""
        results = []
        end_time = time.time() + duration
        
        while time.time() < end_time:
            # Simulate different request patterns
            if user_id % 3 == 0:
                result = await self.make_request("resources/list")
            elif user_id % 3 == 1:
                result = await self.make_request("resources/read", {"uri": "test://resource/1"})
            else:
                result = await self.make_request("tools/list")
            
            results.append(result)
            
            # Simulate think time
            await asyncio.sleep(0.1)
        
        return results
    
    async def run_load_test(self, duration: int = 60) -> LoadTestResult:
        """Run load test with multiple concurrent users"""
        await self.setup()
        
        try:
            print(f"Starting load test with {self.concurrent_users} concurrent users for {duration} seconds...")
            
            # Start all user simulations
            tasks = [
                self.run_user_simulation(i, duration)
                for i in range(self.concurrent_users)
            ]
            
            # Wait for all tasks to complete
            user_results = await asyncio.gather(*tasks)
            
            # Aggregate results
            all_results = []
            for user_result in user_results:
                all_results.extend(user_result)
            
            return self.calculate_test_results(all_results, duration)
        
        finally:
            await self.teardown()
    
    def calculate_test_results(self, results: List[Dict[str, Any]], duration: int) -> LoadTestResult:
        """Calculate load test results"""
        total_requests = len(results)
        successful_requests = sum(1 for r in results if r["success"])
        failed_requests = total_requests - successful_requests
        
        response_times = [r["response_time"] for r in results]
        
        return LoadTestResult(
            total_requests=total_requests,
            successful_requests=successful_requests,
            failed_requests=failed_requests,
            avg_response_time=statistics.mean(response_times),
            min_response_time=min(response_times),
            max_response_time=max(response_times),
            p95_response_time=statistics.quantiles(response_times, n=20)[18],  # 95th percentile
            p99_response_time=statistics.quantiles(response_times, n=100)[98],  # 99th percentile
            requests_per_second=total_requests / duration,
            error_rate=failed_requests / total_requests if total_requests > 0 else 0
        )

# Usage example
async def main():
    tester = MCPLoadTester("http://localhost:8080", concurrent_users=50)
    result = await tester.run_load_test(duration=60)
    
    print(f"Load Test Results:")
    print(f"Total Requests: {result.total_requests}")
    print(f"Successful Requests: {result.successful_requests}")
    print(f"Failed Requests: {result.failed_requests}")
    print(f"Average Response Time: {result.avg_response_time:.3f}s")
    print(f"P95 Response Time: {result.p95_response_time:.3f}s")
    print(f"P99 Response Time: {result.p99_response_time:.3f}s")
    print(f"Requests per Second: {result.requests_per_second:.2f}")
    print(f"Error Rate: {result.error_rate:.2%}")

if __name__ == "__main__":
    asyncio.run(main())
```

## Performance Anti-Patterns to Avoid

### Common Performance Mistakes
**DON'T**:
- Use synchronous I/O operations in async contexts
- Create new database connections for each request
- Implement unbounded caches that can cause memory leaks
- Use blocking operations in event loops
- Ignore connection timeouts and circuit breaker patterns
- Perform expensive operations in hot paths without caching
- Use inefficient serialization formats for large data
- Ignore database query optimization and indexing
- Implement polling instead of push-based notifications
- Use global locks that can become bottlenecks

**DO**:
- Use async/await patterns consistently
- Implement proper connection pooling
- Use bounded caches with TTL and eviction policies
- Keep event loops free of blocking operations
- Implement timeouts and circuit breakers
- Cache expensive operations appropriately
- Use efficient serialization (Protocol Buffers, MessagePack)
- Optimize database queries and use proper indexing
- Implement push-based notifications when possible
- Use fine-grained locking or lock-free data structures

## Validation Checklist

**MUST** verify:
- [ ] All I/O operations use async/await patterns
- [ ] Connection pooling implemented for external resources
- [ ] Caching strategies appropriate for data access patterns
- [ ] Performance monitoring and metrics collection in place
- [ ] Load testing completed with acceptable results
- [ ] Memory usage monitored and bounded
- [ ] Database queries optimized with proper indexing
- [ ] Error handling doesn't impact performance significantly

**SHOULD** check:
- [ ] Streaming implemented for large resource transfers
- [ ] Circuit breaker patterns implemented for external services
- [ ] Compression used for large message payloads
- [ ] Resource cleanup properly implemented
- [ ] Performance benchmarks documented and tracked
- [ ] Profiling tools used to identify bottlenecks
- [ ] Cache hit rates monitored and optimized
- [ ] Response time SLAs defined and monitored

## References

- [Python AsyncIO Documentation](https://docs.python.org/3/library/asyncio.html)
- [Node.js Performance Best Practices](https://nodejs.org/en/docs/guides/simple-profiling/)
- [Java Virtual Threads](https://openjdk.org/jeps/444)
- [Redis Caching Strategies](https://redis.io/docs/manual/clients-guide/)
- [Database Connection Pooling](https://en.wikipedia.org/wiki/Connection_pool)
- [Load Testing Best Practices](https://k6.io/docs/testing-guides/load-testing/)
- [Performance Monitoring](https://prometheus.io/docs/introduction/overview/)
