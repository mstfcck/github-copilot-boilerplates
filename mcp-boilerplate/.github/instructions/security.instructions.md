---
applyTo: '**'
---

# MCP Security Implementation Guide

This document provides comprehensive security implementation guidelines for Model Context Protocol (MCP) applications following protocol specifications and industry best practices.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** validate all input parameters at protocol boundaries
- **REQUIRED** to implement proper authentication for HTTP/SSE transports
- **SHALL** sanitize all outputs to prevent information disclosure
- **MUST** implement rate limiting for tool invocations and resource access
- **NEVER** execute arbitrary code or expose sensitive system information

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** implement OAuth 2.1 for HTTP transport authentication
- **RECOMMENDED** to use HTTPS for all production deployments
- **ALWAYS** validate Origin header for DNS rebinding attack prevention
- **DO** implement proper access control for resources and tools
- **DON'T** log sensitive information or credentials

### Optional Enhancements (**MAY** Consider)
- **MAY** implement advanced monitoring and audit logging
- **OPTIONAL** to add IP-based access restrictions
- **USE** content security policies for web-based interfaces
- **IMPLEMENT** encryption for sensitive data at rest
- **AVOID** exposing internal system details in error messages

## Implementation Guidance

**USE** these security patterns:

### Input Validation
```python
# Python Input Validation
import json
from typing import Any, Dict
from jsonschema import validate, ValidationError

class InputValidator:
    def __init__(self):
        self.tool_schemas = {}
    
    def validate_tool_input(self, tool_name: str, arguments: Dict[str, Any]) -> bool:
        """Validate tool input against schema"""
        if tool_name not in self.tool_schemas:
            raise ValueError(f"Unknown tool: {tool_name}")
        
        schema = self.tool_schemas[tool_name]
        try:
            validate(instance=arguments, schema=schema)
            return True
        except ValidationError as e:
            raise ValueError(f"Invalid input for {tool_name}: {e.message}")
    
    def sanitize_string(self, value: str) -> str:
        """Sanitize string input"""
        # Remove potential script injections
        dangerous_patterns = ['<script', 'javascript:', 'data:', 'vbscript:']
        sanitized = value
        for pattern in dangerous_patterns:
            sanitized = sanitized.replace(pattern, '')
        return sanitized.strip()
```

### Authentication Implementation
```typescript
// TypeScript OAuth 2.1 Implementation
interface AuthConfig {
    authorizationUrl: string;
    tokenUrl: string;
    clientId: string;
    clientSecret?: string;
    scopes: string[];
}

class MCPAuthenticator {
    private config: AuthConfig;
    private accessToken?: string;
    private refreshToken?: string;
    
    constructor(config: AuthConfig) {
        this.config = config;
    }
    
    async authenticate(): Promise<void> {
        // Implement OAuth 2.1 PKCE flow
        const codeVerifier = this.generateCodeVerifier();
        const codeChallenge = await this.generateCodeChallenge(codeVerifier);
        
        const authUrl = new URL(this.config.authorizationUrl);
        authUrl.searchParams.set('client_id', this.config.clientId);
        authUrl.searchParams.set('response_type', 'code');
        authUrl.searchParams.set('code_challenge', codeChallenge);
        authUrl.searchParams.set('code_challenge_method', 'S256');
        authUrl.searchParams.set('scope', this.config.scopes.join(' '));
        
        // Redirect user to authorization URL
        // Handle callback and exchange code for tokens
    }
    
    private generateCodeVerifier(): string {
        const array = new Uint8Array(32);
        crypto.getRandomValues(array);
        return btoa(String.fromCharCode(...array))
            .replace(/\+/g, '-')
            .replace(/\//g, '_')
            .replace(/=/g, '');
    }
    
    private async generateCodeChallenge(verifier: string): Promise<string> {
        const encoder = new TextEncoder();
        const data = encoder.encode(verifier);
        const digest = await crypto.subtle.digest('SHA-256', data);
        return btoa(String.fromCharCode(...new Uint8Array(digest)))
            .replace(/\+/g, '-')
            .replace(/\//g, '_')
            .replace(/=/g, '');
    }
}
```

### Rate Limiting
```java
// Java Rate Limiting Implementation
import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

public class MCPRateLimiter {
    private final ConcurrentHashMap<String, ClientBucket> clientBuckets = new ConcurrentHashMap<>();
    private final int maxRequestsPerMinute;
    private final Duration windowDuration;
    
    public MCPRateLimiter(int maxRequestsPerMinute) {
        this.maxRequestsPerMinute = maxRequestsPerMinute;
        this.windowDuration = Duration.ofMinutes(1);
    }
    
    public boolean isAllowed(String clientId, String operation) {
        ClientBucket bucket = clientBuckets.computeIfAbsent(clientId, k -> new ClientBucket());
        return bucket.tryConsume(operation);
    }
    
    private class ClientBucket {
        private final ConcurrentHashMap<String, OperationWindow> operations = new ConcurrentHashMap<>();
        
        public boolean tryConsume(String operation) {
            OperationWindow window = operations.computeIfAbsent(operation, k -> new OperationWindow());
            return window.tryConsume();
        }
        
        private class OperationWindow {
            private volatile Instant windowStart = Instant.now();
            private final AtomicInteger requestCount = new AtomicInteger(0);
            
            public boolean tryConsume() {
                Instant now = Instant.now();
                
                // Reset window if expired
                if (now.isAfter(windowStart.plus(windowDuration))) {
                    synchronized (this) {
                        if (now.isAfter(windowStart.plus(windowDuration))) {
                            windowStart = now;
                            requestCount.set(0);
                        }
                    }
                }
                
                // Check if under limit
                return requestCount.incrementAndGet() <= maxRequestsPerMinute;
            }
        }
    }
}
```

**IMPLEMENT** these security configurations:

### HTTP Transport Security
```python
# Python HTTP Transport Security
from aiohttp import web, ClientSession
from aiohttp.web_middlewares import cors_handler
import ssl

class SecureMCPServer:
    def __init__(self):
        self.app = web.Application()
        self.setup_security_middleware()
        self.setup_routes()
    
    def setup_security_middleware(self):
        """Setup security middleware"""
        
        async def validate_origin(request, handler):
            """Validate Origin header to prevent DNS rebinding"""
            origin = request.headers.get('Origin')
            if origin:
                allowed_origins = ['https://localhost', 'https://127.0.0.1']
                if origin not in allowed_origins:
                    raise web.HTTPForbidden(text="Invalid origin")
            return await handler(request)
        
        async def validate_auth(request, handler):
            """Validate authentication token"""
            auth_header = request.headers.get('Authorization')
            if not auth_header or not auth_header.startswith('Bearer '):
                raise web.HTTPUnauthorized(text="Missing or invalid authorization")
            
            token = auth_header[7:]  # Remove 'Bearer ' prefix
            if not self.validate_token(token):
                raise web.HTTPUnauthorized(text="Invalid token")
            
            return await handler(request)
        
        async def add_security_headers(request, handler):
            """Add security headers to responses"""
            response = await handler(request)
            response.headers['X-Content-Type-Options'] = 'nosniff'
            response.headers['X-Frame-Options'] = 'DENY'
            response.headers['X-XSS-Protection'] = '1; mode=block'
            response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
            return response
        
        self.app.middlewares.append(validate_origin)
        self.app.middlewares.append(validate_auth)
        self.app.middlewares.append(add_security_headers)
    
    def validate_token(self, token: str) -> bool:
        """Validate JWT token"""
        try:
            # Implement JWT validation
            # Verify signature, expiration, issuer, audience
            return True
        except Exception:
            return False
    
    def setup_ssl_context(self):
        """Setup SSL context for HTTPS"""
        ssl_context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
        ssl_context.load_cert_chain('path/to/cert.pem', 'path/to/key.pem')
        return ssl_context
```

### Access Control Implementation
```typescript
// TypeScript Access Control
interface AccessPolicy {
    resource: string;
    action: string;
    conditions?: Record<string, any>;
}

class MCPAccessController {
    private policies: Map<string, AccessPolicy[]> = new Map();
    
    addPolicy(clientId: string, policy: AccessPolicy): void {
        const clientPolicies = this.policies.get(clientId) || [];
        clientPolicies.push(policy);
        this.policies.set(clientId, clientPolicies);
    }
    
    async checkAccess(clientId: string, resource: string, action: string, context?: any): Promise<boolean> {
        const clientPolicies = this.policies.get(clientId) || [];
        
        for (const policy of clientPolicies) {
            if (this.policyMatches(policy, resource, action, context)) {
                return true;
            }
        }
        
        return false;
    }
    
    private policyMatches(policy: AccessPolicy, resource: string, action: string, context?: any): boolean {
        // Check resource pattern match
        if (!this.matchesPattern(policy.resource, resource)) {
            return false;
        }
        
        // Check action match
        if (policy.action !== '*' && policy.action !== action) {
            return false;
        }
        
        // Check conditions if present
        if (policy.conditions && context) {
            for (const [key, expectedValue] of Object.entries(policy.conditions)) {
                if (context[key] !== expectedValue) {
                    return false;
                }
            }
        }
        
        return true;
    }
    
    private matchesPattern(pattern: string, value: string): boolean {
        // Simple wildcard matching
        const regex = new RegExp(pattern.replace(/\*/g, '.*'));
        return regex.test(value);
    }
}
```

**ENSURE** these security validations:

### Output Sanitization
```python
# Python Output Sanitization
import html
import re
from typing import Any, Dict

class OutputSanitizer:
    def __init__(self):
        self.sensitive_patterns = [
            r'password\s*[:=]\s*[^\s]+',
            r'token\s*[:=]\s*[^\s]+',
            r'key\s*[:=]\s*[^\s]+',
            r'secret\s*[:=]\s*[^\s]+',
            r'/etc/passwd',
            r'/etc/shadow',
            r'c:\\windows\\system32'
        ]
    
    def sanitize_output(self, data: Any) -> Any:
        """Sanitize output to prevent information disclosure"""
        if isinstance(data, str):
            return self.sanitize_string(data)
        elif isinstance(data, dict):
            return {k: self.sanitize_output(v) for k, v in data.items()}
        elif isinstance(data, list):
            return [self.sanitize_output(item) for item in data]
        else:
            return data
    
    def sanitize_string(self, text: str) -> str:
        """Sanitize string to remove sensitive information"""
        sanitized = text
        
        # Remove sensitive patterns
        for pattern in self.sensitive_patterns:
            sanitized = re.sub(pattern, '[REDACTED]', sanitized, flags=re.IGNORECASE)
        
        # HTML escape if needed
        sanitized = html.escape(sanitized)
        
        return sanitized
    
    def sanitize_error_message(self, error: Exception) -> str:
        """Sanitize error messages to prevent information disclosure"""
        error_msg = str(error)
        
        # Remove file paths
        error_msg = re.sub(r'/[^\s]+', '[PATH]', error_msg)
        error_msg = re.sub(r'[A-Z]:\\[^\s]+', '[PATH]', error_msg)
        
        # Remove sensitive patterns
        for pattern in self.sensitive_patterns:
            error_msg = re.sub(pattern, '[REDACTED]', error_msg, flags=re.IGNORECASE)
        
        return error_msg
```

## Anti-Patterns

**DON'T** implement these security approaches:

### Avoid Insecure Authentication
```python
# BAD - Insecure authentication
def bad_auth_check(request):
    # NEVER use simple password comparison
    if request.headers.get('password') == 'admin123':
        return True
    
    # NEVER trust client-provided tokens without validation
    token = request.headers.get('token')
    return token is not None  # No validation
```

### Avoid Information Disclosure
```typescript
// BAD - Information disclosure
class BadErrorHandler {
    handleError(error: Error): any {
        // NEVER expose internal errors
        return {
            error: error.stack,  // Exposes internal structure
            config: this.config,  // Exposes configuration
            env: process.env     // Exposes environment variables
        };
    }
}
```

**AVOID** these common security mistakes:

### SQL Injection Vulnerabilities
```python
# BAD - SQL injection vulnerability
def bad_database_query(user_input):
    # NEVER use string concatenation for SQL queries
    query = f"SELECT * FROM users WHERE name = '{user_input}'"
    return execute_query(query)
```

### Command Injection Vulnerabilities
```java
// BAD - Command injection vulnerability
public class BadToolHandler {
    public String handleTool(String command) {
        // NEVER execute arbitrary commands
        try {
            Process process = Runtime.getRuntime().exec(command);
            return getOutput(process);
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}
```

**NEVER** do these security violations:

### Hardcoded Secrets
```python
# BAD - Hardcoded secrets
API_KEY = "sk-1234567890abcdef"  # NEVER hardcode secrets
DATABASE_PASSWORD = "password123"  # NEVER hardcode passwords

def connect_to_service():
    return ServiceClient(api_key=API_KEY)  # Security violation
```

### Inadequate Input Validation
```typescript
// BAD - Inadequate input validation
class BadInputHandler {
    async handleToolCall(toolName: string, args: any): Promise<any> {
        // NEVER trust input without validation
        return await this.tools[toolName](args);
        
        // NEVER allow arbitrary file access
        const filePath = args.path;
        return fs.readFileSync(filePath);
    }
}
```

## Code Examples

### Complete Security Implementation
```python
import asyncio
import jwt
import hashlib
import secrets
from typing import Dict, Any, Optional
from datetime import datetime, timedelta

class SecureMCPImplementation:
    def __init__(self):
        self.rate_limiter = MCPRateLimiter(100)  # 100 requests per minute
        self.access_controller = MCPAccessController()
        self.input_validator = InputValidator()
        self.output_sanitizer = OutputSanitizer()
        self.jwt_secret = secrets.token_urlsafe(32)
    
    async def secure_tool_call(self, client_id: str, tool_name: str, 
                              arguments: Dict[str, Any], auth_token: str) -> Dict[str, Any]:
        """Secure tool call with comprehensive security checks"""
        
        try:
            # 1. Validate authentication
            if not self.validate_jwt_token(auth_token):
                raise SecurityError("Invalid authentication token")
            
            # 2. Check rate limiting
            if not self.rate_limiter.is_allowed(client_id, f"tool:{tool_name}"):
                raise SecurityError("Rate limit exceeded")
            
            # 3. Validate input
            self.input_validator.validate_tool_input(tool_name, arguments)
            
            # 4. Check access control
            if not await self.access_controller.check_access(client_id, f"tool:{tool_name}", "execute"):
                raise SecurityError("Access denied")
            
            # 5. Execute tool with sanitized input
            sanitized_args = self.input_validator.sanitize_input(arguments)
            result = await self.execute_tool(tool_name, sanitized_args)
            
            # 6. Sanitize output
            sanitized_result = self.output_sanitizer.sanitize_output(result)
            
            return {
                "success": True,
                "result": sanitized_result,
                "timestamp": datetime.utcnow().isoformat()
            }
            
        except SecurityError as e:
            # Log security event
            await self.log_security_event(client_id, "SECURITY_VIOLATION", str(e))
            raise
        except Exception as e:
            # Sanitize error message
            sanitized_error = self.output_sanitizer.sanitize_error_message(e)
            return {
                "success": False,
                "error": sanitized_error,
                "timestamp": datetime.utcnow().isoformat()
            }
    
    def validate_jwt_token(self, token: str) -> bool:
        """Validate JWT token with proper verification"""
        try:
            decoded = jwt.decode(
                token,
                self.jwt_secret,
                algorithms=['HS256'],
                options={
                    'verify_signature': True,
                    'verify_exp': True,
                    'verify_iat': True,
                    'verify_aud': True,
                    'verify_iss': True
                }
            )
            
            # Additional validation
            if decoded.get('aud') != 'mcp-server':
                return False
            if decoded.get('iss') != 'mcp-auth':
                return False
            
            return True
            
        except jwt.InvalidTokenError:
            return False
    
    async def log_security_event(self, client_id: str, event_type: str, details: str):
        """Log security events for monitoring"""
        event = {
            "timestamp": datetime.utcnow().isoformat(),
            "client_id": client_id,
            "event_type": event_type,
            "details": details,
            "source_ip": "redacted"  # Don't log IP addresses
        }
        
        # Send to security monitoring system
        await self.send_to_security_monitor(event)

class SecurityError(Exception):
    """Security-related exception"""
    pass
```

## Security Testing Requirements

### Unit Tests
**MUST** test security components:
```python
import pytest
from unittest.mock import Mock, patch

class TestMCPSecurity:
    def test_input_validation(self):
        validator = InputValidator()
        
        # Test valid input
        valid_args = {"param": "safe_value"}
        assert validator.validate_tool_input("test_tool", valid_args)
        
        # Test invalid input
        invalid_args = {"param": "<script>alert('xss')</script>"}
        with pytest.raises(ValueError):
            validator.validate_tool_input("test_tool", invalid_args)
    
    def test_rate_limiting(self):
        limiter = MCPRateLimiter(2)  # 2 requests per minute
        
        # First two requests should succeed
        assert limiter.is_allowed("client1", "operation1")
        assert limiter.is_allowed("client1", "operation1")
        
        # Third request should fail
        assert not limiter.is_allowed("client1", "operation1")
    
    def test_access_control(self):
        controller = MCPAccessController()
        controller.add_policy("client1", {
            "resource": "tool:calculator",
            "action": "execute"
        })
        
        # Should allow access to calculator tool
        assert controller.check_access("client1", "tool:calculator", "execute")
        
        # Should deny access to other tools
        assert not controller.check_access("client1", "tool:file_system", "execute")
```

### Integration Tests
**MUST** test security integrations:
```python
import asyncio
import aiohttp
from aiohttp.test_utils import AioHTTPTestCase

class TestSecurityIntegration(AioHTTPTestCase):
    async def get_application(self):
        return create_secure_mcp_app()
    
    async def test_authentication_required(self):
        # Test unauthenticated request
        async with self.client.post('/mcp/tools/call') as resp:
            assert resp.status == 401
    
    async def test_origin_validation(self):
        # Test invalid origin
        headers = {'Origin': 'https://malicious.com'}
        async with self.client.post('/mcp/tools/call', headers=headers) as resp:
            assert resp.status == 403
    
    async def test_rate_limiting_integration(self):
        headers = {'Authorization': 'Bearer valid_token'}
        
        # Make requests up to limit
        for i in range(100):
            async with self.client.post('/mcp/tools/call', headers=headers) as resp:
                assert resp.status in [200, 400]  # Success or validation error
        
        # Next request should be rate limited
        async with self.client.post('/mcp/tools/call', headers=headers) as resp:
            assert resp.status == 429
```

## Validation Checklist

**MUST** verify:
- [ ] Input validation implemented for all protocol endpoints
- [ ] Authentication and authorization properly configured
- [ ] Rate limiting implemented for all operations
- [ ] Output sanitization prevents information disclosure
- [ ] HTTPS configured for production deployments
- [ ] Origin header validation prevents DNS rebinding attacks
- [ ] Error messages don't expose sensitive information
- [ ] Secrets are properly externalized and secured

**SHOULD** check:
- [ ] JWT tokens properly validated with signature verification
- [ ] Access control policies correctly implemented
- [ ] Security events logged and monitored
- [ ] Security headers configured for HTTP responses
- [ ] Input schemas strictly enforce expected data types
- [ ] File system access properly restricted
- [ ] Database queries use parameterized statements

## References

- [MCP Security Best Practices](https://modelcontextprotocol.io/introduction/specification/draft/basic/security_best_practices)
- [OAuth 2.1 Security Best Practices](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics)
- [MCP Transport Security](https://modelcontextprotocol.io/introduction/specification/draft/basic/transports)
- [OWASP Security Guidelines](https://owasp.org/www-project-top-ten/)
- [JWT Security Best Practices](https://auth0.com/blog/a-look-at-the-latest-draft-for-jwt-bcp/)
