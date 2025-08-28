---
applyTo: '**'
---

# Boilerplate Template Structure Guide

This document provides the exact template structure that **MUST** be followed when creating new boilerplates for the GitHub Copilot Boilerplates project.

## Complete Directory Template

**MUST** use this exact structure for all new boilerplates:

```text
{technology-name}-boilerplate/
├── .github/                                   # REQUIRED: GitHub and AI configurations
│   ├── copilot-instructions.md                # REQUIRED: Main AI development guidance
│   ├── instructions/                          # OPTIONAL: Modular instruction files
│   │   ├── architecture.instructions.md       # OPTIONAL: Architecture decisions and patterns
│   │   ├── security.instructions.md           # OPTIONAL: Security implementation guidelines
│   │   ├── testing.instructions.md            # OPTIONAL: Testing strategies and approaches
│   │   ├── gitignore.instructions.md          # OPTIONAL: Version control best practices
│   │   ├── coding-standards.instructions.md   # OPTIONAL: Code quality standards
│   │   ├── performance.instructions.md        # OPTIONAL: Performance optimization
│   │   ├── configuration.instructions.md      # OPTIONAL: Environment configuration
│   │   ├── deployment.instructions.md         # OPTIONAL: Deployment strategies
│   │   └── {domain-specific}.instructions.md  # OPTIONAL: Technology-specific guides
│   ├── prompts/                               # OPTIONAL: Ready-to-use AI prompts
│   │   ├── project-initialization.prompt.md   # OPTIONAL: Project setup guidance
│   │   ├── feature-development.prompt.md      # OPTIONAL: Feature implementation
│   │   ├── api-design.prompt.md               # OPTIONAL: API design assistance
│   │   ├── troubleshooting.prompt.md          # OPTIONAL: Problem-solving guidance
│   │   └── {scenario-specific}.prompt.md      # OPTIONAL: Specialized scenarios
│   └── workflows/                             # OPTIONAL: GitHub Actions workflows
│       ├── ci.yml                             # OPTIONAL: Continuous integration
│       ├── cd.yml                             # OPTIONAL: Continuous deployment
│       └── security-scan.yml                  # OPTIONAL: Security scanning
├── docs/                                      # REQUIRED: Comprehensive documentation
│   ├── {technology}/                         # RECOMMENDED: Technology documentation
│   │   ├── setup.md                          # RECOMMENDED: Setup instructions
│   │   ├── configuration.md                  # RECOMMENDED: Configuration guide
│   │   ├── best-practices.md                 # RECOMMENDED: Best practices
│   │   └── troubleshooting.md                # RECOMMENDED: Common issues
│   ├── api/                                  # RECOMMENDED: API documentation
│   │   ├── endpoints.md                      # RECOMMENDED: API endpoints
│   │   ├── authentication.md                 # RECOMMENDED: Auth documentation
│   │   └── examples.md                       # RECOMMENDED: Usage examples
│   ├── deployment/                           # RECOMMENDED: Deployment guides
│   │   ├── local.md                          # RECOMMENDED: Local development
│   │   ├── staging.md                        # RECOMMENDED: Staging environment
│   │   ├── production.md                     # RECOMMENDED: Production deployment
│   │   └── docker.md                         # RECOMMENDED: Container deployment
│   ├── examples/                             # RECOMMENDED: Implementation examples
│   │   ├── basic-usage/                      # RECOMMENDED: Basic examples
│   │   ├── advanced-patterns/               # RECOMMENDED: Advanced patterns
│   │   └── integration-examples/            # RECOMMENDED: Integration samples
│   ├── architecture/                         # OPTIONAL: Architecture documentation
│   │   ├── decisions/                        # OPTIONAL: ADRs (Architecture Decision Records)
│   │   ├── diagrams/                         # OPTIONAL: System diagrams
│   │   └── patterns/                         # OPTIONAL: Design patterns
│   └── references/                           # OPTIONAL: Reference materials
│       ├── glossary.md                       # OPTIONAL: Terminology definitions
│       ├── resources.md                      # OPTIONAL: External resources
│       └── changelog.md                      # OPTIONAL: Version history
├── src/                                       # OPTIONAL: Example source code
│   ├── main/                                 # OPTIONAL: Main application code
│   │   ├── {language-specific-structure}/    # OPTIONAL: Language-appropriate structure
│   │   └── resources/                        # OPTIONAL: Configuration files
│   ├── test/                                 # OPTIONAL: Test implementations
│   │   ├── unit/                             # OPTIONAL: Unit tests
│   │   ├── integration/                      # OPTIONAL: Integration tests
│   │   └── e2e/                              # OPTIONAL: End-to-end tests
│   └── examples/                             # OPTIONAL: Code examples
├── config/                                    # OPTIONAL: Configuration templates
│   ├── environments/                         # OPTIONAL: Environment configs
│   │   ├── development.yml                   # OPTIONAL: Dev configuration
│   │   ├── staging.yml                       # OPTIONAL: Staging configuration
│   │   └── production.yml                    # OPTIONAL: Prod configuration
│   ├── security/                             # OPTIONAL: Security configurations
│   └── monitoring/                           # OPTIONAL: Monitoring configs
├── scripts/                                   # OPTIONAL: Automation scripts
│   ├── setup.sh                              # OPTIONAL: Environment setup
│   ├── build.sh                              # OPTIONAL: Build automation
│   ├── deploy.sh                             # OPTIONAL: Deployment automation
│   └── test.sh                               # OPTIONAL: Test automation
├── templates/                                 # OPTIONAL: Code generation templates
│   ├── controllers/                          # OPTIONAL: Controller templates
│   ├── services/                             # OPTIONAL: Service templates
│   ├── models/                               # OPTIONAL: Model templates
│   └── tests/                                # OPTIONAL: Test templates
├── README.md                                 # REQUIRED: Comprehensive project guide
├── .gitignore                                # REQUIRED: Technology-appropriate exclusions
├── LICENSE                                   # OPTIONAL: License file (if different from root)
├── CONTRIBUTING.md                           # OPTIONAL: Contribution guidelines
├── CHANGELOG.md                              # OPTIONAL: Version history
└── {build-file}                              # RECOMMENDED: Build configuration
    ├── package.json                          # FOR: Node.js/TypeScript projects
    ├── pom.xml                               # FOR: Java/Maven projects
    ├── build.gradle                          # FOR: Java/Gradle projects
    ├── requirements.txt                      # FOR: Python projects
    ├── Cargo.toml                            # FOR: Rust projects
    └── go.mod                                # FOR: Go projects
```

## File Content Templates

### **REQUIRED** Template: `copilot-instructions.md`

```markdown
# {Technology} Boilerplate - AI Development Assistant

Brief description of the boilerplate and its purpose for {technology} development.

## Core Principles and Guidelines

**MUST** follow these fundamental principles:
- [List technology-specific core principles]
- [Include SOLID principles, clean code, etc.]
- [Add domain-specific best practices]

## Technology Stack Specifications

**MUST** use these technologies:
- [Primary technology and version]
- [Required frameworks and libraries]
- [Essential development tools]
- [Testing frameworks]
- [Build and deployment tools]

## Architecture Decision Framework

**ALWAYS** consider these architectural questions:
1. [Architecture type decisions]
2. [Cost optimization strategies]
3. [Security considerations]
4. [Reliability considerations]
5. [Scalability considerations]
6. [Operational excellence]
7. [Performance efficiency]
8. [Integration requirements]
9. [Deployment strategy]

## Development Standards

**ENSURE** all code follows these standards:
- [Code quality requirements]
- [Design pattern usage]
- [Error handling approaches]
- [Logging and monitoring]
- [Security implementation]

**DO** implement these patterns:
- [Recommended design patterns]
- [Implementation approaches]
- [Code organization strategies]

**DON'T** implement these anti-patterns:
- [Prohibited approaches]
- [Common mistakes to avoid]
- [Performance anti-patterns]

## Quality Requirements

**MUST** include for every feature:
- [Non-negotiable quality requirements]
- [Testing requirements]
- [Security requirements]
- [Performance requirements]

**SHOULD** consider:
- [Recommended enhancements]
- [Best practice implementations]
- [Optimization opportunities]

**NICE TO HAVE**:
- [Optional improvements]
- [Advanced features]
- [Future considerations]

## Sub-Instructions

Reference to modular instruction files:
- **[Architecture Guide](./instructions/architecture.instructions.md)**
- **[Security Guide](./instructions/security.instructions.md)**
- **[Testing Guide](./instructions/testing.instructions.md)**
- **[Coding Standards](./instructions/coding-standards.instructions.md)**
- **[Performance Guide](./instructions/performance.instructions.md)**
- **[Configuration Guide](./instructions/configuration.instructions.md)**
```

### **REQUIRED** Template: Instruction Files

**MUST** follow this format for all `.instructions.md` files:

```markdown
---
applyTo: '**'
---

# {Topic} Instructions

Brief description of the instruction area and its scope for {technology} development.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST**: [Absolute security/compliance requirements]
- **REQUIRED**: [Non-negotiable technical specifications]
- **SHALL**: [Protocol/standard compliance requirements]
- **NEVER**: [Absolute prohibitions with security implications]

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD**: [Best practice recommendations]
- **RECOMMENDED**: [Industry standard approaches]
- **ALWAYS**: [Consistency requirements]
- **DO**: [Implementation patterns to follow]
- **DON'T**: [Anti-patterns to avoid]

### Optional Enhancements (**MAY** Consider)
- **MAY**: [Optional features and enhancements]
- **OPTIONAL**: [Enhancement opportunities]
- **USE**: [Recommended tools/libraries]
- **IMPLEMENT**: [Optional patterns]
- **AVOID**: [Issues to prevent]

## Implementation Guidance

**USE** these approaches:
- [Specific implementation instructions]
- [Tool and library recommendations]
- [Configuration guidelines]

**IMPLEMENT** these patterns:
- [Code pattern examples with snippets]
- [Architecture pattern implementations]
- [Integration pattern examples]

**ENSURE** these validations:
- [Verification steps and procedures]
- [Quality assurance checks]
- [Testing requirements]

## Anti-Patterns

**DON'T** implement these approaches:
- [Prohibited patterns with explanations]
- [Common mistake explanations]
- [Performance anti-pattern warnings]

**AVOID** these common mistakes:
- [Common pitfalls to prevent]
- [Integration issues to avoid]
- [Security vulnerabilities to prevent]

**NEVER** do these actions:
- [Absolute prohibitions]
- [Security violations]
- [Data integrity threats]

## Code Examples

[Provide practical implementation examples in the target technology]

```{language}
// Example implementation demonstrating the concept
[Include actual, runnable code examples]
```

## Validation Checklist

**MUST** verify:
- [ ] [Required validation items]
- [ ] [Security verification points]
- [ ] [Compliance check items]

**SHOULD** check:
- [ ] [Recommended validation items]
- [ ] [Quality assurance points]
- [ ] [Performance verification]

## References

- [Official technology documentation]
- [Best practice resources]
- [Security guidelines]
- [Performance optimization guides]
```

### **REQUIRED** Template: `README.md`

```markdown
# {Technology} Boilerplate

A comprehensive {technology} boilerplate project designed to accelerate {use-case} development with AI-guided best practices.

## 🚀 Overview

This boilerplate provides a solid foundation for building {technology} applications with:

- **{Key Feature 1}** following industry best practices
- **Comprehensive AI-guided instructions** for different development scenarios
- **{Architecture Pattern}** supporting {deployment scenarios}
- **Security-first approach** with {security framework}
- **Performance optimization** with {performance features}
- **Extensive testing strategy** with {testing frameworks}
- **Production-ready configuration** for different environments

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [AI-Guided Development](#ai-guided-development)
- [Project Structure](#project-structure)
- [Technology Stack](#technology-stack)
- [Configuration](#configuration)
- [Testing](#testing)
- [Deployment](#deployment)

## ✨ Features

### Core Features
- [List primary features]
- [Include key capabilities]
- [Highlight unique aspects]

### Development Features
- **AI-Guided Instructions** for common development tasks
- **Code Quality Standards** with comprehensive guidelines
- **Testing Templates** for different testing scenarios
- **Performance Optimization** guidelines and implementations
- **Security Best Practices** with detailed configurations

### Operational Features
- [Production-ready features]
- [Monitoring and observability]
- [Deployment capabilities]

## 🏗️ Architecture

[Include architecture description and diagrams]

## 🚀 Getting Started

### Prerequisites

- [List required tools and versions]
- [Include environment requirements]
- [Specify dependencies]

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/{technology}-boilerplate.git
   cd {technology}-boilerplate
   ```

2. **Set up environment**
   [Include setup instructions]

3. **Run the application**
   [Include run commands]

4. **Access the application**
   [Include access information]

## 🤖 AI-Guided Development

This project includes comprehensive AI instructions to guide development:

### Available Instructions

- **[Architecture Guide](.github/instructions/architecture.instructions.md)**
- **[Security Guide](.github/instructions/security.instructions.md)**
- **[Testing Guide](.github/instructions/testing.instructions.md)**
- [Additional instruction files]

### Using AI Instructions

1. **Review the main instructions**
2. **Choose the appropriate guide**
3. **Follow the MUST, SHOULD, and NICE TO HAVE guidelines**
4. **Use the provided code examples**
5. **Apply the anti-patterns checklist**

[Continue with remaining sections following the spring-boilerplate README pattern]
```

## Naming Conventions

### **MUST** Follow These Naming Standards

#### Directory Names
- **USE** lowercase with hyphens: `{technology-name}-boilerplate`
- **EXAMPLES**: `react-boilerplate`, `python-fastapi-boilerplate`, `go-microservices-boilerplate`

#### File Names
- **USE** kebab-case for instruction files: `{topic}.instructions.md`
- **USE** kebab-case for prompt files: `{scenario}.prompt.md`
- **EXAMPLES**: `security.instructions.md`, `project-initialization.prompt.md`

#### Technology Naming
- **USE** official technology names and proper capitalization
- **EXAMPLES**: "Spring Boot", "React", "TypeScript", "PostgreSQL"

## Validation Requirements

### **MUST** Complete Before Submission

1. **Structure Validation**:
   - [ ] All **REQUIRED** directories and files are present
   - [ ] File naming follows established conventions
   - [ ] Directory structure matches template exactly

2. **Content Validation**:
   - [ ] All instruction files use proper RFC 2119/8174 keywords
   - [ ] Code examples are tested and functional
   - [ ] Links and references are valid and accessible
   - [ ] Documentation is comprehensive and clear

3. **AI Compatibility Testing**:
   - [ ] Instructions work effectively with GitHub Copilot
   - [ ] Prompts produce expected development guidance
   - [ ] Code generation follows specified patterns
   - [ ] Anti-patterns are properly avoided

4. **Quality Assurance**:
   - [ ] Technical accuracy verified by domain experts
   - [ ] Security best practices implemented
   - [ ] Performance guidelines included
   - [ ] Testing strategies comprehensive

This template structure ensures consistency, quality, and effectiveness across all boilerplates in the GitHub Copilot Boilerplates project.
