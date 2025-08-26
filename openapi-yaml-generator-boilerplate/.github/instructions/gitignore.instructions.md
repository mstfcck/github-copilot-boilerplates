---
applyTo: '**'
---

# .gitignore Instructions for OpenAPI YAML Generator

This document provides guidance for creating appropriate `.gitignore` files for OpenAPI YAML generator projects and related development environments.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** exclude generated files and build artifacts from version control
- **REQUIRED** to ignore IDE-specific configuration files
- **SHALL** exclude sensitive information like API keys and credentials
- **NEVER** commit personal development environment configurations

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** ignore temporary files and cache directories
- **RECOMMENDED** to exclude OS-specific system files
- **ALWAYS** review and update .gitignore for project-specific needs
- **DO** include comments explaining non-obvious exclusions
- **DON'T** ignore files that are necessary for project setup

### Optional Enhancements (**MAY** Consider)
- **MAY** use global gitignore for common IDE and OS files
- **OPTIONAL** to include project-specific documentation about ignored files
- **USE** gitignore templates appropriate for the development stack
- **IMPLEMENT** different ignore patterns for different environments
- **AVOID** overly broad patterns that might ignore important files

## Implementation Guidance

**USE** these ignore patterns for OpenAPI projects:

### Generated Files and Build Artifacts
```gitignore
# Generated OpenAPI files
generated/
dist/
build/
out/
target/

# Generated documentation
docs/generated/
public/docs/
site/

# Generated client SDKs
sdk/
clients/
lib/generated/

# Build outputs
*.jar
*.war
*.ear
*.zip
*.tar.gz
*.tgz

# Compiled sources
*.class
*.pyc
*.pyo
__pycache__/
*.so
*.dylib
*.dll
```

### Development Tools and IDEs
```gitignore
# IDEs and Editors
.vscode/
.idea/
*.swp
*.swo
*~
.project
.classpath
.settings/
*.sublime-project
*.sublime-workspace
.atom/
.brackets.json

# IDE-specific files
.vscode/settings.json
.vscode/launch.json
.vscode/extensions.json
.idea/workspace.xml
.idea/tasks.xml
.idea/dictionaries/
.idea/shelf/

# Visual Studio
.vs/
*.user
*.suo
*.userosscache
*.sln.docstates
```

### Dependencies and Package Managers
```gitignore
# Node.js dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.npm
.yarn-integrity
.yarn/cache/
.yarn/unplugged/
.yarn/build-state.yml
.yarn/install-state.gz
.pnp.*

# Python dependencies
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
pip-log.txt
pip-delete-this-directory.txt
.Python
*.egg-info/
dist/
.eggs/

# Java dependencies
.gradle/
gradle-app.setting
!gradle-wrapper.jar
.gradletasknamecache
.m2/
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml

# Ruby dependencies
.bundle/
vendor/bundle/
.ruby-version
.ruby-gemset

# Go dependencies
vendor/
go.sum
```

### Environment and Configuration Files
```gitignore
# Environment variables and secrets
.env
.env.*
!.env.example
!.env.template
.envrc
.secrets
secrets.yaml
secrets.yml
.secret

# Configuration files with sensitive data
config/production.yaml
config/production.yml
config/local.yaml
config/local.yml
application-local.properties
application-production.properties

# API keys and credentials
api-keys.json
credentials.json
service-account.json
*.pem
*.key
*.crt
*.p12
*.pfx

# Database files
*.db
*.sqlite
*.sqlite3
database.url
```

### Temporary and Cache Files
```gitignore
# Temporary files
*.tmp
*.temp
temp/
tmp/
.tmp/
.cache/
cache/

# Log files
*.log
logs/
log/
*.log.*
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime files
*.pid
*.lock
.lock-wscript

# Test output
test-results/
coverage/
.coverage
.pytest_cache/
.tox/
htmlcov/
.mocha.json
junit.xml
testresults.xml

# Documentation generation
.doctrees/
.buildinfo
```

### OS-Specific Files
```gitignore
# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk

# Windows
Thumbs.db
Thumbs.db:encryptable
ehthumbs.db
ehthumbs_vista.db
*.stackdump
[Dd]esktop.ini
$RECYCLE.BIN/
*.cab
*.msi
*.msix
*.msm
*.msp
*.lnk

# Linux
*~
.fuse_hidden*
.directory
.Trash-*
.nfs*
```

**IMPLEMENT** project-specific patterns:

### OpenAPI Tool-Specific Ignores
```gitignore
# Swagger/OpenAPI tools
.swagger-codegen/
.swagger-codegen-ignore
.openapi-generator/
.openapi-generator-ignore

# Redoc output
redoc-static.html
redoc-output/

# Spectral output
.spectral-cache/
spectral-results.json
spectral-results.html

# API documentation sites
api-docs/
swagger-ui/
redoc-ui/

# Postman collections (if auto-generated)
postman/generated/
collections/generated/

# Mock server data
mock-data/
mocks/generated/
wiremock/mappings/generated/
```

### CI/CD and Deployment
```gitignore
# CI/CD artifacts
.github/workflows/generated/
.jenkins/
.travis.yml.generated
.circleci/generated/
.gitlab-ci.generated.yml

# Deployment artifacts
deploy/
deployment/generated/
k8s/generated/
docker/generated/
terraform/.terraform/
terraform/terraform.tfstate*
terraform/.terraform.lock.hcl

# Helm charts (if generated)
charts/generated/
helm/generated/

# Container images
*.tar
docker-images/
```

**ENSURE** appropriate documentation:

### Complete .gitignore with Comments
```gitignore
# OpenAPI YAML Generator Project .gitignore
# Generated: 2023-01-01
# Last Updated: 2023-01-01

# ==============================================
# Generated Files and Build Artifacts
# ==============================================

# OpenAPI code generation output
generated/
sdk/
clients/
docs/generated/

# Build outputs
dist/
build/
out/
target/

# ==============================================
# Development Environment
# ==============================================

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# ==============================================
# Dependencies and Packages
# ==============================================

# Node.js
node_modules/
npm-debug.log*
yarn-error.log*
.yarn/

# Python
.venv/
__pycache__/
*.pyc

# Java
.gradle/
target/
*.jar

# ==============================================
# Configuration and Secrets
# ==============================================

# Environment files
.env
.env.*
!.env.example

# API keys and credentials
api-keys.json
credentials.json
*.key
*.pem

# Local configuration
config/local.*
application-local.properties

# ==============================================
# Temporary and Runtime Files
# ==============================================

# Logs
*.log
logs/

# Cache
.cache/
cache/

# Test output
coverage/
test-results/

# ==============================================
# Tool-Specific Files
# ==============================================

# OpenAPI generators
.swagger-codegen/
.openapi-generator/

# Documentation generators
redoc-static.html
swagger-ui/

# Linting and validation
.spectral-cache/

# ==============================================
# CI/CD and Deployment
# ==============================================

# Deployment artifacts
k8s/generated/
terraform/.terraform/
docker/generated/

# Container images
*.tar
docker-images/

# ==============================================
# Project-Specific Exclusions
# ==============================================

# Add project-specific patterns here
# Example:
# my-custom-tool-output/
# project-specific-temp/
```

## Anti-Patterns

**DON'T** implement these gitignore approaches:
- **Overly broad patterns**: Using `*` patterns that might ignore important files
- **Missing essential excludes**: Not ignoring sensitive files like credentials
- **Platform-specific in project**: Including OS-specific files in project .gitignore
- **Ignoring version control**: Adding .git/ to .gitignore (unnecessary and wrong)

**AVOID** these common mistakes:
- **Forgetting generated files**: Not ignoring build outputs and generated code
- **Committing secrets**: Missing patterns for API keys and credentials
- **IDE creep**: Committing IDE-specific configuration files
- **Incomplete patterns**: Partial patterns that don't cover all cases

**NEVER** do these actions:
- **Ignore source files**: Accidentally ignoring important source code
- **Commit credentials**: Including API keys, passwords, or certificates
- **Ignore documentation**: Excluding important README or documentation files
- **Use absolute paths**: Using absolute paths in .gitignore patterns

## Validation Checklist

**MUST** verify:
- [ ] All generated files and build artifacts are ignored
- [ ] Sensitive information (credentials, API keys) is excluded
- [ ] IDE and OS-specific files are ignored appropriately
- [ ] Dependency directories are excluded from version control
- [ ] .gitignore syntax is valid and patterns work correctly

**SHOULD** check:
- [ ] Comments explain non-obvious ignore patterns
- [ ] Project-specific patterns are included
- [ ] CI/CD artifacts are appropriately ignored
- [ ] Tool-specific cache and output directories are excluded
- [ ] .gitignore is organized and maintainable

## References

- [Git Documentation - gitignore](https://git-scm.com/docs/gitignore)
- [GitHub gitignore templates](https://github.com/github/gitignore)
- [Gitignore.io - Generate gitignore files](https://www.toptal.com/developers/gitignore)
- [OpenAPI Generator - .gitignore considerations](https://openapi-generator.tech/)
