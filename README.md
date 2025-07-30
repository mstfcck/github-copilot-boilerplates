# GitHub Copilot Boilerplates

A comprehensive collection of pre-configured boilerplate projects with GitHub Copilot instructions and prompts to accelerate development across different technology stacks.

## Overview

This repository contains carefully crafted boilerplate projects that include:

- **Pre-defined GitHub Copilot Instructions** for consistent AI-assisted development
- **Structured Prompts** for common development scenarios
- **Best Practice Guidelines** for each technology stack
- **Complete Project Templates** ready for immediate use

Each boilerplate is designed to help developers quickly bootstrap new projects while following industry best practices and maintaining high code quality standards through AI-guided development.

## Available Boilerplates

### [Spring Boilerplate](./spring-boilerplate/)

Enterprise-grade Spring Boot application boilerplate with comprehensive AI-guided instructions.

**Features:**

- Spring Boot 3.x with Java 17+
- Security-first approach with Spring Security 6.x
- RESTful API design patterns
- Comprehensive testing strategies
- Database integration with JPA/Hibernate
- Performance optimization guidelines
- Production-ready configurations

**Use Cases:**

- Enterprise web applications
- Microservices development
- RESTful API backends
- Cloud-native applications

### [MCP Boilerplate](./mcp-boilerplate/)

Model Context Protocol (MCP) application boilerplate for building AI-integrated applications.

**Features:**

- Official MCP SDK integrations
- Protocol specification documentation
- Best practices for MCP development
- Reference server examples
- Coding standards and guidelines

**Use Cases:**

- AI-powered applications
- Context-aware systems
- Language model integrations
- Protocol-based communication

## Getting Started

### 1. Choose Your Boilerplate

Navigate to the appropriate boilerplate directory based on your project needs:

```bash
# For Spring Boot projects
cd spring-boilerplate/

# For MCP projects
cd mcp-boilerplate/
```

### 2. Review the Instructions

Each boilerplate contains a `.github/copilot-instructions.md` file with comprehensive guidelines:

- **Main Instructions**: Core development principles and standards
- **Sub-Instructions**: Specialized guides for specific areas (security, testing, etc.)
- **Prompts**: Ready-to-use prompts for common development tasks

### 3. Copy and Customize

1. Copy the boilerplate to your new project directory
2. Review and customize the instructions based on your specific requirements
3. Start developing with AI assistance using the provided guidelines

## Instruction Structure

Each boilerplate follows a consistent instruction structure:

```text
.github/
├── copilot-instructions.md          # Main AI instructions
├── instructions/                    # Specialized instruction files
│   ├── architecture.instructions.md
│   ├── security.instructions.md
│   ├── testing.instructions.md
│   └── ...
└── prompts/                        # Ready-to-use prompts
    ├── project-initialization.prompt.md
    └── ...
```

### Instruction Types

- **Instructions (.instructions.md)**: Comprehensive guidelines for specific development areas
- **Prompts (.prompt.md)**: Ready-to-use prompts for common development scenarios
- **Documentation**: Reference materials and specifications

## How to Use with GitHub Copilot

### 1. Set Up Copilot Instructions

Copy the `.github/copilot-instructions.md` file to your project root to enable AI-guided development.

### 2. Reference Sub-Instructions

Use specific instruction files for focused development tasks:

```markdown
@architecture Design a microservices architecture for user management
@security Implement JWT authentication with refresh tokens
@testing Create comprehensive test suite for the user service
```

### 3. Use Prepared Prompts

Leverage the prompt files for complex scenarios:

```markdown
/project-initialization Set up a new Spring Boot project with PostgreSQL and Redis
/api-design Create RESTful endpoints for user management
```

## Customization Guidelines

### Adding New Instructions

1. Create instruction files in `.github/instructions/`
2. Follow the established naming convention: `{topic}.instructions.md`
3. Include clear MUST, SHOULD, and NICE TO HAVE sections
4. Reference from main copilot-instructions.md

### Creating Custom Prompts

1. Add prompt files in `.github/prompts/`
2. Use descriptive naming: `{scenario}.prompt.md`
3. Include step-by-step guidance
4. Provide example implementations

### Technology-Specific Adaptations

1. Update technology stack requirements
2. Modify coding standards and conventions
3. Adjust testing strategies
4. Update security guidelines

## Documentation Standards

Each boilerplate includes comprehensive documentation:

- **README.md**: Project overview and quick start guide
- **Architecture Guides**: Detailed architectural decisions and patterns
- **API Documentation**: OpenAPI/Swagger specifications where applicable
- **Deployment Guides**: Environment setup and deployment instructions

## Contributing

We welcome contributions to improve these boilerplates:

1. **Fork** the repository
2. **Create** a feature branch
3. **Add** or improve boilerplate instructions
4. **Test** with actual development scenarios
5. **Submit** a pull request

### Contribution Guidelines

- Follow the established instruction format
- Include practical examples
- Test instructions with GitHub Copilot
- Update documentation as needed

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Resources

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Model Context Protocol](https://modelcontextprotocol.io/)

---

**Made with ❤️ for developers who want to accelerate their development process with AI assistance.**
