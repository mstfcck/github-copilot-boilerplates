---
applyTo: '**'
---

# Spring Security Implementation Guide

This document provides comprehensive security implementation guidelines for Spring applications.

## Security Configuration Fundamentals

### Basic Security Setup
**MUST** implement these security measures:

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse()))
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()));
        return http.build();
    }
}
```

### Authentication Strategies

#### JWT Token-Based Authentication
**CHOOSE** when:
- Building RESTful APIs
- Need stateless authentication
- Mobile or SPA applications
- Microservices architecture

**IMPLEMENTATION REQUIREMENTS**:
```java
@Component
public class JwtAuthenticationProvider implements AuthenticationProvider {
    // MUST validate token signature
    // MUST check token expiration
    // MUST validate issuer and audience
    // MUST handle token refresh logic
}
```

#### Session-Based Authentication
**CHOOSE** when:
- Traditional web applications
- Server-side rendered pages
- Need advanced session management
- Simple deployment requirements

**IMPLEMENTATION REQUIREMENTS**:
```java
@Configuration
public class SessionConfig {
    @Bean
    public HttpSessionIdResolver httpSessionIdResolver() {
        return HeaderHttpSessionIdResolver.xAuthToken();
    }
}
```

#### OAuth2/OpenID Connect
**CHOOSE** when:
- Integration with external identity providers
- Single Sign-On (SSO) requirements
- Social login capabilities
- Enterprise identity integration

**IMPLEMENTATION REQUIREMENTS**:
```java
@Configuration
public class OAuth2Config {
    @Bean
    public ReactiveClientRegistrationRepository clientRegistrationRepository() {
        // Configure client registrations
    }
}
```

## Authorization Patterns

### Role-Based Access Control (RBAC)
**IMPLEMENTATION**:
```java
@Entity
public class User {
    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "user_roles",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles;
}

@PreAuthorize("hasRole('ADMIN') or #username == authentication.name")
public UserDTO getUserProfile(String username) {
    // Implementation
}
```

### Attribute-Based Access Control (ABAC)
**IMPLEMENTATION**:
```java
@PreAuthorize("@authorizationService.canAccessResource(authentication, #resourceId, 'READ')")
public ResourceDTO getResource(Long resourceId) {
    // Implementation
}

@Component
public class AuthorizationService {
    public boolean canAccessResource(Authentication auth, Long resourceId, String action) {
        // Complex authorization logic based on attributes
    }
}
```

## Input Validation and Sanitization

### Bean Validation
**MUST** use for all API endpoints:
```java
@RestController
@Validated
public class UserController {
    
    @PostMapping("/users")
    public ResponseEntity<UserDTO> createUser(@Valid @RequestBody CreateUserRequest request) {
        // Implementation
    }
}

public class CreateUserRequest {
    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    @Pattern(regexp = "^[a-zA-Z0-9_]+$", message = "Username can only contain alphanumeric characters and underscores")
    private String username;
    
    @Email(message = "Email must be valid")
    @NotBlank(message = "Email is required")
    private String email;
    
    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).*$", message = "Password must contain uppercase, lowercase, and digit")
    private String password;
}
```

### SQL Injection Prevention
**ALWAYS** use parameterized queries:
```java
// CORRECT - Using JPA repository methods
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    @Query("SELECT u FROM User u WHERE u.email = :email")
    Optional<User> findByEmail(@Param("email") String email);
}

// CORRECT - Using criteria API for dynamic queries
@Repository
public class UserCustomRepository {
    public List<User> findUsersWithCriteria(String username, String email) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<User> query = cb.createQuery(User.class);
        // Build criteria safely
    }
}
```

### XSS Prevention
**IMPLEMENT** output encoding:
```java
@Component
public class SecurityUtils {
    
    public String sanitizeHtml(String input) {
        return Jsoup.clean(input, Safelist.basic());
    }
    
    public String escapeHtml(String input) {
        return StringEscapeUtils.escapeHtml4(input);
    }
}
```

## Secure Configuration Practices

### Password Security
**MUST** use strong password encoding:
```java
@Configuration
public class PasswordConfig {
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12); // Use strong work factor
    }
    
    @Bean
    public PasswordPolicy passwordPolicy() {
        return PasswordPolicyBuilder.create()
            .withMinLength(8)
            .withMaxLength(128)
            .withUpperCaseCharacters(1)
            .withLowerCaseCharacters(1)
            .withDigits(1)
            .withSpecialCharacters(1)
            .build();
    }
}
```

### Secrets Management
**NEVER** hardcode secrets in code:
```java
// CORRECT - Using environment variables
@Value("${app.jwt.secret}")
private String jwtSecret;

// CORRECT - Using Spring Cloud Config
@ConfigurationProperties(prefix = "app.security")
@Data
public class SecurityProperties {
    private String jwtSecret;
    private Duration jwtExpiration;
    private String encryptionKey;
}
```

### HTTPS Configuration
**ENFORCE** HTTPS in production:
```java
@Configuration
public class HttpsConfig implements WebMvcConfigurer {
    
    @Bean
    public ServletWebServerFactory servletContainer() {
        TomcatServletWebServerFactory tomcat = new TomcatServletWebServerFactory() {
            @Override
            protected void postProcessContext(Context context) {
                SecurityConstraint securityConstraint = new SecurityConstraint();
                securityConstraint.setUserConstraint("CONFIDENTIAL");
                SecurityCollection collection = new SecurityCollection();
                collection.addPattern("/*");
                securityConstraint.addCollection(collection);
                context.addConstraint(securityConstraint);
            }
        };
        tomcat.addAdditionalTomcatConnectors(redirectConnector());
        return tomcat;
    }
}
```

## Logging and Monitoring

### Security Event Logging
**MUST** log security events:
```java
@Component
public class SecurityEventLogger {
    
    private static final Logger securityLogger = LoggerFactory.getLogger("SECURITY");
    
    public void logAuthenticationSuccess(String username, String ipAddress) {
        securityLogger.info("Authentication successful - User: {}, IP: {}", username, ipAddress);
    }
    
    public void logAuthenticationFailure(String username, String ipAddress, String reason) {
        securityLogger.warn("Authentication failed - User: {}, IP: {}, Reason: {}", username, ipAddress, reason);
    }
    
    public void logUnauthorizedAccess(String username, String resource, String action) {
        securityLogger.warn("Unauthorized access attempt - User: {}, Resource: {}, Action: {}", username, resource, action);
    }
}
```

### Rate Limiting
**IMPLEMENT** to prevent abuse:
```java
@Component
public class RateLimitingInterceptor implements HandlerInterceptor {
    
    private final RedisTemplate<String, String> redisTemplate;
    
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String clientId = getClientIdentifier(request);
        String key = "rate_limit:" + clientId;
        
        String current = redisTemplate.opsForValue().get(key);
        if (current == null) {
            redisTemplate.opsForValue().set(key, "1", Duration.ofMinutes(1));
            return true;
        }
        
        int requests = Integer.parseInt(current);
        if (requests >= 100) { // 100 requests per minute
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            return false;
        }
        
        redisTemplate.opsForValue().increment(key);
        return true;
    }
}
```

## Security Testing Requirements

### Unit Tests
**MUST** test security components:
```java
@ExtendWith(MockitoExtension.class)
class SecurityServiceTest {
    
    @Test
    void shouldHashPasswordSecurely() {
        String password = "testPassword123!";
        String hashed = securityService.hashPassword(password);
        
        assertThat(hashed).isNotEqualTo(password);
        assertThat(securityService.verifyPassword(password, hashed)).isTrue();
    }
    
    @Test
    void shouldValidateJwtToken() {
        String token = jwtService.generateToken("testuser");
        
        assertThat(jwtService.validateToken(token)).isTrue();
        assertThat(jwtService.getUsernameFromToken(token)).isEqualTo("testuser");
    }
}
```

### Integration Tests
**MUST** test security configurations:
```java
@SpringBootTest
@AutoConfigureTestDatabase
@TestMethodOrder(OrderAnnotation.class)
class SecurityIntegrationTest {
    
    @Test
    @WithMockUser(roles = "USER")
    void shouldAllowUserAccessToUserEndpoints() throws Exception {
        mockMvc.perform(get("/api/user/profile"))
                .andExpect(status().isOk());
    }
    
    @Test
    @WithMockUser(roles = "USER")
    void shouldDenyUserAccessToAdminEndpoints() throws Exception {
        mockMvc.perform(get("/api/admin/users"))
                .andExpect(status().isForbidden());
    }
}
```

## Security Checklist

**BEFORE** deploying to production, **ENSURE**:

- [ ] All endpoints are properly secured
- [ ] Input validation is implemented on all API endpoints
- [ ] Passwords are properly hashed with strong algorithms
- [ ] Secrets are externalized and not hardcoded
- [ ] HTTPS is enforced
- [ ] CSRF protection is enabled for state-changing operations
- [ ] Rate limiting is implemented
- [ ] Security headers are configured
- [ ] Authentication and authorization events are logged
- [ ] Security tests are passing
- [ ] Dependency vulnerability scan is clean
- [ ] Security configuration is reviewed

## Common Security Anti-Patterns

**DON'T**:
- Store passwords in plain text
- Use weak encryption algorithms
- Expose sensitive information in error messages
- Allow unrestricted file uploads
- Use default security configurations
- Ignore security headers
- Log sensitive information
- Trust user input without validation
