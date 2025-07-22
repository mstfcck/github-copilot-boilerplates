---
applyTo: '**'
---

# Spring Performance Optimization Instructions

This document provides comprehensive performance optimization guidelines for Spring Boot applications to ensure scalability, responsiveness, and efficient resource utilization.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** implement proper connection pooling for database connections
- **REQUIRED** to configure appropriate timeout values for external service calls
- **SHALL** use caching strategies for frequently accessed data
- **NEVER** perform blocking operations on the main thread without proper async handling
- **MUST** implement proper indexing for database queries
- **REQUIRED** to use pagination for large result sets
- **SHALL** monitor and optimize memory usage patterns

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** use asynchronous processing for time-consuming operations
- **RECOMMENDED** to implement circuit breaker patterns for external services
- **ALWAYS** use appropriate HTTP status codes and response compression
- **DO** implement proper logging levels to avoid performance impact
- **ALWAYS** use lazy loading for JPA relationships where appropriate
- **DO** implement proper batch processing for bulk operations
- **DON'T** load entire collections when only count is needed

### Optional Enhancements (**MAY** Consider)
- **MAY** implement advanced caching strategies (Redis, Hazelcast)
- **OPTIONAL** to use database read replicas for read-heavy operations
- **USE** Spring Boot Actuator for performance monitoring
- **IMPLEMENT** custom metrics for business-specific performance indicators
- **AVOID** premature optimization without proper benchmarking

## Implementation Guidance

**USE** these caching strategies:
- **Local Caching**: For frequently accessed, rarely changing data
- **Distributed Caching**: For session data and shared application state
- **Database Query Caching**: For complex, expensive queries
- **HTTP Response Caching**: For static or semi-static content

**IMPLEMENT** these connection pool configurations:
```yaml
# HikariCP Configuration
spring:
  datasource:
    hikari:
      minimum-idle: 5
      maximum-pool-size: 20
      idle-timeout: 300000
      connection-timeout: 20000
      max-lifetime: 1200000
      leak-detection-threshold: 60000
```

**ENSURE** proper async configuration:
```java
@Configuration
@EnableAsync
public class AsyncConfig {
    
    @Bean(name = "taskExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("async-");
        executor.initialize();
        return executor;
    }
}
```

## Anti-Patterns

**DON'T** use inefficient database queries:
```java
// BAD - N+1 query problem
@OneToMany(mappedBy = "user", fetch = FetchType.EAGER)
private List<Order> orders; // AVOID eager loading
```

**AVOID** blocking operations in controllers:
```java
// BAD - Blocking operation
@GetMapping("/slow-operation")
public ResponseEntity<String> slowOperation() {
    Thread.sleep(5000); // NEVER block the main thread
    return ResponseEntity.ok("Done");
}
```

**NEVER** ignore connection pooling:
```java
// BAD - Creating new connections every time
DriverManager.getConnection(url, user, password); // NEVER do this
```

## Code Examples

### Proper Caching Implementation
```java
@Service
@Slf4j
public class UserService {
    
    private final UserRepository userRepository;
    
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
    
    @Cacheable(value = "users", key = "#id")
    public UserDto findById(Long id) {
        log.debug("Fetching user from database: {}", id);
        return userRepository.findById(id)
            .map(this::convertToDto)
            .orElseThrow(() -> new UserNotFoundException("User not found: " + id));
    }
    
    @CacheEvict(value = "users", key = "#user.id")
    public UserDto update(UserDto user) {
        log.debug("Updating user and evicting cache: {}", user.getId());
        // Update logic
        return user;
    }
    
    @CacheEvict(value = "users", allEntries = true)
    public void clearCache() {
        log.debug("Clearing all user cache entries");
    }
}
```

### Proper Async Processing
```java
@Service
@Slf4j
public class EmailService {
    
    @Async("taskExecutor")
    public CompletableFuture<Void> sendWelcomeEmail(String email) {
        log.info("Sending welcome email to: {}", email);
        
        try {
            // Simulate email sending
            Thread.sleep(2000);
            log.info("Welcome email sent successfully to: {}", email);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("Email sending interrupted for: {}", email);
        } catch (Exception e) {
            log.error("Failed to send welcome email to: {}", email, e);
        }
        
        return CompletableFuture.completedFuture(null);
    }
    
    @Async("taskExecutor")
    public CompletableFuture<String> processLargeFile(String filePath) {
        log.info("Processing large file: {}", filePath);
        
        try {
            // Simulate file processing
            Thread.sleep(10000);
            return CompletableFuture.completedFuture("Processing completed");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return CompletableFuture.failedFuture(e);
        }
    }
}
```

### Proper Database Query Optimization
```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // Use projection for specific fields
    @Query("SELECT new com.example.dto.UserSummaryDto(u.id, u.email, u.firstName, u.lastName) " +
           "FROM User u WHERE u.status = :status")
    List<UserSummaryDto> findUserSummariesByStatus(@Param("status") UserStatus status);
    
    // Use pagination for large datasets
    @Query("SELECT u FROM User u WHERE u.createdAt >= :startDate ORDER BY u.createdAt DESC")
    Page<User> findRecentUsers(@Param("startDate") LocalDateTime startDate, Pageable pageable);
    
    // Use batch operations for bulk updates
    @Modifying
    @Query("UPDATE User u SET u.status = :status WHERE u.id IN :ids")
    int updateUserStatus(@Param("ids") List<Long> ids, @Param("status") UserStatus status);
    
    // Use exists for existence checks
    boolean existsByEmail(String email);
    
    // Use count for counting operations
    @Query("SELECT COUNT(u) FROM User u WHERE u.status = :status")
    long countByStatus(@Param("status") UserStatus status);
}
```

### Proper Circuit Breaker Implementation
```java
@Component
@Slf4j
public class ExternalServiceClient {
    
    private final RestTemplate restTemplate;
    
    public ExternalServiceClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }
    
    @CircuitBreaker(name = "external-service", fallbackMethod = "fallbackMethod")
    @TimeLimiter(name = "external-service")
    @Retry(name = "external-service")
    public CompletableFuture<String> callExternalService(String request) {
        log.debug("Calling external service with request: {}", request);
        
        return CompletableFuture.supplyAsync(() -> {
            try {
                ResponseEntity<String> response = restTemplate.postForEntity(
                    "/external/api", request, String.class);
                return response.getBody();
            } catch (Exception e) {
                log.error("External service call failed: {}", e.getMessage());
                throw new ExternalServiceException("Service call failed", e);
            }
        });
    }
    
    public CompletableFuture<String> fallbackMethod(String request, Exception ex) {
        log.warn("Using fallback method for request: {}, error: {}", request, ex.getMessage());
        return CompletableFuture.completedFuture("Default response");
    }
}
```

### Proper Batch Processing
```java
@Service
@Slf4j
public class BatchProcessingService {
    
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    
    public BatchProcessingService(UserRepository userRepository, 
                                NotificationService notificationService) {
        this.userRepository = userRepository;
        this.notificationService = notificationService;
    }
    
    @Transactional
    public void processUsersInBatches(List<Long> userIds) {
        int batchSize = 100;
        
        for (int i = 0; i < userIds.size(); i += batchSize) {
            int endIndex = Math.min(i + batchSize, userIds.size());
            List<Long> batchIds = userIds.subList(i, endIndex);
            
            processBatch(batchIds);
            
            // Clear entity manager to prevent memory issues
            if (i % (batchSize * 10) == 0) {
                log.debug("Clearing entity manager at batch: {}", i / batchSize);
                // EntityManager.clear() if needed
            }
        }
    }
    
    private void processBatch(List<Long> batchIds) {
        List<User> users = userRepository.findAllById(batchIds);
        
        for (User user : users) {
            // Process each user
            processUser(user);
        }
        
        // Send notifications asynchronously
        notificationService.sendBatchNotifications(users);
    }
    
    private void processUser(User user) {
        // User processing logic
        log.debug("Processing user: {}", user.getId());
    }
}
```

## Validation Checklist

**MUST** verify:
- [ ] Database connection pooling is properly configured
- [ ] Appropriate caching strategies are implemented
- [ ] Async processing is used for time-consuming operations
- [ ] Database queries are optimized and indexed
- [ ] Pagination is implemented for large result sets
- [ ] Circuit breaker patterns are used for external services
- [ ] Proper timeout configurations are set

**SHOULD** check:
- [ ] Memory usage patterns are monitored
- [ ] Lazy loading is used appropriately for JPA relationships
- [ ] Batch processing is implemented for bulk operations
- [ ] HTTP response compression is enabled
- [ ] Proper logging levels are configured
- [ ] Performance metrics are collected and monitored

## References

- [Spring Boot Performance Tuning](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.metrics)
- [HikariCP Configuration](https://github.com/brettwooldridge/HikariCP#configuration-knobs-baby)
- [Spring Cache Abstraction](https://docs.spring.io/spring-framework/docs/current/reference/html/integration.html#cache)
- [Spring Async](https://docs.spring.io/spring-framework/docs/current/reference/html/integration.html#scheduling-async)
- [Resilience4j Documentation](https://resilience4j.readme.io/docs/getting-started)
- [JPA Performance Best Practices](https://vladmihalcea.com/tutorials/hibernate/)
