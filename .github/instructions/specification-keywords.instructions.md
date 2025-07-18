---
applyTo: '**'
---

# Specification Keywords Usage Guide

This document provides comprehensive guidance on using RFC 2119/8174 specification keywords in GitHub Copilot Boilerplate instructions to ensure consistent interpretation and implementation.

## Keyword Classification and Usage

### Absolute Requirements (Non-Negotiable)

#### **MUST** / **REQUIRED** / **SHALL**
**Definition**: Absolute requirement of the specification that cannot be ignored.

**Usage Examples**:
```markdown
**MUST** include comprehensive test coverage for all public methods
**REQUIRED** to implement proper input validation on all API endpoints
**SHALL** follow the specified directory structure exactly as documented
```

**When to Use**:
- Security requirements that prevent vulnerabilities
- Protocol compliance requirements
- Essential architectural constraints
- Critical quality gates

#### **MUST NOT** / **SHALL NOT**
**Definition**: Absolute prohibition that must never be violated.

**Usage Examples**:
```markdown
**MUST NOT** store passwords in plain text
**SHALL NOT** expose internal implementation details in public APIs
**MUST NOT** use deprecated dependencies in production code
```

**When to Use**:
- Security anti-patterns
- Prohibited architectural approaches
- Dangerous coding practices
- Compliance violations

#### **NEVER**
**Definition**: Absolute prohibition with emphasis on critical implications.

**Usage Examples**:
```markdown
**NEVER** commit secrets or API keys to version control
**NEVER** disable security features in production environments
**NEVER** use synchronous blocking calls in async contexts
```

**When to Use**:
- Critical security violations
- Performance-killing patterns
- Data integrity threats
- System stability risks

### Strong Recommendations (Best Practices)

#### **SHOULD** / **RECOMMENDED**
**Definition**: Strong recommendation that should be followed unless there are valid reasons not to.

**Usage Examples**:
```markdown
**SHOULD** implement circuit breaker patterns for external service calls
**RECOMMENDED** to use dependency injection instead of service locator pattern
**SHOULD** include integration tests for critical business workflows
```

**When to Use**:
- Industry best practices
- Performance optimizations
- Maintainability improvements
- Scalability patterns

#### **SHOULD NOT** / **NOT RECOMMENDED**
**Definition**: Strong recommendation against a practice, with valid exceptions possible.

**Usage Examples**:
```markdown
**SHOULD NOT** use field injection in favor of constructor injection
**NOT RECOMMENDED** to implement custom security mechanisms
**SHOULD NOT** create God classes with multiple responsibilities
```

**When to Use**:
- Common anti-patterns
- Poor design choices
- Maintenance challenges
- Performance concerns

#### **ALWAYS**
**Definition**: Strong recommendation for consistency and reliability.

**Usage Examples**:
```markdown
**ALWAYS** validate input parameters at service boundaries
**ALWAYS** use parameterized queries to prevent SQL injection
**ALWAYS** implement proper error handling and logging
```

**When to Use**:
- Consistency requirements
- Reliability patterns
- Quality assurance practices
- Standard procedures

#### **DO**
**Definition**: Strong recommendation for implementation patterns.

**Usage Examples**:
```markdown
**DO** implement builder patterns for complex object creation
**DO** use meaningful names for variables, methods, and classes
**DO** separate business logic from presentation logic
```

**When to Use**:
- Recommended implementation approaches
- Code quality improvements
- Design pattern applications
- Best practice implementations

#### **DON'T**
**Definition**: Strong recommendation against specific approaches.

**Usage Examples**:
```markdown
**DON'T** catch generic exceptions without proper handling
**DON'T** use magic numbers or strings in business logic
**DON'T** couple components tightly without interfaces
```

**When to Use**:
- Common mistakes to avoid
- Anti-pattern prevention
- Code quality issues
- Design smell indicators

### Optional Guidelines (Flexibility Allowed)

#### **MAY** / **OPTIONAL**
**Definition**: Truly optional choices that implementers may choose based on their needs.

**Usage Examples**:
```markdown
**MAY** implement caching for frequently accessed data
**OPTIONAL** to add monitoring dashboards for advanced observability
**MAY** choose between PostgreSQL or MySQL based on team expertise
```

**When to Use**:
- Enhancement opportunities
- Technology choice flexibility
- Feature variations
- Implementation alternatives

#### **USE**
**Definition**: Recommended tool, library, or technology choice.

**Usage Examples**:
```markdown
**USE** Spring Security for authentication and authorization
**USE** JUnit 5 and Mockito for testing frameworks
**USE** SLF4J with Logback for logging implementation
```

**When to Use**:
- Technology stack recommendations
- Tool selection guidance
- Library preferences
- Framework choices

#### **IMPLEMENT**
**Definition**: Recommended implementation approach or pattern.

**Usage Examples**:
```markdown
**IMPLEMENT** repository pattern for data access layer
**IMPLEMENT** DTO pattern for API data transfer
**IMPLEMENT** factory pattern for object creation strategies
```

**When to Use**:
- Design pattern recommendations
- Architectural approach suggestions
- Implementation strategy guidance
- Code organization patterns

#### **ENSURE**
**Definition**: Recommended verification or validation step.

**Usage Examples**:
```markdown
**ENSURE** all dependencies are up to date before deployment
**ENSURE** proper error messages are returned to API consumers
**ENSURE** database connections are properly closed after use
```

**When to Use**:
- Quality assurance steps
- Validation requirements
- Verification procedures
- Safety checks

#### **AVOID**
**Definition**: Recommended approach to prevent common issues.

**Usage Examples**:
```markdown
**AVOID** deep inheritance hierarchies in favor of composition
**AVOID** premature optimization without performance measurements
**AVOID** tight coupling between unrelated components
```

**When to Use**:
- Issue prevention
- Common pitfall warnings
- Design smell avoidance
- Maintenance burden reduction

## Keyword Combination Patterns

### Progressive Requirements Structure

```markdown
## Feature Implementation Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** implement proper authentication for all endpoints
- **REQUIRED** to validate all input parameters
- **SHALL** log all security-related events

### Strong Recommendations (**SHOULD** Implement)  
- **SHOULD** implement rate limiting for public APIs
- **RECOMMENDED** to use caching for frequently accessed data
- **ALWAYS** include comprehensive error handling

### Implementation Guidance (**DO** Apply)
- **DO** use established design patterns
- **IMPLEMENT** proper separation of concerns
- **USE** dependency injection for component management

### Quality Assurance (**ENSURE** Verification)
- **ENSURE** all code paths are covered by tests
- **VERIFY** performance requirements are met
- **VALIDATE** security configurations before deployment

### Anti-Patterns (**DON'T** / **AVOID**)
- **DON'T** expose internal implementation details
- **NEVER** store sensitive data in logs
- **AVOID** complex nested conditional logic

### Optional Enhancements (**MAY** Consider)
- **MAY** implement advanced monitoring features
- **OPTIONAL** to add performance optimization
- **NICE TO HAVE** automated deployment pipelines
```

### Conditional Requirements

```markdown
**IF** implementing microservices architecture:
- **MUST** implement service discovery
- **SHOULD** use circuit breaker patterns
- **MAY** consider event-driven communication

**IF** handling sensitive data:
- **MUST** encrypt data at rest and in transit
- **NEVER** log sensitive information
- **REQUIRED** to implement proper access controls

**WHEN** deploying to production:
- **MUST** have proper monitoring in place
- **SHALL** implement health check endpoints
- **REQUIRED** to have rollback procedures ready
```

## Documentation Standards for Keywords

### Formatting Requirements

**MUST** format specification keywords as:
- Bold text with double asterisks: `**KEYWORD**`
- All uppercase letters only
- Consistent spacing and punctuation

### Context Requirements

**SHOULD** provide context for each keyword usage:
- Clear explanation of what is required/recommended
- Specific implementation guidance
- Rationale for the requirement level

### Example Structure

```markdown
**MUST** implement input validation:
- Validate all user inputs at API boundaries
- Use appropriate validation libraries (Bean Validation)
- Return meaningful error messages for invalid inputs
- Prevent injection attacks through proper sanitization

Rationale: Input validation is critical for security and prevents
common vulnerabilities like SQL injection and XSS attacks.
```

## Compliance Verification

### Content Review Checklist

**VERIFY** all instruction documents include:
- [ ] Proper keyword formatting (bold, uppercase)
- [ ] Consistent keyword usage throughout
- [ ] Clear context and rationale for requirements
- [ ] Appropriate requirement levels for each instruction
- [ ] No contradictory requirements or recommendations

### AI Testing Validation

**ENSURE** all instructions are tested with GitHub Copilot:
- [ ] AI can interpret keywords correctly
- [ ] Generated code follows specified requirements
- [ ] Recommendations are implemented appropriately
- [ ] Anti-patterns are properly avoided
- [ ] Optional items are treated as suggestions

### Quality Assurance Process

**MUST** complete before publication:
1. **Technical Review**: Verify technical accuracy
2. **Keyword Compliance**: Check RFC 2119/8174 adherence
3. **AI Compatibility**: Test with GitHub Copilot
4. **User Validation**: Verify developer comprehension
5. **Consistency Check**: Ensure project-wide consistency

This guide ensures consistent interpretation and implementation of specification keywords across all GitHub Copilot Boilerplate instructions, improving clarity and effectiveness of AI-guided development.
