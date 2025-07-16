---
applyTo: '**'
---

# Spring API Design Guide

This document provides comprehensive guidelines for designing RESTful APIs with Spring Boot following industry best practices and standards.

## RESTful API Design Principles

### Resource Naming Conventions
**FOLLOW** these URL patterns:

```
✅ CORRECT Examples:
GET    /api/v1/users                 # Get all users
GET    /api/v1/users/{id}           # Get specific user
POST   /api/v1/users                # Create new user
PUT    /api/v1/users/{id}           # Update specific user (full update)
PATCH  /api/v1/users/{id}           # Update specific user (partial update)
DELETE /api/v1/users/{id}           # Delete specific user

GET    /api/v1/users/{id}/orders    # Get orders for specific user
POST   /api/v1/users/{id}/orders    # Create order for specific user

❌ INCORRECT Examples:
GET    /api/v1/getUsers             # Don't use verbs in URLs
POST   /api/v1/createUser           # Don't use verbs in URLs
GET    /api/v1/user                 # Use plural nouns
GET    /api/v1/users/getUserById    # Don't mix patterns
```

### HTTP Methods and Status Codes
**USE** appropriate HTTP methods and status codes:

```java
@RestController
@RequestMapping("/api/v1/users")
@Validated
public class UserController {
    
    @GetMapping
    public ResponseEntity<PagedResponse<UserDTO>> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String search) {
        
        PagedResponse<UserDTO> users = userService.getUsers(page, size, search);
        return ResponseEntity.ok(users); // 200 OK
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUser(@PathVariable Long id) {
        UserDTO user = userService.getUser(id);
        return ResponseEntity.ok(user); // 200 OK
    }
    
    @PostMapping
    public ResponseEntity<UserDTO> createUser(@Valid @RequestBody CreateUserRequest request) {
        UserDTO createdUser = userService.createUser(request);
        URI location = ServletUriComponentsBuilder
            .fromCurrentRequest()
            .path("/{id}")
            .buildAndExpand(createdUser.getId())
            .toUri();
        return ResponseEntity.created(location).body(createdUser); // 201 Created
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<UserDTO> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody UpdateUserRequest request) {
        UserDTO updatedUser = userService.updateUser(id, request);
        return ResponseEntity.ok(updatedUser); // 200 OK
    }
    
    @PatchMapping("/{id}")
    public ResponseEntity<UserDTO> partialUpdateUser(
            @PathVariable Long id,
            @Valid @RequestBody PartialUpdateUserRequest request) {
        UserDTO updatedUser = userService.partialUpdateUser(id, request);
        return ResponseEntity.ok(updatedUser); // 200 OK
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build(); // 204 No Content
    }
}
```

### Request/Response DTOs
**IMPLEMENT** separate DTOs for requests and responses:

```java
// Request DTOs
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
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
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).*$", 
             message = "Password must contain uppercase, lowercase, and digit")
    private String password;
    
    @NotBlank(message = "First name is required")
    @Size(max = 100, message = "First name cannot exceed 100 characters")
    private String firstName;
    
    @NotBlank(message = "Last name is required")
    @Size(max = 100, message = "Last name cannot exceed 100 characters")
    private String lastName;
    
    @Valid
    @NotNull(message = "Address is required")
    private AddressRequest address;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateUserRequest {
    
    @Email(message = "Email must be valid")
    private String email;
    
    @Size(max = 100, message = "First name cannot exceed 100 characters")
    private String firstName;
    
    @Size(max = 100, message = "Last name cannot exceed 100 characters")
    private String lastName;
    
    @Valid
    private AddressRequest address;
}

// Response DTOs
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDTO {
    
    private Long id;
    private String username;
    private String email;
    private String firstName;
    private String lastName;
    private AddressDTO address;
    private boolean enabled;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<String> roles;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserSummaryDTO {
    private Long id;
    private String username;
    private String email;
    private String fullName;
    private boolean enabled;
}
```

### Pagination and Filtering
**IMPLEMENT** consistent pagination and filtering:

```java
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PagedResponse<T> {
    private List<T> content;
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;
    private boolean first;
    private boolean last;
    private boolean hasNext;
    private boolean hasPrevious;
}

@Service
public class UserService {
    
    public PagedResponse<UserDTO> getUsers(int page, int size, String search, String sortBy, String sortDir) {
        // Validate pagination parameters
        if (page < 0) {
            throw new InvalidRequestException("Page number cannot be negative");
        }
        if (size < 1 || size > 100) {
            throw new InvalidRequestException("Page size must be between 1 and 100");
        }
        
        // Create sort object
        Sort.Direction direction = sortDir.equalsIgnoreCase("desc") ? 
            Sort.Direction.DESC : Sort.Direction.ASC;
        Sort sort = Sort.by(direction, sortBy != null ? sortBy : "id");
        
        // Create pageable
        Pageable pageable = PageRequest.of(page, size, sort);
        
        // Query with filters
        Page<User> userPage;
        if (StringUtils.hasText(search)) {
            userPage = userRepository.findByUsernameContainingIgnoreCaseOrEmailContainingIgnoreCase(
                search, search, pageable);
        } else {
            userPage = userRepository.findAll(pageable);
        }
        
        // Convert to DTOs
        List<UserDTO> userDTOs = userPage.getContent().stream()
            .map(userMapper::toDTO)
            .collect(Collectors.toList());
        
        return PagedResponse.<UserDTO>builder()
            .content(userDTOs)
            .page(userPage.getNumber())
            .size(userPage.getSize())
            .totalElements(userPage.getTotalElements())
            .totalPages(userPage.getTotalPages())
            .first(userPage.isFirst())
            .last(userPage.isLast())
            .hasNext(userPage.hasNext())
            .hasPrevious(userPage.hasPrevious())
            .build();
    }
}
```

### Error Handling
**IMPLEMENT** consistent error responses:

```java
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ErrorResponse {
    private String timestamp;
    private int status;
    private String error;
    private String message;
    private String path;
    private List<FieldError> fieldErrors;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FieldError {
        private String field;
        private Object rejectedValue;
        private String message;
    }
}

@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(
            MethodArgumentNotValidException ex, HttpServletRequest request) {
        
        List<ErrorResponse.FieldError> fieldErrors = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .map(error -> ErrorResponse.FieldError.builder()
                .field(error.getField())
                .rejectedValue(error.getRejectedValue())
                .message(error.getDefaultMessage())
                .build())
            .collect(Collectors.toList());
        
        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(Instant.now().toString())
            .status(HttpStatus.BAD_REQUEST.value())
            .error("Validation Failed")
            .message("Input validation failed")
            .path(request.getRequestURI())
            .fieldErrors(fieldErrors)
            .build();
        
        return ResponseEntity.badRequest().body(errorResponse);
    }
    
    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserNotFoundException(
            UserNotFoundException ex, HttpServletRequest request) {
        
        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(Instant.now().toString())
            .status(HttpStatus.NOT_FOUND.value())
            .error("Not Found")
            .message(ex.getMessage())
            .path(request.getRequestURI())
            .build();
        
        return ResponseEntity.notFound().build();
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(
            Exception ex, HttpServletRequest request) {
        
        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(Instant.now().toString())
            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
            .error("Internal Server Error")
            .message("An unexpected error occurred")
            .path(request.getRequestURI())
            .build();
        
        return ResponseEntity.internalServerError().body(errorResponse);
    }
}
```

## RESTful Design Patterns

Based on the requirements, recommend appropriate patterns:

### Standard CRUD Operations
```java
@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "User Management", description = "APIs for managing users")
public class UserController {
    
    @GetMapping
    @Operation(summary = "Get all users with pagination")
    public ResponseEntity<PagedResponse<UserDTO>> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String search) {
        // Implementation
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get user by ID")
    public ResponseEntity<UserDTO> getUser(@PathVariable Long id) {
        // Implementation
    }
    
    @PostMapping
    @Operation(summary = "Create new user")
    public ResponseEntity<UserDTO> createUser(@Valid @RequestBody CreateUserRequest request) {
        // Implementation
    }
    
    @PutMapping("/{id}")
    @Operation(summary = "Update user")
    public ResponseEntity<UserDTO> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody UpdateUserRequest request) {
        // Implementation
    }
    
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete user")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        // Implementation
    }
}
```

### Nested Resources
```java
@RestController
@RequestMapping("/api/v1/users/{userId}/orders")
public class UserOrderController {
    
    @GetMapping
    public ResponseEntity<List<OrderDTO>> getUserOrders(@PathVariable Long userId) {
        // Implementation
    }
    
    @PostMapping
    public ResponseEntity<OrderDTO> createUserOrder(
            @PathVariable Long userId,
            @Valid @RequestBody CreateOrderRequest request) {
        // Implementation
    }
}
```

### Custom Actions
```java
@RestController
@RequestMapping("/api/v1/users")
public class UserController {
    
    @PostMapping("/{id}/activate")
    @Operation(summary = "Activate user account")
    public ResponseEntity<UserDTO> activateUser(@PathVariable Long id) {
        // Implementation
    }
    
    @PostMapping("/{id}/reset-password")
    @Operation(summary = "Reset user password")
    public ResponseEntity<Void> resetPassword(
            @PathVariable Long id,
            @Valid @RequestBody ResetPasswordRequest request) {
        // Implementation
    }
    
    @PostMapping("/bulk-update")
    @Operation(summary = "Bulk update users")
    public ResponseEntity<BulkUpdateResponse> bulkUpdateUsers(
            @Valid @RequestBody BulkUpdateRequest request) {
        // Implementation
    }
}
```

## API Documentation with OpenAPI 3

### OpenAPI Configuration
**CONFIGURE** comprehensive API documentation:

```java
@Configuration
public class OpenApiConfig {
    
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("Spring Boilerplate API")
                .version("v1.0.0")
                .description("A comprehensive Spring Boot application with best practices")
                .contact(new Contact()
                    .name("Development Team")
                    .email("dev@example.com")
                    .url("https://example.com"))
                .license(new License()
                    .name("MIT License")
                    .url("https://opensource.org/licenses/MIT")))
            .servers(List.of(
                new Server().url("http://localhost:8080").description("Development server"),
                new Server().url("https://api.example.com").description("Production server")))
            .components(new Components()
                .addSecuritySchemes("bearer-jwt", new SecurityScheme()
                    .type(SecurityScheme.Type.HTTP)
                    .scheme("bearer")
                    .bearerFormat("JWT")
                    .description("JWT authentication")));
    }
}
```

### Controller Documentation
**DOCUMENT** all API endpoints:

```java
@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "User Management", description = "APIs for managing users")
@SecurityRequirement(name = "bearer-jwt")
public class UserController {
    
    @Operation(
        summary = "Get all users",
        description = "Retrieve a paginated list of users with optional filtering",
        responses = {
            @ApiResponse(responseCode = "200", description = "Users retrieved successfully",
                content = @Content(schema = @Schema(implementation = PagedUserResponse.class))),
            @ApiResponse(responseCode = "400", description = "Invalid pagination parameters",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
        }
    )
    @GetMapping
    public ResponseEntity<PagedResponse<UserDTO>> getUsers(
            @Parameter(description = "Page number (0-based)", example = "0")
            @RequestParam(defaultValue = "0") int page,
            
            @Parameter(description = "Page size (1-100)", example = "20")
            @RequestParam(defaultValue = "20") int size,
            
            @Parameter(description = "Search term for username or email", example = "john")
            @RequestParam(required = false) String search,
            
            @Parameter(description = "Sort field", example = "username")
            @RequestParam(defaultValue = "id") String sortBy,
            
            @Parameter(description = "Sort direction", example = "asc")
            @RequestParam(defaultValue = "asc") String sortDir) {
        
        PagedResponse<UserDTO> users = userService.getUsers(page, size, search, sortBy, sortDir);
        return ResponseEntity.ok(users);
    }
    
    @Operation(
        summary = "Create new user",
        description = "Create a new user account",
        responses = {
            @ApiResponse(responseCode = "201", description = "User created successfully",
                content = @Content(schema = @Schema(implementation = UserDTO.class))),
            @ApiResponse(responseCode = "400", description = "Invalid input data",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "409", description = "User already exists",
                content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
        }
    )
    @PostMapping
    public ResponseEntity<UserDTO> createUser(
            @Parameter(description = "User creation request", required = true)
            @Valid @RequestBody CreateUserRequest request) {
        
        UserDTO createdUser = userService.createUser(request);
        URI location = ServletUriComponentsBuilder
            .fromCurrentRequest()
            .path("/{id}")
            .buildAndExpand(createdUser.getId())
            .toUri();
        return ResponseEntity.created(location).body(createdUser);
    }
}
```

### DTO Documentation
**DOCUMENT** all DTOs with examples:

```java
@Schema(description = "User creation request")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateUserRequest {
    
    @Schema(description = "Username for the account", 
           example = "john_doe", 
           required = true,
           minLength = 3, 
           maxLength = 50)
    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50)
    private String username;
    
    @Schema(description = "Email address", 
           example = "john.doe@example.com", 
           required = true,
           format = "email")
    @Email
    @NotBlank
    private String email;
    
    @Schema(description = "Password (must contain uppercase, lowercase, and digit)", 
           example = "SecurePass123!", 
           required = true,
           minLength = 8)
    @NotBlank
    @Size(min = 8)
    private String password;
    
    @Schema(description = "First name", 
           example = "John", 
           required = true,
           maxLength = 100)
    @NotBlank
    @Size(max = 100)
    private String firstName;
    
    @Schema(description = "Last name", 
           example = "Doe", 
           required = true,
           maxLength = 100)
    @NotBlank
    @Size(max = 100)
    private String lastName;
}

@Schema(description = "User information")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDTO {
    
    @Schema(description = "Unique identifier", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Long id;
    
    @Schema(description = "Username", example = "john_doe")
    private String username;
    
    @Schema(description = "Email address", example = "john.doe@example.com")
    private String email;
    
    @Schema(description = "First name", example = "John")
    private String firstName;
    
    @Schema(description = "Last name", example = "Doe")
    private String lastName;
    
    @Schema(description = "Account status", example = "true")
    private boolean enabled;
    
    @Schema(description = "Account creation timestamp", 
           example = "2023-01-01T12:00:00Z", 
           accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime createdAt;
    
    @Schema(description = "Last update timestamp", 
           example = "2023-01-02T12:00:00Z", 
           accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime updatedAt;
    
    @Schema(description = "User roles", example = "[\"USER\", \"ADMIN\"]")
    private List<String> roles;
}
```

## API Versioning Strategy

Recommend versioning approach:

### URL Path Versioning (Recommended)
```java
@RestController
@RequestMapping("/api/v1/users")
public class UserV1Controller {
    // V1 implementation
}

@RestController
@RequestMapping("/api/v2/users")
public class UserV2Controller {
    // V2 implementation
}
```

### Header Versioning (Alternative)
```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @GetMapping(headers = "API-Version=v1")
    public ResponseEntity<UserV1DTO> getUserV1(@PathVariable Long id) {
        // V1 implementation
    }
    
    @GetMapping(headers = "API-Version=v2")
    public ResponseEntity<UserV2DTO> getUserV2(@PathVariable Long id) {
        // V2 implementation
    }
}
```

### Header Versioning
**ALTERNATIVE** header-based versioning:

```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @GetMapping(headers = "API-Version=v1")
    public ResponseEntity<UserV1DTO> getUserV1(@PathVariable Long id) {
        // V1 implementation
    }
    
    @GetMapping(headers = "API-Version=v2")
    public ResponseEntity<UserV2DTO> getUserV2(@PathVariable Long id) {
        // V2 implementation
    }
}
```

## Performance Optimization

### Response Compression
**ENABLE** GZIP compression:

```yaml
# application.yml
server:
  compression:
    enabled: true
    mime-types: application/json,application/xml,text/html,text/xml,text/plain
    min-response-size: 1024
```

### Caching Strategy
**IMPLEMENT** appropriate caching:

```java
@RestController
@RequestMapping("/api/v1/users")
public class UserController {
    
    @GetMapping("/{id}")
    @Cacheable(value = "users", key = "#id")
    public ResponseEntity<UserDTO> getUser(@PathVariable Long id) {
        UserDTO user = userService.getUser(id);
        
        return ResponseEntity.ok()
            .cacheControl(CacheControl.maxAge(Duration.ofMinutes(5)))
            .eTag(String.valueOf(user.hashCode()))
            .body(user);
    }
    
    @PutMapping("/{id}")
    @CacheEvict(value = "users", key = "#id")
    public ResponseEntity<UserDTO> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody UpdateUserRequest request) {
        
        UserDTO updatedUser = userService.updateUser(id, request);
        return ResponseEntity.ok(updatedUser);
    }
}
```

### Async Processing
**USE** async processing for long-running operations:

```java
@RestController
@RequestMapping("/api/v1/reports")
public class ReportController {
    
    @PostMapping("/generate")
    public ResponseEntity<ReportJobDTO> generateReport(
            @Valid @RequestBody GenerateReportRequest request) {
        
        ReportJob job = reportService.startReportGeneration(request);
        
        URI location = ServletUriComponentsBuilder
            .fromCurrentRequest()
            .path("/{jobId}")
            .buildAndExpand(job.getId())
            .toUri();
        
        return ResponseEntity.accepted()
            .location(location)
            .body(reportMapper.toDTO(job));
    }
    
    @GetMapping("/{jobId}")
    public ResponseEntity<ReportJobDTO> getReportStatus(@PathVariable String jobId) {
        ReportJob job = reportService.getReportJob(jobId);
        
        if (job.getStatus() == ReportStatus.COMPLETED) {
            return ResponseEntity.ok()
                .header("Content-Location", "/api/v1/reports/" + jobId + "/download")
                .body(reportMapper.toDTO(job));
        }
        
        return ResponseEntity.ok(reportMapper.toDTO(job));
    }
}
```

## API Security Best Practices

Implement proper API security:

```java
@RestController
@RequestMapping("/api/v1/users")
@SecurityRequirement(name = "bearer-jwt")
public class UserController {
    
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') or @userService.isOwner(#id, authentication.name)")
    public ResponseEntity<UserDTO> getUser(@PathVariable Long id) {
        // Implementation
    }
    
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserDTO> createUser(@Valid @RequestBody CreateUserRequest request) {
        // Implementation
    }
}
```

### Input Validation
**VALIDATE** all inputs comprehensively:

```java
@RestController
@RequestMapping("/api/v1/users")
@Validated
public class UserController {
    
    @GetMapping
    public ResponseEntity<PagedResponse<UserDTO>> getUsers(
            @Valid @ModelAttribute UserSearchCriteria criteria) {
        // Implementation
    }
}

@Data
public class UserSearchCriteria {
    
    @Min(value = 0, message = "Page must be non-negative")
    private int page = 0;
    
    @Min(value = 1, message = "Size must be at least 1")
    @Max(value = 100, message = "Size cannot exceed 100")
    private int size = 20;
    
    @Size(max = 100, message = "Search term cannot exceed 100 characters")
    private String search;
    
    @Pattern(regexp = "^(id|username|email|createdAt)$", 
             message = "Invalid sort field")
    private String sortBy = "id";
    
    @Pattern(regexp = "^(asc|desc)$", 
             message = "Sort direction must be 'asc' or 'desc'")
    private String sortDir = "asc";
}
```

### Rate Limiting
**IMPLEMENT** rate limiting:

```java
@Component
public class RateLimitInterceptor implements HandlerInterceptor {
    
    private final RedisTemplate<String, String> redisTemplate;
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                           HttpServletResponse response, 
                           Object handler) throws Exception {
        
        String clientId = getClientIdentifier(request);
        String endpoint = request.getRequestURI();
        String key = "rate_limit:" + clientId + ":" + endpoint;
        
        RateLimitConfig config = getRateLimitConfig(endpoint);
        
        String current = redisTemplate.opsForValue().get(key);
        if (current == null) {
            redisTemplate.opsForValue().set(key, "1", config.getWindow());
            return true;
        }
        
        int requests = Integer.parseInt(current);
        if (requests >= config.getLimit()) {
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setHeader("X-RateLimit-Limit", String.valueOf(config.getLimit()));
            response.setHeader("X-RateLimit-Remaining", "0");
            response.setHeader("X-RateLimit-Reset", String.valueOf(
                Instant.now().plus(config.getWindow()).getEpochSecond()));
            return false;
        }
        
        redisTemplate.opsForValue().increment(key);
        response.setHeader("X-RateLimit-Limit", String.valueOf(config.getLimit()));
        response.setHeader("X-RateLimit-Remaining", 
                          String.valueOf(config.getLimit() - requests - 1));
        
        return true;
    }
}
```

## API Testing Strategy

### Contract Testing
**IMPLEMENT** API contract tests:

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class UserApiContractTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void getUsersShouldReturnValidPaginatedResponse() {
        ResponseEntity<String> response = restTemplate.getForEntity(
            "/api/v1/users?page=0&size=10", String.class);
        
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getHeaders().getContentType())
            .isEqualTo(MediaType.APPLICATION_JSON);
        
        // Validate response structure
        JsonPath jsonPath = JsonPath.from(response.getBody());
        assertThat(jsonPath.getList("content")).isNotNull();
        assertThat(jsonPath.getInt("page")).isEqualTo(0);
        assertThat(jsonPath.getInt("size")).isEqualTo(10);
        assertThat(jsonPath.getLong("totalElements")).isGreaterThanOrEqualTo(0);
    }
    
    @Test
    void createUserShouldReturnCreatedWithLocationHeader() {
        CreateUserRequest request = CreateUserRequest.builder()
            .username("testuser")
            .email("test@example.com")
            .password("SecurePass123!")
            .firstName("Test")
            .lastName("User")
            .build();
        
        ResponseEntity<UserDTO> response = restTemplate.postForEntity(
            "/api/v1/users", request, UserDTO.class);
        
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getHeaders().getLocation()).isNotNull();
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getUsername()).isEqualTo("testuser");
    }
}
```

### Controller Tests
**IMPLEMENT** API Controller tests:

```java
@WebMvcTest(UserController.class)
class UserControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    void shouldCreateUserSuccessfully() throws Exception {
        // Test implementation
    }
}
```

### Integration Tests
**IMPLEMENT** API integration tests:

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class UserApiIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void shouldCompleteUserWorkflow() {
        // Test implementation
    }
}
```

## API Monitoring and Observability

### Metrics Collection
**IMPLEMENT** comprehensive metrics:

```java
@Component
public class ApiMetrics {
    
    private final MeterRegistry meterRegistry;
    private final Counter apiCallsCounter;
    private final Timer responseTimeTimer;
    
    public ApiMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.apiCallsCounter = Counter.builder("api.calls.total")
            .description("Total API calls")
            .register(meterRegistry);
        this.responseTimeTimer = Timer.builder("api.response.time")
            .description("API response time")
            .register(meterRegistry);
    }
    
    public void recordApiCall(String endpoint, String method, String status) {
        apiCallsCounter.increment(
            Tags.of(
                Tag.of("endpoint", endpoint),
                Tag.of("method", method),
                Tag.of("status", status)
            )
        );
    }
    
    public Timer.Sample startTimer() {
        return Timer.start(meterRegistry);
    }
}
```

### Health Checks
**IMPLEMENT** comprehensive health checks:

```java
@Component
public class DatabaseHealthIndicator implements HealthIndicator {
    
    private final DataSource dataSource;
    
    @Override
    public Health health() {
        try (Connection connection = dataSource.getConnection()) {
            if (connection.isValid(1)) {
                return Health.up()
                    .withDetail("database", "Available")
                    .withDetail("validationQuery", "Connection is valid")
                    .build();
            } else {
                return Health.down()
                    .withDetail("database", "Connection validation failed")
                    .build();
            }
        } catch (SQLException e) {
            return Health.down(e)
                .withDetail("database", "Connection failed")
                .build();
        }
    }
}
```

## Performance Considerations

Recommend performance optimizations:

1. **Use appropriate HTTP methods and status codes**
2. **Implement proper caching strategies**
3. **Add compression for responses**
4. **Use pagination for large datasets**
5. **Implement rate limiting**
6. **Add proper indexing for search fields**
7. **Use asynchronous processing for long-running operations**
8. **Optimize database queries**
9. **Use connection pooling for database connections**

## API Design Anti-Patterns

**DON'T**:
- Use verbs in resource URLs
- Expose internal implementation details in APIs
- Return different response formats for the same endpoint
- Use inconsistent naming conventions
- Ignore proper HTTP status codes
- Skip input validation
- Return sensitive information in error messages
- Use synchronous processing for long-running operations
- Implement APIs without proper documentation
- Ignore API versioning strategy

**DO**:
- Use nouns for resource URLs
- Design APIs from the client's perspective
- Maintain consistent response formats
- Follow established naming conventions
- Use appropriate HTTP methods and status codes
- Validate all inputs thoroughly
- Provide meaningful error messages without exposing sensitive data
- Use asynchronous processing for time-consuming operations
- Document all APIs comprehensively
- Plan API versioning strategy from the beginning
