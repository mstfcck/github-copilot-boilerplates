---
applyTo: '**'
---

# MCP Testing Strategy Guide

This document provides comprehensive testing guidelines for Model Context Protocol (MCP) applications following protocol specifications and industry best practices.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** test protocol compliance with official MCP specification
- **REQUIRED** to implement unit tests for all components (resources, tools, prompts)
- **SHALL** use official MCP test utilities and mock frameworks
- **MUST** validate transport layer functionality (STDIO, HTTP/SSE)
- **NEVER** skip integration testing with real protocol messages

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** implement comprehensive test coverage (minimum 80%)
- **RECOMMENDED** to use property-based testing for protocol edge cases
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
