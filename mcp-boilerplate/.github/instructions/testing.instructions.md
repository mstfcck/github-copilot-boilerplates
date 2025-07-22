---
applyTo: '**'
---
Testing instructions for FastMCP and FastAPI Model Context Protocol (MCP) applications.

# Testing Instructions

This document provides comprehensive testing guidelines for Model Context Protocol (MCP) applications using FastMCP framework and FastAPI integration.

## Requirements

### Critical Testing Requirements (**MUST** Follow)
- **MUST** use FastMCP in-memory testing for unit tests
- **REQUIRED** to test all MCP tools, resources, and prompts
- **SHALL** implement FastAPI TestClient for HTTP testing
- **MUST** achieve minimum 90% code coverage
- **NEVER** skip testing error handling and edge cases

### Strong Testing Recommendations (**SHOULD** Implement)
- **SHOULD** use pytest with async support for FastMCP testing
- **RECOMMENDED** to implement integration tests with real FastMCP clients
- **ALWAYS** test performance and load scenarios
- **DO** use property-based testing for complex data transformations
- **DON'T** rely solely on mocking for critical path testing

### Optional Testing Enhancements (**MAY** Consider)
- **MAY** implement end-to-end testing with FastAPI + FastMCP hybrid apps
- **OPTIONAL** to use Docker containers for integration testing
- **USE** FastAPI dependency overrides for testing isolation
- **IMPLEMENT** automated performance benchmarking
- **AVOID** testing implementation details over behavior

## FastMCP Testing Patterns

**IMPLEMENT** these testing strategies:

### FastMCP Unit Testing
```python
"""
FastMCP unit testing with in-memory patterns.
"""
import pytest
from fastmcp import FastMCP, Client
from typing import List, Dict, Any
import asyncio

# Test server setup
@pytest.fixture
def analysis_server():
    """Create FastMCP server for testing."""
    mcp = FastMCP("test-analysis-server")
    
    @mcp.tool
    async def analyze_data(data: List[float], method: str = "mean") -> Dict[str, Any]:
        """Tool for data analysis testing."""
        if not data:
            raise ValueError("Data cannot be empty")
        
        if method == "mean":
            return {"result": sum(data) / len(data), "method": method}
        elif method == "sum":
            return {"result": sum(data), "method": method}
        else:
            raise ValueError(f"Unknown method: {method}")
    
    @mcp.resource("data://config")
    async def get_config() -> Dict[str, Any]:
        """Resource for configuration testing."""
        return {
            "version": "1.0.0",
            "features": ["analysis", "reporting"],
            "limits": {"max_data_points": 1000}
        }
    
    @mcp.prompt("analysis")
    async def analysis_prompt(data_type: str = "numeric") -> str:
        """Prompt for analysis testing."""
        return f"Analyze the {data_type} data using statistical methods."
    
    return mcp

@pytest.fixture
async def test_client(analysis_server):
    """Create test client for FastMCP server."""
    async with Client(analysis_server) as client:
        yield client

# Tool testing
@pytest.mark.asyncio
async def test_analyze_data_mean(test_client):
    """Test data analysis tool with mean method."""
    result = await test_client.call_tool(
        "analyze_data",
        {"data": [1.0, 2.0, 3.0, 4.0, 5.0], "method": "mean"}
    )
    
    assert result.data["result"] == 3.0
    assert result.data["method"] == "mean"

@pytest.mark.asyncio
async def test_analyze_data_sum(test_client):
    """Test data analysis tool with sum method."""
    result = await test_client.call_tool(
        "analyze_data",
        {"data": [1.0, 2.0, 3.0], "method": "sum"}
    )
    
    assert result.data["result"] == 6.0
    assert result.data["method"] == "sum"

@pytest.mark.asyncio
async def test_analyze_data_empty_error(test_client):
    """Test error handling for empty data."""
    with pytest.raises(Exception) as exc_info:
        await test_client.call_tool("analyze_data", {"data": []})
    
    assert "Data cannot be empty" in str(exc_info.value)

@pytest.mark.asyncio
async def test_analyze_data_invalid_method(test_client):
    """Test error handling for invalid method."""
    with pytest.raises(Exception) as exc_info:
        await test_client.call_tool(
            "analyze_data",
            {"data": [1.0, 2.0], "method": "invalid"}
        )
    
    assert "Unknown method: invalid" in str(exc_info.value)

# Resource testing
@pytest.mark.asyncio
async def test_get_config_resource(test_client):
    """Test configuration resource."""
    result = await test_client.get_resource("data://config")
    
    assert result.data["version"] == "1.0.0"
    assert "analysis" in result.data["features"]
    assert result.data["limits"]["max_data_points"] == 1000

# Prompt testing
@pytest.mark.asyncio
async def test_analysis_prompt_default(test_client):
    """Test analysis prompt with default parameter."""
    result = await test_client.get_prompt("analysis")
    
    assert "Analyze the numeric data" in result.data

@pytest.mark.asyncio
async def test_analysis_prompt_custom(test_client):
    """Test analysis prompt with custom parameter."""
    result = await test_client.get_prompt("analysis", {"data_type": "categorical"})
    
    assert "Analyze the categorical data" in result.data

# Parameterized testing
@pytest.mark.parametrize("data,expected", [
    ([1.0, 2.0, 3.0], 2.0),
    ([0.0], 0.0),
    ([10.0, 20.0], 15.0),
    ([-1.0, 1.0], 0.0)
])
@pytest.mark.asyncio
async def test_analyze_data_various_inputs(test_client, data, expected):
    """Test data analysis with various inputs."""
    result = await test_client.call_tool("analyze_data", {"data": data})
    assert result.data["result"] == expected

# Property-based testing
from hypothesis import given, strategies as st

@given(st.lists(st.floats(min_value=-1000, max_value=1000), min_size=1, max_size=100))
@pytest.mark.asyncio
async def test_analyze_data_property_based(test_client, data):
    """Property-based test for data analysis."""
    # Filter out NaN and infinite values
    clean_data = [x for x in data if not (x != x or abs(x) == float('inf'))]
    
    if clean_data:
        result = await test_client.call_tool("analyze_data", {"data": clean_data})
        
        # Properties that should always hold
        assert isinstance(result.data["result"], (int, float))
        assert result.data["method"] == "mean"
        
        # Mean should be within the range of input data
        min_val, max_val = min(clean_data), max(clean_data)
        assert min_val <= result.data["result"] <= max_val
```

### FastAPI Testing Integration
```python
"""
FastAPI + FastMCP integration testing.
"""
import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from fastmcp import FastMCP
from typing import Dict, Any
import asyncio

# Test application setup
def create_test_app():
    """Create test FastAPI + FastMCP application."""
    app = FastAPI(title="Test API")
    
    # Create FastMCP server from FastAPI
    mcp = FastMCP.from_fastapi(
        app=app,
        name="TestHybridServer",
        httpx_client_kwargs={"timeout": 10.0}
    )
    
    # Add MCP tools
    @mcp.tool
    async def process_api_data(
        endpoint: str,
        data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Process API data through MCP tool."""
        return {
            "endpoint": endpoint,
            "processed_data": data,
            "status": "processed"
        }
    
    # Add FastAPI endpoints
    @app.get("/health")
    async def health_check():
        return {"status": "healthy"}
    
    @app.post("/process")
    async def process_data(data: Dict[str, Any]):
        # Use MCP tool from FastAPI endpoint
        result = await process_api_data("internal", data)
        return {"api_result": result}
    
    return app, mcp

@pytest.fixture
def test_app():
    """Create test application."""
    app, mcp = create_test_app()
    return app, mcp

@pytest.fixture
def fastapi_client(test_app):
    """Create FastAPI test client."""
    app, _ = test_app
    return TestClient(app)

@pytest.fixture
async def mcp_client(test_app):
    """Create MCP test client."""
    _, mcp = test_app
    async with Client(mcp) as client:
        yield client

# FastAPI endpoint testing
def test_health_endpoint(fastapi_client):
    """Test FastAPI health endpoint."""
    response = fastapi_client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_process_endpoint(fastapi_client):
    """Test FastAPI process endpoint."""
    test_data = {"value": 42, "type": "number"}
    response = fastapi_client.post("/process", json=test_data)
    
    assert response.status_code == 200
    result = response.json()
    assert result["api_result"]["status"] == "processed"
    assert result["api_result"]["processed_data"] == test_data

# MCP tool testing
@pytest.mark.asyncio
async def test_process_api_data_tool(mcp_client):
    """Test MCP tool functionality."""
    result = await mcp_client.call_tool(
        "process_api_data",
        {"endpoint": "test", "data": {"key": "value"}}
    )
    
    assert result.data["endpoint"] == "test"
    assert result.data["processed_data"]["key"] == "value"
    assert result.data["status"] == "processed"

# Integration testing
@pytest.mark.asyncio
async def test_full_integration(test_app):
    """Test full FastAPI + MCP integration."""
    app, mcp = test_app
    
    # Test FastAPI side
    with TestClient(app) as fastapi_client:
        response = fastapi_client.post(
            "/process",
            json={"integration": "test", "value": 123}
        )
        assert response.status_code == 200
    
    # Test MCP side
    async with Client(mcp) as mcp_client:
        result = await mcp_client.call_tool(
            "process_api_data",
            {"endpoint": "integration", "data": {"test": True}}
        )
        assert result.data["status"] == "processed"
```

### Database Testing with FastMCP
```python
"""
Database testing patterns for FastMCP applications.
"""
import pytest
import pytest_asyncio
from fastmcp import FastMCP
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import aiosqlite

Base = declarative_base()

class TestData(Base):
    """Test database model."""
    __tablename__ = 'test_data'
    
    id = Column(Integer, primary_key=True)
    name = Column(String(50))
    value = Column(Integer)

@pytest_asyncio.fixture
async def test_db():
    """Create test database."""
    engine = create_async_engine(
        "sqlite+aiosqlite:///:memory:",
        echo=True
    )
    
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )
    
    yield async_session
    
    await engine.dispose()

@pytest.fixture
def db_server(test_db):
    """Create FastMCP server with database operations."""
    mcp = FastMCP("test-db-server")
    
    @mcp.tool
    async def create_record(name: str, value: int) -> Dict[str, Any]:
        """Create a database record."""
        async with test_db() as session:
            record = TestData(name=name, value=value)
            session.add(record)
            await session.commit()
            await session.refresh(record)
            
            return {
                "id": record.id,
                "name": record.name,
                "value": record.value
            }
    
    @mcp.tool
    async def get_record(record_id: int) -> Dict[str, Any]:
        """Get a database record by ID."""
        async with test_db() as session:
            record = await session.get(TestData, record_id)
            
            if record:
                return {
                    "id": record.id,
                    "name": record.name,
                    "value": record.value
                }
            else:
                raise ValueError(f"Record with id {record_id} not found")
    
    return mcp

@pytest.mark.asyncio
async def test_database_operations(db_server):
    """Test database operations through MCP tools."""
    async with Client(db_server) as client:
        # Create record
        create_result = await client.call_tool(
            "create_record",
            {"name": "test_item", "value": 42}
        )
        
        assert create_result.data["name"] == "test_item"
        assert create_result.data["value"] == 42
        record_id = create_result.data["id"]
        
        # Get record
        get_result = await client.call_tool(
            "get_record",
            {"record_id": record_id}
        )
        
        assert get_result.data["id"] == record_id
        assert get_result.data["name"] == "test_item"
        assert get_result.data["value"] == 42

@pytest.mark.asyncio
async def test_database_error_handling(db_server):
    """Test database error handling."""
    async with Client(db_server) as client:
        with pytest.raises(Exception) as exc_info:
            await client.call_tool("get_record", {"record_id": 99999})
        
        assert "Record with id 99999 not found" in str(exc_info.value)
```

### Performance Testing
```python
"""
Performance testing for FastMCP applications.
"""
import pytest
import asyncio
import time
from fastmcp import FastMCP, Client
from typing import List, Dict, Any
import statistics

@pytest.fixture
def performance_server():
    """Create FastMCP server for performance testing."""
    mcp = FastMCP("performance-test-server")
    
    @mcp.tool
    async def fast_operation(data: List[int]) -> Dict[str, Any]:
        """Fast operation for performance testing."""
        return {"sum": sum(data), "count": len(data)}
    
    @mcp.tool
    async def slow_operation(delay: float = 0.1) -> Dict[str, Any]:
        """Slow operation for performance testing."""
        await asyncio.sleep(delay)
        return {"completed": True, "delay": delay}
    
    return mcp

@pytest.mark.asyncio
async def test_response_time_performance(performance_server):
    """Test response time performance."""
    async with Client(performance_server) as client:
        start_time = time.time()
        
        result = await client.call_tool(
            "fast_operation",
            {"data": list(range(1000))}
        )
        
        response_time = time.time() - start_time
        
        assert result.data["count"] == 1000
        assert response_time < 0.1  # Should complete in under 100ms

@pytest.mark.asyncio
async def test_concurrent_performance(performance_server):
    """Test concurrent request performance."""
    async with Client(performance_server) as client:
        
        async def make_request():
            return await client.call_tool(
                "fast_operation",
                {"data": [1, 2, 3, 4, 5]}
            )
        
        start_time = time.time()
        
        # Make 100 concurrent requests
        tasks = [make_request() for _ in range(100)]
        results = await asyncio.gather(*tasks)
        
        total_time = time.time() - start_time
        
        assert len(results) == 100
        assert all(r.data["sum"] == 15 for r in results)
        assert total_time < 2.0  # Should complete in under 2 seconds

@pytest.mark.asyncio
async def test_load_testing(performance_server):
    """Test server load capacity."""
    async with Client(performance_server) as client:
        
        response_times = []
        
        for _ in range(50):
            start_time = time.time()
            
            await client.call_tool(
                "fast_operation",
                {"data": list(range(100))}
            )
            
            response_time = time.time() - start_time
            response_times.append(response_time)
        
        # Calculate performance metrics
        avg_response_time = statistics.mean(response_times)
        p95_response_time = statistics.quantiles(response_times, n=20)[18]  # 95th percentile
        
        assert avg_response_time < 0.05  # Average under 50ms
        assert p95_response_time < 0.1   # 95th percentile under 100ms
```

## Testing Configuration

**USE** these testing configurations:

### Pytest Configuration (conftest.py)
```python
"""
Pytest configuration for FastMCP testing.
"""
import pytest
import asyncio
from typing import Generator
import logging

# Configure logging for tests
logging.basicConfig(level=logging.INFO)

# Async test support
@pytest.fixture(scope="session")
def event_loop() -> Generator:
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()

# Test markers
pytest_plugins = ["pytest_asyncio"]

def pytest_configure(config):
    """Configure pytest markers."""
    config.addinivalue_line(
        "markers", "unit: mark test as a unit test"
    )
    config.addinivalue_line(
        "markers", "integration: mark test as an integration test"
    )
    config.addinivalue_line(
        "markers", "performance: mark test as a performance test"
    )
    config.addinivalue_line(
        "markers", "slow: mark test as slow running"
    )

# Common test fixtures
@pytest.fixture
def mock_external_api():
    """Mock external API responses."""
    return {
        "status": "success",
        "data": {"value": 42}
    }

@pytest.fixture
async def cleanup_temp_files():
    """Cleanup temporary files after tests."""
    temp_files = []
    
    yield temp_files
    
    # Cleanup
    for file_path in temp_files:
        try:
            import os
            os.remove(file_path)
        except FileNotFoundError:
            pass
```

### pytest.ini Configuration
```ini
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = 
    --strict-markers
    --strict-config
    --asyncio-mode=auto
    --cov=src
    --cov-report=term-missing
    --cov-report=html
    --cov-fail-under=90
markers =
    unit: Unit tests
    integration: Integration tests
    performance: Performance tests
    slow: Slow running tests
asyncio_mode = auto
```

## Testing Best Practices

**FOLLOW** these testing best practices:

### Test Organization
- Separate unit, integration, and performance tests
- Use descriptive test names that explain the scenario
- Group related tests in test classes
- Use fixtures for common setup and teardown

### FastMCP-Specific Testing
- Always use FastMCP Client for testing tools and resources
- Test both success and error scenarios
- Use parameterized tests for testing multiple inputs
- Test async behavior and concurrency

### FastAPI Integration Testing
- Use TestClient for HTTP endpoint testing
- Test dependency injection and middleware
- Verify request/response serialization
- Test authentication and authorization

### Performance Testing
- Set clear performance benchmarks
- Test under various load conditions
- Monitor resource usage during tests
- Use profiling tools for optimization

### Error Testing
- Test all error conditions and edge cases
- Verify proper error messages and status codes
- Test error handling in async contexts
- Test resource cleanup after failures

## Quality Metrics

**ACHIEVE** these testing quality metrics:

### Coverage Requirements
- Code coverage: >90%
- Branch coverage: >85%
- Function coverage: 100%
- Critical path coverage: 100%

### Performance Benchmarks
- Unit test execution: <10ms average
- Integration test execution: <1s average
- Test suite completion: <5 minutes
- Performance test baseline: Document and maintain

### Test Reliability
- Flaky test rate: <1%
- Test failure investigation: <24 hours
- Test maintenance: Regular updates with code changes
- CI/CD integration: All tests must pass before deployment

## References

- [FastMCP Testing Guide](https://gofastmcp.com/testing) - Framework-specific testing patterns
- [FastAPI Testing](https://fastapi.tiangolo.com/tutorial/testing/) - Web framework testing
- [Pytest Documentation](https://docs.pytest.org/) - Testing framework reference
- [MCP Instructions](./mcp.instructions.md) - Comprehensive FastMCP and FastAPI documentation
- [Performance Instructions](./performance.instructions.md) - Performance testing guidelines
- **ALWAYS** test error handling and protocol compliance
- **DO** implement end-to-end testing with real language models
- **DON'T** rely solely on unit tests without integration testing

### Optional Enhancements (**MAY** Consider)
- **MAY** implement performance testing for high-throughput scenarios
- **OPTIONAL** to add chaos engineering tests for resilience
- **USE** automated security testing tools
- **IMPLEMENT** contract testing for client-server interactions
- **AVOID** testing implementation details over protocol behavior

## Testing Pyramid Structure

### Unit Tests (70% of tests)
**PURPOSE**: Test individual components in isolation
**SCOPE**: Resources, tools, prompts, validators, handlers
**REQUIREMENTS**:
- Test each MCP component independently
- Mock external dependencies and transport layers
- Validate input/output schemas and transformations
- Test error handling and edge cases

```python
# Python Unit Test Example
import pytest
from unittest.mock import Mock, AsyncMock
from mcp.server import Server
import mcp.types as types

class TestMCPResourceProvider:
    def setup_method(self):
        self.server = Server("test-server")
        self.resource_provider = ResourceProvider()
    
    @pytest.mark.asyncio
    async def test_list_resources_success(self):
        """Test successful resource listing"""
        # Given
        expected_resources = [
            types.Resource(
                uri="test://resource/1",
                name="Test Resource",
                description="A test resource"
            )
        ]
        
        # When
        resources = await self.resource_provider.list_resources()
        
        # Then
        assert len(resources) == 1
        assert resources[0].name == "Test Resource"
        assert resources[0].uri == "test://resource/1"
    
    @pytest.mark.asyncio
    async def test_read_resource_not_found(self):
        """Test resource not found error"""
        # Given
        invalid_uri = "test://resource/nonexistent"
        
        # When & Then
        with pytest.raises(ValueError, match="Resource not found"):
            await self.resource_provider.read_resource(invalid_uri)
    
    @pytest.mark.asyncio
    async def test_resource_input_validation(self):
        """Test resource input validation"""
        # Given
        invalid_uri = ""
        
        # When & Then
        with pytest.raises(ValueError, match="URI cannot be empty"):
            await self.resource_provider.read_resource(invalid_uri)
```

```typescript
// TypeScript Unit Test Example
import { describe, it, expect, jest } from '@jest/globals';
import { MCPToolRegistry } from '../src/tools/registry';

describe('MCPToolRegistry', () => {
    let registry: MCPToolRegistry;
    
    beforeEach(() => {
        registry = new MCPToolRegistry();
    });
    
    it('should register and list tools correctly', () => {
        // Given
        const tool = {
            name: 'calculator',
            description: 'Perform calculations',
            inputSchema: {
                type: 'object',
                properties: {
                    expression: { type: 'string' }
                },
                required: ['expression']
            },
            handler: jest.fn()
        };
        
        // When
        registry.registerTool(tool);
        const tools = registry.listTools();
        
        // Then
        expect(tools).toHaveLength(1);
        expect(tools[0].name).toBe('calculator');
        expect(tools[0].description).toBe('Perform calculations');
    });
    
    it('should validate tool input schema', async () => {
        // Given
        const tool = {
            name: 'calculator',
            description: 'Perform calculations',
            inputSchema: {
                type: 'object',
                properties: {
                    expression: { type: 'string' }
                },
                required: ['expression']
            },
            handler: jest.fn().mockResolvedValue({ result: '42' })
        };
        
        registry.registerTool(tool);
        
        // When
        const result = await registry.callTool('calculator', { expression: '2+2' });
        
        // Then
        expect(result).toEqual({ result: '42' });
        expect(tool.handler).toHaveBeenCalledWith({ expression: '2+2' });
    });
    
    it('should throw error for invalid tool input', async () => {
        // Given
        const tool = {
            name: 'calculator',
            description: 'Perform calculations',
            inputSchema: {
                type: 'object',
                properties: {
                    expression: { type: 'string' }
                },
                required: ['expression']
            },
            handler: jest.fn()
        };
        
        registry.registerTool(tool);
        
        // When & Then
        await expect(registry.callTool('calculator', {})).rejects.toThrow();
    });
});
```

### Integration Tests (20% of tests)
**PURPOSE**: Test component interactions and protocol compliance
**SCOPE**: Transport layers, protocol message handling, SDK integration
**REQUIREMENTS**:
- Test MCP protocol message exchanges
- Use real transport implementations
- Test client-server interactions
- Validate protocol compliance

```python
# Python Integration Test Example
import pytest
import asyncio
from mcp.client import Client
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.client.stdio import stdio_client

class TestMCPProtocolIntegration:
    @pytest.mark.asyncio
    async def test_client_server_resource_exchange(self):
        """Test complete client-server resource exchange"""
        # Setup server
        server = Server("test-server")
        
        @server.list_resources()
        async def list_resources():
            return [
                types.Resource(
                    uri="test://resource/1",
                    name="Test Resource",
                    description="Integration test resource"
                )
            ]
        
        @server.read_resource()
        async def read_resource(uri: str):
            if uri == "test://resource/1":
                return types.TextResourceContents(
                    uri=uri,
                    text="Test content"
                )
            raise ValueError("Resource not found")
        
        # Setup client and server communication
        server_params = StdioServerParameters(
            command="python",
            args=["-c", "import asyncio; asyncio.run(server.run())"]
        )
        
        async with stdio_client(server_params) as streams:
            client = Client({
                "name": "test-client",
                "version": "1.0.0"
            }, {
                "capabilities": {}
            })
            
            await client.connect(streams)
            
            # Test resource listing
            resources = await client.list_resources()
            assert len(resources) == 1
            assert resources[0].name == "Test Resource"
            
            # Test resource reading
            content = await client.read_resource("test://resource/1")
            assert content.text == "Test content"
    
    @pytest.mark.asyncio
    async def test_tool_invocation_integration(self):
        """Test complete tool invocation flow"""
        server = Server("test-server")
        
        @server.list_tools()
        async def list_tools():
            return [
                types.Tool(
                    name="echo",
                    description="Echo input text",
                    inputSchema={
                        "type": "object",
                        "properties": {
                            "text": {"type": "string"}
                        },
                        "required": ["text"]
                    }
                )
            ]
        
        @server.call_tool()
        async def call_tool(name: str, arguments: dict):
            if name == "echo":
                return [types.TextContent(
                    type="text",
                    text=f"Echo: {arguments.get('text', '')}"
                )]
            raise ValueError(f"Unknown tool: {name}")
        
        # Test tool invocation through protocol
        result = await call_tool("echo", {"text": "Hello MCP"})
        assert len(result) == 1
        assert result[0].text == "Echo: Hello MCP"
```

### Protocol Compliance Tests (10% of tests)
**PURPOSE**: Validate MCP protocol specification compliance
**SCOPE**: Message formats, transport behaviors, error handling
**REQUIREMENTS**:
- Test protocol message schemas
- Validate transport layer compliance
- Test error code conformance
- Verify specification adherence

```java
// Java Protocol Compliance Test
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

public class MCPProtocolComplianceTest {
    private MCPServer server;
    private MCPClient client;
    
    @BeforeEach
    void setUp() {
        server = new MCPServer("test-server", "1.0.0");
        client = new MCPClient("test-client", "1.0.0");
    }
    
    @Test
    void testInitializationProtocol() {
        // Test MCP initialization sequence
        var initRequest = new InitializeRequest(
            "test-client",
            "1.0.0",
            new ClientCapabilities(true, true, true)
        );
        
        var initResponse = server.handleInitialize(initRequest);
        
        // Verify protocol compliance
        assertNotNull(initResponse.getServerInfo());
        assertNotNull(initResponse.getCapabilities());
        assertEquals("2024-11-05", initResponse.getProtocolVersion());
        
        // Test that server capabilities are properly declared
        var capabilities = initResponse.getCapabilities();
        if (capabilities.hasResources()) {
            assertTrue(server.hasResourceHandlers());
        }
        if (capabilities.hasTools()) {
            assertTrue(server.hasToolHandlers());
        }
    }
    
    @Test
    void testErrorCodeCompliance() {
        // Test that server returns proper MCP error codes
        var invalidRequest = new Request("invalid_method", null);
        
        var response = server.handleRequest(invalidRequest);
        
        // Should return METHOD_NOT_FOUND error
        assertTrue(response.isError());
        assertEquals(-32601, response.getError().getCode());
        assertNotNull(response.getError().getMessage());
    }
    
    @Test
    void testResourceProtocolCompliance() {
        // Register a test resource
        server.addResource(new Resource(
            "test://resource/1",
            "Test Resource",
            "Test Description"
        ));
        
        // Test list resources protocol
        var listRequest = new ListResourcesRequest();
        var listResponse = server.handleListResources(listRequest);
        
        assertFalse(listResponse.isError());
        assertEquals(1, listResponse.getResult().getResources().size());
        
        var resource = listResponse.getResult().getResources().get(0);
        assertEquals("test://resource/1", resource.getUri());
        assertEquals("Test Resource", resource.getName());
        assertEquals("Test Description", resource.getDescription());
    }
}
```

## Testing Specific Components

### Transport Layer Tests
**FOCUS** on transport mechanisms and protocol compliance:
```python
# Python Transport Layer Tests
import pytest
from unittest.mock import Mock, patch
import asyncio

class TestMCPTransportLayer:
    @pytest.mark.asyncio
    async def test_stdio_transport_message_exchange(self):
        """Test STDIO transport message exchange"""
        # Mock stdin/stdout
        mock_stdin = Mock()
        mock_stdout = Mock()
        
        transport = StdioTransport(mock_stdin, mock_stdout)
        
        # Test message sending
        message = {
            "jsonrpc": "2.0",
            "method": "resources/list",
            "id": 1
        }
        
        await transport.send_message(message)
        
        # Verify message format
        mock_stdout.write.assert_called_once()
        sent_data = mock_stdout.write.call_args[0][0]
        assert b'"jsonrpc": "2.0"' in sent_data
        assert b'"method": "resources/list"' in sent_data
    
    @pytest.mark.asyncio
    async def test_http_sse_transport_connection(self):
        """Test HTTP/SSE transport connection"""
        with patch('aiohttp.ClientSession') as mock_session:
            mock_response = Mock()
            mock_response.status = 200
            mock_session.return_value.__aenter__.return_value.get.return_value = mock_response
            
            transport = HttpSseTransport("http://localhost:8080")
            
            await transport.connect()
            
            # Verify connection establishment
            mock_session.return_value.__aenter__.return_value.get.assert_called_once()
```

### Security Tests
**TEST** authentication, authorization, and input validation:
```typescript
// TypeScript Security Tests
describe('MCP Security Tests', () => {
    let server: MCPServer;
    let authenticator: MCPAuthenticator;
    
    beforeEach(() => {
        server = new MCPServer();
        authenticator = new MCPAuthenticator();
    });
    
    it('should validate JWT tokens properly', async () => {
        // Given
        const validToken = await authenticator.generateToken('client1');
        const invalidToken = 'invalid.token.here';
        
        // When & Then
        expect(authenticator.validateToken(validToken)).toBeTruthy();
        expect(authenticator.validateToken(invalidToken)).toBeFalsy();
    });
    
    it('should enforce rate limiting', async () => {
        // Given
        const rateLimiter = new RateLimiter(2); // 2 requests per minute
        
        // When
        const request1 = rateLimiter.isAllowed('client1', 'tool:calculator');
        const request2 = rateLimiter.isAllowed('client1', 'tool:calculator');
        const request3 = rateLimiter.isAllowed('client1', 'tool:calculator');
        
        // Then
        expect(request1).toBeTruthy();
        expect(request2).toBeTruthy();
        expect(request3).toBeFalsy();
    });
    
    it('should sanitize input properly', () => {
        // Given
        const validator = new InputValidator();
        const maliciousInput = {
            command: 'rm -rf /',
            script: '<script>alert("xss")</script>'
        };
        
        // When
        const sanitized = validator.sanitizeInput(maliciousInput);
        
        // Then
        expect(sanitized.command).not.toContain('rm -rf');
        expect(sanitized.script).not.toContain('<script>');
    });
});
```

### Performance Tests
**VALIDATE** performance characteristics and resource usage:
```python
# Python Performance Tests
import pytest
import asyncio
import time
from concurrent.futures import ThreadPoolExecutor

class TestMCPPerformance:
    @pytest.mark.asyncio
    async def test_concurrent_resource_access(self):
        """Test concurrent resource access performance"""
        server = Server("performance-test-server")
        
        @server.list_resources()
        async def list_resources():
            # Simulate some work
            await asyncio.sleep(0.01)
            return [types.Resource(
                uri="test://resource/1",
                name="Performance Test Resource"
            )]
        
        # Test concurrent access
        start_time = time.time()
        tasks = [server.handle_list_resources() for _ in range(100)]
        results = await asyncio.gather(*tasks)
        end_time = time.time()
        
        # Verify performance
        assert len(results) == 100
        assert end_time - start_time < 5.0  # Should complete within 5 seconds
    
    @pytest.mark.asyncio
    async def test_tool_invocation_performance(self):
        """Test tool invocation performance under load"""
        server = Server("performance-test-server")
        invocation_count = 0
        
        @server.call_tool()
        async def call_tool(name: str, arguments: dict):
            nonlocal invocation_count
            invocation_count += 1
            return [types.TextContent(
                type="text",
                text=f"Result {invocation_count}"
            )]
        
        # Test high-frequency tool calls
        start_time = time.time()
        tasks = [
            server.handle_call_tool("test_tool", {"param": i})
            for i in range(1000)
        ]
        await asyncio.gather(*tasks)
        end_time = time.time()
        
        # Verify performance metrics
        assert invocation_count == 1000
        throughput = 1000 / (end_time - start_time)
        assert throughput > 100  # Should handle at least 100 calls/second
```

## Test Configuration Best Practices

### Test Environment Setup
**USE** proper test configuration:
```yaml
# test-config.yaml
test:
  mcp:
    server:
      name: "test-mcp-server"
      version: "1.0.0-test"
      capabilities:
        resources:
          subscribe: true
        tools: {}
        prompts: {}
    
    transport:
      type: "stdio"
      timeout: 30
    
    logging:
      level: "DEBUG"
      format: "structured"
    
    security:
      auth_required: false
      rate_limiting: false
      input_validation: true
```

### Test Data Management
**IMPLEMENT** proper test data patterns:
```python
# Python Test Data Management
import pytest
from typing import Dict, Any

class TestDataFactory:
    @staticmethod
    def create_test_resource(uri: str = "test://resource/1", **kwargs) -> types.Resource:
        """Create test resource with default values"""
        defaults = {
            "name": "Test Resource",
            "description": "A test resource",
            "mimeType": "text/plain"
        }
        defaults.update(kwargs)
        
        return types.Resource(
            uri=uri,
            name=defaults["name"],
            description=defaults["description"],
            mimeType=defaults["mimeType"]
        )
    
    @staticmethod
    def create_test_tool(name: str = "test_tool", **kwargs) -> types.Tool:
        """Create test tool with default values"""
        defaults = {
            "description": "A test tool",
            "inputSchema": {
                "type": "object",
                "properties": {
                    "input": {"type": "string"}
                },
                "required": ["input"]
            }
        }
        defaults.update(kwargs)
        
        return types.Tool(
            name=name,
            description=defaults["description"],
            inputSchema=defaults["inputSchema"]
        )
    
    @staticmethod
    def create_test_message(method: str, **kwargs) -> Dict[str, Any]:
        """Create test protocol message"""
        defaults = {
            "jsonrpc": "2.0",
            "id": 1,
            "params": {}
        }
        defaults.update(kwargs)
        
        return {
            "jsonrpc": defaults["jsonrpc"],
            "method": method,
            "id": defaults["id"],
            "params": defaults["params"]
        }

# Usage in tests
@pytest.fixture
def test_resource():
    return TestDataFactory.create_test_resource()

@pytest.fixture
def test_tool():
    return TestDataFactory.create_test_tool()
```

## Test Coverage Requirements

### Coverage Metrics
**MINIMUM** coverage requirements:
- **Overall**: 80% line coverage for MCP applications
- **Protocol Components**: 95% line coverage for core protocol handling
- **Security Components**: 100% line coverage for authentication/authorization
- **Transport Layer**: 90% line coverage for message handling
- **Error Handling**: 95% line coverage for error scenarios

### Coverage Tools Configuration
**USE** appropriate coverage tools:
```yaml
# Python coverage configuration (.coveragerc)
[run]
source = src/
omit = 
    */tests/*
    */venv/*
    */migrations/*
    */settings/*

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:

[html]
directory = htmlcov

[xml]
output = coverage.xml
```

```json
// TypeScript/JavaScript coverage configuration (jest.config.js)
{
  "collectCoverage": true,
  "coverageDirectory": "coverage",
  "coverageReporters": ["text", "lcov", "html"],
  "coverageThreshold": {
    "global": {
      "branches": 80,
      "functions": 80,
      "lines": 80,
      "statements": 80
    },
    "src/protocol/": {
      "branches": 95,
      "functions": 95,
      "lines": 95,
      "statements": 95
    }
  },
  "collectCoverageFrom": [
    "src/**/*.{ts,js}",
    "!src/**/*.d.ts",
    "!src/tests/**/*"
  ]
}
```

## Testing Anti-Patterns to Avoid

**DON'T**:
- Test implementation details instead of protocol behavior
- Create tests that depend on external services without proper mocking
- Write overly complex tests that are hard to understand
- Test multiple unrelated behaviors in a single test
- Use Thread.sleep() or arbitrary delays in async tests
- Ignore flaky tests or intermittent failures
- Test private methods directly instead of testing through public interfaces
- Create tests without clear arrange-act-assert structure

**DO**:
- Test public protocol APIs and contracts
- Use proper mocking for external dependencies
- Keep tests simple and focused on single behaviors
- Follow the single responsibility principle for tests
- Use proper async/await patterns for concurrent testing
- Fix or delete flaky tests immediately
- Test behavior through public protocol interfaces
- Structure tests clearly with given-when-then or arrange-act-assert patterns

## Validation Checklist

**MUST** verify:
- [ ] Protocol compliance tested with official MCP test utilities
- [ ] Unit tests cover all components with minimum 80% coverage
- [ ] Integration tests validate client-server protocol exchanges
- [ ] Security tests verify authentication and input validation
- [ ] Error handling tests cover all protocol error scenarios
- [ ] Performance tests validate throughput and latency requirements
- [ ] Transport layer tests cover STDIO and HTTP/SSE transports

**SHOULD** check:
- [ ] Property-based testing used for protocol edge cases
- [ ] Test data factories used for consistent test setup
- [ ] Comprehensive mocking for external dependencies
- [ ] Async/await patterns properly tested
- [ ] Test configuration externalized and environment-specific
- [ ] Coverage reports generated and monitored
- [ ] Test documentation explains testing strategy

## References

- [MCP Protocol Specification](https://modelcontextprotocol.io/introduction)
- [MCP Testing Utilities](https://github.com/modelcontextprotocol)
- [pytest Documentation](https://docs.pytest.org/)
- [Jest Testing Framework](https://jestjs.io/)
- [JUnit 5 Documentation](https://junit.org/junit5/)
- [Property-Based Testing](https://hypothesis.readthedocs.io/)
- [Testing Best Practices](https://testingjavascript.com/)
