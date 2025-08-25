# FastAPI Development Setup Guide

This guide provides comprehensive instructions for setting up a Python FastAPI development environment with PostgreSQL, Redis, and Docker.

## Prerequisites

### System Requirements

**MUST** have these installed:
- Python 3.11 or higher
- Docker and Docker Compose
- Git for version control
- A code editor (VS Code recommended)

### Recommended Tools

**SHOULD** install these tools:
- Poetry for dependency management
- PostgreSQL client tools
- Redis CLI tools
- Postman or similar API testing tool

## Installation Guide

### 1. Python Environment Setup

#### Install Python 3.11+
```bash
# macOS with Homebrew
brew install python@3.11

# Ubuntu/Debian
sudo apt update
sudo apt install python3.11 python3.11-venv python3.11-dev

# Windows
# Download from https://www.python.org/downloads/
```

#### Verify Installation
```bash
python3.11 --version
# Should output: Python 3.11.x
```

### 2. Poetry Installation

#### Install Poetry
```bash
# Official installer (recommended)
curl -sSL https://install.python-poetry.org | python3 -

# Alternative: pip install
pip install poetry
```

#### Configure Poetry
```bash
# Configure to create virtual environments in project directory
poetry config virtualenvs.in-project true

# Verify installation
poetry --version
```

### 3. Docker Installation

#### Install Docker Desktop
- **macOS**: Download from [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/install/)
- **Windows**: Download from [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/install/)
- **Linux**: Follow [Docker Engine installation guide](https://docs.docker.com/engine/install/)

#### Verify Docker Installation
```bash
docker --version
docker-compose --version

# Test Docker
docker run hello-world
```

### 4. PostgreSQL Client Tools

#### Install PostgreSQL Client
```bash
# macOS with Homebrew
brew install postgresql

# Ubuntu/Debian
sudo apt install postgresql-client

# Windows
# Install with PostgreSQL installer from https://www.postgresql.org/download/windows/
```

#### Verify Installation
```bash
psql --version
```

### 5. Code Editor Setup

#### VS Code Installation
1. Download from [Visual Studio Code](https://code.visualstudio.com/)
2. Install recommended extensions:
   - Python
   - Python Docstring Generator
   - Docker
   - PostgreSQL
   - GitLens

#### VS Code Configuration
Create `.vscode/settings.json`:
```json
{
    "python.defaultInterpreterPath": ".venv/bin/python",
    "python.formatting.provider": "black",
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.linting.mypyEnabled": true,
    "editor.formatOnSave": true,
    "files.associations": {
        "*.env": "dotenv"
    }
}
```

## Project Setup

### 1. Clone the Boilerplate
```bash
git clone <repository-url> my-fastapi-project
cd my-fastapi-project
```

### 2. Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit .env file with your settings
vim .env  # or use your preferred editor
```

### 3. Install Dependencies
```bash
# Install project dependencies
poetry install

# Activate virtual environment
poetry shell

# Alternative: use poetry run for commands
poetry run python main.py
```

### 4. Pre-commit Hooks
```bash
# Install pre-commit hooks
pre-commit install

# Test pre-commit hooks
pre-commit run --all-files
```

## Development Workflow

### 1. Start Development Services
```bash
# Start PostgreSQL and Redis
docker-compose -f docker-compose.dev.yml up -d db redis

# Check services are running
docker-compose ps
```

### 2. Database Setup
```bash
# Run database migrations
alembic upgrade head

# Create a new migration (when models change)
alembic revision --autogenerate -m "Description of changes"
```

### 3. Run the Application
```bash
# Development mode with auto-reload
uvicorn main:app --reload --port 8000

# Production mode
uvicorn main:app --host 0.0.0.0 --port 8000
```

### 4. Access the Application
- **API Documentation**: http://localhost:8000/docs
- **Alternative Docs**: http://localhost:8000/redoc
- **Health Check**: http://localhost:8000/health

## Testing Setup

### 1. Test Database Setup
```bash
# Create test database
createdb test_database

# Set test environment variables
export TEST_DATABASE_URL="postgresql+asyncpg://postgres:password@localhost:5432/test_database"
```

### 2. Run Tests
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov

# Run specific test file
pytest tests/test_users.py

# Run with verbose output
pytest -v -s
```

### 3. Test Configuration
Create `pytest.ini`:
```ini
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = --strict-markers --disable-warnings
markers =
    unit: Unit tests
    integration: Integration tests
    slow: Slow tests
```

## Docker Development

### 1. Full Stack with Docker
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop services
docker-compose down
```

### 2. Development with Docker
```bash
# Use development compose file
docker-compose -f docker-compose.dev.yml up -d

# Run commands in container
docker-compose exec app bash
docker-compose exec app pytest
```

### 3. Building Images
```bash
# Build application image
docker build -t my-fastapi-app .

# Build with no cache
docker build --no-cache -t my-fastapi-app .
```

## Debugging Setup

### 1. VS Code Debugging
Create `.vscode/launch.json`:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "FastAPI",
            "type": "python",
            "request": "launch",
            "module": "uvicorn",
            "args": ["main:app", "--reload"],
            "console": "integratedTerminal",
            "envFile": "${workspaceFolder}/.env"
        }
    ]
}
```

### 2. Database Debugging
```bash
# Connect to development database
psql $DATABASE_URL

# Connect to Docker database
docker-compose exec db psql -U postgres

# View database logs
docker-compose logs db
```

### 3. Application Logging
```python
# Enable debug logging
import logging
logging.basicConfig(level=logging.DEBUG)

# SQLAlchemy query logging
logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)
```

## Performance Optimization

### 1. Database Optimization
```bash
# Analyze query performance
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

# Check database statistics
docker-compose exec db psql -U postgres -c "SELECT * FROM pg_stat_activity;"
```

### 2. Application Profiling
```python
# Install profiling tools
poetry add --group dev py-spy line_profiler

# Profile application
py-spy record -o profile.svg -- python -m uvicorn main:app
```

### 3. Load Testing
```bash
# Install load testing tools
pip install locust

# Run load tests
locust -f tests/load_test.py --host http://localhost:8000
```

## Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Find process using port 8000
lsof -i :8000

# Kill process
kill -9 <PID>
```

#### Database Connection Issues
```bash
# Check database status
docker-compose ps db

# View database logs
docker-compose logs db

# Reset database
docker-compose down -v
docker-compose up -d db
```

#### Virtual Environment Issues
```bash
# Remove and recreate virtual environment
poetry env remove python
poetry install
```

### Getting Help

**IF** you encounter issues:
1. Check application logs
2. Verify environment configuration
3. Test database connectivity
4. Review Docker container status
5. Consult the troubleshooting guide

**RESOURCES**:
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)

This setup guide provides a complete development environment for building FastAPI applications with production-ready configurations and best practices.
