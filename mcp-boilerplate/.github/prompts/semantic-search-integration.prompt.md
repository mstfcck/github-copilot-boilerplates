# Semantic Search & Context7 Integration Prompt for MCP Development

This prompt provides guidance for leveraging semantic search capabilities and Context7 MCP server integration for enhanced Model Context Protocol (MCP) development with AI assistance.

## Objective

To accelerate MCP development by using semantic search to find relevant MCP patterns and Context7 for accessing up-to-date MCP documentation and protocol specifications.

## Prerequisites

**MUST** have these prerequisites:
- AI development environment with MCP support
- Context7 MCP server configured and accessible
- Basic understanding of MCP protocol and architecture
- Familiarity with MCP SDKs and reference implementations

**SHOULD** review these resources:
- Context7 MCP server as reference implementation
- MCP protocol specification via Context7
- MCP SDK documentation and examples
- Reference server implementations

## Step-by-Step Process

### Phase 1: MCP Environment Setup
**DO** these actions:
1. Configure Context7 MCP server in your development environment
2. Study Context7 as a reference MCP server implementation
3. Verify semantic search capabilities for MCP pattern discovery
4. Test Context7 integration with MCP-specific queries

**ENSURE** these validations:
- Context7 MCP server responds to tool and resource requests
- Semantic search finds relevant MCP server patterns
- Development environment supports MCP protocol
- Context7 provides current MCP specification documentation

### Phase 2: MCP Development Workflow
**IMPLEMENT** these MCP-specific practices:
1. Use semantic search to find MCP server implementation patterns
2. Query Context7 for current MCP protocol documentation
3. Study Context7 source code for MCP best practices
4. Validate implementations against MCP specification via Context7

**ALWAYS** follow this MCP workflow:
- Search for existing MCP patterns using semantic search
- Query Context7 for up-to-date MCP documentation
- Study Context7 implementation for reference patterns
- Implement following MCP protocol compliance
- Validate against Context7 documentation and patterns

### Phase 3: Advanced MCP Integration
**LEVERAGE** these advanced MCP techniques:
1. Use Context7 as both reference and documentation source
2. Implement semantic search for MCP pattern discovery
3. Create MCP-specific automated prompts
4. Build MCP knowledge base from Context7 insights

**OPTIMIZE** your MCP development process:
- Study Context7 tool and resource implementation patterns
- Document MCP patterns discovered through semantic search
- Establish MCP-specific Context7 queries
- Build MCP knowledge base from Context7 documentation

## Expected Outcomes

**MUST** achieve:
- Faster discovery of MCP implementation patterns
- Access to current MCP protocol specification
- Reduced MCP development time through pattern reuse
- Higher MCP protocol compliance through current standards

**SHOULD** produce:
- Consistent MCP server implementations
- Up-to-date MCP protocol adherence
- Reduced debugging time through proven MCP patterns
- Enhanced MCP knowledge sharing

## Context7 MCP Integration Examples

### MCP Server Implementation
```bash
# Create MCP server with current best practices
"Create an MCP server with tools and resources capabilities. use context7"

# Study Context7 MCP server patterns
"Analyze Context7 MCP server implementation for tool patterns. use context7"

# MCP protocol compliance
"Validate MCP server implementation against current specification. use context7"
```

### MCP SDK Integration
```bash
# Python SDK implementation
"Implement MCP server using Python SDK with proper error handling. use library /modelcontextprotocol/python-sdk"

# TypeScript SDK patterns
"Create MCP client with TypeScript SDK. use library /modelcontextprotocol/typescript-sdk"

# Java SDK implementation
"Implement MCP server with Java SDK. use library /modelcontextprotocol/java-sdk"
```

### Context7 as Reference Implementation
```bash
# Learn from Context7 patterns
"Show Context7 MCP server tool registration patterns. use context7"

# Study Context7 resource management
"Explain Context7 resource URI handling implementation. use context7"

# Understand Context7 error handling
"Analyze Context7 MCP server error handling patterns. use context7"
```

## Semantic Search for MCP Development

### Finding MCP Patterns
```bash
# Search for MCP server patterns
semantic_search("MCP server implementation with tools and resources")

# Search for MCP client patterns
semantic_search("MCP client connection handling and reconnection")

# Search for MCP protocol compliance
semantic_search("MCP protocol validation and error handling")
```

### MCP Code Discovery Workflow
1. Use semantic search to find similar MCP implementations
2. Analyze MCP patterns and protocol adherence
3. Query Context7 for current MCP specification
4. Study Context7 implementation as reference
5. Combine insights to create optimal MCP implementation
6. Validate against MCP protocol requirements

## Quality Checks

**VERIFY** these MCP-specific items:
- [ ] Semantic search performed for MCP patterns
- [ ] Context7 consulted for current MCP documentation
- [ ] Context7 studied as reference implementation
- [ ] MCP protocol compliance verified
- [ ] MCP server capabilities properly declared

**VALIDATE** MCP implementation quality:
- [ ] Patterns align with Context7 implementation
- [ ] Current MCP specification followed
- [ ] Error handling follows MCP protocol
- [ ] Tool and resource patterns implemented correctly
- [ ] Transport abstraction properly handled

## Common MCP Issues and Solutions

**IF** Context7 MCP server tools not working:
- **THEN** check tool registration and capability declaration
- **VERIFY** tool request handling follows MCP protocol
- **ENSURE** proper error response formatting

**IF** semantic search returns no MCP patterns:
- **THEN** try MCP-specific search terms
- **REFINE** search with MCP protocol concepts
- **EXPAND** search to include Context7 patterns

**IF** MCP protocol compliance issues:
- **THEN** verify against Context7 implementation
- **CHECK** MCP specification via Context7
- **VALIDATE** message format and transport handling

## Follow-up Actions

**MUST** complete:
- Document MCP patterns discovered through semantic search
- Share Context7 insights with MCP development team
- Update MCP development guidelines based on findings
- Establish regular Context7 documentation reviews

**SHOULD** consider:
- Creating automated Context7 integration workflows
- Building MCP semantic search query templates
- Establishing team standards for MCP development
- Contributing MCP patterns back to knowledge base

## Context7 MCP Server Analysis

**STUDY** Context7 for these MCP implementation patterns:

### Tool Implementation
```typescript
// Based on Context7 patterns
server.setRequestHandler(ToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  
  // Context7 pattern: Clean tool handling
  if (name === 'resolve-library-id') {
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

### Resource Management
```typescript
// Based on Context7 resource patterns
server.setRequestHandler(ResourceRequestSchema, async (request) => {
  const { uri } = request.params;
  
  // Context7 pattern: Dynamic resource handling
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

### Error Handling
```typescript
// Based on Context7 error patterns
server.onerror = (error) => {
  console.error('MCP Server Error:', error);
  // Context7 pattern: Structured error logging
};
```

## Team Collaboration for MCP Development

**ESTABLISH** these MCP team practices:
- Regular sharing of Context7 MCP insights
- MCP pattern documentation and semantic search queries
- MCP protocol compliance review sessions
- Context7 reference implementation study sessions

**ENCOURAGE** these MCP behaviors:
- Consistent use of Context7 for MCP documentation
- Semantic search before implementing MCP features
- Team review of Context7 implementation patterns
- Continuous improvement of MCP development techniques

This prompt serves as a comprehensive guide for integrating semantic search and Context7 into your MCP development workflow, ensuring faster development, higher protocol compliance, and access to current MCP best practices.
