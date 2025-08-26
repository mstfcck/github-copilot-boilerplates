# OpenAPI YAML Generator - AI Agent Prompt

This prompt is designed to help AI agents generate high-quality, production-ready OpenAPI YAML specifications following industry best practices and standards.

## Objective

Generate comprehensive OpenAPI 3.1.x YAML specifications that are:
- **Syntactically correct** and validate against OpenAPI schema
- **Semantically meaningful** with clear, well-documented APIs
- **Production-ready** with proper security, error handling, and examples
- **Consistent** following established patterns and conventions

## Prerequisites

**MUST** have these prerequisites:
- Understanding of OpenAPI Specification 3.1.x
- Knowledge of RESTful API design principles
- Familiarity with YAML syntax and formatting
- Awareness of HTTP methods and status codes

**SHOULD** review these resources:
- [OpenAPI Specification 3.1.0](https://spec.openapis.org/oas/v3.1.0)
- [HTTP Semantics (RFC 9110)](https://httpwg.org/specs/rfc9110.html)
- [JSON Schema Draft 2020-12](https://json-schema.org/draft/2020-12/schema)

## Step-by-Step Process

### Phase 1: Information Gathering
**DO** these actions:
1. **Analyze Requirements**: Understand the API purpose, domain, and business context
2. **Identify Resources**: Determine main entities and their relationships
3. **Define Operations**: Map business operations to HTTP methods and endpoints
4. **Consider Constraints**: Note security, performance, and compliance requirements

**ENSURE** these validations:
- Requirements are clearly understood and documented
- Resource model is logical and follows domain boundaries
- Operations align with business workflows

### Phase 2: Structure Definition
**DO** these actions:
1. **Create Info Object**: Define API metadata, contact, license, and description
2. **Define Servers**: Specify development, staging, and production environments
3. **Plan Security**: Choose appropriate authentication and authorization schemes
4. **Design Paths**: Create resource-oriented URL structure

**ENSURE** these validations:
- Info object is comprehensive with proper versioning
- Server URLs follow environment conventions
- Security schemes meet project requirements
- Path design follows RESTful principles

### Phase 3: Schema Design
**DO** these actions:
1. **Create Core Schemas**: Define main data models with proper validation
2. **Design Request/Response Objects**: Create input/output structures
3. **Define Error Schemas**: Standardize error response formats
4. **Add Examples**: Include realistic, validating examples

**ENSURE** these validations:
- Schemas use appropriate data types and constraints
- Required fields are properly marked
- Examples validate against their schemas
- Error responses are comprehensive

### Phase 4: Endpoint Implementation
**DO** these actions:
1. **Implement Operations**: Define each endpoint with complete metadata
2. **Add Parameters**: Include path, query, and header parameters
3. **Define Responses**: Cover all possible response scenarios
4. **Include Security**: Apply appropriate security requirements

**ENSURE** these validations:
- All HTTP methods follow semantic correctness
- Parameters have proper validation and examples
- Response codes match operation outcomes
- Security is consistently applied

### Phase 5: Documentation and Examples
**DO** these actions:
1. **Write Descriptions**: Add clear, comprehensive documentation
2. **Create Examples**: Include realistic request/response examples
3. **Add Comments**: Explain complex business logic or constraints
4. **Review Completeness**: Ensure all components are documented

**ENSURE** these validations:
- Documentation is clear and actionable
- Examples demonstrate real-world usage
- Complex scenarios are properly explained
- API is self-documenting

### Phase 6: Validation and Quality Assurance
**DO** these actions:
1. **Validate Syntax**: Check YAML formatting and OpenAPI compliance
2. **Test Examples**: Verify all examples validate against schemas
3. **Review Consistency**: Ensure patterns are applied consistently
4. **Check Completeness**: Verify all requirements are addressed

**ENSURE** these validations:
- OpenAPI specification validates without errors
- All examples are realistic and correct
- Naming conventions are consistent throughout
- Security and error handling are comprehensive

## Expected Outcomes

**MUST** achieve:
- Valid OpenAPI 3.1.x YAML specification
- Complete API documentation with examples
- Proper security implementation
- Consistent error handling

**SHOULD** produce:
- Self-documenting API specification
- Realistic, practical examples
- Clear operation descriptions
- Comprehensive validation rules

## Quality Checks

**VERIFY** these items:
- [ ] OpenAPI specification validates against 3.1.x schema
- [ ] All endpoints follow RESTful design principles
- [ ] HTTP methods and status codes are semantically correct
- [ ] Security schemes are properly implemented
- [ ] Error responses follow consistent format
- [ ] All schemas include appropriate validation rules
- [ ] Examples are realistic and validate against schemas
- [ ] Documentation is comprehensive and clear
- [ ] YAML formatting is consistent (2-space indentation)
- [ ] Naming conventions are applied consistently

## Common Issues and Solutions

**IF** validation errors occur:
- **THEN** check YAML syntax and indentation (use 2 spaces)
- **VERIFY** all required OpenAPI fields are present
- **ENSURE** examples match their corresponding schemas

**IF** design seems complex:
- **THEN** simplify resource hierarchies
- **CONSIDER** breaking into smaller, focused APIs
- **REVIEW** business requirements for unnecessary complexity

**IF** security implementation is unclear:
- **THEN** choose OAuth 2.0 for user authentication
- **USE** API keys for service-to-service communication
- **IMPLEMENT** proper scope definitions for authorization

## Follow-up Actions

**MUST** complete:
- Validate generated specification with OpenAPI tools
- Review with stakeholders for business accuracy
- Test with mock server or code generation tools
- Document deployment and usage procedures

**SHOULD** consider:
- Generate client SDKs to verify usability
- Create integration tests based on examples
- Set up automated validation in CI/CD pipeline
- Plan for API versioning and evolution

## Template Structure

```yaml
openapi: 3.1.0
info:
  title: [API Name]
  description: |
    [Comprehensive API description]
    
    ## Features
    - [Key feature 1]
    - [Key feature 2]
    
    ## Authentication
    [Authentication description]
  version: [Version number]
  contact:
    name: [Contact name]
    email: [Contact email]
    url: [Contact URL]
  license:
    name: [License name]
    url: [License URL]

servers:
  - url: [Production URL]
    description: Production server
  - url: [Staging URL]
    description: Staging server

security:
  - [Default security requirement]

paths:
  [Resource paths with operations]

components:
  schemas:
    [Data models and schemas]
  
  responses:
    [Reusable response definitions]
  
  parameters:
    [Reusable parameter definitions]
  
  securitySchemes:
    [Security scheme definitions]
  
  examples:
    [Reusable example definitions]

tags:
  [API operation tags for organization]
```

This prompt provides comprehensive guidance for AI agents to generate production-ready OpenAPI YAML specifications that follow industry best practices and maintain high quality standards.
