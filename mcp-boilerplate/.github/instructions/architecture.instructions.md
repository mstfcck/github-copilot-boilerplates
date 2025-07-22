---
applyTo: '**'
---

# MCP Architecture Instructions

This document provides comprehensive architectural guidance for Model Context Protocol (MCP) applications following protocol specifications and industry best practices.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** implement official MCP protocol specification 2024-11-05 or later
- **REQUIRED** to use official MCP SDKs for protocol compliance
- **SHALL** follow MCP transport layer specifications (STDIO, HTTP/SSE)
- **MUST** implement proper capability negotiation during initialization
- **NEVER** bypass protocol requirements or implement custom message formats

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** implement modular architecture with clear separation of concerns
- **RECOMMENDED** to use dependency injection for component management
- **ALWAYS** implement proper error handling with protocol-compliant error codes
- **DO** implement resource, tool, and prompt patterns according to MCP specifications
- **DON'T** create tightly coupled components between transport and business logic

### Optional Enhancements (**MAY** Consider)
- **MAY** implement caching layers for frequently accessed resources
- **OPTIONAL** to add advanced monitoring and observability features
- **USE** established design patterns like Factory or Builder for complex objects
- **IMPLEMENT** connection pooling for high-throughput scenarios
- **AVOID** premature optimization without performance measurements

## Implementation Guidance

**USE** these architectural patterns:

### Server Architecture Pattern
```python
# Python MCP Server Architecture
from mcp.server import Server
from mcp.server.stdio import stdio_server
import mcp.types as types

class MCPServerArchitecture:
    def __init__(self):
        self.app = Server("my-mcp-server")
        self.resources = ResourceManager()
        self.tools = ToolManager()
        self.prompts = PromptManager()
    
    def setup_capabilities(self):
        # Declare server capabilities
        return {
            "resources": {"subscribe": True},
            "tools": {},
            "prompts": {}
        }
```

```typescript
// TypeScript MCP Server Architecture
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

class MCPServerArchitecture {
    private server: Server;
    private resourceManager: ResourceManager;
    private toolManager: ToolManager;
    
    constructor() {
        this.server = new Server({
            name: "my-mcp-server",
            version: "1.0.0"
        }, {
            capabilities: {
                resources: { subscribe: true },
                tools: {},
                prompts: {}
            }
        });
    }
}
```

### Transport Layer Abstraction
```java
// Java MCP Transport Abstraction
public interface MCPTransport {
    void connect() throws MCPException;
    void disconnect() throws MCPException;
    CompletableFuture<Response> sendRequest(Request request);
    void sendNotification(Notification notification);
}

public class StdioTransport implements MCPTransport {
    // STDIO implementation
}

public class HttpSseTransport implements MCPTransport {
    // HTTP/SSE implementation
}
```

**IMPLEMENT** these architectural patterns:

### Resource Provider Pattern
```python
# Resource Provider Architecture
class ResourceProvider:
    def __init__(self):
        self.resources = {}
        self.subscribers = set()
    
    async def list_resources(self) -> list[types.Resource]:
        return [
            types.Resource(
                uri=f"mcp://resource/{key}",
                name=resource.name,
                description=resource.description,
                mimeType=resource.mime_type
            )
            for key, resource in self.resources.items()
        ]
    
    async def read_resource(self, uri: str) -> types.ResourceContents:
        # Implement resource reading logic
        pass
        
    async def notify_resource_change(self, uri: str):
        # Notify subscribers of resource changes
        for subscriber in self.subscribers:
            await subscriber.notify_resource_updated(uri)
```

### Tool Registry Pattern
```typescript
// Tool Registry Architecture
interface ToolDefinition {
    name: string;
    description: string;
    inputSchema: object;
    handler: (args: any) => Promise<any>;
}

class ToolRegistry {
    private tools: Map<string, ToolDefinition> = new Map();
    
    registerTool(tool: ToolDefinition): void {
        this.tools.set(tool.name, tool);
    }
    
    async callTool(name: string, args: any): Promise<any> {
        const tool = this.tools.get(name);
        if (!tool) {
            throw new Error(`Tool ${name} not found`);
        }
        return await tool.handler(args);
    }
    
    listTools(): ToolDefinition[] {
        return Array.from(this.tools.values());
    }
}
```

**ENSURE** proper initialization sequence:

### MCP Initialization Flow
```python
# Proper MCP Initialization
async def initialize_mcp_server():
    # 1. Create server instance
    server = Server("my-server")
    
    # 2. Register capabilities
    await server.register_capabilities({
        "resources": {"subscribe": True},
        "tools": {},
        "prompts": {}
    })
    
    # 3. Register handlers
    await server.register_resource_handlers(resource_provider)
    await server.register_tool_handlers(tool_registry)
    await server.register_prompt_handlers(prompt_manager)
    
    # 4. Start transport
    async with stdio_server() as streams:
        await server.run(streams[0], streams[1])
```

## Anti-Patterns

**DON'T** implement these architectural approaches:

### Avoid Monolithic Message Handlers
```python
# BAD - Monolithic handler
async def handle_all_messages(message):
    if message.method == "resources/list":
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
