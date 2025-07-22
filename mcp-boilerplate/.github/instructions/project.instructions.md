---
applyTo: '**'
---
Project instructions for FastMCP and FastAPI Model Context Protocol (MCP) applications.

# Project Instructions

This document outlines the project structure, organization patterns, and development workflows for Model Context Protocol (MCP) applications using FastMCP framework and FastAPI integration.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** use FastMCP framework as the primary MCP implementation
- **REQUIRED** to follow FastMCP project structure conventions
- **SHALL** organize code using modular FastMCP component patterns
- **MUST** include FastAPI integration when building HTTP-based MCP servers
- **NEVER** mix raw MCP SDK code with FastMCP implementations

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** use virtual environments for Python dependency isolation
- **RECOMMENDED** to implement FastMCP server composition for complex applications
- **ALWAYS** include comprehensive testing with FastMCP in-memory patterns
- **DO** structure projects to support both development and production deployments
- **DON'T** create deeply nested module hierarchies without clear purpose

### Optional Enhancements (**MAY** Consider)
- **MAY** implement FastMCP proxy patterns for microservice architectures
- **OPTIONAL** to use Docker containerization for deployment consistency
- **USE** FastAPI middleware for cross-cutting concerns
- **IMPLEMENT** OpenAPI integration via FastMCP.from_fastapi()
- **AVOID** overengineering project structure for simple use cases

## FastMCP Project Structure

**USE** this recommended project layout:

### Basic FastMCP Server Project
```
fastmcp-server/
├── .env                          # Environment variables
├── .gitignore                    # Git ignore patterns
├── README.md                     # Project documentation
├── requirements.txt              # Python dependencies
├── pyproject.toml               # Python project configuration
├── docker-compose.yml          # Local development setup
├── Dockerfile                  # Container deployment
├── server.py                   # Main FastMCP server entry point
├── src/
│   ├── __init__.py
│   ├── server.py               # FastMCP server implementation
│   ├── tools/                  # MCP tools modules
│   │   ├── __init__.py
│   │   ├── analysis.py         # Data analysis tools
│   │   ├── reporting.py        # Report generation tools
│   │   └── utilities.py        # Utility functions
│   ├── resources/              # MCP resources modules
│   │   ├── __init__.py
│   │   ├── config.py          # Configuration resources
│   │   ├── data.py            # Data resources
│   │   └── templates.py       # Template resources
│   ├── prompts/               # MCP prompts modules
│   │   ├── __init__.py
│   │   ├── analysis.py        # Analysis prompts
│   │   └── reporting.py       # Reporting prompts
│   └── shared/                # Shared utilities
│       ├── __init__.py
│       ├── database.py        # Database connections
│       ├── auth.py           # Authentication utilities
│       └── config.py         # Configuration management
├── tests/
│   ├── __init__.py
│   ├── conftest.py           # Pytest configuration
│   ├── test_server.py        # Server tests
│   ├── test_tools.py         # Tools tests
│   ├── test_resources.py     # Resources tests
│   └── integration/          # Integration tests
│       ├── __init__.py
│       ├── test_client.py    # Client integration tests
│       └── test_workflows.py # End-to-end tests
├── configs/
│   ├── development.yaml      # Development configuration
│   ├── production.yaml       # Production configuration
│   └── test.yaml            # Test configuration
└── docs/
    ├── api.md               # API documentation
    ├── deployment.md        # Deployment guide
    └── examples/           # Usage examples
        ├── basic_usage.py
        └── advanced_patterns.py
```

### FastMCP + FastAPI Hybrid Project
```
fastmcp-fastapi-app/
├── .env
├── .gitignore
├── README.md
├── requirements.txt
├── pyproject.toml
├── docker-compose.yml
├── Dockerfile
├── main.py                     # Application entry point
├── src/
│   ├── __init__.py
│   ├── app.py                 # FastAPI application
│   ├── mcp_server.py          # FastMCP server integration
│   ├── api/                   # FastAPI routes
│   │   ├── __init__.py
│   │   ├── v1/
│   │   │   ├── __init__.py
│   │   │   ├── analysis.py    # Analysis endpoints
│   │   │   ├── reports.py     # Reports endpoints
│   │   │   └── health.py      # Health check endpoints
│   │   └── dependencies.py    # FastAPI dependencies
│   ├── mcp/                   # MCP components
│   │   ├── __init__.py
│   │   ├── tools/
│   │   │   ├── __init__.py
│   │   │   ├── analysis.py
│   │   │   └── integration.py # API integration tools
│   │   ├── resources/
│   │   │   ├── __init__.py
│   │   │   ├── api_data.py
│   │   │   └── system_info.py
│   │   └── prompts/
│   │       ├── __init__.py
│   │       └── api_prompts.py
│   ├── models/                # Pydantic models
│   │   ├── __init__.py
│   │   ├── analysis.py
│   │   ├── reports.py
│   │   └── base.py
│   ├── services/              # Business logic
│   │   ├── __init__.py
│   │   ├── analysis_service.py
│   │   └── report_service.py
│   └── core/                  # Core utilities
│       ├── __init__.py
│       ├── config.py
│       ├── database.py
│       ├── security.py
│       └── middleware.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_api/             # FastAPI tests
│   │   ├── __init__.py
│   │   ├── test_analysis.py
│   │   └── test_health.py
│   ├── test_mcp/             # MCP tests
│   │   ├── __init__.py
│   │   ├── test_tools.py
│   │   └── test_integration.py
│   └── integration/          # End-to-end tests
│       ├── __init__.py
│       └── test_full_workflow.py
├── migrations/               # Database migrations
│   └── versions/
├── static/                   # Static files (if needed)
└── templates/               # Jinja2 templates (if needed)
```

### Microservices Architecture with FastMCP
```
fastmcp-microservices/
├── docker-compose.yml
├── .env
├── README.md
├── shared/                    # Shared libraries
│   ├── __init__.py
│   ├── models.py             # Common Pydantic models
│   ├── auth.py              # Shared authentication
│   └── utils.py             # Common utilities
├── services/
│   ├── analytics/           # Analytics microservice
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   ├── main.py
│   │   ├── src/
│   │   │   ├── analytics_server.py
│   │   │   ├── tools/
│   │   │   └── resources/
│   │   └── tests/
│   ├── reports/             # Reports microservice
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   ├── main.py
│   │   ├── src/
│   │   │   ├── reports_server.py
│   │   │   ├── tools/
│   │   │   └── resources/
│   │   └── tests/
│   └── gateway/             # API Gateway with FastMCP proxy
│       ├── Dockerfile
│       ├── requirements.txt
│       ├── main.py
│       ├── src/
│       │   ├── gateway_server.py
│       │   ├── proxy_config.py
│       │   └── routing.py
│       └── tests/
├── configs/                 # Service configurations
│   ├── analytics.yaml
│   ├── reports.yaml
│   └── gateway.yaml
└── scripts/                # Deployment scripts
    ├── deploy.sh
    ├── test_all.sh
    └── setup_dev.sh
```

## Implementation Examples

**IMPLEMENT** these project patterns:

### Basic FastMCP Server (server.py)
```python
"""
FastMCP Server Implementation
Entry point for the MCP server application.
"""
from fastmcp import FastMCP
from src.tools.analysis import setup_analysis_tools
from src.resources.config import setup_config_resources
from src.prompts.analysis import setup_analysis_prompts
from src.shared.config import get_settings
import asyncio

def create_server() -> FastMCP:
    """Create and configure FastMCP server."""
    settings = get_settings()
    
    mcp = FastMCP(
        name=settings.server_name,
        instructions="""
        This server provides comprehensive data analysis capabilities.
        Use analyze_data() for statistical analysis.
        Access configuration via data://settings resource.
        Generate analysis prompts using analysis_prompt().
        """
    )
    
    # Setup components
    setup_analysis_tools(mcp)
    setup_config_resources(mcp)
    setup_analysis_prompts(mcp)
    
    return mcp

async def main():
    """Run the FastMCP server."""
    mcp = create_server()
    
    # Run with transport specified in environment
    transport = get_settings().transport
    if transport == "http":
        mcp.run(transport="http", port=8000)
    else:
        mcp.run()  # Default to stdio

if __name__ == "__main__":
    asyncio.run(main())
```

### FastAPI + FastMCP Integration (main.py)
```python
"""
FastAPI + FastMCP Hybrid Application
Combines REST API with MCP server capabilities.
"""
from fastapi import FastAPI
from fastmcp import FastMCP
from src.app import create_fastapi_app
from src.mcp_server import create_mcp_server
from src.core.config import get_settings

def create_application():
    """Create hybrid FastAPI + FastMCP application."""
    settings = get_settings()
    
    # Create FastAPI app
    app = create_fastapi_app()
    
    # Create FastMCP server from FastAPI
    mcp = FastMCP.from_fastapi(
        app=app,
        name="Hybrid-API-MCP-Server",
        httpx_client_kwargs={"timeout": 30.0}
    )
    
    # Add MCP-specific components
    create_mcp_server(mcp)
    
    return app, mcp

app, mcp_server = create_application()

if __name__ == "__main__":
    settings = get_settings()
    
    if settings.mode == "api":
        # Run as FastAPI server
        import uvicorn
        uvicorn.run(app, host="0.0.0.0", port=8000)
    elif settings.mode == "mcp":
        # Run as MCP server
        mcp_server.run()
    else:
        # Run as HTTP MCP server
        mcp_server.run(transport="http", port=8000)
```

### Modular Tool Implementation (src/tools/analysis.py)
```python
"""
Analysis Tools Module
FastMCP tools for data analysis operations.
"""
from fastmcp import FastMCP
from typing import List, Dict, Any, Optional
from ..shared.database import get_database_session
from ..models.analysis import AnalysisRequest, AnalysisResult
import asyncio

def setup_analysis_tools(mcp: FastMCP):
    """Register analysis tools with the FastMCP server."""
    
    @mcp.tool
    async def analyze_dataset(
        data: List[float],
        method: str = "statistical",
        options: Optional[Dict[str, Any]] = None
    ) -> AnalysisResult:
        """
        Perform comprehensive data analysis.
        
        Args:
            data: List of numerical values to analyze
            method: Analysis method (statistical, advanced, ml)
            options: Additional analysis options
        
        Returns:
            AnalysisResult with computed statistics and insights
        """
        await asyncio.sleep(0.1)  # Simulate async processing
        
        if method == "statistical":
            return AnalysisResult(
                method=method,
                count=len(data),
                mean=sum(data) / len(data),
                min_value=min(data),
                max_value=max(data),
                insights=["Data appears normally distributed"]
            )
        elif method == "advanced":
            # Advanced analysis logic
            return AnalysisResult(
                method=method,
                count=len(data),
                mean=sum(data) / len(data),
                insights=["Advanced patterns detected"]
            )
        else:
            raise ValueError(f"Unsupported analysis method: {method}")
    
    @mcp.tool
    async def batch_analyze(
        datasets: List[List[float]],
        method: str = "statistical"
    ) -> List[AnalysisResult]:
        """
        Analyze multiple datasets in batch.
        
        Args:
            datasets: List of datasets to analyze
            method: Analysis method to apply to all datasets
        
        Returns:
            List of analysis results for each dataset
        """
        results = []
        for dataset in datasets:
            result = await analyze_dataset(dataset, method)
            results.append(result)
        return results
    
    @mcp.tool
    async def get_analysis_history(
        user_id: Optional[str] = None,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """
        Get historical analysis records.
        
        Args:
            user_id: Optional user ID filter
            limit: Maximum number of records to return
        
        Returns:
            List of historical analysis records
        """
        # Simulate database query
        async with get_database_session() as session:
            # Database query logic would go here
            return [
                {
                    "id": f"analysis_{i}",
                    "timestamp": "2024-01-01T00:00:00Z",
                    "method": "statistical",
                    "status": "completed"
                }
                for i in range(limit)
            ]
```

### Resource Implementation (src/resources/config.py)
```python
"""
Configuration Resources Module
FastMCP resources for server configuration and metadata.
"""
from fastmcp import FastMCP
from typing import Dict, Any
from ..shared.config import get_settings
from ..shared.database import get_database_status

def setup_config_resources(mcp: FastMCP):
    """Register configuration resources with the FastMCP server."""
    
    @mcp.resource("data://settings")
    async def get_server_settings() -> Dict[str, Any]:
        """
        Provide server configuration settings.
        
        Returns:
            Server configuration and feature flags
        """
        settings = get_settings()
        return {
            "server_name": settings.server_name,
            "version": settings.version,
            "features": {
                "analysis": True,
                "reporting": True,
                "batch_processing": True
            },
            "limits": {
                "max_data_points": settings.max_data_points,
                "batch_size": settings.batch_size,
                "rate_limit": settings.rate_limit
            },
            "environment": settings.environment
        }
    
    @mcp.resource("system://status")
    async def get_system_status() -> Dict[str, Any]:
        """
        Provide current system status and health information.
        
        Returns:
            System status including database connectivity
        """
        db_status = await get_database_status()
        
        return {
            "status": "healthy",
            "timestamp": "2024-01-01T00:00:00Z",
            "services": {
                "database": db_status,
                "cache": "connected",
                "external_apis": "available"
            },
            "performance": {
                "cpu_usage": "15%",
                "memory_usage": "45%",
                "disk_usage": "30%"
            }
        }
    
    @mcp.resource("analysis://templates/{template_type}")
    async def get_analysis_template(template_type: str) -> Dict[str, Any]:
        """
        Get analysis configuration templates.
        
        Args:
            template_type: Type of analysis template
        
        Returns:
            Analysis template configuration
        """
        templates = {
            "basic": {
                "methods": ["statistical"],
                "options": {"include_charts": False},
                "output_format": "summary"
            },
            "advanced": {
                "methods": ["statistical", "ml", "forecasting"],
                "options": {"include_charts": True, "detailed_insights": True},
                "output_format": "detailed"
            },
            "batch": {
                "methods": ["statistical"],
                "options": {"parallel_processing": True},
                "batch_size": 100
            }
        }
        
        if template_type not in templates:
            raise ValueError(f"Unknown template type: {template_type}")
        
        return templates[template_type]
```

## Development Workflow

**FOLLOW** this development process:

### 1. Environment Setup
```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate     # Windows

# Install dependencies
pip install fastmcp fastapi uvicorn pytest
pip install -r requirements.txt

# Install development dependencies
pip install -r requirements-dev.txt
```

### 2. Configuration Management
```python
# src/shared/config.py
from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    server_name: str = "FastMCP-Server"
    version: str = "1.0.0"
    environment: str = "development"
    transport: str = "stdio"
    
    # Database settings
    database_url: Optional[str] = None
    
    # API settings
    api_host: str = "0.0.0.0"
    api_port: int = 8000
    
    # Analysis settings
    max_data_points: int = 10000
    batch_size: int = 100
    rate_limit: int = 100
    
    class Config:
        env_file = ".env"

_settings = None

def get_settings() -> Settings:
    global _settings
    if _settings is None:
        _settings = Settings()
    return _settings
```

### 3. Testing Strategy
```python
# tests/conftest.py
import pytest
from fastmcp import FastMCP, Client
from src.server import create_server

@pytest.fixture
def test_server():
    """Create test FastMCP server."""
    return create_server()

@pytest.fixture
async def test_client(test_server):
    """Create test client for FastMCP server."""
    async with Client(test_server) as client:
        yield client

@pytest.mark.asyncio
async def test_analyze_tool(test_client):
    """Test analysis tool functionality."""
    result = await test_client.call_tool(
        "analyze_dataset",
        {"data": [1, 2, 3, 4, 5], "method": "statistical"}
    )
    assert result.data["count"] == 5
    assert result.data["mean"] == 3.0
```

### 4. Deployment Configuration
```yaml
# docker-compose.yml
version: '3.8'
services:
  fastmcp-server:
    build: .
    ports:
      - "8000:8000"
    environment:
      - ENVIRONMENT=production
      - DATABASE_URL=postgresql://user:pass@db:5432/fastmcp
    depends_on:
      - db
    volumes:
      - ./configs:/app/configs
  
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: fastmcp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## Quality Standards

**MAINTAIN** these project quality standards:

### Code Quality
- Use type hints throughout Python code
- Follow PEP 8 style guidelines
- Implement comprehensive error handling
- Write descriptive docstrings for all MCP components
- Use consistent naming conventions

### Testing
- Achieve >90% test coverage
- Use FastMCP in-memory testing for unit tests
- Implement integration tests for client-server interactions
- Include performance tests for critical operations
- Test error handling and edge cases

### Documentation
- Document all MCP tools, resources, and prompts
- Include usage examples and common patterns
- Maintain deployment and configuration guides
- Document API endpoints for hybrid applications
- Keep README files up to date

### Security
- Use environment variables for sensitive configuration
- Implement proper authentication when required
- Validate all inputs to MCP tools
- Use HTTPS for production deployments
- Regular security dependency updates

## References

- [FastMCP Documentation](https://gofastmcp.com/) - Framework documentation and examples
- [FastAPI Documentation](https://fastapi.tiangolo.com/) - Web framework integration
- [MCP Instructions](./mcp.instructions.md) - Comprehensive FastMCP and FastAPI documentation
- [Coding Standards](./coding-standards.instructions.md) - FastMCP coding standards
- [Architecture Instructions](./architecture.instructions.md) - FastMCP architecture patterns
