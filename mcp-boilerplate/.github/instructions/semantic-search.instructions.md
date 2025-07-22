---
applyTo: '**'
---

# Semantic Search & Context7 Integration for MCP Development

This document provides guidance on leveraging semantic search capabilities and Context7 MCP server integration for enhanced Model Context Protocol (MCP) development with AI assistance.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** use semantic search to find relevant MCP implementation patterns before developing new features
- **REQUIRED** to verify MCP implementations against current protocol specification via Context7
- **SHALL** integrate Context7 MCP server for accessing up-to-date MCP documentation
- **NEVER** implement MCP features without consulting current protocol specification through Context7

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** use semantic search to identify existing MCP server patterns in reference implementations
- **RECOMMENDED** to append 'use context7' to AI prompts for MCP-specific queries
- **ALWAYS** cross-reference semantic search results with Context7 MCP documentation
- **DO** leverage Context7 for MCP SDK-specific documentation and examples
- **DON'T** implement MCP servers without first searching for similar patterns

### Optional Enhancements (**MAY** Consider)
- **MAY** set up Context7 as a reference MCP server implementation
- **OPTIONAL** to configure Context7 auto-invocation rules for MCP development
- **USE** Context7 MCP server as a learning tool for protocol compliance
- **IMPLEMENT** semantic search-based MCP pattern discovery
- **AVOID** duplicate MCP server implementations without semantic search validation

## Context7 MCP Server Integration

**USE** Context7 as both a development tool and reference implementation:

### Context7 MCP Server Configuration
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

### Context7 as Reference Implementation
Context7 itself is an excellent MCP server implementation that demonstrates:
- **Tool Implementation**: `resolve-library-id` and `get-library-docs` tools
- **Resource Management**: Dynamic documentation resource handling
- **Error Handling**: Proper MCP error response patterns
- **Protocol Compliance**: Full MCP specification adherence
- **Performance**: Efficient documentation retrieval and caching

## Semantic Search for MCP Development

**IMPLEMENT** these semantic search patterns for MCP development:

### Finding MCP Server Patterns
```bash
# Search for MCP server implementations
semantic_search("MCP server implementation with tools and resources")

# Search for MCP client patterns
semantic_search("MCP client connection handling and error management")

# Search for MCP protocol compliance
semantic_search("MCP protocol validation and testing patterns")
```

### MCP-Specific Pattern Discovery
```typescript
// Use semantic search to find similar MCP server patterns
import { Server } from '@modelcontextprotocol/sdk/server/index.js';

// Search for: "MCP server capability declaration patterns"
const server = new Server({
  name: 'example-server',
  version: '1.0.0',
  capabilities: {
    // Implementation based on semantic search results
    tools: {},
    resources: {},
    prompts: {}
  }
});
```

## Context7 Integration for MCP Development

**ENSURE** these Context7 integration approaches for MCP development:

### MCP Protocol Specific Queries
```bash
# Current MCP specification documentation
"Create an MCP server with tools and resources capabilities. use context7"

# MCP SDK integration
"Implement MCP client with proper error handling. use library /modelcontextprotocol/sdk"

# MCP protocol compliance
"Validate MCP server implementation against current specification. use context7"
```

### SDK-Specific Documentation Access
```bash
# Target specific MCP SDKs
"Configure MCP server using Python SDK. use library /modelcontextprotocol/python-sdk"

# TypeScript SDK patterns
"Implement MCP client with TypeScript SDK. use library /modelcontextprotocol/typescript-sdk"

# Java SDK implementation
"Create MCP server with Java SDK. use library /modelcontextprotocol/java-sdk"
```

### Context7 as Learning Tool
```bash
# Study Context7 implementation patterns
"Analyze Context7 MCP server implementation for tool patterns. use context7"

# Learn from Context7 error handling
"Show Context7 MCP server error handling patterns. use context7"

# Understand Context7 resource management
"Explain Context7 resource management implementation. use context7"
```

## MCP Server Implementation Guidance

**IMPLEMENT** these MCP server patterns found through semantic search and Context7:

### Tool Implementation Pattern
```typescript
// Based on Context7 MCP server implementation
server.setRequestHandler(ToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  
  // Search: "MCP tool implementation error handling"
  if (name === 'resolve-library-id') {
    // Implementation guided by Context7 patterns
    return {
      content: [
        {
          type: 'text',
          text: await resolveLibraryId(args.libraryName)
        }
      ]
    };
  }
  
  throw new Error(`Unknown tool: ${name}`);
});
```

### Resource Management Pattern
```typescript
// Based on semantic search for MCP resource patterns
server.setRequestHandler(ResourceRequestSchema, async (request) => {
  const { uri } = request.params;
  
  // Search: "MCP resource URI handling patterns"
  // Implementation based on Context7 resource management
  return {
    contents: [
      {
        uri,
        mimeType: 'text/plain',
        text: await getResourceContent(uri)
      }
    ]
  };
});
```

## Anti-Patterns

**DON'T** implement these MCP anti-patterns:
- Implementing MCP servers without studying Context7 reference implementation
- Using outdated MCP protocol patterns without Context7 verification
- Ignoring MCP specification compliance found through semantic search
- Bypassing MCP error handling patterns demonstrated in Context7

**AVOID** these common MCP mistakes:
- Duplicate MCP server implementations without semantic search for existing patterns
- Custom MCP protocol extensions without Context7 specification verification
- Complex MCP implementations when semantic search reveals simpler alternatives
- Missing MCP protocol compliance requirements identified through Context7

**NEVER** do these actions:
- Implement MCP servers without consulting current protocol specification
- Ignore Context7 MCP server implementation patterns
- Override MCP protocol requirements without Context7 documentation
- Disable MCP protocol compliance testing

## Code Examples

### Context7-Inspired MCP Server
```typescript
// Implementation inspired by Context7 MCP server patterns
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

// Search: "MCP server initialization patterns"
const server = new Server({
  name: 'semantic-search-server',
  version: '1.0.0',
  capabilities: {
    tools: {},
    resources: {}
  }
});

// Based on Context7 tool implementation patterns
server.setRequestHandler(ToolRequestSchema, async (request) => {
  // Implementation following Context7 patterns
});

// Context7-inspired error handling
server.onerror = (error) => {
  console.error('MCP Server Error:', error);
};
```

### Semantic Search Integration
```typescript
// MCP server with semantic search capabilities
server.setRequestHandler(ToolRequestSchema, async (request) => {
  if (request.params.name === 'semantic-search') {
    // Search: "semantic search implementation patterns"
    const results = await performSemanticSearch(request.params.arguments.query);
    
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(results, null, 2)
        }
      ]
    };
  }
});
```

## Validation Checklist

**MUST** verify:
- [ ] Semantic search performed for MCP implementation patterns
- [ ] Context7 MCP server studied as reference implementation
- [ ] Current MCP protocol specification consulted via Context7
- [ ] MCP server implementation follows Context7 patterns
- [ ] Protocol compliance verified through Context7 documentation

**SHOULD** check:
- [ ] Context7 MCP server configured in development environment
- [ ] Semantic search results documented for MCP pattern sharing
- [ ] MCP implementation follows Context7 best practices
- [ ] Code reuse opportunities identified through semantic search
- [ ] MCP protocol version compatibility verified via Context7

## Context7 MCP Server Analysis

**STUDY** Context7 implementation for these MCP patterns:

### Tool Implementation
- Clean tool registration and handling
- Proper error response formatting
- Input validation and sanitization
- Structured response formatting

### Resource Management
- Dynamic resource discovery
- Efficient content retrieval
- Proper MIME type handling
- Resource caching strategies

### Protocol Compliance
- Capability declaration
- Error handling standards
- Message format compliance
- Transport abstraction

## References

- [Context7 MCP Server](https://github.com/upstash/context7) - Reference implementation
- [MCP Protocol Specification](https://spec.modelcontextprotocol.io/)
- [MCP SDK Documentation](https://github.com/modelcontextprotocol)
- [Context7 Documentation](https://context7.com/docs)
- [MCP Reference Servers](https://github.com/modelcontextprotocol/servers)
