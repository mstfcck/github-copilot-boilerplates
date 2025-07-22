# Semantic Search & Context7 Integration Prompt

This prompt provides guidance for leveraging semantic search capabilities and Context7 MCP server integration for enhanced development with AI assistance.

## Objective

To accelerate development by using semantic search to find relevant code patterns and Context7 for accessing up-to-date documentation and best practices.

## Prerequisites

**MUST** have these prerequisites:
- AI development environment (VS Code, Cursor, Claude, etc.)
- Context7 MCP server configured and accessible
- Basic understanding of semantic search capabilities
- Familiarity with the target technology stack

**SHOULD** review these resources:
- Context7 MCP server documentation
- Semantic search best practices
- Current technology documentation via Context7

## Step-by-Step Process

### Phase 1: Environment Setup
**DO** these actions:
1. Configure Context7 MCP server in your development environment
2. Verify semantic search capabilities are available
3. Test Context7 integration with sample queries

**ENSURE** these validations:
- Context7 MCP server responds to basic queries
- Semantic search returns relevant results
- Development environment supports both tools

### Phase 2: Development Workflow Integration
**IMPLEMENT** these practices:
1. Use semantic search before implementing new features
2. Append 'use context7' to technology-specific queries
3. Cross-reference semantic search results with Context7 documentation
4. Validate implementations against current best practices

**ALWAYS** follow this workflow:
- Search for existing patterns using semantic search
- Query Context7 for up-to-date documentation
- Implement following discovered patterns and current practices
- Validate against both semantic search results and Context7 guidance

### Phase 3: Advanced Integration
**LEVERAGE** these advanced techniques:
1. Use Context7 library-specific IDs for targeted documentation
2. Implement semantic search-based code review processes
3. Create automated prompts that combine both tools
4. Establish team patterns for consistent usage

**OPTIMIZE** your development process:
- Create Context7 auto-invocation rules
- Document discovered patterns for team sharing
- Establish semantic search queries for common tasks
- Build knowledge base from Context7 insights

## Expected Outcomes

**MUST** achieve:
- Faster discovery of relevant code patterns
- Access to current documentation and best practices
- Reduced implementation time through pattern reuse
- Higher code quality through current standards adherence

**SHOULD** produce:
- Consistent code patterns across projects
- Up-to-date implementations following current best practices
- Reduced debugging time through proven patterns
- Enhanced team knowledge sharing

## Context7 Integration Examples

### Spring Boot Development
```bash
# Find Spring Boot patterns
"Create a Spring Boot REST controller with proper exception handling. use context7"

# Access specific library documentation
"Implement JWT authentication with Spring Security 6.x. use library /springframework/spring-security"

# Query for current best practices
"Configure Spring Boot Actuator endpoints. use context7"
```

### MCP Development
```bash
# MCP server implementation
"Create an MCP server with tools and resources capabilities. use context7"

# Protocol compliance
"Validate MCP server implementation against current specification. use context7"

# SDK-specific patterns
"Implement MCP client with TypeScript SDK. use library /modelcontextprotocol/typescript-sdk"
```

### General Development
```bash
# Current framework patterns
"Implement authentication middleware with proper error handling. use context7"

# Library-specific integration
"Configure database connection with current best practices. use context7"

# Performance optimization
"Optimize API response time with current techniques. use context7"
```

## Semantic Search Integration

### Finding Existing Patterns
```bash
# Search for controller patterns
semantic_search("REST controller implementation with exception handling")

# Search for service layer patterns
semantic_search("service class with transaction management")

# Search for testing patterns
semantic_search("integration test setup and configuration")
```

### Code Discovery Workflow
1. Use semantic search to find similar implementations
2. Analyze patterns and approaches found
3. Query Context7 for current best practices
4. Combine insights to create optimal implementation
5. Validate against both sources

## Quality Checks

**VERIFY** these items:
- [ ] Semantic search performed before implementation
- [ ] Context7 consulted for current documentation
- [ ] Similar patterns identified and analyzed
- [ ] Implementation follows current best practices
- [ ] Code quality meets established standards

**VALIDATE** implementation quality:
- [ ] Patterns align with semantic search results
- [ ] Current standards verified through Context7
- [ ] Error handling follows discovered patterns
- [ ] Performance considerations addressed
- [ ] Security practices implemented correctly

## Common Issues and Solutions

**IF** Context7 MCP server is not responding:
- **THEN** check server configuration and restart
- **VERIFY** network connectivity and authentication
- **ENSURE** correct MCP server URL and transport

**IF** semantic search returns no results:
- **THEN** try broader search terms
- **REFINE** search query with specific technology terms
- **EXPAND** search scope to include related patterns

**IF** Context7 documentation seems outdated:
- **THEN** verify you're using the latest Context7 version
- **CHECK** if library-specific ID is correct
- **QUERY** Context7 for latest version information

## Follow-up Actions

**MUST** complete:
- Document discovered patterns for team knowledge base
- Share Context7 insights with development team
- Update development guidelines based on findings
- Establish regular Context7 documentation reviews

**SHOULD** consider:
- Creating automated Context7 integration workflows
- Building semantic search query templates
- Establishing team standards for tool usage
- Contributing patterns back to knowledge base

## Team Collaboration

**ESTABLISH** these team practices:
- Regular sharing of Context7 insights
- Semantic search query documentation
- Pattern discovery sessions
- Knowledge base maintenance

**ENCOURAGE** these behaviors:
- Consistent use of Context7 for documentation queries
- Semantic search before implementing new features
- Team review of discovered patterns
- Continuous improvement of search techniques

This prompt serves as a comprehensive guide for integrating semantic search and Context7 into your development workflow, ensuring faster development, higher quality code, and access to current best practices.
