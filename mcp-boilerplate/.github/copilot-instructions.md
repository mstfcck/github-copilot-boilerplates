# MCP Boilerplate - AI Development Assistant

This is a comprehensive Model Context Protocol (MCP) boilerplate project designed to accelerate AI-integrated application development with GitHub Copilot guidance and industry best practices.

Using this boilerplate, you can set up a new MCP application or enhance an existing one by following the protocol specifications, architectural guidelines, coding standards, and development practices outlined in this document.

## Core Principles and Guidelines

**MUST** follow these fundamental principles when developing MCP applications:
- **Protocol Compliance**: All implementations must strictly follow MCP specification requirements
- **Security First**: Input validation, authentication, and access control are mandatory
- **Modular Design**: Server and client components should be independently maintainable
- **Type Safety**: Use official MCP SDKs with strong typing support
- **Documentation**: Comprehensive documentation and clear error messages are essential
- **Semantic Search Integration**: Leverage semantic search capabilities for finding relevant patterns and implementations
- **Context7 Integration**: Use Context7 MCP server for accessing up-to-date documentation and best practices

## Technology Stack Specifications

**MUST** use these technologies and frameworks:
- **Official MCP SDKs**: Python, TypeScript, Java, C#, Kotlin, or other official implementations
- **Protocol Version**: MCP 2024-11-05 or later for new implementations
- **Transport**: STDIO for local development, HTTP/SSE for production deployments
- **Security**: OAuth 2.1 for authentication when using HTTP transport
- **Testing**: Protocol compliance testing with official test utilities
- **Documentation**: OpenAPI/JSON Schema for API documentation

## Architecture Decision Framework

**ALWAYS** consider these architectural questions when developing MCP applications:

1. **What is the deployment architecture?**
   - Local development with STDIO transport
   - Production deployment with HTTP/SSE transport
   - Cloud-native serverless deployment
   - Container-based deployment

2. **What are the protocol requirements?**
   - Resources: Static or dynamic context data
   - Tools: Functions available to language models
   - Prompts: Interactive templates for user workflows
   - Sampling: AI-powered content generation capabilities

3. **What are the security considerations?**
   - Authentication and authorization mechanisms
   - Input validation and sanitization requirements
   - Rate limiting and access control policies
   - Data privacy and information disclosure prevention

4. **What are the performance requirements?**
   - Concurrent connection handling
   - Message throughput and latency requirements
   - Resource consumption constraints
   - Scalability and load balancing needs

## Development Standards

**ENSURE** all code follows these standards:
- Use official MCP SDKs and follow their conventions
- Implement proper error handling with meaningful error messages
- Follow protocol-specific patterns for resources, tools, and prompts
- Use appropriate logging levels and structured logging
- Implement comprehensive input validation and sanitization
- Follow security best practices for AI-integrated applications
- **USE** semantic search to find relevant MCP implementation patterns
- **IMPLEMENT** Context7 integration for accessing current MCP documentation

**DO** implement these patterns:
- Server pattern with proper capability declaration
- Resource pattern for exposing contextual data
- Tool pattern for actionable functions
- Prompt pattern for interactive workflows
- Transport abstraction for different deployment scenarios
- **Semantic search patterns** for finding relevant MCP server implementations
- **Context7 integration patterns** for accessing up-to-date MCP documentation

**DON'T** implement these anti-patterns:
- Hardcoded protocol versions or capabilities
- Bypassing input validation or sanitization
- Exposing sensitive information in error messages
- Ignoring protocol compliance requirements
- Implementing custom protocols instead of using MCP
- **Relying on outdated MCP documentation** without Context7 verification

## Code Quality Requirements

**MUST** include for every feature:
- Protocol compliance testing with official test utilities
- Input validation and error handling for all endpoints
- Comprehensive logging with appropriate log levels
- Security considerations and access control
- Documentation with code examples and usage patterns
- **Semantic search validation** to ensure implementation follows current MCP best practices
- **Context7 integration** for accessing up-to-date MCP protocol documentation

**SHOULD** consider:
- Performance optimization for high-throughput scenarios
- Caching strategies for frequently accessed resources
- Monitoring and observability for production deployments
- Integration testing with real language models
- Documentation updates and API versioning
- **Using semantic search** to find relevant MCP patterns across reference implementations
- **Leveraging Context7** for the latest MCP specification updates and examples

**NICE TO HAVE**:
- Load testing scenarios for concurrent connections
- Advanced security features like rate limiting
- Performance benchmarks and optimization guides
- Community contribution guidelines and examples
- **Automated semantic search integration** for MCP pattern discovery
- **Context7 MCP server** setup as a reference implementation

## AI-Assisted MCP Development

**MUST** leverage AI tools effectively for MCP development:
- **USE** semantic search to find relevant MCP server implementations and patterns
- **IMPLEMENT** Context7 MCP server for accessing current MCP protocol documentation
- **ENSURE** AI-generated MCP code follows protocol compliance requirements
- **VALIDATE** AI suggestions against current MCP specification via Context7

**ALWAYS** when using AI assistance for MCP development:
- Append 'use context7' to prompts for MCP-specific queries
- Use semantic search to find similar MCP server implementations
- Verify AI-generated code against current MCP protocol specification
- Cross-reference patterns found through semantic search with Context7 documentation

**Context7 Integration Commands for MCP:**
```bash
# For MCP server implementation
Create an MCP server with tools and resources capabilities. use context7

# For MCP client integration
Implement MCP client with proper error handling and reconnection logic. use context7

# For MCP protocol compliance
Validate MCP server implementation against current specification. use library /modelcontextprotocol/specification
```

## Sub-Instructions

Reference to modular instruction files:
- **[Architecture Guide](./instructions/architecture.instructions.md)**: MCP-specific architectural patterns and decisions
- **[Security Guide](./instructions/security.instructions.md)**: Security implementation for AI-integrated applications
- **[Testing Guide](./instructions/testing.instructions.md)**: Protocol compliance and integration testing strategies
- **[Coding Standards](./instructions/coding-standards.instructions.md)**: MCP best practices and code quality guidelines
- **[Performance Guide](./instructions/performance.instructions.md)**: Optimization strategies for MCP servers
- **[Configuration Guide](./instructions/configuration.instructions.md)**: Environment and protocol configuration
- **[Deployment Guide](./instructions/deployment.instructions.md)**: Production deployment strategies
- **[MCP Specifications](./instructions/mcp.instructions.md)**: Protocol specifications and SDK usage
- **[Semantic Search Guide](./instructions/semantic-search.instructions.md)**: Semantic search and Context7 integration for MCP development
- **[Git Ignore Guide](./instructions/gitignore.instructions.md)**: Version control best practices

## Documentation Standards

**MUST** maintain comprehensive documentation under the `./docs` directory:
- Protocol specification compliance and implementation details
- API documentation with request/response examples
- Deployment guides for different environments
- Usage examples and integration patterns

**ALWAYS** ensure documentation is:
- Current with the latest MCP specification versions
- Well-structured with clear examples and code samples
- Practical with actionable implementation guidance
- Comprehensive covering all protocol features and capabilities

This project serves as the foundation for MCP application development, providing developers with protocol-compliant patterns, comprehensive guidance, and standardized approaches to building secure, scalable, and maintainable AI-integrated applications.
