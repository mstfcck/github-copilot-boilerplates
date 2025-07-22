# Spring Boot Troubleshooting Prompt

This prompt provides systematic guidance for diagnosing and resolving common issues in Spring Boot applications.

## Objective

Guide developers through a structured approach to identify, diagnose, and resolve issues in Spring Boot applications, from development to production environments.

## Prerequisites

**MUST** have these prerequisites:
- Access to application logs and monitoring tools
- Understanding of the application architecture
- Knowledge of Spring Boot fundamentals
- Access to debugging tools and environment

**SHOULD** review these resources:
- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)
- [Performance Instructions](../instructions/performance.instructions.md)
- [Security Instructions](../instructions/security.instructions.md)
- [Deployment Instructions](../instructions/deployment.instructions.md)

## Step-by-Step Process

### Phase 1: Issue Identification and Classification
**DO** these actions:
1. **Gather Issue Information**
   - Collect error messages and stack traces
   - Identify when the issue started occurring
   - Determine the affected components/features
   - Note the environment where the issue occurs

2. **Classify the Issue Type**
   - **Application Startup Issues**: Application fails to start
   - **Runtime Errors**: Exceptions during application execution
   - **Performance Issues**: Slow response times, memory leaks
   - **Security Issues**: Authentication/authorization failures
   - **Database Issues**: Connection problems, query failures
   - **External Service Issues**: API calls, third-party integrations

**ENSURE** these validations:
- [ ] Error messages are captured completely
- [ ] Issue reproduction steps are documented
- [ ] Environment details are recorded
- [ ] Impact assessment is completed

### Phase 2: Application Startup Issues
**DO** these actions:
1. **Check Application Logs**
   ```bash
   # Check application logs for startup errors
   tail -f logs/application.log
   
   # Check for port conflicts
   netstat -tulpn | grep :8080
   
   # Check Java process status
   ps aux | grep java
   ```

2. **Common Startup Issues and Solutions**
   
   **IF** Port Already in Use:
   ```bash
   # Find process using the port
   lsof -i :8080
   
   # Kill the process
   kill -9 <PID>
   
   # Or change port in application.yml
   server:
     port: 8081
   ```

   **IF** Bean Creation Failure:
   ```java
   // Check for circular dependencies
   @Lazy
   @Autowired
   private SomeService someService;
   
   // Or use constructor injection
   public class MyService {
       private final SomeService someService;
       
       public MyService(SomeService someService) {
           this.someService = someService;
       }
   }
   ```

   **IF** Database Connection Issues:
   ```yaml
   # Check database configuration
   spring:
     datasource:
       url: jdbc:postgresql://localhost:5432/mydb
       username: ${DB_USERNAME:myuser}
       password: ${DB_PASSWORD:mypass}
       driver-class-name: org.postgresql.Driver
   
   # Test database connectivity
   spring:
     datasource:
       hikari:
         connection-test-query: SELECT 1
         connection-timeout: 20000
   ```

**ENSURE** these validations:
- [ ] Application starts without errors
- [ ] All required beans are created successfully
- [ ] Database connections are established
- [ ] External service connections are working

### Phase 3: Runtime Error Diagnosis
**DO** these actions:
1. **Analyze Stack Traces**
   ```java
   // Enable detailed error responses in development
   server:
     error:
       include-stacktrace: on-trace-param
       include-message: always
   
   logging:
     level:
       root: INFO
       com.example: DEBUG
   ```

2. **Common Runtime Issues and Solutions**
   
   **IF** NullPointerException:
   ```java
   // Use Optional for nullable values
   @Service
   public class UserService {
       
       public UserDto findById(Long id) {
           return userRepository.findById(id)
               .map(this::convertToDto)
               .orElseThrow(() -> new UserNotFoundException("User not found: " + id));
       }
   }
   
   // Use null checks
   if (user != null && user.getEmail() != null) {
       // Process email
   }
   ```

   **IF** DataIntegrityViolationException:
   ```java
   // Handle constraint violations
   @Service
   public class UserService {
       
       public UserDto create(CreateUserRequest request) {
           try {
               // Validate unique constraints
               if (userRepository.existsByEmail(request.getEmail())) {
                   throw new DuplicateEmailException("Email already exists");
               }
               
               User user = userMapper.toEntity(request);
               User savedUser = userRepository.save(user);
               return userMapper.toDto(savedUser);
           } catch (DataIntegrityViolationException e) {
               throw new UserCreationException("Failed to create user", e);
           }
       }
   }
   ```

   **IF** TransactionRollbackException:
   ```java
   // Check transaction boundaries
   @Service
   @Transactional
   public class OrderService {
       
       @Transactional(rollbackFor = Exception.class)
       public OrderDto processOrder(ProcessOrderRequest request) {
           try {
               // Business logic
               Order order = createOrder(request);
               sendNotification(order);
               return orderMapper.toDto(order);
           } catch (Exception e) {
               log.error("Order processing failed: {}", e.getMessage());
               throw new OrderProcessingException("Failed to process order", e);
           }
       }
   }
   ```

**ENSURE** these validations:
- [ ] Root cause of exceptions is identified
- [ ] Proper error handling is implemented
- [ ] Transaction boundaries are correctly defined
- [ ] Error messages are user-friendly

### Phase 4: Performance Issue Diagnosis
**DO** these actions:
1. **Monitor Application Performance**
   ```yaml
   # Enable actuator endpoints
   management:
     endpoints:
       web:
         exposure:
           include: health,metrics,prometheus,httptrace
     metrics:
       export:
         prometheus:
           enabled: true
   ```

2. **Common Performance Issues and Solutions**
   
   **IF** Slow Database Queries:
   ```java
   // Enable query logging
   logging:
     level:
       org.hibernate.SQL: DEBUG
       org.hibernate.type.descriptor.sql.BasicBinder: TRACE
   
   // Use query optimization
   @Query("SELECT u FROM User u JOIN FETCH u.orders WHERE u.id = :id")
   Optional<User> findByIdWithOrders(@Param("id") Long id);
   
   // Add database indexes
   @Table(name = "users", indexes = {
       @Index(name = "idx_email", columnList = "email"),
       @Index(name = "idx_status", columnList = "status")
   })
   ```

   **IF** Memory Leaks:
   ```java
   // Check for proper resource management
   @Service
   public class FileService {
       
       public void processFile(String filePath) {
           try (InputStream inputStream = Files.newInputStream(Paths.get(filePath))) {
               // Process file
           } catch (IOException e) {
               log.error("File processing failed: {}", e.getMessage());
           }
       }
   }
   
   // Use weak references for caches
   private final Map<String, WeakReference<CachedData>> cache = new ConcurrentHashMap<>();
   ```

   **IF** High CPU Usage:
   ```java
   // Use async processing for heavy tasks
   @Service
   public class ProcessingService {
       
       @Async("taskExecutor")
       public CompletableFuture<ProcessResult> processAsync(ProcessRequest request) {
           // Heavy processing logic
           return CompletableFuture.completedFuture(result);
       }
   }
   
   // Implement proper connection pooling
   spring:
     datasource:
       hikari:
         maximum-pool-size: 20
         minimum-idle: 5
         connection-timeout: 20000
         idle-timeout: 300000
   ```

**ENSURE** these validations:
- [ ] Query performance is optimized
- [ ] Memory usage is within acceptable limits
- [ ] CPU usage is reasonable
- [ ] Connection pooling is properly configured

### Phase 5: Security Issue Resolution
**DO** these actions:
1. **Check Security Configuration**
   ```java
   @Configuration
   @EnableWebSecurity
   public class SecurityConfig {
       
       @Bean
       public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
           http
               .authorizeHttpRequests(auth -> auth
                   .requestMatchers("/api/public/**").permitAll()
                   .requestMatchers("/api/admin/**").hasRole("ADMIN")
                   .anyRequest().authenticated()
               )
               .oauth2ResourceServer(oauth2 -> oauth2
                   .jwt(jwt -> jwt.jwtDecoder(jwtDecoder()))
               )
               .csrf(csrf -> csrf.disable())
               .headers(headers -> headers
                   .frameOptions().deny()
                   .contentTypeOptions().and()
                   .httpStrictTransportSecurity(hstsConfig -> hstsConfig
                       .maxAgeInSeconds(31536000)
                       .includeSubdomains(true)
                   )
               );
           
           return http.build();
       }
   }
   ```

2. **Common Security Issues and Solutions**
   
   **IF** Authentication Failures:
   ```java
   // Check JWT token validation
   @Component
   public class JwtAuthenticationFilter extends OncePerRequestFilter {
       
       @Override
       protected void doFilterInternal(HttpServletRequest request, 
                                     HttpServletResponse response, 
                                     FilterChain filterChain) throws ServletException, IOException {
           try {
               String token = extractTokenFromRequest(request);
               if (token != null && jwtTokenProvider.validateToken(token)) {
                   Authentication auth = jwtTokenProvider.getAuthentication(token);
                   SecurityContextHolder.getContext().setAuthentication(auth);
               }
           } catch (JwtException e) {
               log.error("JWT validation failed: {}", e.getMessage());
               response.setStatus(HttpStatus.UNAUTHORIZED.value());
               return;
           }
           
           filterChain.doFilter(request, response);
       }
   }
   ```

   **IF** Authorization Failures:
   ```java
   // Check method-level security
   @RestController
   @RequestMapping("/api/v1/admin")
   @PreAuthorize("hasRole('ADMIN')")
   public class AdminController {
       
       @GetMapping("/users")
       @PreAuthorize("hasAuthority('USER_READ')")
       public ResponseEntity<List<UserDto>> getAllUsers() {
           // Implementation
       }
   }
   ```

**ENSURE** these validations:
- [ ] Authentication mechanisms are working correctly
- [ ] Authorization rules are properly enforced
- [ ] Security headers are configured
- [ ] Sensitive data is properly protected

## Expected Outcomes

**MUST** achieve:
- Issue is identified and root cause is determined
- Problem is resolved with minimal impact
- Solution is documented for future reference
- Preventive measures are implemented

**SHOULD** produce:
- Comprehensive issue analysis report
- Updated monitoring and alerting rules
- Enhanced error handling and logging
- Improved system reliability

## Quality Checks

**VERIFY** these items:
- [ ] Issue is completely resolved
- [ ] Solution doesn't introduce new problems
- [ ] System performance is restored
- [ ] Security is not compromised
- [ ] Documentation is updated
- [ ] Monitoring is enhanced
- [ ] Team is informed of the resolution

## Common Issues and Solutions

**IF** application is not starting:
- **THEN** check port conflicts and configuration
- **THEN** verify database connectivity
- **THEN** review bean dependency chains

**IF** getting 404 errors:
- **THEN** verify controller mapping paths
- **THEN** check security configuration
- **THEN** ensure proper component scanning

**IF** database connection fails:
- **THEN** verify connection parameters
- **THEN** check network connectivity
- **THEN** validate database credentials

**IF** authentication is failing:
- **THEN** verify JWT token configuration
- **THEN** check user credentials and roles
- **THEN** review security filter chain

## Follow-up Actions

**MUST** complete:
- Document the issue and resolution steps
- Update monitoring and alerting rules
- Implement preventive measures
- Share knowledge with team members

**SHOULD** consider:
- Performance impact assessment
- Security vulnerability review
- System reliability improvements
- Process optimization opportunities

This prompt provides a comprehensive approach to troubleshooting Spring Boot applications, ensuring systematic problem resolution and continuous improvement.
