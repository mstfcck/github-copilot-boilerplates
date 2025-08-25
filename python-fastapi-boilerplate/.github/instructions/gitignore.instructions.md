---
applyTo: '**'
---

# Git Ignore Instructions

Comprehensive .gitignore configuration for Python FastAPI applications with proper exclusions for development and production environments.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** exclude all sensitive files containing secrets, credentials, or API keys
- **REQUIRED** to ignore all compiled Python files and cache directories
- **SHALL** exclude environment-specific configuration files
- **NEVER** commit database files or migration data to version control
- **MUST** ignore all IDE and editor-specific configuration files
- **REQUIRED** to exclude build artifacts and distribution files

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** ignore log files and temporary files
- **RECOMMENDED** to exclude OS-specific files and directories
- **ALWAYS** ignore virtual environment directories
- **DO** exclude test coverage reports and artifacts
- **DON'T** commit node_modules or frontend build directories
- **ALWAYS** ignore Docker build context files when appropriate

### Optional Enhancements (**MAY** Consider)
- **MAY** ignore specific testing artifacts or performance reports
- **OPTIONAL** to exclude documentation build directories
- **USE** global gitignore for personal development tools
- **IMPLEMENT** project-specific ignores for unique requirements
- **AVOID** overly broad patterns that might exclude needed files

## Implementation Guidance

**USE** this comprehensive .gitignore configuration:

```gitignore
# Python FastAPI .gitignore

# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
pip-wheel-metadata/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
#  Usually these files are written by a python script from a template
#  before PyInstaller builds the exe, so as to inject date/other infos into it.
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/

# Translations
*.mo
*.pot

# Django stuff (if using Django components)
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff (if using Flask components)
instance/
.webassets-cache

# Scrapy stuff
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# pipenv
#   According to pypa/pipenv#598, it is recommended to include Pipfile.lock in version control.
#   However, in case of collaboration, if having platform-specific dependencies or dependencies
#   having no cross-platform support, pipenv may install dependencies that don't work, or not
#   install all needed dependencies.
#Pipfile.lock

# PEP 582; used by e.g. github.com/David-OConnor/pyflow
__pypackages__/

# Celery stuff
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# FastAPI specific
# Environment files
.env.local
.env.development
.env.staging
.env.production
.env.test

# Database
*.db
*.sqlite
*.sqlite3
database.db
test.db

# Alembic
# Uncomment if you want to ignore migration files (not recommended)
# alembic/versions/

# Redis dump files
dump.rdb

# Log files
logs/
*.log
*.log.*

# Upload directories
uploads/
media/
static/files/

# Cache directories
.cache/
*.cache

# FastAPI auto-generated files
.DS_Store
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/

# Docker
docker-compose.override.yml
Dockerfile.local
.dockerignore.local

# Kubernetes
*.yaml.local
*.yml.local

# Monitoring and profiling
profiling/
metrics/
monitoring/

# Backup files
*.bak
*.backup
*.tmp

# Temporary directories
tmp/
temp/
.tmp/

# Poetry (if using)
poetry.lock  # Uncomment if you don't want to lock dependencies

# pip
pip-log.txt
pip-delete-this-directory.txt

# Node.js (if using for frontend)
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Frontend build directories
frontend/dist/
frontend/build/
static/js/
static/css/

# SSL certificates (never commit these!)
*.pem
*.key
*.crt
*.p12
*.pfx
ssl/

# Security
secrets/
credentials/
*.secret

# Development tools
.pytest_cache/
.coverage
htmlcov/
.bandit
.safety

# IDE specific files
# PyCharm
.idea/
*.iml
*.iws
*.ipr

# VS Code
.vscode/
*.code-workspace

# Sublime Text
*.sublime-project
*.sublime-workspace

# Vim
*.swp
*.swo
Session.vim

# Emacs
*~
\#*\#
/.emacs.desktop
/.emacs.desktop.lock
*.elc
auto-save-list
tramp
.\#*

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

# Application specific
config/local.py
config/secrets.py
config/development.py  # If contains sensitive data

# Performance and monitoring
performance_reports/
load_test_results/
benchmark_results/

# Third-party integrations
integrations/*/config.json
integrations/*/secrets.json

# Terraform (if using for infrastructure)
*.tfstate
*.tfstate.*
.terraform/
terraform.tfvars

# Ansible (if using for deployment)
*.retry
inventory/host_vars/
inventory/group_vars/
vault_pass.txt

# CI/CD secrets
.github/secrets/
.gitlab-ci-secrets/
ci-secrets/

# Local development overrides
docker-compose.local.yml
docker-compose.dev.yml
Dockerfile.dev
local_settings.py
```

**IMPLEMENT** these gitignore patterns:

### Environment-Specific Ignores
```gitignore
# Development environment
.env.development
.env.dev
dev_config.py
local_settings.py

# Staging environment  
.env.staging
.env.stage
staging_config.py

# Production environment
.env.production
.env.prod
production_config.py

# Testing environment
.env.test
.env.testing
test_config.py
```

### Security-Related Ignores
```gitignore
# Never commit these security-sensitive files
*.key
*.pem
*.p12
*.pfx
*.crt
*.csr
*_rsa
*_rsa.pub
*_dsa
*_dsa.pub
*_ecdsa
*_ecdsa.pub
*_ed25519
*_ed25519.pub

# API keys and secrets
api_keys.py
secrets.py
credentials.json
service_account.json
auth_config.py

# OAuth and JWT secrets
oauth_secrets.py
jwt_secrets.py
```

**ENSURE** these patterns are ignored:
- All environment files containing sensitive configuration
- Database files and dumps that may contain sensitive data
- Log files that may contain sensitive information
- Cache and temporary files that consume space unnecessarily
- IDE and editor configuration files that are user-specific

## Anti-Patterns

**DON'T** implement these approaches:
- Committing environment files with real credentials or API keys
- Ignoring important configuration templates that others need
- Using overly broad patterns that exclude necessary files
- Forgetting to ignore OS-specific files that pollute the repository
- Committing large binary files or database dumps

**AVOID** these common mistakes:
- Not ignoring virtual environment directories
- Committing compiled Python files (__pycache__, *.pyc)
- Including IDE-specific configuration files in version control
- Forgetting to ignore test coverage reports and artifacts
- Not excluding log files and temporary debugging files

**NEVER** do these actions:
- Commit files containing passwords, API keys, or other secrets
- Include production database dumps or sensitive data files
- Commit SSL certificates or private keys
- Include user-specific IDE settings that don't apply to all developers
- Ignore the .gitignore file itself or important project configuration

## Code Examples

### Project-Specific Gitignore Additions
```gitignore
# Project: FastAPI E-commerce API
# Additional project-specific ignores

# Product images and user uploads
uploads/products/
uploads/users/avatars/
static/media/

# Payment processing logs
payments/logs/
stripe_webhooks.log
paypal_notifications.log

# Inventory tracking
inventory/exports/
inventory/imports/
*.csv
*.xlsx

# Email templates (compiled)
email_templates/compiled/
email_previews/

# Search index files
search_indices/
elasticsearch/data/

# ML model files
models/trained/
models/checkpoints/
*.pkl
*.h5
*.model

# Report generation
reports/generated/
reports/exports/
```

### Development vs Production Patterns
```gitignore
# Development only (include in .gitignore)
.env.development
debug_logs/
profiling_results/
test_data_exports/
development_notes.md
TODO.md

# Files that should be tracked but may have local overrides
# config/settings.py (track)
# config/settings.local.py (ignore - local overrides)
config/settings.local.py
config/database.local.py
config/cache.local.py

# Docker development overrides
docker-compose.dev.yml
docker-compose.local.yml
Dockerfile.dev
```

### Conditional Ignores with Comments
```gitignore
# Database migrations - generally should be tracked
# Uncomment the line below if you want to ignore migration files
# alembic/versions/*.py

# Poetry lock file - uncomment if you want to allow flexible dependency versions
# poetry.lock

# Test database - should always be ignored
test.db
test.sqlite
*.test.db

# Environment files - always ignore
.env
.env.*
!.env.example  # Track the example file

# Static files - ignore generated, track source
static/css/generated/
static/js/dist/
static/images/processed/
!static/images/source/

# Documentation - ignore built docs, track source
docs/_build/
docs/build/
!docs/source/
```

## Validation Checklist

**MUST** verify:
- [ ] All environment files and secrets are ignored
- [ ] Compiled Python files and cache directories are excluded
- [ ] Database files and dumps are not committed
- [ ] IDE and editor-specific files are ignored
- [ ] OS-specific files are properly excluded

**SHOULD** check:
- [ ] Log files and temporary files are ignored
- [ ] Test artifacts and coverage reports are excluded
- [ ] Virtual environment directories are ignored
- [ ] Build and distribution artifacts are excluded
- [ ] Upload directories and user-generated content are ignored

## References

- [GitHub Python .gitignore Template](https://github.com/github/gitignore/blob/main/Python.gitignore)
- [Git Documentation - gitignore](https://git-scm.com/docs/gitignore)
- [Python .gitignore Best Practices](https://realpython.com/python-gitignore/)
- [FastAPI Deployment Guide](https://fastapi.tiangolo.com/deployment/)
- [Security Best Practices for Git](https://owasp.org/www-project-devsecops-guideline/latest/02a-Git-Secrets)
