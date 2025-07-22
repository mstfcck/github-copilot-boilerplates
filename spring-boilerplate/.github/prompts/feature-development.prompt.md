# Spring Boot Feature Development Prompt

This prompt provides comprehensive guidance for developing new features in Spring Boot applications following established patterns and best practices.

## Objective

Guide developers through the complete process of implementing new features in Spring Boot applications, from planning to deployment, ensuring consistency with architectural patterns and coding standards.

## Prerequisites

**MUST** have these prerequisites:
- Spring Boot project structure is properly established
- Database schema is designed and documented
- API endpoints are planned and documented
- Development environment is configured

**SHOULD** review these resources:
- [Spring Boot Reference Documentation](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)
- [Architecture Instructions](../instructions/architecture.instructions.md)
- [Coding Standards](../instructions/coding-standards.instructions.md)
- [Testing Guidelines](../instructions/testing.instructions.md)

## Step-by-Step Process

### Phase 1: Feature Planning and Design
**DO** these actions:
1. **Define Feature Requirements**
   - Identify business requirements and acceptance criteria
   - Create user stories and use cases
   - Define API contracts and data models
   - Plan database schema changes if needed

2. **Design Feature Architecture**
   - Choose appropriate architectural patterns (MVC, layered, etc.)
   - Plan component interactions and dependencies
   - Design data flow and transaction boundaries
   - Consider security and performance implications

**ENSURE** these validations:
- [ ] Feature requirements are clearly documented
- [ ] API contracts are reviewed and approved
- [ ] Database design follows normalization principles
- [ ] Security requirements are identified and planned

### Phase 2: Implementation Setup
**DO** these actions:
1. **Create Branch and Setup**
   ```bash
   git checkout -b feature/feature-name
   git push -u origin feature/feature-name
   ```

2. **Generate Base Structure**
   - Create entity classes with proper JPA annotations
   - Generate repository interfaces
   - Create service classes with business logic
   - Implement controller classes with REST endpoints
   - Create DTO classes for data transfer

3. **Configure Dependencies**
   - Add required dependencies to pom.xml
   - Configure new properties in application.yml
   - Update database migration scripts if needed

**ENSURE** these validations:
- [ ] All classes follow naming conventions
- [ ] Package structure is organized by feature
- [ ] Dependencies are properly configured
- [ ] Database migrations are backward compatible

### Phase 3: Core Implementation
**DO** these actions:
1. **Implement Entity Layer**
   ```java
   @Entity
   @Table(name = "feature_entities")
   @Data
   @NoArgsConstructor
   @AllArgsConstructor
   @Builder
   public class FeatureEntity {
       @Id
       @GeneratedValue(strategy = GenerationType.IDENTITY)
       private Long id;
       
       @Column(nullable = false)
       private String name;
       
       @Column(nullable = false)
       private String description;
       
       @Enumerated(EnumType.STRING)
       private FeatureStatus status;
       
       @CreationTimestamp
       private LocalDateTime createdAt;
       
       @UpdateTimestamp
       private LocalDateTime updatedAt;
   }
   ```

2. **Implement Repository Layer**
   ```java
   @Repository
   public interface FeatureRepository extends JpaRepository<FeatureEntity, Long> {
       
       List<FeatureEntity> findByStatus(FeatureStatus status);
       
       @Query("SELECT f FROM FeatureEntity f WHERE f.name LIKE %:name%")
       List<FeatureEntity> findByNameContaining(@Param("name") String name);
       
       boolean existsByName(String name);
   }
   ```

3. **Implement Service Layer**
   ```java
   @Service
   @Transactional
   @Slf4j
   public class FeatureService {
       
       private final FeatureRepository featureRepository;
       private final FeatureMapper featureMapper;
       
       public FeatureService(FeatureRepository featureRepository, 
                           FeatureMapper featureMapper) {
           this.featureRepository = featureRepository;
           this.featureMapper = featureMapper;
       }
       
       @Transactional(readOnly = true)
       public List<FeatureDto> findAll() {
           return featureRepository.findAll().stream()
               .map(featureMapper::toDto)
               .collect(Collectors.toList());
       }
       
       @Transactional(readOnly = true)
       public FeatureDto findById(Long id) {
           FeatureEntity entity = featureRepository.findById(id)
               .orElseThrow(() -> new FeatureNotFoundException("Feature not found: " + id));
           return featureMapper.toDto(entity);
       }
       
       public FeatureDto create(CreateFeatureRequest request) {
           validateUniqueFeatureName(request.getName());
           
           FeatureEntity entity = featureMapper.toEntity(request);
           entity.setStatus(FeatureStatus.ACTIVE);
           
           FeatureEntity savedEntity = featureRepository.save(entity);
           log.info("Feature created successfully: {}", savedEntity.getId());
           
           return featureMapper.toDto(savedEntity);
       }
       
       public FeatureDto update(Long id, UpdateFeatureRequest request) {
           FeatureEntity entity = featureRepository.findById(id)
               .orElseThrow(() -> new FeatureNotFoundException("Feature not found: " + id));
           
           featureMapper.updateEntityFromRequest(request, entity);
           
           FeatureEntity updatedEntity = featureRepository.save(entity);
           log.info("Feature updated successfully: {}", updatedEntity.getId());
           
           return featureMapper.toDto(updatedEntity);
       }
       
       public void delete(Long id) {
           if (!featureRepository.existsById(id)) {
               throw new FeatureNotFoundException("Feature not found: " + id);
           }
           
           featureRepository.deleteById(id);
           log.info("Feature deleted successfully: {}", id);
       }
       
       private void validateUniqueFeatureName(String name) {
           if (featureRepository.existsByName(name)) {
               throw new DuplicateFeatureException("Feature name already exists: " + name);
           }
       }
   }
   ```

4. **Implement Controller Layer**
   ```java
   @RestController
   @RequestMapping("/api/v1/features")
   @Validated
   @Slf4j
   public class FeatureController {
       
       private final FeatureService featureService;
       
       public FeatureController(FeatureService featureService) {
           this.featureService = featureService;
       }
       
       @GetMapping
       public ResponseEntity<List<FeatureDto>> getAllFeatures() {
           List<FeatureDto> features = featureService.findAll();
           return ResponseEntity.ok(features);
       }
       
       @GetMapping("/{id}")
       public ResponseEntity<FeatureDto> getFeature(@PathVariable @Min(1) Long id) {
           FeatureDto feature = featureService.findById(id);
           return ResponseEntity.ok(feature);
       }
       
       @PostMapping
       public ResponseEntity<FeatureDto> createFeature(@Valid @RequestBody CreateFeatureRequest request) {
           FeatureDto createdFeature = featureService.create(request);
           return ResponseEntity.status(HttpStatus.CREATED).body(createdFeature);
       }
       
       @PutMapping("/{id}")
       public ResponseEntity<FeatureDto> updateFeature(@PathVariable @Min(1) Long id, 
                                                      @Valid @RequestBody UpdateFeatureRequest request) {
           FeatureDto updatedFeature = featureService.update(id, request);
           return ResponseEntity.ok(updatedFeature);
       }
       
       @DeleteMapping("/{id}")
       public ResponseEntity<Void> deleteFeature(@PathVariable @Min(1) Long id) {
           featureService.delete(id);
           return ResponseEntity.noContent().build();
       }
   }
   ```

**ENSURE** these validations:
- [ ] All classes use constructor injection
- [ ] Input validation is implemented using Bean Validation
- [ ] Proper exception handling is in place
- [ ] Logging is implemented at appropriate levels
- [ ] Transaction boundaries are correctly defined

### Phase 4: Testing Implementation
**DO** these actions:
1. **Create Unit Tests**
   ```java
   @ExtendWith(MockitoExtension.class)
   class FeatureServiceTest {
       
       @Mock
       private FeatureRepository featureRepository;
       
       @Mock
       private FeatureMapper featureMapper;
       
       @InjectMocks
       private FeatureService featureService;
       
       @Test
       void shouldCreateFeatureSuccessfully() {
           // Given
           CreateFeatureRequest request = new CreateFeatureRequest("Test Feature", "Description");
           FeatureEntity entity = new FeatureEntity();
           FeatureEntity savedEntity = new FeatureEntity();
           savedEntity.setId(1L);
           FeatureDto expectedDto = new FeatureDto();
           
           when(featureRepository.existsByName("Test Feature")).thenReturn(false);
           when(featureMapper.toEntity(request)).thenReturn(entity);
           when(featureRepository.save(entity)).thenReturn(savedEntity);
           when(featureMapper.toDto(savedEntity)).thenReturn(expectedDto);
           
           // When
           FeatureDto result = featureService.create(request);
           
           // Then
           assertThat(result).isEqualTo(expectedDto);
           verify(featureRepository).existsByName("Test Feature");
           verify(featureRepository).save(entity);
       }
       
       @Test
       void shouldThrowExceptionWhenFeatureNameAlreadyExists() {
           // Given
           CreateFeatureRequest request = new CreateFeatureRequest("Existing Feature", "Description");
           when(featureRepository.existsByName("Existing Feature")).thenReturn(true);
           
           // When & Then
           assertThatThrownBy(() -> featureService.create(request))
               .isInstanceOf(DuplicateFeatureException.class)
               .hasMessage("Feature name already exists: Existing Feature");
       }
   }
   ```

2. **Create Integration Tests**
   ```java
   @SpringBootTest
   @AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
   @Testcontainers
   class FeatureIntegrationTest {
       
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
       private TestRestTemplate restTemplate;
       
       @Autowired
       private FeatureRepository featureRepository;
       
       @Test
       void shouldCreateAndRetrieveFeature() {
           // Given
           CreateFeatureRequest request = new CreateFeatureRequest("Integration Test Feature", "Test Description");
           
           // When
           ResponseEntity<FeatureDto> createResponse = restTemplate.postForEntity(
               "/api/v1/features", request, FeatureDto.class);
           
           // Then
           assertThat(createResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
           assertThat(createResponse.getBody().getName()).isEqualTo("Integration Test Feature");
           
           // Verify in database
           Optional<FeatureEntity> savedEntity = featureRepository.findById(createResponse.getBody().getId());
           assertThat(savedEntity).isPresent();
           assertThat(savedEntity.get().getName()).isEqualTo("Integration Test Feature");
       }
   }
   ```

**ENSURE** these validations:
- [ ] Unit tests cover all business logic
- [ ] Integration tests verify end-to-end functionality
- [ ] Test coverage meets minimum requirements (80%)
- [ ] Edge cases and error scenarios are tested

### Phase 5: Documentation and Review
**DO** these actions:
1. **Update API Documentation**
   - Add OpenAPI annotations to controllers
   - Update API documentation with new endpoints
   - Document request/response models
   - Add usage examples

2. **Create/Update Documentation**
   - Update README with new feature information
   - Document configuration changes
   - Add troubleshooting guide if needed
   - Update architecture diagrams if applicable

3. **Code Review Preparation**
   - Run all tests and ensure they pass
   - Check code coverage meets requirements
   - Review code for compliance with coding standards
   - Ensure all security requirements are met

**ENSURE** these validations:
- [ ] API documentation is complete and accurate
- [ ] Code follows established patterns and standards
- [ ] All tests pass successfully
- [ ] Security requirements are satisfied
- [ ] Performance requirements are met

## Expected Outcomes

**MUST** achieve:
- Feature implementation is complete and functional
- All tests pass with adequate coverage
- Code follows established patterns and standards
- API documentation is complete and accurate
- Security requirements are satisfied

**SHOULD** produce:
- Clean, maintainable code
- Comprehensive test coverage
- Updated documentation
- Performance benchmarks where applicable
- Security scan results

## Quality Checks

**VERIFY** these items:
- [ ] All business requirements are implemented
- [ ] Code follows SOLID principles
- [ ] Error handling is comprehensive
- [ ] Logging is appropriate and informative
- [ ] Database operations are optimized
- [ ] Security measures are implemented
- [ ] Performance requirements are met
- [ ] Documentation is complete and accurate

## Common Issues and Solutions

**IF** tests are failing:
- **THEN** review test data setup and mock configurations
- **THEN** verify database state and transaction boundaries
- **THEN** check for race conditions in integration tests

**IF** performance is poor:
- **THEN** review database queries and indexing
- **THEN** implement caching where appropriate
- **THEN** consider pagination for large result sets

**IF** security vulnerabilities are found:
- **THEN** implement proper input validation
- **THEN** add authentication and authorization checks
- **THEN** sanitize user inputs and prevent injection attacks

## Follow-up Actions

**MUST** complete:
- Submit pull request with detailed description
- Address code review feedback
- Deploy to staging environment for testing
- Monitor feature performance and errors

**SHOULD** consider:
- Performance monitoring and optimization
- User feedback collection and analysis
- Feature usage analytics
- Future enhancement planning

This prompt ensures comprehensive feature development following Spring Boot best practices and maintaining code quality throughout the development lifecycle.
