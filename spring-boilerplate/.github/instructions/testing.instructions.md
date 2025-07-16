---
applyTo: '**'
---

# Spring Testing Strategy Guide

This document provides comprehensive testing guidelines for Spring applications following industry best practices.

## Testing Pyramid Structure

### Unit Tests (70% of tests)
**PURPOSE**: Test individual components in isolation
**SCOPE**: Single class or method
**REQUIREMENTS**:
- Fast execution (< 10ms per test)
- No external dependencies
- High code coverage (minimum 80%)
- Use mocks for dependencies

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private PasswordEncoder passwordEncoder;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    @DisplayName("Should create user successfully with valid input")
    void shouldCreateUserSuccessfully() {
        // Given
        CreateUserRequest request = CreateUserRequest.builder()
            .username("testuser")
            .email("test@example.com")
            .password("SecurePass123!")
            .build();
        
        User savedUser = User.builder()
            .id(1L)
            .username("testuser")
            .email("test@example.com")
            .build();
        
        when(userRepository.existsByUsername("testuser")).thenReturn(false);
        when(userRepository.existsByEmail("test@example.com")).thenReturn(false);
        when(passwordEncoder.encode("SecurePass123!")).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        
        // When
        UserDTO result = userService.createUser(request);
        
        // Then
        assertThat(result).isNotNull();
        assertThat(result.getUsername()).isEqualTo("testuser");
        assertThat(result.getEmail()).isEqualTo("test@example.com");
        
        verify(userRepository).existsByUsername("testuser");
        verify(userRepository).existsByEmail("test@example.com");
        verify(userRepository).save(any(User.class));
    }
    
    @Test
    @DisplayName("Should throw exception when username already exists")
    void shouldThrowExceptionWhenUsernameExists() {
        // Given
        CreateUserRequest request = CreateUserRequest.builder()
            .username("existinguser")
            .email("test@example.com")
            .password("SecurePass123!")
            .build();
        
        when(userRepository.existsByUsername("existinguser")).thenReturn(true);
        
        // When & Then
        assertThatThrownBy(() -> userService.createUser(request))
            .isInstanceOf(UserAlreadyExistsException.class)
            .hasMessage("Username 'existinguser' already exists");
        
        verify(userRepository).existsByUsername("existinguser");
        verify(userRepository, never()).save(any(User.class));
    }
}
```

### Integration Tests (20% of tests)
**PURPOSE**: Test component interactions and configurations
**SCOPE**: Multiple components working together
**REQUIREMENTS**:
- Test real integrations (database, external services)
- Use test containers for external dependencies
- Test configuration and auto-configuration

```java
@SpringBootTest
@Testcontainers
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class UserRepositoryIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Test
    @Transactional
    @Rollback
    void shouldFindUserByEmail() {
        // Given
        User user = User.builder()
            .username("testuser")
            .email("test@example.com")
            .password("encodedPassword")
            .build();
        
        entityManager.persistAndFlush(user);
        
        // When
        Optional<User> found = userRepository.findByEmail("test@example.com");
        
        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getUsername()).isEqualTo("testuser");
    }
    
    @Test
    @Transactional
    @Rollback
    void shouldReturnEmptyWhenUserNotFound() {
        // When
        Optional<User> found = userRepository.findByEmail("nonexistent@example.com");
        
        // Then
        assertThat(found).isEmpty();
    }
}
```

### End-to-End Tests (10% of tests)
**PURPOSE**: Test complete user workflows
**SCOPE**: Full application stack
**REQUIREMENTS**:
- Test critical user journeys
- Use real external services or realistic mocks
- Test deployment configurations

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class UserManagementE2ETest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");
    
    @Container
    static GenericContainer<?> redis = new GenericContainer<>("redis:7-alpine")
            .withExposedPorts(6379);
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    void shouldCompleteUserRegistrationFlow() {
        // Given - User registration request
        CreateUserRequest registrationRequest = CreateUserRequest.builder()
            .username("newuser")
            .email("newuser@example.com")
            .password("SecurePass123!")
            .build();
        
        // When - Register user
        ResponseEntity<UserDTO> registrationResponse = restTemplate.postForEntity(
            "/api/v1/users", 
            registrationRequest, 
            UserDTO.class
        );
        
        // Then - Registration successful
        assertThat(registrationResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(registrationResponse.getBody()).isNotNull();
        assertThat(registrationResponse.getBody().getUsername()).isEqualTo("newuser");
        
        // And - User exists in database
        Optional<User> savedUser = userRepository.findByUsername("newuser");
        assertThat(savedUser).isPresent();
        
        // When - Login with created user
        LoginRequest loginRequest = LoginRequest.builder()
            .username("newuser")
            .password("SecurePass123!")
            .build();
        
        ResponseEntity<AuthResponse> loginResponse = restTemplate.postForEntity(
            "/api/v1/auth/login", 
            loginRequest, 
            AuthResponse.class
        );
        
        // Then - Login successful
        assertThat(loginResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(loginResponse.getBody()).isNotNull();
        assertThat(loginResponse.getBody().getAccessToken()).isNotBlank();
        
        // When - Access protected resource with token
        String token = loginResponse.getBody().getAccessToken();
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(token);
        HttpEntity<String> entity = new HttpEntity<>(headers);
        
        ResponseEntity<UserDTO> profileResponse = restTemplate.exchange(
            "/api/v1/users/profile", 
            HttpMethod.GET, 
            entity, 
            UserDTO.class
        );
        
        // Then - Protected resource accessible
        assertThat(profileResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(profileResponse.getBody()).isNotNull();
        assertThat(profileResponse.getBody().getUsername()).isEqualTo("newuser");
    }
}
```

## Test Configuration Best Practices

### Test Profiles
**USE** separate profiles for testing:
```yaml
# application-test.yml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
  logging:
    level:
      org.springframework.security: DEBUG
      com.yourcompany: DEBUG
```

### Test Data Management
**IMPLEMENT** proper test data setup:
```java
@TestConfiguration
public class TestDataConfig {
    
    @Bean
    @Primary
    public Clock testClock() {
        return Clock.fixed(Instant.parse("2023-01-01T00:00:00Z"), ZoneOffset.UTC);
    }
    
    @Component
    public static class TestDataBuilder {
        
        public User.UserBuilder defaultUser() {
            return User.builder()
                .username("testuser")
                .email("test@example.com")
                .password("encodedPassword")
                .createdAt(LocalDateTime.now())
                .enabled(true);
        }
        
        public CreateUserRequest.CreateUserRequestBuilder defaultCreateUserRequest() {
            return CreateUserRequest.builder()
                .username("testuser")
                .email("test@example.com")
                .password("SecurePass123!");
        }
    }
}
```

### Mock Configuration
**USE** proper mocking strategies:
```java
@TestConfiguration
public class MockConfig {
    
    @Bean
    @Primary
    @Profile("test")
    public EmailService mockEmailService() {
        return Mockito.mock(EmailService.class);
    }
    
    @Bean
    @Primary
    @Profile("test")
    public PaymentService mockPaymentService() {
        PaymentService mock = Mockito.mock(PaymentService.class);
        when(mock.processPayment(any())).thenReturn(PaymentResult.success());
        return mock;
    }
}
```

## Testing Specific Components

### Controller Tests
**FOCUS** on HTTP layer concerns:
```java
@WebMvcTest(UserController.class)
class UserControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    void shouldCreateUserSuccessfully() throws Exception {
        // Given
        CreateUserRequest request = CreateUserRequest.builder()
            .username("testuser")
            .email("test@example.com")
            .password("SecurePass123!")
            .build();
        
        UserDTO expectedUser = UserDTO.builder()
            .id(1L)
            .username("testuser")
            .email("test@example.com")
            .build();
        
        when(userService.createUser(any(CreateUserRequest.class))).thenReturn(expectedUser);
        
        // When & Then
        mockMvc.perform(post("/api/v1/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.username").value("testuser"))
                .andExpect(jsonPath("$.email").value("test@example.com"))
                .andExpect(header().exists("Location"));
        
        verify(userService).createUser(any(CreateUserRequest.class));
    }
    
    @Test
    void shouldReturnBadRequestForInvalidInput() throws Exception {
        // Given
        CreateUserRequest invalidRequest = CreateUserRequest.builder()
            .username("") // Invalid - empty username
            .email("invalid-email") // Invalid - not an email
            .password("123") // Invalid - too short
            .build();
        
        // When & Then
        mockMvc.perform(post("/api/v1/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors").isArray())
                .andExpected(jsonPath("$.errors", hasSize(greaterThan(0))));
        
        verify(userService, never()).createUser(any());
    }
}
```

### Repository Tests
**USE** @DataJpaTest for repository testing:
```java
@DataJpaTest
class UserRepositoryTest {
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    void shouldFindActiveUsersByRole() {
        // Given
        Role userRole = Role.builder().name("USER").build();
        entityManager.persistAndFlush(userRole);
        
        User activeUser = User.builder()
            .username("activeuser")
            .email("active@example.com")
            .enabled(true)
            .roles(Set.of(userRole))
            .build();
        
        User inactiveUser = User.builder()
            .username("inactiveuser")
            .email("inactive@example.com")
            .enabled(false)
            .roles(Set.of(userRole))
            .build();
        
        entityManager.persistAndFlush(activeUser);
        entityManager.persistAndFlush(inactiveUser);
        
        // When
        List<User> activeUsers = userRepository.findActiveUsersByRole("USER");
        
        // Then
        assertThat(activeUsers).hasSize(1);
        assertThat(activeUsers.get(0).getUsername()).isEqualTo("activeuser");
    }
}
```

### Security Tests
**TEST** authentication and authorization:
```java
@SpringBootTest
@AutoConfigureTestDatabase
class SecurityConfigurationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    void shouldAllowPublicAccessToHealthEndpoint() throws Exception {
        mockMvc.perform(get("/actuator/health"))
                .andExpect(status().isOk());
    }
    
    @Test
    void shouldRequireAuthenticationForProtectedEndpoints() throws Exception {
        mockMvc.perform(get("/api/v1/users/profile"))
                .andExpect(status().isUnauthorized());
    }
    
    @Test
    @WithMockUser(username = "testuser", roles = "USER")
    void shouldAllowAuthenticatedUserAccessToUserEndpoints() throws Exception {
        mockMvc.perform(get("/api/v1/users/profile"))
                .andExpect(status().isOk());
    }
    
    @Test
    @WithMockUser(username = "testuser", roles = "USER")
    void shouldDenyUserAccessToAdminEndpoints() throws Exception {
        mockMvc.perform(get("/api/v1/admin/users"))
                .andExpect(status().isForbidden());
    }
    
    @Test
    @WithMockUser(username = "admin", roles = "ADMIN")
    void shouldAllowAdminAccessToAdminEndpoints() throws Exception {
        mockMvc.perform(get("/api/v1/admin/users"))
                .andExpect(status().isOk());
    }
}
```

## Performance Testing

### Load Testing with JMeter
**CREATE** performance test scenarios:
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class PerformanceTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    @Timeout(value = 30, unit = TimeUnit.SECONDS)
    void shouldHandleConcurrentUserCreation() throws InterruptedException {
        int numberOfThreads = 10;
        int requestsPerThread = 50;
        CountDownLatch latch = new CountDownLatch(numberOfThreads);
        List<Long> responseTimes = Collections.synchronizedList(new ArrayList<>());
        
        for (int i = 0; i < numberOfThreads; i++) {
            final int threadIndex = i;
            new Thread(() -> {
                try {
                    for (int j = 0; j < requestsPerThread; j++) {
                        long startTime = System.currentTimeMillis();
                        
                        CreateUserRequest request = CreateUserRequest.builder()
                            .username("user" + threadIndex + "_" + j)
                            .email("user" + threadIndex + "_" + j + "@example.com")
                            .password("SecurePass123!")
                            .build();
                        
                        ResponseEntity<UserDTO> response = restTemplate.postForEntity(
                            "/api/v1/users", request, UserDTO.class);
                        
                        long responseTime = System.currentTimeMillis() - startTime;
                        responseTimes.add(responseTime);
                        
                        assertThat(response.getStatusCode()).isIn(
                            HttpStatus.CREATED, HttpStatus.CONFLICT);
                    }
                } finally {
                    latch.countDown();
                }
            }).start();
        }
        
        latch.await();
        
        // Verify performance metrics
        double averageResponseTime = responseTimes.stream()
            .mapToLong(Long::longValue)
            .average()
            .orElse(0.0);
        
        assertThat(averageResponseTime).isLessThan(1000); // Less than 1 second average
        
        long maxResponseTime = responseTimes.stream()
            .mapToLong(Long::longValue)
            .max()
            .orElse(0);
        
        assertThat(maxResponseTime).isLessThan(5000); // Less than 5 seconds max
    }
}
```

## Test Quality Guidelines

### Test Naming Conventions
**USE** descriptive test names:
```java
// GOOD - Describes what is being tested and expected outcome
@Test
void shouldReturnUserDTOWhenValidUserIdProvided() { }

@Test
void shouldThrowUserNotFoundExceptionWhenInvalidUserIdProvided() { }

@Test
void shouldUpdateUserPasswordWhenValidOldPasswordProvided() { }

// BAD - Not descriptive
@Test
void testGetUser() { }

@Test
void testUpdate() { }
```

### Assertion Best Practices
**USE** AssertJ for fluent assertions:
```java
// GOOD - Descriptive and fluent
assertThat(userList)
    .hasSize(3)
    .extracting(User::getUsername)
    .containsExactly("user1", "user2", "user3");

assertThat(user)
    .isNotNull()
    .satisfies(u -> {
        assertThat(u.getUsername()).isEqualTo("testuser");
        assertThat(u.getEmail()).isEqualTo("test@example.com");
        assertThat(u.isEnabled()).isTrue();
    });

// BETTER - Use soft assertions for multiple checks
SoftAssertions.assertSoftly(softly -> {
    softly.assertThat(user.getUsername()).isEqualTo("testuser");
    softly.assertThat(user.getEmail()).isEqualTo("test@example.com");
    softly.assertThat(user.isEnabled()).isTrue();
});
```

### Test Data Builders
**IMPLEMENT** test data builders for complex objects:
```java
public class UserTestDataBuilder {
    private String username = "defaultuser";
    private String email = "default@example.com";
    private String password = "defaultPassword";
    private boolean enabled = true;
    private Set<Role> roles = new HashSet<>();
    
    public static UserTestDataBuilder aUser() {
        return new UserTestDataBuilder();
    }
    
    public UserTestDataBuilder withUsername(String username) {
        this.username = username;
        return this;
    }
    
    public UserTestDataBuilder withEmail(String email) {
        this.email = email;
        return this;
    }
    
    public UserTestDataBuilder disabled() {
        this.enabled = false;
        return this;
    }
    
    public UserTestDataBuilder withRoles(Role... roles) {
        this.roles = Set.of(roles);
        return this;
    }
    
    public User build() {
        return User.builder()
            .username(username)
            .email(email)
            .password(password)
            .enabled(enabled)
            .roles(roles)
            .build();
    }
}

// Usage in tests
@Test
void shouldCreateUser() {
    User user = aUser()
        .withUsername("testuser")
        .withEmail("test@example.com")
        .withRoles(Role.USER)
        .build();
    
    // Test implementation
}
```

## Test Coverage Requirements

### Coverage Metrics
**MINIMUM** coverage requirements:
- **Overall**: 80% line coverage
- **Service Layer**: 90% line coverage
- **Repository Layer**: 95% line coverage
- **Controller Layer**: 85% line coverage
- **Security Components**: 95% line coverage

### Coverage Tools Configuration
**CONFIGURE** JaCoCo for coverage reporting:
```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.8</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
        <execution>
            <id>check</id>
            <goals>
                <goal>check</goal>
            </goals>
            <configuration>
                <rules>
                    <rule>
                        <element>BUNDLE</element>
                        <limits>
                            <limit>
                                <counter>LINE</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.80</minimum>
                            </limit>
                        </limits>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

## Testing Anti-Patterns to Avoid

**DON'T**:
- Test implementation details instead of behavior
- Create tests that depend on external systems without proper isolation
- Write overly complex tests that are hard to understand
- Test multiple unrelated behaviors in a single test
- Use Thread.sleep() in tests
- Ignore flaky tests
- Test private methods directly
- Create tests without clear arrange-act-assert structure

**DO**:
- Test public API and contracts
- Use test doubles for external dependencies
- Keep tests simple and focused
- Follow the single responsibility principle for tests
- Use proper synchronization mechanisms
- Fix or delete flaky tests immediately
- Test behavior through public interfaces
- Structure tests clearly with given-when-then or arrange-act-assert
