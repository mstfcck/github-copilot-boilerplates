# MCP Boilerplate

A comprehensive Model Context Protocol (MCP) boilerplate project designed to accelerate AI-integrated application development with GitHub Copilot guidance and industry best practices.

## 🚀 Overview

This boilerplate provides a solid foundation for building MCP applications with:

- **Protocol-compliant architecture** following MCP specifications
- **Comprehensive AI-guided instructions** for MCP development
- **Multi-language SDK support** with official MCP SDKs
- **Reference implementations** and example servers
- **Security-first approach** with input validation and error handling
- **Modular design patterns** for scalable MCP servers
- **Extensive documentation** with protocol specifications

## 📋 Table of Contents

- [Features](#features)
- [MCP Protocol Overview](#mcp-protocol-overview)
- [Getting Started](#getting-started)
- [AI-Guided Development](#ai-guided-development)
- [Project Structure](#project-structure)
- [Supported SDKs](#supported-sdks)
- [Reference Servers](#reference-servers)
- [Configuration](#configuration)
- [Examples](#examples)
- [Deployment](#deployment)

## ✨ Features

### Core MCP Features
- **Protocol Implementation** with official MCP SDKs
- **Resource Management** for context-aware operations
- **Tool Integration** with external systems and APIs
- **Prompt Engineering** with structured prompt templates
- **Error Handling** with comprehensive error management
- **Security Patterns** with input validation and sanitization
- **Async Operations** for high-performance implementations

### Development Features
- **AI-Guided Instructions** for MCP-specific development
- **Code Quality Standards** with MCP best practices
- **Testing Templates** for protocol compliance testing
- **Performance Optimization** guidelines for MCP servers
- **Security Best Practices** for AI-integrated applications
- **Documentation Patterns** with protocol specification adherence

### Operational Features
- **Health Monitoring** with server status indicators
- **Logging Configuration** with structured MCP logging
- **Environment Management** for different deployment scenarios
- **Protocol Validation** with specification compliance checks
- **Performance Metrics** for MCP server monitoring

## 🔌 MCP Protocol Overview

The Model Context Protocol (MCP) is an open standard for connecting AI assistants to external data sources and tools. This boilerplate implements the core MCP concepts:

### Key Concepts
- **Servers**: Provide resources, tools, and prompts to clients
- **Clients**: AI applications that consume MCP services
- **Resources**: Data and content exposed by servers
- **Tools**: Functions that can be called by AI assistants
- **Prompts**: Structured templates for AI interactions

### Architecture
```text
┌─────────────────┐    MCP Protocol    ┌─────────────────┐
│   AI Assistant  │ ◄────────────────► │   MCP Server    │
│    (Client)     │                    │                 │
└─────────────────┘                    └─────────────────┘
                                              │
                                              ▼
                                       ┌─────────────────┐
                                       │  Data Sources   │
                                       │  External APIs  │
                                       │     Tools       │
                                       └─────────────────┘
```

## 🚀 Getting Started

### Prerequisites

Choose your development environment:

**Python Environment**:
- Python 3.8+ 
- pip package manager

**TypeScript/Node.js Environment**:
- Node.js 18+
- npm or yarn package manager

**Java Environment**:
- Java 17+
- Maven or Gradle

**C# Environment**:
- .NET 6+
- NuGet package manager

**Kotlin Environment**:
- Kotlin 1.8+
- Gradle build system

### Quick Start

1. **Clone the boilerplate**
   ```bash
   git clone https://github.com/your-username/mcp-boilerplate.git
   cd mcp-boilerplate
   ```

2. **Choose your SDK and initialize project**
   ```bash
   # For Python
   mkdir src && cd src
   pip install mcp

   # For TypeScript
   mkdir src && cd src
   npm install @modelcontextprotocol/sdk

   # For Java
   mkdir src && cd src
   # Add MCP SDK dependency to your pom.xml or build.gradle

   # For C#
   mkdir src && cd src
   dotnet add package ModelContextProtocol.Sdk

   # For Kotlin
   mkdir src && cd src
   # Add MCP SDK dependency to your build.gradle.kts
   ```

3. **Set up your development environment**
   ```bash
   # Create necessary directories
   mkdir tests docs

   # Copy AI instructions to your project
   cp .github/copilot-instructions.md your-project/
   ```

4. **Start developing with AI guidance**
   - Review the [MCP instructions](.github/instructions/mcp.instructions.md)
   - Follow the [coding standards](.github/instructions/coding-standarts.instructions.md)
   - Use the provided [project structure](.github/instructions/project.instructions.md)

## 🤖 AI-Guided Development

This project includes comprehensive AI instructions for MCP development:

### Available Instructions

- **[Main MCP Guide](.github/copilot-instructions.md)**: Core MCP development principles
- **[MCP Specifications](.github/instructions/mcp.instructions.md)**: Protocol compliance and SDK usage
- **[Coding Standards](.github/instructions/coding-standarts.instructions.md)**: Code quality and best practices
- **[Project Structure](.github/instructions/project.instructions.md)**: Recommended project organization

### Protocol Documentation

- **[Protocol Architecture](docs/mcp/PROTOCOL_ARCHITECTURE.md)**: MCP system architecture
- **[Base Protocol](docs/mcp/PROTOCOL_BASE_PROTOCOL.md)**: Core protocol specification
- **[Client Features](docs/mcp/PROTOCOL_CLIENT_FEATURES.md)**: Client implementation guide
- **[Server Features](docs/mcp/PROTOCOL_SERVER_FEATURES.md)**: Server implementation guide
- **[Full Specification](docs/mcp/PROTOCOL_SPECIFICATION.md)**: Complete MCP specification

### Using AI Instructions

1. **Review the main instructions** for overall development approach
2. **Choose the appropriate SDK** based on your technology preference
3. **Follow the protocol specifications** for compliant implementations
4. **Use the coding standards** to ensure quality and consistency
5. **Reference example servers** for implementation patterns

## 📁 Project Structure

Recommended project structure for MCP applications:

```text
your-mcp-project/
├── .github/
│   ├── copilot-instructions.md      # AI development guidance
│   └── instructions/                # Specialized instruction files
├── src/                            # Source code directory
│   ├── server/                     # MCP server implementation
│   ├── resources/                  # Resource providers
│   ├── tools/                      # Tool implementations
│   ├── prompts/                    # Prompt templates
│   └── utils/                      # Utility functions
├── tests/                          # Test implementations
│   ├── unit/                       # Unit tests
│   ├── integration/               # Integration tests
│   └── protocol/                  # Protocol compliance tests
├── docs/                           # Project documentation
│   ├── api/                       # API documentation
│   ├── deployment/                # Deployment guides
│   └── examples/                  # Usage examples
├── config/                         # Configuration files
├── scripts/                        # Build and deployment scripts
├── README.md                       # Project documentation
└── .gitignore                      # Git ignore patterns
```

## 🛠️ Supported SDKs

### Official MCP SDKs

| Language | SDK | Documentation |
|----------|-----|---------------|
| **Python** | [@modelcontextprotocol/python-sdk](https://github.com/modelcontextprotocol/python-sdk) | [Docs](https://github.com/modelcontextprotocol/python-sdk#readme) |
| **TypeScript** | [@modelcontextprotocol/typescript-sdk](https://github.com/modelcontextprotocol/typescript-sdk) | [Docs](https://github.com/modelcontextprotocol/typescript-sdk#readme) |
| **Java** | [java-sdk](https://github.com/modelcontextprotocol/java-sdk) | [Docs](https://github.com/modelcontextprotocol/java-sdk#readme) |
| **C#** | [csharp-sdk](https://github.com/modelcontextprotocol/csharp-sdk) | [Docs](https://github.com/modelcontextprotocol/csharp-sdk#readme) |
| **Kotlin** | [kotlin-sdk](https://github.com/modelcontextprotocol/kotlin-sdk) | [Docs](https://github.com/modelcontextprotocol/kotlin-sdk#readme) |

### SDK Features

All official SDKs provide:
- **Protocol Implementation**: Complete MCP protocol support
- **Type Safety**: Strong typing for protocol messages
- **Async Support**: Non-blocking operations
- **Error Handling**: Comprehensive error management
- **Testing Utilities**: Tools for protocol testing
- **Documentation**: Complete API documentation

## 🔧 Reference Servers

Learn from these official reference implementations:

### Core Examples
- **[Everything Server](https://github.com/modelcontextprotocol/servers/tree/main/src/everything)**: Complete feature demonstration
- **[Filesystem Server](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem)**: File operations with security controls
- **[Git Server](https://github.com/modelcontextprotocol/servers/tree/main/src/git)**: Repository management and manipulation

### Specialized Servers
- **[Fetch Server](https://github.com/modelcontextprotocol/servers/tree/main/src/fetch)**: Web content retrieval and processing
- **[Memory Server](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)**: Knowledge graph-based memory
- **[Sequential Thinking Server](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking)**: Problem-solving workflows
- **[Time Server](https://github.com/modelcontextprotocol/servers/tree/main/src/time)**: Time and timezone operations

### Integration Examples
- **[Database Servers](https://github.com/modelcontextprotocol/servers)**: Various database integrations
- **[API Servers](https://github.com/modelcontextprotocol/servers)**: External API integrations
- **[Tool Servers](https://github.com/modelcontextprotocol/servers)**: Specialized tool implementations

## ⚙️ Configuration

### Environment Configuration

Create environment-specific configuration files:

```yaml
# config/development.yaml
server:
  host: localhost
  port: 8000
  debug: true

logging:
  level: DEBUG
  format: structured

security:
  input_validation: strict
  rate_limiting: false
```

```yaml
# config/production.yaml
server:
  host: 0.0.0.0
  port: ${PORT:-8000}
  debug: false

logging:
  level: INFO
  format: json

security:
  input_validation: strict
  rate_limiting: true
  max_requests_per_minute: 100
```

### Protocol Configuration

Configure MCP-specific settings:

```json
{
  "mcp": {
    "version": "1.0",
    "capabilities": {
      "resources": true,
      "tools": true,
      "prompts": true,
      "logging": true
    },
    "features": {
      "progress_notifications": true,
      "cancellation": true,
      "sampling": false
    }
  }
}
```

## 💡 Examples

### Basic MCP Server (Python)

```python
from mcp import Server, Resource, Tool
from mcp.types import TextResourceContents

app = Server("example-server")

@app.list_resources()
async def list_resources():
    return [
        Resource(
            uri="file://example.txt",
            name="Example Resource",
            description="A simple example resource"
        )
    ]

@app.read_resource()
async def read_resource(uri: str):
    if uri == "file://example.txt":
        return TextResourceContents(
            uri=uri,
            text="This is example content"
        )
    raise ValueError(f"Unknown resource: {uri}")

@app.list_tools()
async def list_tools():
    return [
        Tool(
            name="echo",
            description="Echo the input text",
            inputSchema={
                "type": "object",
                "properties": {
                    "text": {"type": "string"}
                },
                "required": ["text"]
            }
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: dict):
    if name == "echo":
        return {"text": arguments.get("text", "")}
    raise ValueError(f"Unknown tool: {name}")

if __name__ == "__main__":
    app.run()
```

### Client Integration Example

```python
from mcp import Client

async def main():
    async with Client("your-mcp-server") as client:
        # List available resources
        resources = await client.list_resources()
        print(f"Available resources: {resources}")
        
        # Use a tool
        result = await client.call_tool("echo", {"text": "Hello, MCP!"})
        print(f"Tool result: {result}")

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
```

## 🚀 Deployment

### Local Development

```bash
# Python
python src/server.py

# TypeScript
npm start

# Java
mvn exec:java -Dexec.mainClass="com.example.MCPServer"

# C#
dotnet run

# Kotlin
./gradlew run
```

### Docker Deployment

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY src/ ./src/
COPY config/ ./config/

EXPOSE 8000
CMD ["python", "src/server.py"]
```

### Cloud Deployment

Deploy to various cloud platforms:

- **AWS Lambda**: Serverless MCP server deployment
- **Google Cloud Run**: Containerized server deployment
- **Azure Container Instances**: Managed container deployment
- **Heroku**: Simple platform deployment

## 📚 Learning Resources

### Official Documentation
- [MCP Specification](https://modelcontextprotocol.io/)
- [SDK Documentation](https://github.com/modelcontextprotocol)
- [Example Servers](https://github.com/modelcontextprotocol/servers)

### Community Resources
- [MCP Community Forum](https://github.com/modelcontextprotocol/discussions)
- [Best Practices Guide](docs/best-practices.md)
- [Troubleshooting Guide](docs/troubleshooting.md)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](../CONTRIBUTING.md) for details on:

- How to submit bug reports and feature requests
- How to contribute code improvements
- Coding standards and review process
- Community guidelines

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 🔗 Related Resources

- [Model Context Protocol Official Site](https://modelcontextprotocol.io/)
- [MCP SDK Documentation](https://github.com/modelcontextprotocol)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)

---

**Start building powerful AI-integrated applications with MCP and GitHub Copilot guidance!**
