---
applyTo: '**'
---

# Spring Data & Database Design Guide

This document provides comprehensive guidelines for data layer design, database management, and Spring Data implementation following industry best practices.

## Database Design Principles

### Entity Design
**FOLLOW** these entity design patterns:

```java
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email", unique = true),
    @Index(name = "idx_user_username", columnList = "username", unique = true),
    @Index(name = "idx_user_created_at", columnList = "created_at")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long id;
    
    @Column(name = "username", nullable = false, unique = true, length = 50)
    @Size(min = 3, max = 50)
    @Pattern(regexp = "^[a-zA-Z0-9_]+$")
    private String username;
    
    @Column(name = "email", nullable = false, unique = true, length = 255)
    @Email
    private String email;
    
    @Column(name = "password_hash", nullable = false)
    private String password;
    
    @Column(name = "first_name", nullable = false, length = 100)
    @Size(max = 100)
    private String firstName;
    
    @Column(name = "last_name", nullable = false, length = 100)
    @Size(max = 100)
    private String lastName;
    
    @Column(name = "enabled", nullable = false)
    @Builder.Default
    private Boolean enabled = true;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at", nullable = false)
    @UpdateTimestamp
    private LocalDateTime updatedAt;
    
    @Version
    @Column(name = "version")
    private Long version;
    
    // Relationship mappings
    @ManyToMany(fetch = FetchType.LAZY, cascade = {CascadeType.PERSIST, CascadeType.MERGE})
    @JoinTable(
        name = "user_roles",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    @Builder.Default
    private Set<Role> roles = new HashSet<>();
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Address> addresses = new ArrayList<>();
    
    // Audit fields
    @CreatedBy
    @Column(name = "created_by", updatable = false)
    private String createdBy;
    
    @LastModifiedBy
    @Column(name = "updated_by")
    private String updatedBy;
    
    // Helper methods for relationship management
    public void addRole(Role role) {
        roles.add(role);
        role.getUsers().add(this);
    }
    
    public void removeRole(Role role) {
        roles.remove(role);
        role.getUsers().remove(this);
    }
    
    public void addAddress(Address address) {
        addresses.add(address);
        address.setUser(this);
    }
    
    public void removeAddress(Address address) {
        addresses.remove(address);
        address.setUser(null);
    }
}

@Entity
@Table(name = "roles")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Role {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long id;
    
    @Column(name = "name", nullable = false, unique = true, length = 50)
    @Enumerated(EnumType.STRING)
    private RoleName name;
    
    @Column(name = "description", length = 255)
    private String description;
    
    @ManyToMany(mappedBy = "roles", fetch = FetchType.LAZY)
    @Builder.Default
    private Set<User> users = new HashSet<>();
    
    public enum RoleName {
        USER, ADMIN, MODERATOR
    }
}
```

### Embedded Values
**USE** embedded values for complex value objects:

```java
@Embeddable
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Address {
    
    @Column(name = "street", nullable = false, length = 255)
    @Size(max = 255)
    private String street;
    
    @Column(name = "city", nullable = false, length = 100)
    @Size(max = 100)
    private String city;
    
    @Column(name = "state", nullable = false, length = 100)
    @Size(max = 100)
    private String state;
    
    @Column(name = "postal_code", nullable = false, length = 20)
    @Size(max = 20)
    private String postalCode;
    
    @Column(name = "country", nullable = false, length = 100)
    @Size(max = 100)
    private String country;
}

@Entity
@Table(name = "user_profiles")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfile {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "street", column = @Column(name = "home_street")),
        @AttributeOverride(name = "city", column = @Column(name = "home_city")),
        @AttributeOverride(name = "state", column = @Column(name = "home_state")),
        @AttributeOverride(name = "postalCode", column = @Column(name = "home_postal_code")),
        @AttributeOverride(name = "country", column = @Column(name = "home_country"))
    })
    private Address homeAddress;
    
    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "street", column = @Column(name = "work_street")),
        @AttributeOverride(name = "city", column = @Column(name = "work_city")),
        @AttributeOverride(name = "state", column = @Column(name = "work_state")),
        @AttributeOverride(name = "postalCode", column = @Column(name = "work_postal_code")),
        @AttributeOverride(name = "country", column = @Column(name = "work_country"))
    })
    private Address workAddress;
}
```

## Repository Layer Implementation

### Base Repository Interface
**CREATE** base repository with common functionality:

```java
@NoRepositoryBean
public interface BaseRepository<T, ID> extends JpaRepository<T, ID> {
    
    @Query("SELECT e FROM #{#entityName} e WHERE e.id IN :ids")
    List<T> findByIds(@Param("ids") Collection<ID> ids);
    
    @Modifying
    @Query("UPDATE #{#entityName} e SET e.enabled = false WHERE e.id = :id")
    int softDelete(@Param("id") ID id);
    
    @Query("SELECT COUNT(e) FROM #{#entityName} e WHERE e.enabled = true")
    long countActive();
}

public interface UserRepository extends BaseRepository<User, Long> {
    
    Optional<User> findByUsername(String username);
    
    Optional<User> findByEmail(String email);
    
    boolean existsByUsername(String username);
    
    boolean existsByEmail(String email);
    
    @Query("SELECT u FROM User u WHERE u.enabled = true")
    Page<User> findAllActive(Pageable pageable);
    
    @Query("SELECT u FROM User u WHERE " +
           "(LOWER(u.username) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(u.email) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(u.firstName) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(u.lastName) LIKE LOWER(CONCAT('%', :search, '%'))) " +
           "AND u.enabled = true")
    Page<User> findBySearchTermAndActive(@Param("search") String search, Pageable pageable);
    
    @Query("SELECT u FROM User u JOIN u.roles r WHERE r.name = :roleName AND u.enabled = true")
    List<User> findActiveUsersByRole(@Param("roleName") Role.RoleName roleName);
    
    @Query("SELECT u FROM User u WHERE u.createdAt BETWEEN :startDate AND :endDate")
    List<User> findUsersCreatedBetween(
        @Param("startDate") LocalDateTime startDate,
        @Param("endDate") LocalDateTime endDate);
    
    @Modifying
    @Query("UPDATE User u SET u.enabled = false WHERE u.id = :id")
    int deactivateUser(@Param("id") Long id);
    
    @EntityGraph(attributePaths = {"roles", "addresses"})
    Optional<User> findWithRolesAndAddressesById(Long id);
}
```

### Custom Repository Implementation
**IMPLEMENT** custom repository for complex queries:

```java
public interface UserRepositoryCustom {
    Page<User> findUsersWithCriteria(UserSearchCriteria criteria, Pageable pageable);
    List<UserStatistics> getUserStatisticsByRole();
}

@Repository
public class UserRepositoryImpl implements UserRepositoryCustom {
    
    @PersistenceContext
    private EntityManager entityManager;
    
    @Override
    public Page<User> findUsersWithCriteria(UserSearchCriteria criteria, Pageable pageable) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        
        // Count query
        CriteriaQuery<Long> countQuery = cb.createQuery(Long.class);
        Root<User> countRoot = countQuery.from(User.class);
        countQuery.select(cb.count(countRoot));
        
        List<Predicate> countPredicates = buildPredicates(cb, countRoot, criteria);
        if (!countPredicates.isEmpty()) {
            countQuery.where(countPredicates.toArray(new Predicate[0]));
        }
        
        Long total = entityManager.createQuery(countQuery).getSingleResult();
        
        // Main query
        CriteriaQuery<User> query = cb.createQuery(User.class);
        Root<User> root = query.from(User.class);
        query.select(root);
        
        List<Predicate> predicates = buildPredicates(cb, root, criteria);
        if (!predicates.isEmpty()) {
            query.where(predicates.toArray(new Predicate[0]));
        }
        
        // Add sorting
        if (pageable.getSort().isSorted()) {
            List<Order> orders = pageable.getSort().stream()
                .map(order -> order.isAscending() 
                    ? cb.asc(root.get(order.getProperty()))
                    : cb.desc(root.get(order.getProperty())))
                .collect(Collectors.toList());
            query.orderBy(orders);
        }
        
        TypedQuery<User> typedQuery = entityManager.createQuery(query)
            .setFirstResult((int) pageable.getOffset())
            .setMaxResults(pageable.getPageSize());
        
        List<User> users = typedQuery.getResultList();
        
        return new PageImpl<>(users, pageable, total);
    }
    
    private List<Predicate> buildPredicates(CriteriaBuilder cb, Root<User> root, UserSearchCriteria criteria) {
        List<Predicate> predicates = new ArrayList<>();
        
        if (StringUtils.hasText(criteria.getSearch())) {
            String searchPattern = "%" + criteria.getSearch().toLowerCase() + "%";
            Predicate searchPredicate = cb.or(
                cb.like(cb.lower(root.get("username")), searchPattern),
                cb.like(cb.lower(root.get("email")), searchPattern),
                cb.like(cb.lower(root.get("firstName")), searchPattern),
                cb.like(cb.lower(root.get("lastName")), searchPattern)
            );
            predicates.add(searchPredicate);
        }
        
        if (criteria.getEnabled() != null) {
            predicates.add(cb.equal(root.get("enabled"), criteria.getEnabled()));
        }
        
        if (criteria.getCreatedAfter() != null) {
            predicates.add(cb.greaterThanOrEqualTo(root.get("createdAt"), criteria.getCreatedAfter()));
        }
        
        if (criteria.getCreatedBefore() != null) {
            predicates.add(cb.lessThanOrEqualTo(root.get("createdAt"), criteria.getCreatedBefore()));
        }
        
        if (criteria.getRoles() != null && !criteria.getRoles().isEmpty()) {
            Join<User, Role> roleJoin = root.join("roles");
            predicates.add(roleJoin.get("name").in(criteria.getRoles()));
        }
        
        return predicates;
    }
    
    @Override
    public List<UserStatistics> getUserStatisticsByRole() {
        String jpql = """
            SELECT new com.example.dto.UserStatistics(
                r.name,
                COUNT(u),
                COUNT(CASE WHEN u.enabled = true THEN 1 END),
                COUNT(CASE WHEN u.enabled = false THEN 1 END)
            )
            FROM User u
            JOIN u.roles r
            GROUP BY r.name
            """;
        
        return entityManager.createQuery(jpql, UserStatistics.class)
            .getResultList();
    }
}

// Extend the main repository interface
public interface UserRepository extends BaseRepository<User, Long>, UserRepositoryCustom {
    // Standard repository methods
}
```

## Database Migration with Flyway

### Migration Scripts
**ORGANIZE** migrations properly:

```sql
-- V1.0.0__Create_initial_schema.sql
CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version BIGINT NOT NULL DEFAULT 0,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE TABLE user_roles (
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- Indexes for performance
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_user_username ON users(username);
CREATE INDEX idx_user_created_at ON users(created_at);
CREATE INDEX idx_user_enabled ON users(enabled);

-- Insert default roles
INSERT INTO roles (name, description) VALUES 
('USER', 'Standard user role'),
('ADMIN', 'Administrator role'),
('MODERATOR', 'Moderator role');
```

```sql
-- V1.0.1__Add_user_profiles.sql
CREATE TABLE user_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    home_street VARCHAR(255),
    home_city VARCHAR(100),
    home_state VARCHAR(100),
    home_postal_code VARCHAR(20),
    home_country VARCHAR(100),
    work_street VARCHAR(255),
    work_city VARCHAR(100),
    work_state VARCHAR(100),
    work_postal_code VARCHAR(20),
    work_country VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
```

### Migration Configuration
**CONFIGURE** Flyway properly:

```yaml
# application.yml
spring:
  flyway:
    enabled: true
    locations: classpath:db/migration
    baseline-on-migrate: true
    validate-on-migrate: true
    clean-disabled: true # Never allow clean in production
    schemas: public
    table: flyway_schema_history
```

```java
@Configuration
public class FlywayConfig {
    
    @Bean
    @Profile("!test")
    public FlywayMigrationStrategy flywayMigrationStrategy() {
        return flyway -> {
            // Validate migrations before running
            flyway.validate();
            // Run migrations
            flyway.migrate();
        };
    }
    
    @Bean
    @Profile("test")
    public FlywayMigrationStrategy testFlywayMigrationStrategy() {
        return flyway -> {
            // Clean database in test environment
            flyway.clean();
            flyway.migrate();
        };
    }
}
```

## Transaction Management

### Declarative Transaction Management
**USE** @Transactional appropriately:

```java
@Service
@Transactional(readOnly = true)
public class UserService {
    
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final ApplicationEventPublisher eventPublisher;
    
    // Read-only methods use class-level @Transactional(readOnly = true)
    public UserDTO getUser(Long id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));
        return userMapper.toDTO(user);
    }
    
    public PagedResponse<UserDTO> getUsers(int page, int size, String search) {
        Pageable pageable = PageRequest.of(page, size);
        Page<User> userPage;
        
        if (StringUtils.hasText(search)) {
            userPage = userRepository.findBySearchTermAndActive(search, pageable);
        } else {
            userPage = userRepository.findAllActive(pageable);
        }
        
        return createPagedResponse(userPage);
    }
    
    // Write operations override with readOnly = false
    @Transactional
    public UserDTO createUser(CreateUserRequest request) {
        // Validate business rules
        validateUserCreation(request);
        
        // Create user entity
        User user = User.builder()
            .username(request.getUsername())
            .email(request.getEmail())
            .password(passwordEncoder.encode(request.getPassword()))
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .enabled(true)
            .build();
        
        // Add default role
        Role defaultRole = roleRepository.findByName(Role.RoleName.USER)
            .orElseThrow(() -> new RuntimeException("Default role not found"));
        user.addRole(defaultRole);
        
        // Save user
        User savedUser = userRepository.save(user);
        
        // Publish domain event
        eventPublisher.publishEvent(new UserCreatedEvent(savedUser));
        
        return userMapper.toDTO(savedUser);
    }
    
    @Transactional
    public UserDTO updateUser(Long id, UpdateUserRequest request) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));
        
        // Update fields
        if (StringUtils.hasText(request.getEmail())) {
            validateEmailUniqueness(request.getEmail(), id);
            user.setEmail(request.getEmail());
        }
        
        if (StringUtils.hasText(request.getFirstName())) {
            user.setFirstName(request.getFirstName());
        }
        
        if (StringUtils.hasText(request.getLastName())) {
            user.setLastName(request.getLastName());
        }
        
        User savedUser = userRepository.save(user);
        
        // Publish domain event
        eventPublisher.publishEvent(new UserUpdatedEvent(savedUser));
        
        return userMapper.toDTO(savedUser);
    }
    
    @Transactional
    public void deleteUser(Long id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));
        
        // Soft delete
        user.setEnabled(false);
        userRepository.save(user);
        
        // Publish domain event
        eventPublisher.publishEvent(new UserDeletedEvent(user));
    }
    
    // Complex transaction with multiple operations
    @Transactional
    public UserDTO assignRolesToUser(Long userId, List<String> roleNames) {
        User user = userRepository.findWithRolesAndAddressesById(userId)
            .orElseThrow(() -> new UserNotFoundException("User not found with id: " + userId));
        
        // Clear existing roles
        user.getRoles().clear();
        
        // Add new roles
        for (String roleName : roleNames) {
            Role.RoleName roleEnum = Role.RoleName.valueOf(roleName.toUpperCase());
            Role role = roleRepository.findByName(roleEnum)
                .orElseThrow(() -> new RoleNotFoundException("Role not found: " + roleName));
            user.addRole(role);
        }
        
        User savedUser = userRepository.save(user);
        
        // Publish domain event
        eventPublisher.publishEvent(new UserRolesUpdatedEvent(savedUser, roleNames));
        
        return userMapper.toDTO(savedUser);
    }
    
    private void validateUserCreation(CreateUserRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new UserAlreadyExistsException("Username already exists: " + request.getUsername());
        }
        
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new UserAlreadyExistsException("Email already exists: " + request.getEmail());
        }
    }
    
    private void validateEmailUniqueness(String email, Long userId) {
        userRepository.findByEmail(email)
            .filter(user -> !user.getId().equals(userId))
            .ifPresent(user -> {
                throw new UserAlreadyExistsException("Email already exists: " + email);
            });
    }
}
```

### Programmatic Transaction Management
**USE** for complex transaction scenarios:

```java
@Service
public class BatchUserService {
    
    private final PlatformTransactionManager transactionManager;
    private final UserRepository userRepository;
    
    public BatchProcessResult processBatchUserCreation(List<CreateUserRequest> requests) {
        TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager);
        transactionTemplate.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
        
        List<UserDTO> successfulUsers = new ArrayList<>();
        List<BatchError> errors = new ArrayList<>();
        
        for (int i = 0; i < requests.size(); i++) {
            final int index = i;
            final CreateUserRequest request = requests.get(i);
            
            try {
                UserDTO user = transactionTemplate.execute(status -> {
                    try {
                        return createUser(request);
                    } catch (Exception e) {
                        status.setRollbackOnly();
                        throw e;
                    }
                });
                
                successfulUsers.add(user);
                
            } catch (Exception e) {
                errors.add(BatchError.builder()
                    .index(index)
                    .request(request)
                    .error(e.getMessage())
                    .build());
            }
        }
        
        return BatchProcessResult.builder()
            .successfulUsers(successfulUsers)
            .errors(errors)
            .totalProcessed(requests.size())
            .successCount(successfulUsers.size())
            .errorCount(errors.size())
            .build();
    }
}
```

## Performance Optimization

### Query Optimization
**OPTIMIZE** queries with proper techniques:

```java
@Repository
public class OptimizedUserRepository {
    
    @PersistenceContext
    private EntityManager entityManager;
    
    // Use projections for read-only queries
    @Query("SELECT new com.example.dto.UserSummaryDTO(u.id, u.username, u.email, " +
           "CONCAT(u.firstName, ' ', u.lastName), u.enabled) " +
           "FROM User u WHERE u.enabled = true")
    List<UserSummaryDTO> findAllUserSummaries();
    
    // Use fetch joins to avoid N+1 problems
    @Query("SELECT DISTINCT u FROM User u " +
           "LEFT JOIN FETCH u.roles r " +
           "LEFT JOIN FETCH u.addresses a " +
           "WHERE u.id IN :ids")
    List<User> findUsersWithRolesAndAddresses(@Param("ids") List<Long> ids);
    
    // Use batch fetching for collection loading
    @BatchSize(size = 25)
    @Query("SELECT u FROM User u WHERE u.enabled = true")
    List<User> findAllActiveUsersWithBatchFetching();
    
    // Use native queries for complex operations
    @Query(value = """
        SELECT u.*, 
               COUNT(ur.role_id) as role_count,
               STRING_AGG(r.name, ',') as role_names
        FROM users u
        LEFT JOIN user_roles ur ON u.id = ur.user_id
        LEFT JOIN roles r ON ur.role_id = r.id
        WHERE u.enabled = true
        GROUP BY u.id
        ORDER BY u.created_at DESC
        LIMIT :limit OFFSET :offset
        """, nativeQuery = true)
    List<Object[]> findUsersWithRoleStatsNative(@Param("limit") int limit, @Param("offset") int offset);
    
    // Use criteria API for dynamic queries with optimization
    public List<User> findUsersOptimized(UserSearchCriteria criteria) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<User> query = cb.createQuery(User.class);
        Root<User> root = query.from(User.class);
        
        // Fetch joins to prevent N+1
        if (criteria.isIncludeRoles()) {
            root.fetch("roles", JoinType.LEFT);
        }
        
        if (criteria.isIncludeAddresses()) {
            root.fetch("addresses", JoinType.LEFT);
        }
        
        // Add predicates
        List<Predicate> predicates = buildPredicates(cb, root, criteria);
        if (!predicates.isEmpty()) {
            query.where(predicates.toArray(new Predicate[0]));
        }
        
        // Distinct to handle fetch joins
        query.distinct(true);
        
        return entityManager.createQuery(query)
            .setHint(QueryHints.HINT_PASS_DISTINCT_THROUGH, false)
            .getResultList();
    }
}
```

### Caching Strategy
**IMPLEMENT** appropriate caching:

```java
@Service
@CacheConfig(cacheNames = "users")
public class CachedUserService {
    
    @Cacheable(key = "#id")
    public UserDTO getUser(Long id) {
        // Implementation
    }
    
    @Cacheable(key = "#username")
    public UserDTO getUserByUsername(String username) {
        // Implementation
    }
    
    @CacheEvict(key = "#result.id")
    public UserDTO updateUser(Long id, UpdateUserRequest request) {
        // Implementation
    }
    
    @CacheEvict(key = "#id")
    public void deleteUser(Long id) {
        // Implementation
    }
    
    @Caching(evict = {
        @CacheEvict(key = "#result.id"),
        @CacheEvict(key = "#result.username")
    })
    public UserDTO createUser(CreateUserRequest request) {
        // Implementation
    }
    
    @CacheEvict(allEntries = true)
    public void clearUserCache() {
        // Clear all user cache entries
    }
}

@Configuration
@EnableCaching
public class CacheConfig {
    
    @Bean
    public CacheManager cacheManager() {
        RedisCacheManager.Builder builder = RedisCacheManager
            .RedisCacheManagerBuilder
            .fromConnectionFactory(redisConnectionFactory())
            .cacheDefaults(cacheConfiguration());
        
        return builder.build();
    }
    
    private RedisCacheConfiguration cacheConfiguration() {
        return RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(10))
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer()));
    }
}
```

## Database Connection Management

### Connection Pool Configuration
**CONFIGURE** HikariCP optimally:

```yaml
# application.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/springboilerplate
    username: ${DB_USERNAME:app_user}
    password: ${DB_PASSWORD:app_password}
    driver-class-name: org.postgresql.Driver
    
    # HikariCP configuration
    hikari:
      pool-name: SpringBootHikariCP
      maximum-pool-size: 20
      minimum-idle: 5
      idle-timeout: 300000
      max-lifetime: 600000
      connection-timeout: 20000
      validation-timeout: 5000
      leak-detection-threshold: 60000
      connection-test-query: SELECT 1
      
  jpa:
    hibernate:
      ddl-auto: validate
      naming:
        physical-strategy: org.hibernate.boot.model.naming.SnakeCasePhysicalNamingStrategy
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
        use_sql_comments: true
        batch_size: 25
        fetch_size: 150
        order_inserts: true
        order_updates: true
        batch_versioned_data: true
        connection:
          provider_disables_autocommit: true
        query:
          in_clause_parameter_padding: true
        jdbc:
          time_zone: UTC
    show-sql: false
```

### Multiple DataSource Configuration
**CONFIGURE** for microservices or complex applications:

```java
@Configuration
public class DatabaseConfig {
    
    // Primary datasource configuration
    @Bean
    @Primary
    @ConfigurationProperties("spring.datasource.primary")
    public DataSourceProperties primaryDataSourceProperties() {
        return new DataSourceProperties();
    }
    
    @Bean
    @Primary
    public DataSource primaryDataSource() {
        return primaryDataSourceProperties()
            .initializeDataSourceBuilder()
            .build();
    }
    
    @Bean
    @Primary
    public LocalContainerEntityManagerFactoryBean primaryEntityManagerFactory(
            EntityManagerFactoryBuilder builder) {
        return builder
            .dataSource(primaryDataSource())
            .packages("com.example.domain.primary")
            .persistenceUnit("primary")
            .build();
    }
    
    @Bean
    @Primary
    public PlatformTransactionManager primaryTransactionManager(
            @Qualifier("primaryEntityManagerFactory") EntityManagerFactory entityManagerFactory) {
        return new JpaTransactionManager(entityManagerFactory);
    }
    
    // Secondary datasource configuration
    @Bean
    @ConfigurationProperties("spring.datasource.secondary")
    public DataSourceProperties secondaryDataSourceProperties() {
        return new DataSourceProperties();
    }
    
    @Bean
    public DataSource secondaryDataSource() {
        return secondaryDataSourceProperties()
            .initializeDataSourceBuilder()
            .build();
    }
    
    @Bean
    public LocalContainerEntityManagerFactoryBean secondaryEntityManagerFactory(
            EntityManagerFactoryBuilder builder) {
        return builder
            .dataSource(secondaryDataSource())
            .packages("com.example.domain.secondary")
            .persistenceUnit("secondary")
            .build();
    }
    
    @Bean
    public PlatformTransactionManager secondaryTransactionManager(
            @Qualifier("secondaryEntityManagerFactory") EntityManagerFactory entityManagerFactory) {
        return new JpaTransactionManager(entityManagerFactory);
    }
}
```

## Data Access Anti-Patterns

**DON'T**:
- Use `findAll()` without pagination
- Load unnecessary associations (N+1 problems)
- Use `@Transactional` on read-only operations without `readOnly = true`
- Ignore database indexes and query performance
- Use entity objects as DTOs in API responses
- Implement business logic in repositories
- Use `CascadeType.ALL` without understanding implications
- Ignore optimistic locking for concurrent updates
- Use native queries when JPQL would suffice
- Store large objects (BLOBs) in the database without consideration

**DO**:
- Always use pagination for list operations
- Use appropriate fetch strategies and entity graphs
- Use `@Transactional(readOnly = true)` for read operations
- Monitor and optimize query performance
- Create separate DTOs for data transfer
- Keep repositories focused on data access only
- Use appropriate cascade types for each relationship
- Implement proper versioning for entities
- Prefer JPQL over native queries when possible
- Consider external storage for large files
