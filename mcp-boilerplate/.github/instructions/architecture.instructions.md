---
applyTo: '**'
---

# MCP Architecture Instructions

This document provides comprehensive architectural guidance for Model Context Protocol (MCP) applications using FastMCP framework and FastAPI integration patterns following modern best practices.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** use FastMCP framework as the primary MCP implementation approach
- **REQUIRED** to implement `FastMCP(name="ServerName")` server creation pattern
- **SHALL** use decorator-based component definition: `@mcp.tool`, `@mcp.resource`, `@mcp.prompt`
- **MUST** leverage automatic transport inference with `Client(server_source)`
- **NEVER** implement custom MCP protocol handling when FastMCP provides the functionality

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** use FastAPI integration patterns with `FastMCP.from_fastapi()`
- **RECOMMENDED** to implement server composition with `main.mount(sub, prefix="namespace")`
- **ALWAYS** use async/await patterns for all I/O operations
- **DO** implement FastAPI dependency injection patterns with `Depends()`
- **DON'T** create tightly coupled components between FastMCP and business logic

### Optional Enhancements (**MAY** Consider)
- **MAY** implement proxy patterns with `FastMCP.as_proxy(backend)`
- **OPTIONAL** to use in-memory transport for testing scenarios
- **USE** FastAPI middleware for cross-cutting concerns
- **IMPLEMENT** server composition for modular architectures
- **AVOID** premature optimization without FastMCP profiling

## FastMCP Architecture Patterns

**USE** these FastMCP architectural patterns:

### Core Server Architecture
```python
# FastMCP Server Architecture
from fastmcp import FastMCP
from typing import Optional
import asyncio

class FastMCPServerArchitecture:
    def __init__(self, name: str = "MyMCPServer"):
        self.mcp = FastMCP(
            name=name,
            instructions="""
            This server provides comprehensive data analysis capabilities.
            Use analyze_data() for statistical analysis.
            Access config via data://settings resource.
            """
        )
        self.setup_components()
    
    def setup_components(self):
        """Configure server components with decorators."""
        
        @self.mcp.tool
        async def analyze_data(
            data: list[float], 
            method: str = "statistical"
        ) -> dict:
            """Perform data analysis using specified method."""
            await asyncio.sleep(0.1)  # Simulate async operation
            
            if method == "statistical":
                return {
                    "mean": sum(data) / len(data),
                    "min": min(data),
                    "max": max(data),
                    "count": len(data)
                }
            return {"error": "Unsupported analysis method"}
        
        @self.mcp.resource("data://settings")
        async def get_settings() -> dict:
            """Provide server configuration settings."""
            return {
                "version": "2.0.0",
                "features": ["analysis", "reporting"],
                "limits": {"max_data_points": 10000}
            }
        
        @self.mcp.resource("reports://{report_id}")
        async def get_report(report_id: str) -> dict:
            """Get analysis report by ID."""
            return {
                "id": report_id,
                "status": "completed",
                "results": {"processed": True}
            }
        
        @self.mcp.prompt
        async def analysis_prompt(data_description: str) -> str:
            """Generate analysis prompt for LLM."""
            return f"""
            Please analyze the following data: {data_description}
            Provide insights on patterns, trends, and anomalies.
            Include statistical summary and recommendations.
            """
    
    async def run(self, transport: str = "stdio", **kwargs):
        """Run the FastMCP server."""
        self.mcp.run(transport=transport, **kwargs)
```

### FastAPI Integration Architecture
```python
# FastMCP + FastAPI Integration
from fastapi import FastAPI, Depends, HTTPException
from fastmcp import FastMCP
from typing import Annotated
import asyncio

# Create FastAPI app
app = FastAPI(title="Analysis API", version="1.0.0")

# Shared dependencies
async def get_database_session():
    """Simulated database dependency."""
    await asyncio.sleep(0.01)
    return {"session": "active", "db": "analytics"}

async def get_current_user(token: str = "default"):
    """Simulated authentication dependency."""
    if token == "invalid":
        raise HTTPException(status_code=401, detail="Invalid token")
    return {"user_id": 1, "username": "analyst"}

# FastAPI endpoints
@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "analysis-api"}

@app.post("/analyze")
async def analyze_endpoint(
    data: list[float],
    db: Annotated[dict, Depends(get_database_session)],
    user: Annotated[dict, Depends(get_current_user)]
):
    """FastAPI endpoint for data analysis."""
    return {
        "user": user["username"],
        "analysis": {"mean": sum(data) / len(data)},
        "db_session": db["session"]
    }

# Convert FastAPI to MCP server
mcp = FastMCP.from_fastapi(
    app=app,
    name="Analysis-API-MCP-Bridge",
    httpx_client_kwargs={"timeout": 30.0}
)

# Add MCP-specific tools that use FastAPI dependencies
@mcp.tool
async def get_user_analysis(
    data: list[float],
    user_token: str = "default"
) -> dict:
    """Analyze data for authenticated user."""
    # Reuse FastAPI dependency logic
    user = await get_current_user(user_token)
    db = await get_database_session()
    
    return {
        "user": user["username"],
        "analysis": {"mean": sum(data) / len(data)},
        "timestamp": "2024-01-01T00:00:00Z"
    }

if __name__ == "__main__":
    # Run as MCP server
    mcp.run(transport="http", port=8000)
    
    # Or run FastAPI directly:
    # import uvicorn
    # uvicorn.run(app, host="0.0.0.0", port=8000)
```

### Server Composition Architecture
```python
# FastMCP Server Composition
from fastmcp import FastMCP
import asyncio

class CompositeServerArchitecture:
    def __init__(self):
        self.main_server = FastMCP(name="MainAnalytics")
        self.setup_subservers()
        self.compose_servers()
    
    def setup_subservers(self):
        """Create specialized sub-servers."""
        
        # Data processing sub-server
        self.data_server = FastMCP(name="DataProcessor")
        
        @self.data_server.tool
        async def process_dataset(data: list[float]) -> dict:
            """Process raw dataset."""
            await asyncio.sleep(0.1)
            return {
                "processed": True,
                "size": len(data),
                "checksum": sum(data)
            }
        
        # Reporting sub-server
        self.report_server = FastMCP(name="ReportGenerator")
        
        @self.report_server.tool
        async def generate_report(analysis: dict) -> str:
            """Generate formatted report."""
            return f"Analysis Report: {analysis}"
        
        @self.report_server.resource("templates://report")
        async def get_report_template() -> str:
            """Get report template."""
            return "Report Template: {{title}} - {{content}}"
    
    async def compose_servers(self):
        """Compose sub-servers into main server."""
        
        # Mount sub-servers with prefixes
        await self.main_server.mount(
            self.data_server, 
            prefix="data"
        )
        
        await self.main_server.mount(
            self.report_server,
            prefix="reports"
        )
        
        # Main server tools that orchestrate sub-servers
        @self.main_server.tool
        async def full_analysis_workflow(data: list[float]) -> dict:
            """Complete analysis workflow using composed servers."""
            # This would use the mounted sub-servers
            return {
                "workflow": "completed",
                "data_processed": True,
                "report_generated": True
            }
    
    async def run(self):
        """Run the composed server."""
        await self.compose_servers()
        self.main_server.run()
```

### Client Architecture Patterns
```python
# FastMCP Client Architecture
from fastmcp import Client, FastMCP
import asyncio

class MCPClientArchitecture:
    def __init__(self):
        self.clients = {}
    
    async def setup_clients(self):
        """Setup various client connections."""
        
        # In-memory client for testing
        test_server = FastMCP("TestServer")
        
        @test_server.tool
        def test_operation() -> str:
            return "test result"
        
        self.clients["test"] = Client(test_server)
        
        # HTTP client for production
        self.clients["production"] = Client("https://api.example.com/mcp")
        
        # Local script client
        self.clients["local"] = Client("./analysis_server.py")
        
        # Configuration-based multi-server client
        config = {
            "mcpServers": {
                "analytics": {
                    "transport": "http",
                    "url": "https://analytics.example.com/mcp"
                },
                "reports": {
                    "transport": "stdio",
                    "command": "python",
                    "args": ["./report_server.py"]
                }
            }
        }
        self.clients["multi"] = Client(config)
    
    async def orchestrate_analysis(self, data: list[float]):
        """Orchestrate analysis across multiple servers."""
        results = {}
        
        # Use test client for validation
        async with self.clients["test"] as client:
            test_result = await client.call_tool("test_operation")
            results["validation"] = test_result
        
        # Use multi-server client for distributed processing
        async with self.clients["multi"] as client:
            # Analytics server (prefixed tools)
            analysis = await client.call_tool(
                "analytics_analyze_data", 
                {"data": data}
            )
            results["analysis"] = analysis
            
            # Reports server (prefixed tools)
            report = await client.call_tool(
                "reports_generate_report",
                {"analysis": analysis}
            )
            results["report"] = report
        
        return results
```

### Proxy Architecture Pattern
```python
# FastMCP Proxy Architecture
from fastmcp import FastMCP, Client
from fastmcp.server.proxy import ProxyClient
from fastmcp.client.auth import BearerAuth

class ProxyServerArchitecture:
    def __init__(self):
        self.setup_proxy_servers()
    
    def setup_proxy_servers(self):
        """Setup various proxy configurations."""
        
        # Basic proxy for remote server
        remote_backend = Client("https://remote-server.com/mcp")
        self.basic_proxy = FastMCP.as_proxy(
            remote_backend,
            name="RemoteProxy"
        )
        
        # Authenticated proxy
        auth_backend = Client(
            "https://secure-server.com/mcp",
            auth=BearerAuth(token="secret-token")
        )
        self.auth_proxy = FastMCP.as_proxy(
            auth_backend,
            name="SecureProxy"
        )
        
        # Advanced proxy with full MCP features
        advanced_backend = ProxyClient("advanced_backend.py")
        self.advanced_proxy = FastMCP.as_proxy(
            advanced_backend,
            name="AdvancedProxy"
        )
        
        # Transport bridging proxy (STDIO to HTTP)
        stdio_backend = ProxyClient("stdio_server.py")
        self.bridge_proxy = FastMCP.as_proxy(
            stdio_backend,
            name="TransportBridge"
        )
    
    async def run_proxy(self, proxy_type: str = "basic"):
        """Run specific proxy server."""
        proxy_map = {
            "basic": self.basic_proxy,
            "auth": self.auth_proxy,
            "advanced": self.advanced_proxy,
            "bridge": self.bridge_proxy
        }
        
        proxy = proxy_map.get(proxy_type, self.basic_proxy)
        proxy.run(transport="http", port=8080)
```

## FastAPI Advanced Patterns

**IMPLEMENT** these FastAPI integration patterns:

### Middleware Integration
```python
# FastAPI + FastMCP Middleware
from fastapi import FastAPI, Request
from fastapi.middleware.base import BaseHTTPMiddleware
from fastmcp import FastMCP
import time

class PerformanceMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        start_time = time.time()
        response = await call_next(request)
        process_time = time.time() - start_time
        response.headers["X-Process-Time"] = str(process_time)
        return response

app = FastAPI()
app.add_middleware(PerformanceMiddleware)

# Convert to MCP with middleware preserved
mcp = FastMCP.from_fastapi(app, name="Performance-Monitored-MCP")
```

### Background Tasks Integration
```python
# FastAPI Background Tasks with FastMCP
from fastapi import FastAPI, BackgroundTasks
from fastmcp import FastMCP

app = FastAPI()

def write_analysis_log(analysis_id: str, results: dict):
    """Background task for logging analysis results."""
    with open(f"logs/analysis_{analysis_id}.json", "w") as f:
        json.dump(results, f)

@app.post("/analyze-async")
async def async_analysis(
    data: list[float],
    background_tasks: BackgroundTasks
):
    """FastAPI endpoint with background processing."""
    analysis_id = str(uuid.uuid4())
    results = {"mean": sum(data) / len(data)}
    
    # Add background task
    background_tasks.add_task(write_analysis_log, analysis_id, results)
    
    return {"analysis_id": analysis_id, "status": "processing"}

# MCP server that uses FastAPI's background tasks
mcp = FastMCP.from_fastapi(app, name="Async-Analysis-MCP")
```

## Anti-Patterns to Avoid

**DON'T** implement these architectural approaches:

### ❌ Raw MCP SDK Architecture
```python
# WRONG - Don't use raw MCP SDK
from mcp.server import Server
from mcp.server.stdio import stdio_server

class BadMCPArchitecture:
    def __init__(self):
        self.server = Server("bad-server")  # ❌ Raw SDK
        self.setup_handlers()
    
    def setup_handlers(self):
        @self.server.call_tool()  # ❌ Raw protocol handling
        async def handle_tool(name: str, arguments: dict):
            # Custom protocol implementation
            pass
```

### ❌ Monolithic Server Design
```python
# WRONG - Don't create monolithic servers
class MonolithicMCPServer:
    def handle_everything(self, request):
        # ❌ Single handler for all operations
        if request.type == "tool":
            # Handle tools
        elif request.type == "resource":
            # Handle resources
        # ... all logic in one place
```

### ❌ Synchronous Operations
```python
# WRONG - Don't use blocking operations
@mcp.tool
def blocking_database_operation(query: str) -> dict:
    # ❌ Synchronous database call
    return database.execute_blocking(query)

# CORRECT - Use async operations
@mcp.tool
async def async_database_operation(query: str) -> dict:
    return await database.execute_async(query)
```

## Testing Architecture

**USE** FastMCP testing patterns:

### In-Memory Testing
```python
# FastMCP In-Memory Testing Architecture
import pytest
from fastmcp import FastMCP, Client

@pytest.fixture
def test_server():
    mcp = FastMCP("TestServer")
    
    @mcp.tool
    async def test_tool(value: int) -> int:
        return value * 2
    
    return mcp

async def test_server_functionality(test_server):
    """Test FastMCP server with in-memory transport."""
    async with Client(test_server) as client:
        result = await client.call_tool("test_tool", {"value": 5})
        assert result.data == 10
```

### Integration Testing
```python
# FastAPI + FastMCP Integration Testing
from fastapi.testclient import TestClient
from fastmcp import Client

def test_fastapi_mcp_integration():
    """Test FastAPI to MCP integration."""
    
    # Test FastAPI directly
    with TestClient(app) as fastapi_client:
        response = fastapi_client.get("/health")
        assert response.status_code == 200
    
    # Test MCP server from FastAPI
    async with Client(mcp) as mcp_client:
        tools = await mcp_client.list_tools()
        assert len(tools) > 0
```

## References

- [FastMCP Documentation](https://gofastmcp.com/) - Framework-specific patterns and best practices
- [FastAPI Documentation](https://fastapi.tiangolo.com/) - Web framework integration patterns
- [MCP Instructions](./mcp.instructions.md) - Comprehensive FastMCP and FastAPI documentation
- [MCP Protocol Specification](https://modelcontextprotocol.io/specification) - Protocol compliance reference
- [Coding Standards](./coding-standards.instructions.md) - FastMCP coding standards and patterns
        # Handle resources
    elif message.method == "tools/call":
        # Handle tools
    elif message.method == "prompts/get":
        # Handle prompts
    # This becomes unmaintainable
```

### Avoid Tight Coupling Between Layers
```typescript
// BAD - Tight coupling
class BadMCPServer {
    async handleResourceRequest(request: any) {
        // Directly accessing database in protocol handler
        const data = await database.query("SELECT * FROM resources");
        return this.formatResponse(data);
    }
}
```

**AVOID** these common architectural mistakes:

### Protocol Violations
```python
# BAD - Protocol violations
async def bad_resource_handler():
    # NEVER return non-compliant response format
    return {"data": "some data"}  # Missing required fields
    
    # NEVER ignore error handling
    resource = get_resource()  # Can throw exception
    return resource  # No error handling
```

### Improper State Management
```java
// BAD - Improper state management
public class BadMCPServer {
    private static Map<String, Object> globalState = new HashMap<>();
    
    // NEVER use global mutable state
    public void handleRequest(Request request) {
        globalState.put("lastRequest", request);
    }
}
```

**NEVER** do these architectural decisions:

### Security Violations
```python
# BAD - Security violations
async def bad_tool_handler(args):
    # NEVER execute arbitrary code
    command = args.get("command")
    os.system(command)  # Security vulnerability
    
    # NEVER expose internal paths
    return {"internal_path": "/etc/secrets/config.json"}
```

### Resource Leaks
```typescript
// BAD - Resource leaks
class BadTransport {
    private connections: Connection[] = [];
    
    async connect() {
        const connection = new Connection();
        this.connections.push(connection);
        // NEVER forget to clean up connections
    }
    
    // Missing cleanup methods
}
```

## Code Examples

### Complete MCP Server Architecture (Python)
```python
import asyncio
from mcp.server import Server
from mcp.server.stdio import stdio_server
import mcp.types as types

class CompleteMCPServer:
    def __init__(self):
        self.server = Server("comprehensive-mcp-server")
        self.resources = {}
        self.tools = {}
        self.prompts = {}
        self.setup_handlers()
    
    def setup_handlers(self):
        @self.server.list_resources()
        async def list_resources() -> list[types.Resource]:
            return [
                types.Resource(
                    uri=f"mcp://resource/{key}",
                    name=resource["name"],
                    description=resource["description"]
                )
                for key, resource in self.resources.items()
            ]
        
        @self.server.read_resource()
        async def read_resource(uri: str) -> types.ResourceContents:
            resource_id = uri.split("/")[-1]
            if resource_id not in self.resources:
                raise ValueError(f"Resource {resource_id} not found")
            
            resource = self.resources[resource_id]
            return types.TextResourceContents(
                uri=uri,
                text=resource["content"]
            )
        
        @self.server.list_tools()
        async def list_tools() -> list[types.Tool]:
            return [
                types.Tool(
                    name=name,
                    description=tool["description"],
                    inputSchema=tool["schema"]
                )
                for name, tool in self.tools.items()
            ]
        
        @self.server.call_tool()
        async def call_tool(name: str, arguments: dict) -> list[types.TextContent]:
            if name not in self.tools:
                raise ValueError(f"Tool {name} not found")
            
            tool = self.tools[name]
            result = await tool["handler"](arguments)
            return [types.TextContent(type="text", text=str(result))]
    
    async def run(self):
        async with stdio_server() as streams:
            await self.server.run(streams[0], streams[1])

# Usage
if __name__ == "__main__":
    server = CompleteMCPServer()
    asyncio.run(server.run())
```

### Complete MCP Client Architecture (TypeScript)
```typescript
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

class CompleteMCPClient {
    private client: Client;
    private transport: StdioClientTransport;
    
    constructor() {
        this.client = new Client({
            name: "comprehensive-mcp-client",
            version: "1.0.0"
        }, {
            capabilities: {
                sampling: {},
                roots: { listChanged: true }
            }
        });
        
        this.transport = new StdioClientTransport({
            command: "python",
            args: ["server.py"]
        });
    }
    
    async connect(): Promise<void> {
        await this.client.connect(this.transport);
    }
    
    async listResources(): Promise<any[]> {
        const response = await this.client.request(
            { method: "resources/list" },
            ResourcesListResultSchema
        );
        return response.resources;
    }
    
    async callTool(name: string, args: any): Promise<any> {
        const response = await this.client.request(
            {
                method: "tools/call",
                params: {
                    name: name,
                    arguments: args
                }
            },
            CallToolResultSchema
        );
        return response.content;
    }
    
    async disconnect(): Promise<void> {
        await this.client.close();
    }
}

// Usage
const client = new CompleteMCPClient();
await client.connect();
const resources = await client.listResources();
await client.disconnect();
```

## Validation Checklist

**MUST** verify:
- [ ] Protocol compliance with MCP specification 2024-11-05
- [ ] Proper capability negotiation and initialization
- [ ] Error handling with protocol-compliant error codes
- [ ] Resource, tool, and prompt patterns implemented correctly
- [ ] Security considerations addressed (input validation, access control)
- [ ] Transport layer properly abstracted
- [ ] Proper cleanup and resource management

**SHOULD** check:
- [ ] Modular architecture with clear separation of concerns
- [ ] Dependency injection used for component management
- [ ] Comprehensive logging and monitoring implemented
- [ ] Performance considerations addressed
- [ ] Documentation complete and accurate
- [ ] Code follows established patterns and conventions

## References

- [MCP Protocol Specification](https://modelcontextprotocol.io/introduction)
- [MCP Architecture Documentation](https://modelcontextprotocol.io/introduction/docs/concepts/architecture)
- [Official MCP SDKs](https://github.com/modelcontextprotocol)
- [MCP Security Best Practices](https://modelcontextprotocol.io/introduction/specification/draft/basic/security_best_practices)
- [MCP Transport Specifications](https://modelcontextprotocol.io/introduction/specification/draft/basic/transports)
