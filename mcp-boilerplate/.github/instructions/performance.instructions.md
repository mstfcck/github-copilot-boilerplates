---
applyTo: '**'
---

# MCP Performance Optimization Guide

This document provides comprehensive performance optimization guidelines for Model Context Protocol (MCP) applications to ensure efficient resource utilization and optimal throughput.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** implement proper connection pooling for external resources
- **REQUIRED** to use asynchronous I/O operations for all network calls
- **SHALL** implement proper caching strategies for frequently accessed resources
- **MUST** validate performance requirements before production deployment
- **NEVER** block the event loop with synchronous operations

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** implement request timeout and circuit breaker patterns
- **RECOMMENDED** to use streaming for large resource transfers
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
