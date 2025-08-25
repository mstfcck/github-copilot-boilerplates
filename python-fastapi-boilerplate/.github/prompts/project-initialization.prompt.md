# Project Initialization Prompt

This prompt guides you through setting up a new Python FastAPI project using this boilerplate with production-ready configuration and PostgreSQL integration.

## Objective

Initialize a complete FastAPI project with Docker support, PostgreSQL database, Redis caching, and comprehensive testing setup for production deployment.

## Prerequisites

**MUST** have these prerequisites:
- Python 3.11+ installed
- Docker and Docker Compose installed
- Git for version control
- Code editor with Python support (VS Code recommended)

**SHOULD** review these resources:
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)

## Step-by-Step Process

### Phase 1: Project Setup
**DO** these actions:
1. Clone or copy this boilerplate to your project directory
2. Rename the project directory to match your application name
3. Initialize a new Git repository if not already done
4. Create virtual environment: `python -m venv venv`
5. Activate virtual environment: `source venv/bin/activate` (Linux/Mac) or `venv\Scripts\activate` (Windows)

**ENSURE** these validations:
- Python version is 3.11 or higher
- Virtual environment is properly activated
- Git repository is initialized

### Phase 2: Dependencies Installation
**DO** these actions:
1. Install Poetry if not already installed: `pip install poetry`
2. Install project dependencies: `poetry install`
3. Install pre-commit hooks: `pre-commit install`
4. Copy environment template: `cp .env.example .env`

**ENSURE** these validations:
- All dependencies install without errors
- Pre-commit hooks are configured
- Environment file is created and customized

### Phase 3: Environment Configuration
**DO** these actions:
1. Edit `.env` file with your specific configuration:
   ```env
   # Database Configuration
   DATABASE_URL=postgresql+asyncpg://postgres:yourpassword@localhost:5432/yourdb
   
   # Redis Configuration
   REDIS_URL=redis://localhost:6379/0
   
   # Security Configuration
   SECRET_KEY=your-super-secret-key-here
   ACCESS_TOKEN_EXPIRE_MINUTES=30
   
   # Application Configuration
   DEBUG=true
   APP_NAME=Your FastAPI App
   APP_VERSION=1.0.0
   ```

2. Generate a secure secret key:
   ```python
   import secrets
   print(secrets.token_urlsafe(32))
   ```

**ENSURE** these validations:
- Database URL points to your PostgreSQL instance
- Secret key is properly generated and secure
- All required environment variables are set

### Phase 4: Database Setup
**DO** these actions:
1. Start PostgreSQL using Docker Compose: `docker-compose -f docker-compose.dev.yml up -d db`
2. Wait for database to be ready (check with `docker-compose logs db`)
3. Run database migrations: `alembic upgrade head`
4. Verify database connectivity: `python -c "from core.database.connection import get_db; print('Database connection successful')"`

**ENSURE** these validations:
- PostgreSQL container is running and healthy
- Database migrations complete successfully
- Application can connect to database

### Phase 5: Application Testing
**DO** these actions:
1. Run the application: `uvicorn main:app --reload`
2. Visit `http://localhost:8000/docs` to see API documentation
3. Test health endpoint: `curl http://localhost:8000/health`
4. Run test suite: `pytest`
5. Check code coverage: `pytest --cov`

**ENSURE** these validations:
- Application starts without errors
- API documentation is accessible
- Health checks pass
- All tests pass with good coverage

### Phase 6: Docker Integration
**DO** these actions:
1. Build Docker image: `docker build -t your-app-name .`
2. Start full stack with Docker Compose: `docker-compose up -d`
3. Test containerized application: `curl http://localhost:8000/health`
4. Check all services are healthy: `docker-compose ps`

**ENSURE** these validations:
- Docker image builds successfully
- All containers start and remain healthy
- Application works correctly in containerized environment

### Phase 7: Development Workflow Setup
**DO** these actions:
1. Configure your IDE with Python interpreter from virtual environment
2. Set up code formatting and linting in your editor
3. Test pre-commit hooks: `pre-commit run --all-files`
4. Create your first API endpoint following the boilerplate patterns
5. Write tests for your new endpoint

**ENSURE** these validations:
- IDE is properly configured for Python development
- Code formatting and linting work correctly
- Pre-commit hooks execute successfully
- New code follows established patterns

## Expected Outcomes

**MUST** achieve:
- Fully functional FastAPI application running locally
- PostgreSQL database connected and migrations applied
- Redis caching service operational
- Docker containerization working correctly
- Test suite passing with good coverage
- Pre-commit hooks preventing bad code commits

**SHOULD** produce:
- Comprehensive API documentation accessible at `/docs`
- Health check endpoints responding correctly
- Proper error handling and logging configured
- Authentication system ready for use
- Development environment fully configured

## Quality Checks

**VERIFY** these items:
- [ ] Application starts without errors
- [ ] Database connection is successful
- [ ] API documentation is complete and accurate
- [ ] All tests pass with >90% coverage
- [ ] Docker containers run successfully
- [ ] Pre-commit hooks are working
- [ ] Environment variables are properly configured
- [ ] Security best practices are implemented

## Common Issues and Solutions

**IF** database connection fails:
- **THEN** verify PostgreSQL is running and credentials are correct
- **CHECK** DATABASE_URL format and network connectivity
- **ENSURE** database exists and migrations are applied

**IF** Docker build fails:
- **THEN** check Dockerfile syntax and base image availability
- **VERIFY** all required files are present and not ignored
- **ENSURE** Docker daemon is running and has sufficient resources

**IF** tests fail:
- **THEN** check test database configuration
- **VERIFY** all dependencies are installed correctly
- **ENSURE** test environment variables are set properly

**IF** pre-commit hooks fail:
- **THEN** run formatters manually: `black .` and `isort .`
- **FIX** any linting errors reported by flake8
- **RESOLVE** type checking issues reported by mypy

## Follow-up Actions

**MUST** complete:
- Customize the application for your specific use case
- Add your business logic and domain models
- Configure production environment variables
- Set up CI/CD pipeline for automated testing and deployment

**SHOULD** consider:
- Adding monitoring and observability tools
- Implementing comprehensive logging strategy
- Setting up backup and recovery procedures
- Configuring SSL/TLS for production deployment

**RECOMMENDED** next steps:
- Read through all instruction files in `.github/instructions/`
- Implement your first custom API endpoints
- Set up monitoring and alerting for production
- Configure automated database backups
- Implement comprehensive security audit procedures
