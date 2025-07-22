# Contributing to GitHub Copilot Boilerplates

Thank you for your interest in contributing to GitHub Copilot Boilerplates! This project aims to provide high-quality, AI-guided development templates that accelerate software development across different technology stacks.

## How to Contribute

We welcome contributions in several areas:

### 1. New Boilerplates
- **Technology Stacks**: Add boilerplates for new frameworks, languages, or platforms
- **Specialized Domains**: Create domain-specific templates (e.g., ML, IoT, blockchain)
- **Cloud Platforms**: Add cloud-specific deployment patterns

### 2. Enhance Existing Boilerplates
- **Improve Instructions**: Refine AI guidance and coding standards
- **Add Prompts**: Create new prompts for common development scenarios
- **Update Dependencies**: Keep technology stacks current
- **Documentation**: Improve guides, examples, and explanations

### 3. Quality Improvements
- **Testing**: Add test coverage and validation
- **Performance**: Optimize configurations and patterns
- **Security**: Enhance security best practices
- **Accessibility**: Improve developer experience

## Contribution Guidelines

### Boilerplate Standards

#### Structure Requirements
All boilerplates must follow this structure:
```
boilerplate-name/
├── .github/
│   ├── copilot-instructions.md      # Main AI instructions (REQUIRED)
│   ├── instructions/                # Modular instruction files
│   │   ├── architecture.instructions.md
│   │   ├── security.instructions.md
│   │   ├── testing.instructions.md
│   │   └── ...
│   └── prompts/                     # Ready-to-use prompts
│       ├── project-initialization.prompt.md
│       └── ...
├── docs/                           # Documentation
├── README.md                       # Boilerplate guide (REQUIRED)
└── .gitignore                      # Technology-appropriate gitignore
```

#### Content Requirements

**MUST Include**:
- Comprehensive `copilot-instructions.md` with clear AI guidance
- Technology-specific coding standards and best practices
- Security guidelines and implementation patterns
- Testing strategies and example implementations
- Performance optimization guidelines
- Production-ready configurations
- Complete README with setup instructions

**SHOULD Include**:
- Modular instruction files for specialized areas
- Ready-to-use prompts for common scenarios
- Example implementations and code samples
- Deployment guides for multiple environments
- CI/CD pipeline templates
- Monitoring and observability patterns

**NICE TO HAVE**:
- Video tutorials or walkthroughs
- Advanced configuration examples
- Load testing templates
- Security scanning configurations
- Performance benchmarks

### Instruction File Standards

#### Format Requirements
- Use `.instructions.md` extension for instruction files
- Use `.prompt.md` extension for prompt files
- Include frontmatter with `applyTo` specification when needed
- Follow consistent formatting and structure

#### Content Guidelines
- Use clear, actionable language
- Organize content with MUST, SHOULD, and NICE TO HAVE sections
- Include practical examples and code snippets
- Reference official documentation and best practices
- Provide anti-pattern guidance (what NOT to do)

#### Example Structure
```markdown
---
applyTo: '**'
---

# Topic Instructions

Brief description of the instruction area.

## Requirements

### MUST Follow
- Critical requirements that are non-negotiable
- Security requirements
- Compliance requirements

### SHOULD Implement
- Best practices
- Performance optimizations
- Maintainability patterns

### NICE TO HAVE
- Advanced features
- Optional optimizations
- Future considerations

## Implementation Examples
[Provide practical code examples]

## Anti-Patterns
[List what to avoid]

## References
[Link to official documentation]
```

## Getting Started

### 1. Fork and Clone
```bash
git fork https://github.com/mstfcck/github-copilot-boilerplates.git
git clone https://github.com/your-username/github-copilot-boilerplates.git
cd github-copilot-boilerplates
```

### 2. Create a Feature Branch
```bash
git checkout -b feature/your-contribution-name
```

### 3. Make Your Changes
- Follow the contribution guidelines above
- Test your instructions with GitHub Copilot
- Ensure all required files are included
- Update documentation as needed

### 4. Test Your Contribution
- Validate instruction files work with GitHub Copilot
- Test prompts produce expected results
- Verify all links and references work
- Check for consistency with existing patterns

### 5. Submit a Pull Request
- Use a clear, descriptive title
- Provide a detailed description of your changes
- Reference any related issues
- Include screenshots or examples if applicable

## Review Process

### What We Look For
- **Quality**: High-quality, actionable instructions
- **Consistency**: Follows established patterns and conventions
- **Completeness**: Includes all required components
- **Testing**: Validated with GitHub Copilot
- **Documentation**: Clear, comprehensive documentation

### Review Criteria
1. **Technical Accuracy**: Instructions are technically correct
2. **AI Effectiveness**: Works well with GitHub Copilot
3. **Best Practices**: Follows industry standards
4. **Security**: Includes appropriate security measures
5. **Maintainability**: Code is maintainable and well-structured

## Issue Guidelines

### Reporting Issues
When reporting issues, please include:
- Clear description of the problem
- Steps to reproduce
- Expected vs. actual behavior
- Environment details (OS, versions, etc.)
- Screenshots or code examples if applicable

### Feature Requests
For feature requests, please include:
- Clear description of the proposed feature
- Use case and motivation
- Suggested implementation approach
- Potential impact on existing boilerplates

## Resources

### Development Resources
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Model Context Protocol](https://modelcontextprotocol.io/)

### Style Guides
- [Markdown Style Guide](https://www.markdownguide.org/basic-syntax/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)

### Testing Guidelines
- Test instructions with GitHub Copilot
- Validate prompts produce expected results
- Check for broken links and references
- Verify code examples compile and run

## Recognition

Contributors will be:
- Listed in the project's contributors section
- Mentioned in release notes for their contributions
- Given credit in relevant documentation
- Invited to join the maintainer team for significant contributions

## Getting Help

If you need help with your contribution:
- Open an issue with the `question` label
- Join our community discussions
- Review existing contributions for examples
- Check the project documentation

## Thank You

Thank you for contributing to GitHub Copilot Boilerplates! Your contributions help developers worldwide build better software faster with AI assistance.

---

By contributing to this project, you agree that your contributions will be licensed under the MIT License.
