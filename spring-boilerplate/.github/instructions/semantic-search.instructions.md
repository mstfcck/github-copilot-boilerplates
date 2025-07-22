---
applyTo: '**'
---

# Semantic Search & Context7 Integration Instructions

This document provides guidance on leveraging semantic search capabilities and Context7 MCP server integration for enhanced Spring Boot development with AI assistance.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** use semantic search to find relevant code patterns before implementing new features
- **REQUIRED** to verify implementation approaches against current Spring Boot documentation via Context7
- **SHALL** integrate Context7 MCP server for accessing up-to-date Spring Boot documentation
- **NEVER** rely solely on potentially outdated training data without Context7 verification

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** use semantic search to identify existing patterns in the codebase
- **RECOMMENDED** to append 'use context7' to AI prompts for Spring Boot-specific queries
- **ALWAYS** cross-reference semantic search results with Context7 documentation
- **DO** leverage Context7 for Spring Boot library-specific documentation
- **DON'T** implement features without first searching for existing patterns

### Optional Enhancements (**MAY** Consider)
- **MAY** set up automated semantic search integration in CI/CD pipelines
- **OPTIONAL** to configure Context7 auto-invocation rules for development teams
- **USE** Context7 library-specific IDs for targeted documentation access
- **IMPLEMENT** semantic search-based code review processes
- **AVOID** duplicate implementations without semantic search validation

## Context7 MCP Server Configuration

**USE** these Context7 configurations for different development environments:

### VS Code Configuration
```json
{
  "mcp": {
    "servers": {
      "context7": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "@upstash/context7-mcp"]
      }
    }
  }
}
```

### Cursor IDE Configuration
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

### Remote Server Configuration
```json
{
  "mcpServers": {
    "context7": {
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

## Semantic Search Implementation Guidance

**IMPLEMENT** these semantic search patterns for Spring Boot development:

### Finding Existing Patterns
```bash
# Search for controller patterns
semantic_search("REST controller implementation with exception handling")

# Search for service layer patterns
semantic_search("Spring service class with transaction management")

# Search for repository patterns
semantic_search("JPA repository with custom queries")
```

### Code Pattern Discovery
```java
// Use semantic search to find similar patterns before implementing
@RestController
@RequestMapping("/api/v1/users")
public class UserController {
    
    // Search for: "Spring Boot exception handling patterns"
    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserNotFound(UserNotFoundException ex) {
        // Implementation based on semantic search results
    }
}
```

## Context7 Integration Patterns

**ENSURE** these Context7 integration approaches:

### Spring Boot Specific Queries
```bash
# Current Spring Boot documentation
"Create a Spring Boot REST API with proper validation. use context7"

# Spring Security integration
"Implement JWT authentication with Spring Security 6.x. use library /springframework/spring-security"

# Spring Data JPA queries
"Create JPA repository with pagination and sorting. use context7"
```

### Library-Specific Documentation Access
```bash
# Target specific Spring libraries
"Configure Spring Boot Actuator endpoints. use library /springframework/spring-boot"

# Spring Cloud patterns
"Implement circuit breaker with Spring Cloud. use library /springframework/spring-cloud"

# Spring WebFlux reactive patterns
"Create reactive REST API with WebFlux. use library /springframework/spring-webflux"
```

## Anti-Patterns

**DON'T** implement these approaches:
- Implementing features without semantic search for existing patterns
- Using outdated documentation without Context7 verification
- Ignoring similar implementations found through semantic search
- Copying patterns without understanding Context7 best practices

**AVOID** these common mistakes:
- Duplicate implementations without semantic search validation
- Outdated Spring Boot patterns not verified through Context7
- Complex custom solutions when semantic search reveals simpler alternatives
- Missing opportunities for code reuse identified through semantic search

**NEVER** do these actions:
- Disable semantic search capabilities in development environments
- Ignore Context7 documentation updates for Spring Boot versions
- Implement security patterns without Context7 verification
- Override established patterns without semantic search justification

## Code Examples

### Semantic Search Integration
```java
// Before implementing, search for existing patterns
@Service
@Transactional
public class UserService {
    
    // Search: "Spring Boot service layer exception handling"
    public UserDto createUser(CreateUserRequest request) {
        // Implementation guided by semantic search results
        // and Context7 current best practices
    }
}
```

### Context7 Enhanced Development
```java
// Use Context7 for current Spring Boot practices
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    // Context7 query: "Spring Security 6.x JWT configuration"
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        // Implementation based on Context7 current documentation
        return http.build();
    }
}
```

## Validation Checklist

**MUST** verify:
- [ ] Semantic search performed before implementing new features
- [ ] Context7 documentation consulted for Spring Boot patterns
- [ ] Similar implementations identified through semantic search
- [ ] Current Spring Boot best practices verified via Context7
- [ ] Code patterns align with semantic search results

**SHOULD** check:
- [ ] Context7 MCP server properly configured in development environment
- [ ] Semantic search results documented for team knowledge sharing
- [ ] Implementation follows Context7 recommended patterns
- [ ] Code reuse opportunities identified through semantic search
- [ ] Spring Boot version compatibility verified via Context7

## References

- [Context7 MCP Server Documentation](https://github.com/upstash/context7)
- [Spring Boot Official Documentation](https://spring.io/projects/spring-boot)
- [Model Context Protocol Specification](https://spec.modelcontextprotocol.io/)
- [Semantic Search Best Practices](https://docs.github.com/en/search-github/getting-started-with-searching-on-github/about-searching-on-github)
- [Spring Boot Context7 Library ID](https://context7.com/docs/spring-boot)
