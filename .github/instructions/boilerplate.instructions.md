---
applyTo: '**'
---

# Boilerplate Creation Instructions

This document defines the **REQUIRED** standards for creating GitHub Copilot boilerplates within this project. All boilerplate contributions **MUST** follow these specifications to ensure consistency, quality, and AI-guided development effectiveness.

## Specification Keywords

The key words "**MUST**", "**MUST NOT**", "**REQUIRED**", "**SHALL**", "**SHALL NOT**", "**SHOULD**", "**SHOULD NOT**", "**RECOMMENDED**", "**NOT RECOMMENDED**", "**MAY**", "**OPTIONAL**", "**DO**", "**DON'T**", "**USE**", "**IMPLEMENT**", "**ENSURE**", "**ALWAYS**", "**NEVER**", and "**AVOID**" in this document are to be interpreted as described in RFC 2119 and RFC 8174 when, and only when, they appear in all capitals and bold formatting, as shown here.

### Specification Keyword Definitions

#### Absolute Requirements
- **MUST** / **REQUIRED** / **SHALL**: Absolute requirement of the specification
- **MUST NOT** / **SHALL NOT**: Absolute prohibition of the specification
- **NEVER**: Absolute prohibition with emphasis on security or quality implications

#### Strong Recommendations  
- **SHOULD** / **RECOMMENDED**: Strong recommendation with valid reasons for exceptions
- **SHOULD NOT** / **NOT RECOMMENDED**: Strong recommendation against with valid reasons for exceptions
- **ALWAYS**: Strong recommendation for consistency and best practices
- **DO**: Strong recommendation for implementation patterns
- **DON'T**: Strong recommendation against anti-patterns

#### Optional Guidelines
- **MAY** / **OPTIONAL**: Truly optional item with vendor/implementer choice
- **USE**: Recommended tool, library, or pattern choice
- **IMPLEMENT**: Recommended implementation approach
- **ENSURE**: Recommended verification or validation step
- **AVOID**: Recommended to prevent common issues

## Boilerplate Structure Requirements

### **REQUIRED** Directory Structure

All boilerplates **MUST** follow this exact directory structure:

```text
{boilerplate-name}/
├── .github/                                    # REQUIRED: AI instruction directory
│   ├── copilot-instructions.md                # REQUIRED: Main AI guidance
│   ├── instructions/                          # REQUIRED: Modular instructions
│   │   ├── architecture.instructions.md       # REQUIRED: Architecture guidance
│   │   ├── security.instructions.md           # REQUIRED: Security best practices
│   │   ├── testing.instructions.md            # REQUIRED: Testing strategies
│   │   ├── gitignore.instructions.md          # REQUIRED: Version control guidance
│   │   ├── coding-standards.instructions.md   # RECOMMENDED: Code quality standards
│   │   └── {domain-specific}.instructions.md  # OPTIONAL: Technology-specific guides
│   └── prompts/                               # RECOMMENDED: Ready-to-use prompts
│       ├── project-initialization.prompt.md   # RECOMMENDED: Setup guidance
│       └── {scenario-specific}.prompt.md      # OPTIONAL: Feature-specific prompts
├── docs/                                      # REQUIRED: Documentation directory
│   ├── {technology}/                         # OPTIONAL: Technology-specific docs
│   ├── api/                                  # RECOMMENDED: API documentation
│   ├── deployment/                           # RECOMMENDED: Deployment guides
│   └── examples/                             # RECOMMENDED: Usage examples
├── README.md                                 # REQUIRED: Comprehensive project guide
├── .gitignore                                # REQUIRED: Technology-appropriate exclusions
└── LICENSE                                   # OPTIONAL: License file if different from root
```

### **REQUIRED** File Content Standards

#### Main Instruction File (`copilot-instructions.md`)

All main instruction files **MUST** include:

1. **Technology Overview**: Clear description of the technology stack
2. **Core Principles**: Fundamental development principles to follow
3. **Architecture Guidance**: Decision framework for architectural choices
4. **Development Standards**: Coding standards and best practices
5. **Quality Requirements**: Testing, security, and performance guidelines
6. **Sub-Instruction References**: Links to modular instruction files

**MUST** use this structure:

```markdown
# {Technology} Boilerplate - AI Development Assistant

Brief description of the boilerplate and its purpose.

## Core Principles and Guidelines

**MUST** follow these fundamental principles:
- List of non-negotiable principles

## Technology Stack Specifications

**MUST** use these technologies:
- Required technology specifications

## Architecture Decision Framework

**ALWAYS** consider these architectural questions:
- Decision-making framework

## Development Standards

**ENSURE** all code follows these standards:
- Development requirements

**DO** implement these patterns:
- Recommended implementation patterns

**DON'T** implement these anti-patterns:
- Prohibited approaches

## Quality Requirements

**MUST** include for every feature:
- Non-negotiable quality requirements

**SHOULD** consider:
- Recommended quality enhancements

**NICE TO HAVE**:
- Optional quality improvements

## Sub-Instructions

Reference to modular instruction files:
- **[Architecture Guide](./instructions/architecture.instructions.md)**
- **[Security Guide](./instructions/security.instructions.md)**
- **[Testing Guide](./instructions/testing.instructions.md)**
```

#### Modular Instruction Files (`instructions/*.instructions.md`)

All instruction files **MUST** follow this format:

```markdown
---
applyTo: '**'
---

# {Topic} Instructions

Brief description of the instruction area and its scope.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST**: Absolute requirements
- **REQUIRED**: Non-negotiable specifications
- **SHALL**: Compliance requirements

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD**: Best practice recommendations
- **RECOMMENDED**: Industry standard approaches
- **DO**: Implementation patterns to follow

### Optional Enhancements (**MAY** Consider)
- **MAY**: Optional features
- **OPTIONAL**: Enhancement opportunities
- **NICE TO HAVE**: Future considerations

## Implementation Guidance

**USE** these approaches:
- Specific implementation instructions

**IMPLEMENT** these patterns:
- Code pattern examples

**ENSURE** these validations:
- Verification steps

## Anti-Patterns

**DON'T** implement these approaches:
- Prohibited patterns with explanations

**AVOID** these common mistakes:
- Common pitfalls to prevent

**NEVER** do these actions:
- Absolute prohibitions

## Code Examples

[Provide practical implementation examples]

## Validation Checklist

**MUST** verify:
- [ ] Required validation items

**SHOULD** check:
- [ ] Recommended validation items

## References

- [Official Documentation Links]
- [Best Practice Resources]
```

#### Prompt Files (`prompts/*.prompt.md`)

All prompt files **MUST** follow this format:

```markdown
# {Scenario} Prompt

Brief description of the prompt's purpose and when to use it.

## Objective

Clear statement of what this prompt accomplishes.

## Prerequisites

**MUST** have these prerequisites:
- Required setup or knowledge

**SHOULD** review these resources:
- Recommended preparation

## Step-by-Step Process

### Phase 1: {Phase Name}
**DO** these actions:
1. Specific step instructions
2. Expected outcomes

**ENSURE** these validations:
- Verification points

### Phase 2: {Phase Name}
[Continue with additional phases]

## Expected Outcomes

**MUST** achieve:
- Non-negotiable results

**SHOULD** produce:
- Expected deliverables

## Quality Checks

**VERIFY** these items:
- [ ] Quality checkpoint items

## Common Issues and Solutions

**IF** this issue occurs:
- **THEN** apply this solution

## Follow-up Actions

**MUST** complete:
- Required next steps

**SHOULD** consider:
- Recommended next steps
```

## Content Quality Standards

### Language and Tone

**MUST** use:
- Clear, actionable language
- Consistent terminology
- Professional tone
- AI-friendly phrasing

**AVOID**:
- Ambiguous instructions
- Subjective opinions
- Overly complex explanations
- Technology bias

### Technical Accuracy

**ENSURE**:
- All code examples compile and run
- All links and references are valid
- Technology versions are current
- Security best practices are included

**VERIFY**:
- Instructions work with GitHub Copilot
- Examples produce expected results
- Dependencies are correctly specified

### Documentation Completeness

**MUST** include:
- Comprehensive setup instructions
- Clear learning objectives
- Practical code examples
- Troubleshooting guidance
- Reference documentation links

**SHOULD** include:
- Video tutorials or visual guides
- Advanced configuration examples
- Performance optimization tips
- Community resource links

## GitHub Copilot Integration Standards

### AI Instruction Effectiveness

**MUST**:
- Test all instructions with GitHub Copilot
- Verify AI can interpret and follow guidance
- Ensure instructions produce consistent results
- Validate code generation quality

**SHOULD**:
- Include context for AI decision-making
- Provide multiple example implementations
- Explain reasoning behind requirements
- Include common variation scenarios

### Prompt Engineering

**DO**:
- Use specific, descriptive language
- Include relevant context and constraints
- Provide clear success criteria
- Structure information hierarchically

**DON'T**:
- Use vague or ambiguous terms
- Assume prior knowledge without context
- Include contradictory instructions
- Overwhelm with excessive detail

## Technology-Specific Requirements

### For Each Technology Stack

**MUST** define:
- Required versions and compatibility
- Essential dependencies and tools
- Security configuration requirements
- Performance optimization guidelines
- Testing framework specifications
- Deployment environment setup

**SHOULD** include:
- Alternative technology choices
- Migration strategies
- Upgrade pathways
- Community best practices

### Cross-Technology Standards

**ENSURE** consistency across:
- File naming conventions
- Directory structures
- Documentation formats
- Code style guidelines
- Security practices

## Validation and Testing

### Content Validation

**MUST** validate:
- All instructions work as described
- Code examples execute successfully
- Links and references are accessible
- AI guidance produces expected results

**SHOULD** test:
- Instructions with multiple AI models
- Scenarios across different environments
- Integration with existing projects
- Performance under various conditions

### Quality Assurance Process

**REQUIRED** validation steps:
1. **Technical Review**: Verify technical accuracy
2. **AI Testing**: Test with GitHub Copilot
3. **User Testing**: Validate with target developers
4. **Documentation Review**: Check completeness and clarity
5. **Security Assessment**: Verify security best practices

## Maintenance and Updates

### Version Management

**MUST**:
- Track technology version compatibility
- Update dependencies regularly
- Maintain backward compatibility
- Document breaking changes

**SHOULD**:
- Monitor technology roadmaps
- Gather community feedback
- Track usage analytics
- Plan deprecation strategies

### Continuous Improvement

**ALWAYS**:
- Incorporate user feedback
- Update based on technology evolution
- Improve AI instruction effectiveness
- Enhance documentation clarity

**REGULARLY** review:
- Instruction effectiveness metrics
- Technology best practice evolution
- Community contribution patterns
- Security vulnerability reports

## Compliance and Standards

### RFC Compliance

**MUST** adhere to:
- RFC 2119 keyword specifications
- RFC 8174 capitalization requirements
- Consistent keyword usage
- Clear requirement levels

### Project Standards

**SHALL** comply with:
- Project coding standards
- Documentation format requirements
- Git workflow procedures
- Quality gate criteria

## Contribution Workflow

### Before Creating a Boilerplate

**MUST** complete:
1. Review existing boilerplates for patterns
2. Validate technology choice and scope
3. Create detailed specification document
4. Obtain project maintainer approval

### During Development

**ENSURE**:
- Follow this instruction format exactly
- Test all content with GitHub Copilot
- Validate all code examples
- Document design decisions

### Before Submission

**VERIFY**:
- All **REQUIRED** components are present
- Content follows specification standards
- AI instructions work effectively
- Documentation is complete and accurate

This document serves as the authoritative specification for all boilerplate creation within the GitHub Copilot Boilerplates project. **ALL** contributors **MUST** follow these guidelines to ensure consistency, quality, and effectiveness of AI-guided development resources.


