# OpenAPI YAML Generator - Project Initialization

This prompt guides you through setting up a new API project using OpenAPI specifications with comprehensive planning and documentation.

## Objective

Initialize a complete API project with properly structured OpenAPI specifications, following industry standards and best practices for enterprise-grade API development.

## Prerequisites

**MUST** have these prerequisites:
- Clear understanding of the business domain and requirements
- Knowledge of the target audience (internal, external, partner APIs)
- Understanding of data models and business entities
- Awareness of security and compliance requirements

**SHOULD** review these resources:
- Business requirements and use cases
- Existing API standards in the organization
- Data governance and security policies
- Integration and deployment requirements

## Step-by-Step Process

### Phase 1: Project Analysis and Planning
**DO** these actions:
1. **Gather Requirements**: Document functional and non-functional requirements
2. **Analyze Domain**: Understand business entities and their relationships
3. **Define Scope**: Determine API boundaries and responsibilities
4. **Plan Architecture**: Choose architectural patterns and design principles

**ENSURE** these validations:
- All stakeholder requirements are captured
- Domain model is clearly understood
- API scope is well-defined and focused
- Architectural decisions are documented

### Phase 2: API Design and Structure
**DO** these actions:
1. **Design Resource Model**: Define core resources and their hierarchies
2. **Plan Operations**: Map business operations to HTTP methods
3. **Define Data Models**: Create comprehensive schema definitions
4. **Plan Security**: Choose authentication and authorization strategies

**ENSURE** these validations:
- Resource model follows RESTful principles
- Operations cover all business requirements
- Data models are comprehensive and validated
- Security approach meets compliance requirements

### Phase 3: OpenAPI Specification Creation
**DO** these actions:
1. **Initialize Specification**: Create the base OpenAPI YAML structure
2. **Define Metadata**: Complete info, servers, and contact information
3. **Implement Paths**: Create all endpoint definitions with operations
4. **Add Components**: Define reusable schemas, responses, and parameters

**ENSURE** these validations:
- OpenAPI specification is syntactically valid
- All endpoints are properly documented
- Components are reusable and well-structured
- Examples are realistic and comprehensive

## Expected Outcomes

**MUST** achieve:
- Complete OpenAPI 3.1.x specification
- Comprehensive API documentation
- Realistic examples and test cases
- Proper security implementation
- Consistent error handling patterns

**SHOULD** produce:
- Development environment setup
- Mock server configuration
- Initial test suite
- Deployment documentation
- Code generation templates

## Quality Checks

**VERIFY** these items:
- [ ] OpenAPI specification validates without errors
- [ ] All business requirements are addressed
- [ ] API follows RESTful design principles
- [ ] Security requirements are properly implemented
- [ ] Error handling is comprehensive and consistent
- [ ] Documentation is clear and complete
- [ ] Examples demonstrate realistic usage scenarios
- [ ] Performance considerations are addressed
- [ ] Compliance requirements are met
- [ ] Integration patterns are well-defined

## Follow-up Actions

**MUST** complete:
- Validate specification with stakeholders
- Set up development and testing environments
- Create initial API implementation or mock
- Establish CI/CD pipeline for API lifecycle

**SHOULD** consider:
- Generate client SDKs for consumers
- Create comprehensive test suites
- Set up monitoring and observability
- Plan for API versioning and evolution
- Document operational procedures
