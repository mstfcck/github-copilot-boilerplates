---
applyTo: '**'
---

# Spring Configuration Guide

This document provides comprehensive guidelines for configuring Spring applications with best practices for different environments and deployment scenarios.

## Application Configuration Structure

### Configuration Files Organization
**ORGANIZE** configuration files by environment and purpose:

```
src/main/resources/
├── application.yml                 # Default configuration
├── application-dev.yml            # Development environment
├── application-test.yml           # Testing environment
├── application-staging.yml        # Staging environment
├── application-prod.yml           # Production environment
├── application-docker.yml         # Docker-specific settings
├── application-cloud.yml          # Cloud platform settings
└── config/
    ├── security-config.yml        # Security-specific configuration
    ├── database-config.yml        # Database-specific configuration
    └── integration-config.yml     # External integration settings
```

### Base Application Configuration
**CONFIGURE** application.yml with common settings:

```yaml
# application.yml
spring:
  application:
    name: spring-boilerplate
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:dev}
  
  # Jackson configuration
  jackson:
    default-property-inclusion: non_null
    serialization:
      write-dates-as-timestamps: false
      indent-output: true
    deserialization:
      fail-on-unknown-properties: false
    time-zone: UTC
    date-format: yyyy-MM-dd'T'HH:mm:ss.SSSZ
  
  # JPA configuration
  jpa:
    open-in-view: false
    hibernate:
      naming:
        physical-strategy: org.hibernate.boot.model.naming.SnakeCasePhysicalNamingStrategy
        implicit-strategy: org.springframework.boot.orm.jpa.hibernate.SpringImplicitNamingStrategy
    properties:
      hibernate:
        format_sql: false
        use_sql_comments: false
        batch_size: 25
        order_inserts: true
        order_updates: true
        jdbc:
          time_zone: UTC
  
  # Validation configuration
  validation:
    enabled: true
  
  # Web configuration
  mvc:
    throw-exception-if-no-handler-found: true
  web:
    resources:
      add-mappings: false

# Server configuration
server:
  port: ${PORT:8080}
  servlet:
    context-path: /
  error:
    include-message: on_param
    include-binding-errors: on_param
    include-stacktrace: on_param
    include-exception: false
  compression:
    enabled: true
    mime-types: application/json,application/xml,text/html,text/xml,text/plain
    min-response-size: 1024

# Management and monitoring
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
      base-path: /actuator
  endpoint:
    health:
      show-details: when_authorized
      show-components: when_authorized
  health:
    diskspace:
      enabled: true
    db:
      enabled: true
  metrics:
    export:
      prometheus:
        enabled: true

# Logging configuration
logging:
  level:
    ROOT: INFO
    com.example: DEBUG
    org.springframework.security: INFO
    org.hibernate.SQL: WARN
    org.hibernate.type.descriptor.sql.BasicBinder: WARN
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"

# Application-specific configuration
app:
  cors:
    allowed-origins: ${CORS_ALLOWED_ORIGINS:http://localhost:3000,http://localhost:8080}
    allowed-methods: GET,POST,PUT,DELETE,OPTIONS
    allowed-headers: "*"
    allow-credentials: true
    max-age: 3600
  
  security:
    jwt:
      secret: ${JWT_SECRET:defaultSecretKeyForDevelopmentOnly}
      expiration: ${JWT_EXPIRATION:86400000} # 24 hours in milliseconds
      refresh-expiration: ${JWT_REFRESH_EXPIRATION:604800000} # 7 days
    
    password:
      min-length: 8
      require-uppercase: true
      require-lowercase: true
      require-digit: true
      require-special-char: false
  
  file:
    upload:
      max-size: ${FILE_UPLOAD_MAX_SIZE:10MB}
      allowed-types: jpg,jpeg,png,gif,pdf,doc,docx
      storage-path: ${FILE_STORAGE_PATH:./uploads}
  
  cache:
    ttl: ${CACHE_TTL:600} # 10 minutes
    max-entries: ${CACHE_MAX_ENTRIES:1000}
  
  async:
    core-pool-size: ${ASYNC_CORE_POOL_SIZE:5}
    max-pool-size: ${ASYNC_MAX_POOL_SIZE:10}
    queue-capacity: ${ASYNC_QUEUE_CAPACITY:100}
    thread-name-prefix: "async-"
```

### Environment-Specific Configurations

#### Development Configuration
```yaml
# application-dev.yml
spring:
  datasource:
    url: jdbc:h2:mem:devdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
    driver-class-name: org.h2.Driver
    username: sa
    password: 
  
  h2:
    console:
      enabled: true
      path: /h2-console
  
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
    properties:
      hibernate:
        format_sql: true
        use_sql_comments: true
  
  flyway:
    enabled: false

logging:
  level:
    com.example: DEBUG
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
    org.springframework.web: DEBUG

app:
  security:
    jwt:
      secret: devSecretKeyForDevelopmentOnlyNotForProduction
  
  cors:
    allowed-origins: "*"

debug: true
```

#### Production Configuration
```yaml
# application-prod.yml
spring:
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}
    driver-class-name: org.postgresql.Driver
    hikari:
      maximum-pool-size: ${DB_POOL_SIZE:20}
      minimum-idle: ${DB_MINIMUM_IDLE:5}
      idle-timeout: 300000
      max-lifetime: 600000
      connection-timeout: 20000
      leak-detection-threshold: 60000
  
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        format_sql: false
        use_sql_comments: false
  
  flyway:
    enabled: true
    validate-on-migrate: true
    clean-disabled: true

server:
  forward-headers-strategy: native
  tomcat:
    remoteip:
      remote-ip-header: x-forwarded-for
      protocol-header: x-forwarded-proto

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: never

logging:
  level:
    ROOT: WARN
    com.example: INFO
  file:
    name: ${LOG_FILE_PATH:./logs/application.log}
  logback:
    rollingpolicy:
      max-file-size: 100MB
      total-size-cap: 1GB
      max-history: 30

app:
  security:
    jwt:
      secret: ${JWT_SECRET}
  
  cors:
    allowed-origins: ${CORS_ALLOWED_ORIGINS}
```

#### Test Configuration
```yaml
# application-test.yml
spring:
  datasource:
    url: jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
    driver-class-name: org.h2.Driver
    username: sa
    password: 
  
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: false
  
  flyway:
    enabled: false
  
  test:
    database:
      replace: none

logging:
  level:
    ROOT: WARN
    com.example: INFO
    org.springframework.test: INFO

app:
  security:
    jwt:
      secret: testSecretKeyForTestingOnly
      expiration: 60000 # 1 minute for faster tests
  
  cache:
    ttl: 60 # 1 minute for tests
```

## Configuration Classes

### Security Configuration
**IMPLEMENT** comprehensive security configuration:

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true, securedEnabled = true)
@RequiredArgsConstructor
public class SecurityConfig {
    
    private final JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    private final JwtAccessDeniedHandler jwtAccessDeniedHandler;
    private final JwtTokenProvider jwtTokenProvider;
    private final CorsProperties corsProperties;
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .exceptionHandling(exceptions -> exceptions
                .authenticationEntryPoint(jwtAuthenticationEntryPoint)
                .accessDeniedHandler(jwtAccessDeniedHandler))
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/api/public/**", "/actuator/health").permitAll()
                .requestMatchers(HttpMethod.POST, "/api/v1/auth/**").permitAll()
                .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
                .requestMatchers("/actuator/**").hasRole("ADMIN")
                .anyRequest().authenticated())
            .addFilterBefore(jwtAuthenticationFilter(), 
                           UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
    
    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter() {
        return new JwtAuthenticationFilter(jwtTokenProvider);
    }
    
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(corsProperties.getAllowedOrigins());
        configuration.setAllowedMethods(corsProperties.getAllowedMethods());
        configuration.setAllowedHeaders(corsProperties.getAllowedHeaders());
        configuration.setAllowCredentials(corsProperties.isAllowCredentials());
        configuration.setMaxAge(corsProperties.getMaxAge());
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }
    
    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }
}
```

### Database Configuration
**CONFIGURE** database settings:

```java
@Configuration
@EnableJpaRepositories(
    basePackages = "com.example.repository",
    enableDefaultTransactions = false
)
@EnableTransactionManagement
@RequiredArgsConstructor
public class DatabaseConfig {
    
    private final Environment environment;
    
    @Bean
    @Profile("!test")
    public DataSource dataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(environment.getProperty("spring.datasource.url"));
        config.setUsername(environment.getProperty("spring.datasource.username"));
        config.setPassword(environment.getProperty("spring.datasource.password"));
        config.setDriverClassName(environment.getProperty("spring.datasource.driver-class-name"));
        
        // Pool configuration
        config.setMaximumPoolSize(environment.getProperty("spring.datasource.hikari.maximum-pool-size", Integer.class, 20));
        config.setMinimumIdle(environment.getProperty("spring.datasource.hikari.minimum-idle", Integer.class, 5));
        config.setIdleTimeout(environment.getProperty("spring.datasource.hikari.idle-timeout", Long.class, 300000L));
        config.setMaxLifetime(environment.getProperty("spring.datasource.hikari.max-lifetime", Long.class, 600000L));
        config.setConnectionTimeout(environment.getProperty("spring.datasource.hikari.connection-timeout", Long.class, 20000L));
        config.setLeakDetectionThreshold(environment.getProperty("spring.datasource.hikari.leak-detection-threshold", Long.class, 60000L));
        
        // Performance settings
        config.addDataSourceProperty("cachePrepStmts", "true");
        config.addDataSourceProperty("prepStmtCacheSize", "250");
        config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
        config.addDataSourceProperty("useServerPrepStmts", "true");
        config.addDataSourceProperty("useLocalSessionState", "true");
        config.addDataSourceProperty("rewriteBatchedStatements", "true");
        config.addDataSourceProperty("cacheResultSetMetadata", "true");
        config.addDataSourceProperty("cacheServerConfiguration", "true");
        config.addDataSourceProperty("elideSetAutoCommits", "true");
        config.addDataSourceProperty("maintainTimeStats", "false");
        
        return new HikariDataSource(config);
    }
    
    @Bean
    public PlatformTransactionManager transactionManager(EntityManagerFactory entityManagerFactory) {
        JpaTransactionManager transactionManager = new JpaTransactionManager();
        transactionManager.setEntityManagerFactory(entityManagerFactory);
        return transactionManager;
    }
    
    @Bean
    public JpaVendorAdapter jpaVendorAdapter() {
        HibernateJpaVendorAdapter adapter = new HibernateJpaVendorAdapter();
        adapter.setShowSql(environment.getProperty("spring.jpa.show-sql", Boolean.class, false));
        adapter.setGenerateDdl(false);
        return adapter;
    }
}
```

### Async Configuration
**CONFIGURE** asynchronous processing:

```java
@Configuration
@EnableAsync
@RequiredArgsConstructor
public class AsyncConfig implements AsyncConfigurer {
    
    private final AsyncProperties asyncProperties;
    
    @Override
    @Bean(name = "taskExecutor")
    public Executor getAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(asyncProperties.getCorePoolSize());
        executor.setMaxPoolSize(asyncProperties.getMaxPoolSize());
        executor.setQueueCapacity(asyncProperties.getQueueCapacity());
        executor.setThreadNamePrefix(asyncProperties.getThreadNamePrefix());
        executor.setWaitForTasksToCompleteOnShutdown(true);
        executor.setAwaitTerminationSeconds(60);
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }
    
    @Override
    public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
        return new SimpleAsyncUncaughtExceptionHandler();
    }
    
    @Bean
    @Primary
    public TaskExecutor primaryTaskExecutor() {
        return (TaskExecutor) getAsyncExecutor();
    }
    
    @Bean(name = "emailTaskExecutor")
    public Executor emailTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(5);
        executor.setQueueCapacity(50);
        executor.setThreadNamePrefix("email-");
        executor.initialize();
        return executor;
    }
}
```

### Cache Configuration
**CONFIGURE** caching strategy:

```java
@Configuration
@EnableCaching
@RequiredArgsConstructor
public class CacheConfig {
    
    private final CacheProperties cacheProperties;
    
    @Bean
    public CacheManager cacheManager() {
        RedisCacheManager.Builder builder = RedisCacheManager
            .RedisCacheManagerBuilder
            .fromConnectionFactory(redisConnectionFactory())
            .cacheDefaults(defaultCacheConfiguration());
        
        // Configure specific caches
        Map<String, RedisCacheConfiguration> cacheConfigurations = Map.of(
            "users", cacheConfiguration(Duration.ofMinutes(30)),
            "roles", cacheConfiguration(Duration.ofHours(2)),
            "settings", cacheConfiguration(Duration.ofHours(24))
        );
        
        builder.withInitialCacheConfigurations(cacheConfigurations);
        
        return builder.build();
    }
    
    private RedisCacheConfiguration defaultCacheConfiguration() {
        return RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofSeconds(cacheProperties.getTtl()))
            .computePrefixWith(cacheName -> "spring-boilerplate:" + cacheName + ":")
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer()));
    }
    
    private RedisCacheConfiguration cacheConfiguration(Duration ttl) {
        return defaultCacheConfiguration().entryTtl(ttl);
    }
    
    @Bean
    public RedisConnectionFactory redisConnectionFactory() {
        LettuceConnectionFactory factory = new LettuceConnectionFactory(
            new RedisStandaloneConfiguration("localhost", 6379));
        factory.setValidateConnection(true);
        return factory;
    }
    
    @Bean
    public RedisTemplate<String, Object> redisTemplate() {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(redisConnectionFactory());
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(new GenericJackson2JsonRedisSerializer());
        template.setHashKeySerializer(new StringRedisSerializer());
        template.setHashValueSerializer(new GenericJackson2JsonRedisSerializer());
        template.afterPropertiesSet();
        return template;
    }
}
```

## Configuration Properties

### Type-Safe Configuration Properties
**CREATE** type-safe configuration classes:

```java
@Data
@Configuration
@ConfigurationProperties(prefix = "app")
@Validated
public class ApplicationProperties {
    
    @Valid
    @NotNull
    private Security security = new Security();
    
    @Valid
    @NotNull
    private Cors cors = new Cors();
    
    @Valid
    @NotNull
    private File file = new File();
    
    @Valid
    @NotNull
    private Cache cache = new Cache();
    
    @Valid
    @NotNull
    private Async async = new Async();
    
    @Data
    public static class Security {
        @Valid
        @NotNull
        private Jwt jwt = new Jwt();
        
        @Valid
        @NotNull
        private Password password = new Password();
        
        @Data
        public static class Jwt {
            @NotBlank
            private String secret;
            
            @Min(60000) // At least 1 minute
            private long expiration = 86400000; // 24 hours
            
            @Min(60000)
            private long refreshExpiration = 604800000; // 7 days
        }
        
        @Data
        public static class Password {
            @Min(8)
            @Max(128)
            private int minLength = 8;
            
            private boolean requireUppercase = true;
            private boolean requireLowercase = true;
            private boolean requireDigit = true;
            private boolean requireSpecialChar = false;
        }
    }
    
    @Data
    public static class Cors {
        @NotEmpty
        private List<String> allowedOrigins = List.of("http://localhost:3000");
        
        @NotEmpty
        private List<String> allowedMethods = List.of("GET", "POST", "PUT", "DELETE", "OPTIONS");
        
        @NotEmpty
        private List<String> allowedHeaders = List.of("*");
        
        private boolean allowCredentials = true;
        
        @Min(0)
        private long maxAge = 3600;
    }
    
    @Data
    public static class File {
        @Valid
        @NotNull
        private Upload upload = new Upload();
        
        @Data
        public static class Upload {
            @NotBlank
            private String maxSize = "10MB";
            
            @NotEmpty
            private List<String> allowedTypes = List.of("jpg", "jpeg", "png", "gif", "pdf");
            
            @NotBlank
            private String storagePath = "./uploads";
        }
    }
    
    @Data
    public static class Cache {
        @Min(30)
        private long ttl = 600; // 10 minutes
        
        @Min(100)
        private int maxEntries = 1000;
    }
    
    @Data
    public static class Async {
        @Min(1)
        private int corePoolSize = 5;
        
        @Min(1)
        private int maxPoolSize = 10;
        
        @Min(0)
        private int queueCapacity = 100;
        
        @NotBlank
        private String threadNamePrefix = "async-";
    }
}
```

### External Configuration Sources
**CONFIGURE** external configuration:

```java
@Configuration
@PropertySource("classpath:config/security-config.yml")
@PropertySource("classpath:config/database-config.yml")
@PropertySource(value = "file:${CONFIG_PATH:./config}/external.properties", ignoreResourceNotFound = true)
public class ExternalConfigurationConfig {
    
    @Bean
    @Profile("cloud")
    public static PropertySourcesPlaceholderConfigurer cloudPropertySourcesPlaceholderConfigurer() {
        PropertySourcesPlaceholderConfigurer configurer = new PropertySourcesPlaceholderConfigurer();
        configurer.setIgnoreResourceNotFound(true);
        configurer.setIgnoreUnresolvablePlaceholders(false);
        return configurer;
    }
}

@Configuration
@ConditionalOnProperty(prefix = "spring.cloud.config", name = "enabled", havingValue = "true")
public class CloudConfigConfiguration {
    
    @Bean
    public CloudConfigClient cloudConfigClient() {
        return CloudConfigClient.builder()
            .uri(environment.getProperty("spring.cloud.config.uri"))
            .build();
    }
}
```

## Profile-Specific Configuration

### Profile Activation
**CONFIGURE** profile activation strategies:

```java
@Configuration
public class ProfileConfig {
    
    @Bean
    @Profile("dev")
    public CommandLineRunner devDataLoader(UserRepository userRepository) {
        return args -> {
            if (userRepository.count() == 0) {
                loadDevelopmentData(userRepository);
            }
        };
    }
    
    @Bean
    @Profile("test")
    public TestDataInitializer testDataInitializer() {
        return new TestDataInitializer();
    }
    
    @Bean
    @Profile({"staging", "prod"})
    public ProductionHealthIndicator productionHealthIndicator() {
        return new ProductionHealthIndicator();
    }
    
    private void loadDevelopmentData(UserRepository userRepository) {
        // Load test data for development
    }
}
```

### Conditional Configuration
**USE** conditions for configuration:

```java
@Configuration
public class ConditionalConfig {
    
    @Bean
    @ConditionalOnProperty(prefix = "app.features", name = "email", havingValue = "true")
    public EmailService emailService() {
        return new SmtpEmailService();
    }
    
    @Bean
    @ConditionalOnMissingBean(EmailService.class)
    public EmailService mockEmailService() {
        return new MockEmailService();
    }
    
    @Bean
    @ConditionalOnClass(RedisTemplate.class)
    @ConditionalOnProperty(prefix = "spring.cache", name = "type", havingValue = "redis")
    public CacheManager redisCacheManager() {
        return new RedisCacheManager.Builder(redisConnectionFactory()).build();
    }
    
    @Bean
    @ConditionalOnMissingClass("org.springframework.data.redis.core.RedisTemplate")
    public CacheManager simpleCacheManager() {
        return new ConcurrentMapCacheManager();
    }
    
    @Configuration
    @ConditionalOnWebApplication(type = ConditionalOnWebApplication.Type.SERVLET)
    public static class ServletWebConfig {
        
        @Bean
        public FilterRegistrationBean<CorsFilter> corsFilter() {
            FilterRegistrationBean<CorsFilter> registration = new FilterRegistrationBean<>();
            registration.setFilter(new CorsFilter(corsConfigurationSource()));
            registration.setOrder(Ordered.HIGHEST_PRECEDENCE);
            return registration;
        }
    }
}
```

## Environment Variable Management

### Environment Variable Configuration
**ORGANIZE** environment variables systematically:

```bash
# .env.development
SPRING_PROFILES_ACTIVE=dev
DATABASE_URL=jdbc:h2:mem:devdb
DATABASE_USERNAME=sa
DATABASE_PASSWORD=
JWT_SECRET=devSecretKeyForDevelopmentOnly
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
LOG_LEVEL=DEBUG
CACHE_TTL=300

# .env.production
SPRING_PROFILES_ACTIVE=prod
DATABASE_URL=jdbc:postgresql://prod-db:5432/springboilerplate
DATABASE_USERNAME=${DB_USERNAME}
DATABASE_PASSWORD=${DB_PASSWORD}
JWT_SECRET=${JWT_SECRET}
CORS_ALLOWED_ORIGINS=${ALLOWED_ORIGINS}
LOG_LEVEL=WARN
CACHE_TTL=600
```

### Docker Configuration
**CONFIGURE** for containerized environments:

```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - DATABASE_URL=jdbc:postgresql://db:5432/springboilerplate
      - DATABASE_USERNAME=postgres
      - DATABASE_PASSWORD=postgres
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      - db
      - redis
    volumes:
      - ./uploads:/app/uploads
  
  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=springboilerplate
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

```yaml
# application-docker.yml
spring:
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}
  
  redis:
    host: ${REDIS_HOST:redis}
    port: ${REDIS_PORT:6379}

server:
  port: 8080

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics

logging:
  level:
    ROOT: ${LOG_LEVEL:INFO}
```

## Configuration Validation

### Startup Validation
**VALIDATE** configuration at startup:

```java
@Component
@RequiredArgsConstructor
public class ConfigurationValidator implements ApplicationListener<ApplicationReadyEvent> {
    
    private final ApplicationProperties appProperties;
    private final DataSource dataSource;
    
    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        validateConfiguration();
    }
    
    private void validateConfiguration() {
        validateDatabaseConnection();
        validateJwtConfiguration();
        validateFileStorageConfiguration();
        validateCacheConfiguration();
    }
    
    private void validateDatabaseConnection() {
        try (Connection connection = dataSource.getConnection()) {
            if (!connection.isValid(5)) {
                throw new IllegalStateException("Database connection is not valid");
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to validate database connection", e);
        }
    }
    
    private void validateJwtConfiguration() {
        String secret = appProperties.getSecurity().getJwt().getSecret();
        if (secret.length() < 32) {
            throw new IllegalStateException("JWT secret must be at least 32 characters long");
        }
        
        if ("defaultSecretKeyForDevelopmentOnly".equals(secret)) {
            String activeProfile = System.getProperty("spring.profiles.active", "");
            if (activeProfile.contains("prod")) {
                throw new IllegalStateException("Default JWT secret cannot be used in production");
            }
        }
    }
    
    private void validateFileStorageConfiguration() {
        String storagePath = appProperties.getFile().getUpload().getStoragePath();
        Path path = Paths.get(storagePath);
        
        if (!Files.exists(path)) {
            try {
                Files.createDirectories(path);
            } catch (IOException e) {
                throw new IllegalStateException("Failed to create file storage directory: " + storagePath, e);
            }
        }
        
        if (!Files.isWritable(path)) {
            throw new IllegalStateException("File storage directory is not writable: " + storagePath);
        }
    }
    
    private void validateCacheConfiguration() {
        if (appProperties.getCache().getTtl() < 30) {
            throw new IllegalStateException("Cache TTL must be at least 30 seconds");
        }
    }
}
```

## Configuration Best Practices

### Security Best Practices
**SECURE** configuration management:

```java
@Component
public class ConfigurationSecurityChecker {
    
    @EventListener(ApplicationReadyEvent.class)
    public void checkSecurityConfiguration() {
        checkForDefaultPasswords();
        checkForInsecureSettings();
        checkForProductionReadiness();
    }
    
    private void checkForDefaultPasswords() {
        // Check for default passwords in configuration
    }
    
    private void checkForInsecureSettings() {
        // Check for insecure configuration settings
    }
    
    private void checkForProductionReadiness() {
        String activeProfile = System.getProperty("spring.profiles.active", "");
        if (activeProfile.contains("prod")) {
            validateProductionConfiguration();
        }
    }
    
    private void validateProductionConfiguration() {
        // Validate production-specific settings
    }
}
```

## Configuration Anti-Patterns

**DON'T**:
- Hardcode sensitive values in configuration files
- Use default passwords in production
- Store secrets in version control
- Mix environment-specific settings in the same file
- Ignore configuration validation
- Use weak encryption for sensitive data
- Expose internal configuration through APIs
- Use the same configuration for all environments

**DO**:
- Use environment variables for sensitive data
- Validate configuration at startup
- Separate configuration by environment
- Use type-safe configuration properties
- Implement proper secret management
- Use strong encryption for sensitive data
- Keep configuration documentation up to date
- Follow the principle of least privilege for configuration access
