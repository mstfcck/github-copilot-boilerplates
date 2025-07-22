---
applyTo: '**'
---

# Spring Coding Standards Instructions

This document provides comprehensive coding standards and best practices for Spring Boot application development to ensure consistency, maintainability, and high code quality.

## Requirements

### Critical Requirements (**MUST** Follow)
- **MUST** follow Oracle Java Code Conventions and Spring Boot coding standards
- **REQUIRED** to use consistent naming conventions throughout the application
- **SHALL** implement proper package structure by feature/domain
- **NEVER** use field injection (@Autowired on fields)
- **MUST** use constructor injection for all dependencies
- **REQUIRED** to validate all input parameters using Bean Validation
- **SHALL** implement proper exception handling with custom exception classes

### Strong Recommendations (**SHOULD** Implement)
- **SHOULD** use lombok annotations to reduce boilerplate code
- **RECOMMENDED** to follow SOLID principles in all implementations
- **ALWAYS** use meaningful names for variables, methods, and classes
- **DO** implement proper logging with appropriate log levels
- **ALWAYS** write comprehensive JavaDoc for public methods and classes
- **DO** use Spring Boot's auto-configuration where possible
- **DON'T** create utility classes with public constructors

### Optional Enhancements (**MAY** Consider)
- **MAY** use record classes for immutable data transfer objects
- **OPTIONAL** to implement custom validation annotations for complex rules
- **USE** Spring Boot DevTools for development productivity
- **IMPLEMENT** custom health indicators for monitoring
- **AVOID** premature optimization without performance measurements

## Implementation Guidance

**USE** these naming conventions:
- Classes: PascalCase (e.g., `UserService`, `OrderController`)
- Methods: camelCase (e.g., `getUserById`, `processOrder`)
- Variables: camelCase (e.g., `userId`, `orderTotal`)
- Constants: UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)
- Packages: lowercase with dots (e.g., `com.example.user.service`)

**IMPLEMENT** these package structures:

- [Project Structure](project-structure.instructions.md)

**ENSURE** proper dependency injection:
```java
@Service
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
    
    // Constructor injection - REQUIRED
    public UserService(UserRepository userRepository, EmailService emailService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
    }
}
```

## Anti-Patterns

**DON'T** use field injection:
```java
// BAD - Field injection
@Service
public class UserService {
    @Autowired
    private UserRepository userRepository; // NEVER do this
}
```

**AVOID** God classes and methods:
```java
// BAD - God class with too many responsibilities
public class UserController {
    // 50+ methods handling everything
}
```

**NEVER** expose internal implementation details:
```java
// BAD - Exposing JPA entity directly
@GetMapping("/users/{id}")
public User getUser(@PathVariable Long id) {
    return userRepository.findById(id); // NEVER return entities
}
```

## Code Examples

### Proper Controller Implementation
```java
@RestController
@RequestMapping("/api/v1/users")
@Validated
@Slf4j
public class UserController {
    
    private final UserService userService;
    
    public UserController(UserService userService) {
        this.userService = userService;
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<UserDto> getUser(@PathVariable @Valid @Min(1) Long id) {
        log.debug("Fetching user with id: {}", id);
        UserDto user = userService.findById(id);
        return ResponseEntity.ok(user);
    }
    
    @PostMapping
    public ResponseEntity<UserDto> createUser(@Valid @RequestBody CreateUserRequest request) {
        log.info("Creating new user with email: {}", request.getEmail());
        UserDto createdUser = userService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdUser);
    }
}
```

### Proper Service Implementation
```java
@Service
@Transactional
@Slf4j
public class UserService {
    
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    
    public UserService(UserRepository userRepository, UserMapper userMapper) {
        this.userRepository = userRepository;
        this.userMapper = userMapper;
    }
    
    @Transactional(readOnly = true)
    public UserDto findById(Long id) {
        log.debug("Finding user by id: {}", id);
        User user = userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));
        return userMapper.toDto(user);
    }
    
    public UserDto create(CreateUserRequest request) {
        log.info("Creating user with email: {}", request.getEmail());
        
        // Validate business rules
        validateUniqueEmail(request.getEmail());
        
        User user = userMapper.toEntity(request);
        User savedUser = userRepository.save(user);
        
        log.info("User created successfully with id: {}", savedUser.getId());
        return userMapper.toDto(savedUser);
    }
    
    private void validateUniqueEmail(String email) {
        if (userRepository.existsByEmail(email)) {
            throw new EmailAlreadyExistsException("Email already exists: " + email);
        }
    }
}
```

### Proper Entity Implementation
```java
@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, unique = true)
    private String email;
    
    @Column(nullable = false)
    private String firstName;
    
    @Column(nullable = false)
    private String lastName;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserStatus status;
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
    
    // Custom methods
    public String getFullName() {
        return firstName + " " + lastName;
    }
}
```

### Proper DTO Implementation
```java
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDto {
    private Long id;
    private String email;
    private String firstName;
    private String lastName;
    private UserStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Computed properties
    public String getFullName() {
        return firstName + " " + lastName;
    }
}

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateUserRequest {
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;
    
    @NotBlank(message = "First name is required")
    @Size(min = 2, max = 50, message = "First name must be between 2 and 50 characters")
    private String firstName;
    
    @NotBlank(message = "Last name is required")
    @Size(min = 2, max = 50, message = "Last name must be between 2 and 50 characters")
    private String lastName;
}
```

## Validation Checklist

**MUST** verify:
- [ ] All dependencies use constructor injection
- [ ] Input validation is implemented using Bean Validation
- [ ] Custom exceptions are defined and used appropriately
- [ ] Proper logging is implemented at appropriate levels
- [ ] Transaction boundaries are correctly defined
- [ ] DTOs are used for data transfer (never expose entities)

**SHOULD** check:
- [ ] Meaningful names are used for all classes, methods, and variables
- [ ] JavaDoc is provided for public methods and classes
- [ ] Lombok annotations are used to reduce boilerplate
- [ ] Package structure follows domain-driven design
- [ ] Code follows SOLID principles
- [ ] Unit tests are written for all business logic

## References

- [Spring Boot Reference Documentation](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)
- [Spring Framework Documentation](https://docs.spring.io/spring-framework/docs/current/reference/html/)
- [Oracle Java Code Conventions](https://www.oracle.com/java/technologies/javase/codeconventions-contents.html)
- [Clean Code by Robert C. Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
- [Spring Boot Best Practices](https://www.baeldung.com/spring-boot-best-practices)
