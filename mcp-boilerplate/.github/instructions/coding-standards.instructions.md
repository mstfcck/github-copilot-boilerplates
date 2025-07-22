---
applyTo: '**'
---
Coding standards, domain knowledge, and preferences that AI should follow.

# MCP Coding Standards and Preferences

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** use FastMCP framework as the primary MCP implementation approach
- **REQUIRED** to use `from fastmcp import FastMCP` instead of raw MCP SDK for server creation
- **SHALL** use decorator patterns: `@mcp.tool`, `@mcp.resource`, `@mcp.prompt` for component definition
- **MUST** integrate with FastAPI using `FastMCP.from_fastapi()` for HTTP-based servers
- **NEVER** implement custom MCP protocol handling when FastMCP provides the functionality

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** use `FastMCP(name="ServerName")` for server instantiation with descriptive names
- **RECOMMENDED** to use `Client(server_source)` with automatic transport inference
- **ALWAYS** use async/await patterns for all I/O operations
- **DO** leverage FastAPI dependency injection with `Depends()` for shared logic
- **DON'T** create tightly coupled components between MCP and business logic

### Optional Enhancements (**MAY** Consider)
- **MAY** use server composition with `main.mount(sub, prefix="namespace")`
- **OPTIONAL** to implement proxy patterns with `FastMCP.as_proxy(backend)`
- **USE** in-memory transport `Client(mcp_instance)` for testing scenarios
- **IMPLEMENT** FastAPI middleware for cross-cutting concerns
- **AVOID** premature optimization without FastMCP profiling

## FastMCP Coding Standards

**USE** these FastMCP patterns:

### Server Creation Pattern
```python
from fastmcp import FastMCP

# Preferred FastMCP approach
mcp = FastMCP(
    name="MyMCPServer",
    instructions="""
    This server provides data analysis tools.
    Call get_analysis() to analyze data sets.
    """
)

# NOT raw MCP SDK approach
# from mcp.server import Server  # ❌ Avoid
```

### Tool Definition Pattern
```python
# Preferred FastMCP decorator approach
@mcp.tool
def analyze_data(data: list[float], method: str = "mean") -> dict:
    """Analyze numerical data using specified method."""
    if method == "mean":
        return {"result": sum(data) / len(data), "method": method}
    return {"error": "Unsupported method"}

# NOT raw MCP SDK registration
# @server.call_tool()  # ❌ Avoid
```

### Resource Definition Pattern
```python
# Preferred FastMCP resource approach
@mcp.resource("data://config")
def get_config() -> dict:
    """Provides application configuration."""
    return {"theme": "dark", "version": "2.0", "features": ["analysis"]}

# Template resources with parameters
@mcp.resource("users://{user_id}/profile")
def get_user_profile(user_id: int) -> dict:
    """Get user profile by ID."""
    return {"id": user_id, "name": f"User {user_id}", "active": True}
```

### Client Usage Pattern
```python
from fastmcp import Client

# Preferred FastMCP client with transport inference
async def use_mcp_client():
    # In-memory for testing
    client = Client(mcp_server_instance)
    
    # HTTP/SSE for production
    client = Client("https://api.example.com/mcp")
    
    # Local script
    client = Client("./server.py")
    
    async with client:
        result = await client.call_tool("analyze_data", {"data": [1, 2, 3]})
        return result
```

## FastAPI Integration Standards

**IMPLEMENT** these FastAPI patterns:

### FastAPI + FastMCP Integration
```python
from fastapi import FastAPI, Depends
from fastmcp import FastMCP

app = FastAPI()

# Convert FastAPI to MCP server
mcp = FastMCP.from_fastapi(app, name="API-MCP Bridge")

# Shared dependencies
async def get_database():
    # Database session logic
    pass

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@mcp.tool
def api_status(db=Depends(get_database)) -> dict:
    """Get API and database status."""
    return {"api": "running", "database": "connected"}
```

### Dependency Injection Pattern
```python
from fastapi import Depends
from typing import Annotated

# Shared dependency
async def get_current_user(token: str = Depends(oauth2_scheme)):
    # Authentication logic
    return {"user_id": 1, "username": "admin"}

@mcp.tool
def get_user_data(
    user: Annotated[dict, Depends(get_current_user)]
) -> dict:
    """Get data for authenticated user."""
    return {"data": f"Data for {user['username']}"}
```

## Anti-Patterns to Avoid

**DON'T** use these patterns:

### ❌ Raw MCP SDK Implementation
```python
# WRONG - Don't use raw MCP SDK
from mcp.server import Server
from mcp.server.stdio import stdio_server

server = Server("my-server")

@server.call_tool()
async def my_tool(name: str, arguments: dict):
    # Raw protocol handling
    pass
```

### ❌ Custom Protocol Handling
```python
# WRONG - Don't implement custom MCP protocol
class CustomMCPServer:
    def handle_request(self, request):
        # Custom protocol implementation
        pass
```

### ❌ Synchronous Operations
```python
# WRONG - Don't use synchronous operations
@mcp.tool
def blocking_operation(data: str) -> str:
    time.sleep(5)  # Blocks event loop
    return process_data(data)

# CORRECT - Use async operations
@mcp.tool
async def async_operation(data: str) -> str:
    await asyncio.sleep(5)  # Non-blocking
    return await process_data_async(data)
```

## Best Practices References

- Follow the [FastMCP Documentation](https://gofastmcp.com/) for framework-specific patterns
- Use [FastAPI Documentation](https://fastapi.tiangolo.com/) for web framework integration
- Reference [MCP Specification](https://modelcontextprotocol.io/specification) for protocol compliance
- Review [FastMCP Examples](https://github.com/jlowin/fastmcp) for implementation patterns
- Consult [mcp.instructions.md](./mcp.instructions.md) for comprehensive FastMCP and FastAPI documentation

## Software Engineering Practices

- Follow the SOLID principles with FastMCP's modular component design
- Apply DRY principle through FastMCP server composition and mounting
- Use KISS principle with FastMCP's decorator-based approach
- Follow YAGNI by leveraging FastMCP's built-in capabilities
- Implement Separation of Concerns using FastMCP tools, resources, and prompts as distinct components
- Use meaningful names for MCP components: tools, resources, and prompts
- Document FastMCP components with clear docstrings for AI understanding
- Use consistent FastMCP patterns across all server implementations
- Leverage FastMCP's built-in testing patterns for maintainable code
