---
applyTo: '**'
---

# Enterprise Configuration Instructions

This document outlines enterprise-level configuration management, server-driven module configuration, and multi-environment setup for React Native applications with dynamic module systems and user-type-specific configurations.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** implement server-driven configuration for all module activations
- **REQUIRED** to support user-type-specific configuration without client-side secrets
- **SHALL** implement configuration validation and schema enforcement
- **MUST** support hot configuration updates without app restarts
- **NEVER** hardcode module configurations or user permissions in client code
- **REQUIRED** to implement configuration fallback mechanisms for network failures
- **SHALL** implement proper configuration caching and synchronization
- **MUST** validate all configuration changes before applying them
- **REQUIRED** to implement configuration versioning and rollback capabilities
- **SHALL** support environment-specific configuration management

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** implement configuration A/B testing capabilities
- **RECOMMENDED** to use configuration as code for version control
- **ALWAYS** implement configuration monitoring and alerting
- **DO** implement configuration audit logging for compliance
- **SHOULD** use encrypted configuration storage for sensitive data
- **RECOMMENDED** to implement gradual configuration rollouts
- **DO** implement configuration performance monitoring
- **ALWAYS** implement proper configuration backup and recovery
- **SHOULD** implement configuration dependency management

### Optional Enhancements (**MAY** Consider)

- **MAY** implement real-time configuration synchronization across devices
- **OPTIONAL** to use advanced configuration management platforms
- **USE** machine learning for configuration optimization
- **IMPLEMENT** configuration analytics and usage insights
- **AVOID** over-engineering configuration for simple applications

## Enterprise Configuration Architecture

### Server-Driven Module Configuration

**MUST** implement this configuration pattern:

```typescript
// types/configuration.types.ts
export interface EnterpriseConfiguration {
  version: string;
  timestamp: number;
  environment: Environment;
  userTypes: UserTypeConfiguration[];
  modules: ModuleConfiguration[];
  features: FeatureFlags;
  security: SecurityConfiguration;
  performance: PerformanceConfiguration;
}

export interface UserTypeConfiguration {
  id: string;
  name: string;
  permissions: Permission[];
  modules: UserModuleConfig[];
  ui: UserInterfaceConfig;
  settings: UserTypeSettings;
}

export interface ModuleConfiguration {
  id: string;
  name: string;
  version: string;
  enabled: boolean;
  environments: Environment[];
  userTypes: string[];
  dependencies: ModuleDependency[];
  settings: ModuleSettings;
  performance: ModulePerformanceConfig;
  security: ModuleSecurityConfig;
}

export interface UserModuleConfig {
  moduleId: string;
  enabled: boolean;
  permissions: string[];
  settings: Record<string, any>;
  features: Record<string, boolean>;
}

// Configuration service implementation
export class ConfigurationService {
  private cache: Map<string, any> = new Map();
  private lastFetch: number = 0;
  private cacheTTL: number = 5 * 60 * 1000; // 5 minutes

  async fetchConfiguration(
    userId: string,
    userType: string,
    environment: Environment
  ): Promise<EnterpriseConfiguration> {
    const cacheKey = `config_${userId}_${userType}_${environment}`;
    
    // Check cache first
    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey);
    }

    try {
      const response = await this.apiClient.post('/api/configuration', {
        userId,
        userType,
        environment,
        version: this.getCurrentVersion()
      });

      const config = this.validateConfiguration(response.data);
      this.cache.set(cacheKey, config);
      this.lastFetch = Date.now();

      return config;
    } catch (error) {
      console.error('Failed to fetch configuration:', error);
      return this.getFallbackConfiguration(userType);
    }
  }

  private validateConfiguration(
    config: any
  ): EnterpriseConfiguration {
    // Implement comprehensive configuration validation
    const schema = this.getConfigurationSchema();
    const result = schema.validate(config);
    
    if (result.error) {
      throw new Error(`Invalid configuration: ${result.error.message}`);
    }

    return result.value;
  }

  private getFallbackConfiguration(
    userType: string
  ): EnterpriseConfiguration {
    // Return minimal safe configuration for offline scenarios
    return this.getDefaultConfiguration(userType);
  }

  async updateConfiguration(
    config: Partial<EnterpriseConfiguration>
  ): Promise<void> {
    // Validate configuration update
    const validatedConfig = this.validateConfigurationUpdate(config);
    
    // Apply configuration with rollback capability
    const rollback = this.createRollbackPoint();
    
    try {
      await this.applyConfiguration(validatedConfig);
    } catch (error) {
      console.error('Configuration update failed, rolling back:', error);
      await this.rollback(rollback);
      throw error;
    }
  }

  // Hot configuration updates
  subscribeToConfigurationUpdates(
    callback: (config: EnterpriseConfiguration) => void
  ): () => void {
    return this.configurationEventBus.subscribe(
      'configuration.updated',
      callback
    );
  }
}
```

### Module Configuration Management

**IMPLEMENT** dynamic module configuration:

```typescript
// core/configuration/services/moduleConfigService.ts
export class ModuleConfigurationService {
  private moduleConfigs: Map<string, ModuleConfiguration> = new Map();
  private userModuleConfigs: Map<string, UserModuleConfig[]> = new Map();

  async loadModuleConfigurations(
    userType: string,
    userId: string
  ): Promise<void> {
    try {
      // Fetch module configurations from server
      const response = await this.apiClient.get(
        `/api/modules/configuration`,
        {
          params: { userType, userId }
        }
      );

      const { modules, userModules } = response.data;
      
      // Store module configurations
      modules.forEach((config: ModuleConfiguration) => {
        this.moduleConfigs.set(config.id, config);
      });

      // Store user-specific module configurations
      this.userModuleConfigs.set(userId, userModules);

      // Notify modules of configuration changes
      this.notifyConfigurationUpdates();
    } catch (error) {
      console.error('Failed to load module configurations:', error);
      await this.loadFallbackConfigurations();
    }
  }

  getModuleConfiguration(moduleId: string): ModuleConfiguration | null {
    return this.moduleConfigs.get(moduleId) || null;
  }

  getUserModuleConfiguration(
    userId: string,
    moduleId: string
  ): UserModuleConfig | null {
    const userConfigs = this.userModuleConfigs.get(userId);
    return userConfigs?.find(config => config.moduleId === moduleId) || null;
  }

  isModuleEnabled(
    userId: string,
    moduleId: string
  ): boolean {
    const moduleConfig = this.getModuleConfiguration(moduleId);
    const userConfig = this.getUserModuleConfiguration(userId, moduleId);

    return moduleConfig?.enabled && userConfig?.enabled;
  }

  getModuleSettings(
    userId: string,
    moduleId: string
  ): Record<string, any> {
    const userConfig = this.getUserModuleConfiguration(userId, moduleId);
    const moduleConfig = this.getModuleConfiguration(moduleId);

    return {
      ...moduleConfig?.settings,
      ...userConfig?.settings
    };
  }

  async updateModuleConfiguration(
    moduleId: string,
    updates: Partial<ModuleConfiguration>
  ): Promise<void> {
    const currentConfig = this.getModuleConfiguration(moduleId);
    
    if (!currentConfig) {
      throw new Error(`Module ${moduleId} not found`);
    }

    const updatedConfig = { ...currentConfig, ...updates };
    
    // Validate configuration
    this.validateModuleConfiguration(updatedConfig);
    
    // Update server
    await this.apiClient.put(
      `/api/modules/${moduleId}/configuration`,
      updatedConfig
    );

    // Update local cache
    this.moduleConfigs.set(moduleId, updatedConfig);

    // Notify module of configuration change
    this.notifyModuleConfigurationUpdate(moduleId, updatedConfig);
  }

  private validateModuleConfiguration(
    config: ModuleConfiguration
  ): void {
    // Implement module configuration validation
    const schema = this.getModuleConfigurationSchema();
    const result = schema.validate(config);
    
    if (result.error) {
      throw new Error(
        `Invalid module configuration: ${result.error.message}`
      );
    }
  }

  private notifyConfigurationUpdates(): void {
    this.eventBus.emit('modules.configuration.updated', {
      timestamp: Date.now(),
      modules: Array.from(this.moduleConfigs.values())
    });
  }
}
```

### Environment-Specific Configuration

**USE** proper environment configuration patterns:

```typescript
// config/environment.config.ts
export type Environment = 'development' | 'staging' | 'production';

export interface EnvironmentConfig {
  name: Environment;
  api: ApiConfiguration;
  features: FeatureFlags;
  performance: PerformanceConfiguration;
  security: SecurityConfiguration;
  logging: LoggingConfiguration;
  analytics: AnalyticsConfiguration;
}

const environmentConfigurations: Record<Environment, EnvironmentConfig> = {
  development: {
    name: 'development',
    api: {
      baseUrl: 'https://dev-api.workforce.app',
      timeout: 30000,
      retryAttempts: 3,
      enableMocking: true
    },
    features: {
      debugMode: true,
      performanceMonitoring: true,
      analyticsEnabled: false,
      crashReporting: false,
      betaFeatures: true
    },
    performance: {
      enableProfiling: true,
      trackMemoryUsage: true,
      moduleLoadTimeout: 10000,
      cacheEnabled: false
    },
    security: {
      allowInsecureConnections: true,
      enableCertificatePinning: false,
      sessionTimeout: 3600000, // 1 hour
      enableBiometrics: false
    },
    logging: {
      level: 'debug',
      enableConsoleLogging: true,
      enableRemoteLogging: false,
      maxLogSize: 10485760 // 10MB
    },
    analytics: {
      enabled: false,
      sampleRate: 1.0,
      enableCrashReporting: false
    }
  },
  staging: {
    name: 'staging',
    api: {
      baseUrl: 'https://staging-api.workforce.app',
      timeout: 20000,
      retryAttempts: 2,
      enableMocking: false
    },
    features: {
      debugMode: false,
      performanceMonitoring: true,
      analyticsEnabled: true,
      crashReporting: true,
      betaFeatures: true
    },
    performance: {
      enableProfiling: false,
      trackMemoryUsage: true,
      moduleLoadTimeout: 8000,
      cacheEnabled: true
    },
    security: {
      allowInsecureConnections: false,
      enableCertificatePinning: true,
      sessionTimeout: 1800000, // 30 minutes
      enableBiometrics: true
    },
    logging: {
      level: 'info',
      enableConsoleLogging: false,
      enableRemoteLogging: true,
      maxLogSize: 5242880 // 5MB
    },
    analytics: {
      enabled: true,
      sampleRate: 0.1,
      enableCrashReporting: true
    }
  },
  production: {
    name: 'production',
    api: {
      baseUrl: 'https://api.workforce.app',
      timeout: 15000,
      retryAttempts: 2,
      enableMocking: false
    },
    features: {
      debugMode: false,
      performanceMonitoring: false,
      analyticsEnabled: true,
      crashReporting: true,
      betaFeatures: false
    },
    performance: {
      enableProfiling: false,
      trackMemoryUsage: false,
      moduleLoadTimeout: 5000,
      cacheEnabled: true
    },
    security: {
      allowInsecureConnections: false,
      enableCertificatePinning: true,
      sessionTimeout: 900000, // 15 minutes
      enableBiometrics: true
    },
    logging: {
      level: 'error',
      enableConsoleLogging: false,
      enableRemoteLogging: true,
      maxLogSize: 2097152 // 2MB
    },
    analytics: {
      enabled: true,
      sampleRate: 0.01,
      enableCrashReporting: true
    }
  }
};

## Configuration Validation and Schema

**IMPLEMENT** comprehensive configuration validation:

```typescript
// core/configuration/validation/configurationSchema.ts
import Joi from 'joi';

export const moduleConfigurationSchema = Joi.object({
  id: Joi.string().required(),
  name: Joi.string().required(),
  version: Joi.string().pattern(/^\d+\.\d+\.\d+$/).required(),
  enabled: Joi.boolean().required(),
  environments: Joi.array().items(
    Joi.string().valid('development', 'staging', 'production')
  ).required(),
  userTypes: Joi.array().items(Joi.string()).required(),
  dependencies: Joi.array().items(
    Joi.object({
      moduleId: Joi.string().required(),
      version: Joi.string().pattern(/^\d+\.\d+\.\d+$/).required(),
      required: Joi.boolean().default(true)
    })
  ).default([]),
  settings: Joi.object().default({}),
  performance: Joi.object({
    lazy: Joi.boolean().default(true),
    preload: Joi.boolean().default(false),
    timeout: Joi.number().min(1000).max(30000).default(5000),
    retryAttempts: Joi.number().min(0).max(5).default(3)
  }).default({}),
  security: Joi.object({
    requiresAuth: Joi.boolean().default(true),
    permissions: Joi.array().items(Joi.string()).default([]),
    encryptStorage: Joi.boolean().default(false)
  }).default({})
});

export const userTypeConfigurationSchema = Joi.object({
  id: Joi.string().required(),
  name: Joi.string().required(),
  permissions: Joi.array().items(
    Joi.object({
      id: Joi.string().required(),
      name: Joi.string().required(),
      description: Joi.string().optional()
    })
  ).required(),
  modules: Joi.array().items(
    Joi.object({
      moduleId: Joi.string().required(),
      enabled: Joi.boolean().required(),
      permissions: Joi.array().items(Joi.string()).default([]),
      settings: Joi.object().default({}),
      features: Joi.object().default({})
    })
  ).required(),
  ui: Joi.object({
    theme: Joi.string().required(),
    primaryColor: Joi.string().pattern(/^#[0-9A-F]{6}$/i).required(),
    secondaryColor: Joi.string().pattern(/^#[0-9A-F]{6}$/i).required(),
    navigationStyle: Joi.string().valid('tab', 'drawer', 'stack').required(),
    dashboardLayout: Joi.string().valid('grid', 'list', 'cards').required()
  }).required(),
  settings: Joi.object({
    defaultView: Joi.string().required(),
    autoLogout: Joi.number().min(5).max(480).required(),
    notifications: Joi.boolean().default(true)
  }).required()
});

export const enterpriseConfigurationSchema = Joi.object({
  version: Joi.string().pattern(/^\d+\.\d+\.\d+$/).required(),
  timestamp: Joi.number().required(),
  environment: Joi.string().valid('development', 'staging', 'production').required(),
  userTypes: Joi.array().items(userTypeConfigurationSchema).min(1).required(),
  modules: Joi.array().items(moduleConfigurationSchema).min(1).required(),
  features: Joi.object().default({}),
  security: Joi.object({
    sessionTimeout: Joi.number().min(300000).max(7200000).required(),
    enableBiometrics: Joi.boolean().default(false),
    requireStrongPassword: Joi.boolean().default(true),
    maxLoginAttempts: Joi.number().min(3).max(10).default(5)
  }).default({}),
  performance: Joi.object({
    enableCaching: Joi.boolean().default(true),
    cacheTimeout: Joi.number().min(60000).max(3600000).default(300000),
    enableProfiling: Joi.boolean().default(false),
    maxMemoryUsage: Joi.number().min(50).max(500).default(200)
  }).default({})
});
```

### Configuration Hot Updates

**IMPLEMENT** real-time configuration updates:

```typescript
// core/configuration/services/hotUpdateService.ts
export class ConfigurationHotUpdateService {
  private websocketConnection: WebSocket | null = null;
  private listeners: Map<string, Function[]> = new Map();
  private currentConfig: EnterpriseConfiguration | null = null;

  async initialize(userId: string, userType: string): Promise<void> {
    // Establish WebSocket connection for real-time updates
    await this.connectWebSocket(userId, userType);
    
    // Subscribe to configuration change events
    this.subscribeToConfigurationChanges();
    
    // Set up periodic configuration sync
    this.setupPeriodicSync();
  }

  private async connectWebSocket(
    userId: string, 
    userType: string
  ): Promise<void> {
    const wsUrl = `${this.getWebSocketUrl()}/configuration?userId=${userId}&userType=${userType}`;
    
    this.websocketConnection = new WebSocket(wsUrl);
    
    this.websocketConnection.onmessage = (event) => {
      this.handleConfigurationUpdate(JSON.parse(event.data));
    };

    this.websocketConnection.onclose = () => {
      console.log('Configuration WebSocket connection closed, attempting reconnect...');
      setTimeout(() => this.connectWebSocket(userId, userType), 5000);
    };

    this.websocketConnection.onerror = (error) => {
      console.error('Configuration WebSocket error:', error);
    };
  }

  private handleConfigurationUpdate(update: ConfigurationUpdate): void {
    try {
      // Validate configuration update
      const validatedUpdate = this.validateConfigurationUpdate(update);
      
      // Apply configuration update
      this.applyConfigurationUpdate(validatedUpdate);
      
      // Notify listeners
      this.notifyConfigurationChange(validatedUpdate);
      
      console.log('Configuration updated successfully:', validatedUpdate);
    } catch (error) {
      console.error('Failed to apply configuration update:', error);
    }
  }

  private applyConfigurationUpdate(update: ConfigurationUpdate): void {
    switch (update.type) {
      case 'module.enabled':
        this.updateModuleStatus(update.moduleId, update.enabled);
        break;
      case 'module.settings':
        this.updateModuleSettings(update.moduleId, update.settings);
        break;
      case 'userType.permissions':
        this.updateUserTypePermissions(update.userType, update.permissions);
        break;
      case 'feature.flag':
        this.updateFeatureFlag(update.featureId, update.enabled);
        break;
      default:
        console.warn('Unknown configuration update type:', update.type);
    }
  }

  subscribeToConfigurationChanges(
    callback: (update: ConfigurationUpdate) => void
  ): () => void {
    const eventType = 'configuration.updated';
    
    if (!this.listeners.has(eventType)) {
      this.listeners.set(eventType, []);
    }
    
    this.listeners.get(eventType)!.push(callback);
    
    // Return unsubscribe function
    return () => {
      const callbacks = this.listeners.get(eventType);
      if (callbacks) {
        const index = callbacks.indexOf(callback);
        if (index > -1) {
          callbacks.splice(index, 1);
        }
      }
    };
  }
}
```

### Configuration Examples

**USE** these configuration examples for enterprise applications:

```typescript
// Example: Workforce Management App Configuration
export const workforceManagementConfig: EnterpriseConfiguration = {
  version: "1.0.0",
  timestamp: Date.now(),
  environment: "production",
  userTypes: [
    {
      id: "employer",
      name: "Employer",
      permissions: [
        { id: "time.manage", name: "Manage Time Tracking" },
        { id: "schedule.create", name: "Create Schedules" },
        { id: "payroll.process", name: "Process Payroll" },
        { id: "analytics.view", name: "View Analytics" },
        { id: "employees.manage", name: "Manage Employees" }
      ],
      modules: [
        {
          moduleId: "timeTracking",
          enabled: true,
          permissions: ["time.manage", "time.approve"],
          settings: {
            autoClockOut: true,
            overtimeCalculation: "daily",
            breakDeductions: true,
            geoFencing: true
          },
          features: {
            bulkTimeEdit: true,
            timeSheetExport: true,
            realTimeTracking: true
          }
        },
        {
          moduleId: "scheduling",
          enabled: true,
          permissions: ["schedule.create", "schedule.assign"],
          settings: {
            autoAssignment: false,
            conflictResolution: "manual",
            advanceNotice: 168, // hours
            shiftSwapping: true
          },
          features: {
            dragDropScheduling: true,
            massScheduling: true,
            templateSchedules: true
          }
        },
        {
          moduleId: "payroll",
          enabled: true,
          permissions: ["payroll.process", "payroll.export"],
          settings: {
            payPeriod: "biweekly",
            overtimeThreshold: 40,
            taxCalculation: "automatic",
            directDeposit: true
          },
          features: {
            customDeductions: true,
            bonusCalculation: true,
            payStubGeneration: true
          }
        }
      ],
      ui: {
        theme: "employer",
        primaryColor: "#1F2937",
        secondaryColor: "#3B82F6",
        navigationStyle: "drawer",
        dashboardLayout: "grid"
      },
      settings: {
        defaultView: "dashboard",
        autoLogout: 30,
        notifications: true
      }
    },
    {
      id: "employee",
      name: "Employee",
      permissions: [
        { id: "time.track", name: "Track Time" },
        { id: "schedule.view", name: "View Schedule" },
        { id: "schedule.request", name: "Request Schedule Changes" },
        { id: "communication.send", name: "Send Messages" },
        { id: "profile.edit", name: "Edit Profile" }
      ],
      modules: [
        {
          moduleId: "timeTracking",
          enabled: true,
          permissions: ["time.track", "time.view"],
          settings: {
            autoClockOut: false,
            breakReminders: true,
            geoTracking: true
          },
          features: {
            quickClockIn: true,
            photoTimeStamp: false,
            offlineTracking: true
          }
        },
        {
          moduleId: "scheduling",
          enabled: true,
          permissions: ["schedule.view", "schedule.request"],
          settings: {
            viewAdvance: 336, // hours (2 weeks)
            requestAdvance: 72, // hours
            swapRequests: true
          },
          features: {
            availabilitySettings: true,
            shiftSwapRequests: true,
            scheduleNotifications: true
          }
        }
      ],
      ui: {
        theme: "employee",
        primaryColor: "#059669",
        secondaryColor: "#10B981",
        navigationStyle: "tab",
        dashboardLayout: "cards"
      },
      settings: {
        defaultView: "timeTracking",
        autoLogout: 60,
        notifications: true
      }
    }
  ],
  modules: [
    {
      id: "timeTracking",
      name: "Time Tracking",
      version: "1.2.0",
      enabled: true,
      environments: ["development", "staging", "production"],
      userTypes: ["employer", "employee"],
      dependencies: [],
      settings: {
        precision: "minute",
        timezone: "automatic",
        rounding: "nearest_quarter"
      },
      performance: {
        lazy: true,
        preload: false,
        timeout: 5000,
        retryAttempts: 3
      },
      security: {
        requiresAuth: true,
        permissions: ["time.track", "time.manage"],
        encryptStorage: true
      }
    },
    {
      id: "scheduling",
      name: "Scheduling",
      version: "1.1.0",
      enabled: true,
      environments: ["development", "staging", "production"],
      userTypes: ["employer", "employee"],
      dependencies: ["timeTracking"],
      settings: {
        weekStart: "monday",
        timeFormat: "24h",
        conflictDetection: true
      },
      performance: {
        lazy: true,
        preload: true,
        timeout: 8000,
        retryAttempts: 2
      },
      security: {
        requiresAuth: true,
        permissions: ["schedule.view", "schedule.create"],
        encryptStorage: false
      }
    }
  ],
  features: {
    analytics: true,
    pushNotifications: true,
    biometricAuth: true,
    offlineMode: true,
    darkMode: true
  },
  security: {
    sessionTimeout: 1800000, // 30 minutes
    enableBiometrics: true,
    requireStrongPassword: true,
    maxLoginAttempts: 5
  },
  performance: {
    enableCaching: true,
    cacheTimeout: 300000, // 5 minutes
    enableProfiling: false,
    maxMemoryUsage: 200 // MB
  }
};
```

## Anti-Patterns

**DON'T** implement these configuration approaches:

### Configuration Anti-Patterns

- **NEVER** store sensitive configuration data in client-side code
- **AVOID** hardcoding user permissions or module access in the application
- **DON'T** implement configuration without proper validation schemas
- **NEVER** ignore configuration update failures without proper error handling
- **AVOID** configuration caching without proper invalidation strategies
- **DON'T** implement configuration without proper fallback mechanisms
- **NEVER** allow configuration changes without proper authorization
- **AVOID** configuration updates that don't support rollback

### Security Anti-Patterns

- **NEVER** expose configuration management APIs without proper authentication
- **AVOID** storing configuration in plain text on device storage
- **DON'T** implement configuration without proper audit logging
- **NEVER** allow client-side modification of security-critical configurations
- **AVOID** configuration transmission without proper encryption

## Validation Checklist

**MUST** verify these configuration requirements:

### Configuration Management
- [ ] Server-driven configuration is implemented and tested
- [ ] Configuration validation schemas are comprehensive
- [ ] Hot configuration updates work without app restart
- [ ] Configuration fallback mechanisms are tested
- [ ] Configuration caching and synchronization work properly

### Security Validation
- [ ] Sensitive configuration is properly protected
- [ ] Configuration access is properly authorized
- [ ] Configuration changes are properly audited
- [ ] Configuration transmission is encrypted
- [ ] Configuration storage follows security best practices

### Performance Validation
- [ ] Configuration loading doesn't block app startup
- [ ] Configuration caching improves performance
- [ ] Configuration updates are applied efficiently
- [ ] Memory usage is optimized for configuration storage

## References

- [Server-Driven UI Architecture](https://engineering.fb.com/2021/08/26/android/server-driven-ui/)
- [Configuration Management Best Practices](https://12factor.net/config)
- [Feature Flag Implementation Patterns](https://martinfowler.com/articles/feature-toggles.html)
- [Enterprise Security Configuration](https://owasp.org/www-project-application-security-verification-standard/)
```
  
  // Logging
  logLevel: 'debug' | 'info' | 'warn' | 'error';
  enableNetworkLogging: boolean;
  enableCrashReporting: boolean;
  
  // Performance
  enablePerformanceMonitoring: boolean;
  maxImageCacheSize: number;
  enableCodePush: boolean;
  
  // Security
  certificatePinning: boolean;
  biometricAuthEnabled: boolean;
  encryptionEnabled: boolean;
}

// Configuration validation schema
const configSchema = {
  apiBaseUrl: (value: string) => {
    if (!value || !value.startsWith('http')) {
      throw new Error('Invalid API base URL');
    }
    return value;
  },
  
  apiTimeout: (value: string) => {
    const timeout = parseInt(value, 10);
    if (isNaN(timeout) || timeout < 1000) {
      throw new Error('API timeout must be at least 1000ms');
    }
    return timeout;
  },
  
  logLevel: (value: string) => {
    const validLevels = ['debug', 'info', 'warn', 'error'];
    if (!validLevels.includes(value)) {
      throw new Error(`Invalid log level. Must be one of: ${validLevels.join(', ')}`);
    }
    return value as AppConfig['logLevel'];
  },
};

// Configuration factory
class ConfigManager {
  private static instance: ConfigManager;
  private config: AppConfig;

  private constructor() {
    this.config = this.createConfig();
    this.validateConfig();
  }

  static getInstance(): ConfigManager {
    if (!ConfigManager.instance) {
      ConfigManager.instance = new ConfigManager();
    }
    return ConfigManager.instance;
  }

  private createConfig(): AppConfig {
    const environment = (Config.ENVIRONMENT || 'development') as Environment;
    
    return {
      // Environment
      environment,
      isDevelopment: environment === 'development',
      isStaging: environment === 'staging',
      isProduction: environment === 'production',
      
      // API Configuration
      apiBaseUrl: configSchema.apiBaseUrl(
        Config.API_BASE_URL || this.getDefaultApiUrl(environment)
      ),
      apiTimeout: configSchema.apiTimeout(Config.API_TIMEOUT || '30000'),
      apiRetryAttempts: parseInt(Config.API_RETRY_ATTEMPTS || '3', 10),
      
      // Authentication
      authTokenKey: Config.AUTH_TOKEN_KEY || 'authToken',
      refreshTokenKey: Config.REFRESH_TOKEN_KEY || 'refreshToken',
      authTimeout: parseInt(Config.AUTH_TIMEOUT || '900000', 10), // 15 minutes
      
      // Feature Flags
      features: {
        analytics: Config.ENABLE_ANALYTICS === 'true',
        crashReporting: Config.ENABLE_CRASH_REPORTING === 'true',
        debugMode: environment === 'development' || Config.DEBUG_MODE === 'true',
        betaFeatures: Config.ENABLE_BETA_FEATURES === 'true',
      },
      
      // Logging
      logLevel: configSchema.logLevel(
        Config.LOG_LEVEL || (environment === 'production' ? 'error' : 'debug')
      ),
      enableNetworkLogging: environment !== 'production' && Config.ENABLE_NETWORK_LOGGING !== 'false',
      enableCrashReporting: Config.ENABLE_CRASH_REPORTING === 'true',
      
      // Performance
      enablePerformanceMonitoring: Config.ENABLE_PERFORMANCE_MONITORING === 'true',
      maxImageCacheSize: parseInt(Config.MAX_IMAGE_CACHE_SIZE || '100', 10),
      enableCodePush: environment !== 'development' && Config.ENABLE_CODE_PUSH === 'true',
      
      // Security
      certificatePinning: environment === 'production' || Config.ENABLE_CERT_PINNING === 'true',
      biometricAuthEnabled: Config.ENABLE_BIOMETRIC_AUTH === 'true',
      encryptionEnabled: Config.ENABLE_ENCRYPTION !== 'false',
    };
  }

  private getDefaultApiUrl(environment: Environment): string {
    switch (environment) {
      case 'production':
        return 'https://api.yourapp.com';
      case 'staging':
        return 'https://staging-api.yourapp.com';
      default:
        return 'https://dev-api.yourapp.com';
    }
  }

  private validateConfig(): void {
    try {
      // Validate required configurations
      if (!this.config.apiBaseUrl) {
        throw new Error('API base URL is required');
      }
      
      if (this.config.apiTimeout < 1000) {
        throw new Error('API timeout must be at least 1000ms');
      }
      
      // Log configuration in development
      if (this.config.isDevelopment) {
        console.log('App Configuration:', {
          environment: this.config.environment,
          apiBaseUrl: this.config.apiBaseUrl,
          features: this.config.features,
          logLevel: this.config.logLevel,
        });
      }
    } catch (error) {
      console.error('Configuration validation failed:', error);
      throw error;
    }
  }

  getConfig(): AppConfig {
    return { ...this.config };
  }

  updateConfig(updates: Partial<AppConfig>): void {
    this.config = { ...this.config, ...updates };
    this.validateConfig();
  }

  // Feature flag helpers
  isFeatureEnabled(feature: keyof AppConfig['features']): boolean {
    return this.config.features[feature] || false;
  }

  // Environment helpers
  getApiUrl(endpoint: string): string {
    return `${this.config.apiBaseUrl}${endpoint.startsWith('/') ? '' : '/'}${endpoint}`;
  }
}

export const appConfig = ConfigManager.getInstance().getConfig();
export const configManager = ConfigManager.getInstance();
```

### Build Configuration

**IMPLEMENT** proper build configuration for different platforms and environments:

```javascript
// metro.config.js
const { getDefaultConfig } = require('metro-config');

module.exports = (async () => {
  const {
    resolver: { sourceExts, assetExts },
  } = await getDefaultConfig();

  return {
    transformer: {
      babelTransformerPath: require.resolve('react-native-svg-transformer'),
      getTransformOptions: async () => ({
        transform: {
          experimentalImportSupport: false,
          inlineRequires: true,
        },
      }),
    },
    resolver: {
      assetExts: assetExts.filter(ext => ext !== 'svg'),
      sourceExts: [...sourceExts, 'svg'],
      alias: {
        '@components': './src/components',
        '@screens': './src/screens',
        '@services': './src/services',
        '@utils': './src/utils',
        '@assets': './src/assets',
        '@config': './src/config',
        '@hooks': './src/hooks',
        '@navigation': './src/navigation',
        '@store': './src/store',
        '@types': './src/types',
      },
    },
  };
})();

// babel.config.js
module.exports = {
  presets: ['module:metro-react-native-babel-preset'],
  plugins: [
    ['react-native-reanimated/plugin'],
    [
      'module-resolver',
      {
        root: ['./src'],
        alias: {
          '@components': './src/components',
          '@screens': './src/screens',
          '@services': './src/services',
          '@utils': './src/utils',
          '@assets': './src/assets',
          '@config': './src/config',
          '@hooks': './src/hooks',
          '@navigation': './src/navigation',
          '@store': './src/store',
          '@types': './src/types',
        },
      },
    ],
    ['react-native-config', {
      'module-name': 'react-native-config',
      'generate-env-d-ts': true,
    }],
  ],
  env: {
    production: {
      plugins: ['react-native-paper/babel'],
    },
  },
};
```

### Environment-Specific Configuration Files

**CREATE** environment-specific configuration files:

```bash
# .env.development
ENVIRONMENT=development
API_BASE_URL=https://dev-api.yourapp.com
API_TIMEOUT=30000
API_RETRY_ATTEMPTS=3

# Logging
LOG_LEVEL=debug
ENABLE_NETWORK_LOGGING=true

# Features
ENABLE_ANALYTICS=false
ENABLE_CRASH_REPORTING=false
DEBUG_MODE=true
ENABLE_BETA_FEATURES=true

# Performance
ENABLE_PERFORMANCE_MONITORING=false
MAX_IMAGE_CACHE_SIZE=50
ENABLE_CODE_PUSH=false

# Security
ENABLE_CERT_PINNING=false
ENABLE_BIOMETRIC_AUTH=true
ENABLE_ENCRYPTION=true

# .env.staging
ENVIRONMENT=staging
API_BASE_URL=https://staging-api.yourapp.com
API_TIMEOUT=20000
API_RETRY_ATTEMPTS=3

# Logging
LOG_LEVEL=info
ENABLE_NETWORK_LOGGING=false

# Features
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
DEBUG_MODE=false
ENABLE_BETA_FEATURES=true

# Performance
ENABLE_PERFORMANCE_MONITORING=true
MAX_IMAGE_CACHE_SIZE=75
ENABLE_CODE_PUSH=true

# Security
ENABLE_CERT_PINNING=true
ENABLE_BIOMETRIC_AUTH=true
ENABLE_ENCRYPTION=true

# .env.production
ENVIRONMENT=production
API_BASE_URL=https://api.yourapp.com
API_TIMEOUT=15000
API_RETRY_ATTEMPTS=2

# Logging
LOG_LEVEL=error
ENABLE_NETWORK_LOGGING=false

# Features
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
DEBUG_MODE=false
ENABLE_BETA_FEATURES=false

# Performance
ENABLE_PERFORMANCE_MONITORING=true
MAX_IMAGE_CACHE_SIZE=100
ENABLE_CODE_PUSH=true

# Security
ENABLE_CERT_PINNING=true
ENABLE_BIOMETRIC_AUTH=true
ENABLE_ENCRYPTION=true
```

### Feature Flag Management

**IMPLEMENT** feature flag system:

```typescript
// services/FeatureFlagService.ts
import { appConfig } from '@config/env';
import AsyncStorage from '@react-native-async-storage/async-storage';

export interface FeatureFlags {
  // UI Features
  newDashboard: boolean;
  darkMode: boolean;
  advancedFilters: boolean;
  
  // Functionality Features
  offlineSync: boolean;
  pushNotifications: boolean;
  socialLogin: boolean;
  
  // Experimental Features
  betaFeatures: boolean;
  experimentalUI: boolean;
  newNavigation: boolean;
}

export class FeatureFlagService {
  private static instance: FeatureFlagService;
  private flags: FeatureFlags;
  private remoteFlags: Partial<FeatureFlags> = {};

  private constructor() {
    this.flags = this.getDefaultFlags();
    this.loadRemoteFlags();
  }

  static getInstance(): FeatureFlagService {
    if (!FeatureFlagService.instance) {
      FeatureFlagService.instance = new FeatureFlagService();
    }
    return FeatureFlagService.instance;
  }

  private getDefaultFlags(): FeatureFlags {
    return {
      // UI Features
      newDashboard: appConfig.features.betaFeatures,
      darkMode: true,
      advancedFilters: false,
      
      // Functionality Features
      offlineSync: true,
      pushNotifications: true,
      socialLogin: !appConfig.isProduction,
      
      // Experimental Features
      betaFeatures: appConfig.features.betaFeatures,
      experimentalUI: appConfig.isDevelopment,
      newNavigation: appConfig.features.betaFeatures,
    };
  }

  private async loadRemoteFlags(): Promise<void> {
    try {
      // Load from local storage first
      const localFlags = await AsyncStorage.getItem('featureFlags');
      if (localFlags) {
        this.remoteFlags = JSON.parse(localFlags);
        this.updateFlags();
      }

      // Then fetch from remote (if in production)
      if (appConfig.isProduction) {
        await this.fetchRemoteFlags();
      }
    } catch (error) {
      console.warn('Failed to load feature flags:', error);
    }
  }

  private async fetchRemoteFlags(): Promise<void> {
    try {
      const response = await fetch(`${appConfig.apiBaseUrl}/feature-flags`);
      const remoteFlags = await response.json();
      
      this.remoteFlags = remoteFlags;
      await AsyncStorage.setItem('featureFlags', JSON.stringify(remoteFlags));
      this.updateFlags();
    } catch (error) {
      console.warn('Failed to fetch remote feature flags:', error);
    }
  }

  private updateFlags(): void {
    this.flags = {
      ...this.getDefaultFlags(),
      ...this.remoteFlags,
    };
  }

  isEnabled(flag: keyof FeatureFlags): boolean {
    return this.flags[flag] || false;
  }

  getAllFlags(): FeatureFlags {
    return { ...this.flags };
  }

  async updateFlag(flag: keyof FeatureFlags, enabled: boolean): Promise<void> {
    this.flags[flag] = enabled;
    
    // Save to local storage for development
    if (appConfig.isDevelopment) {
      const currentLocal = await AsyncStorage.getItem('localFeatureFlags') || '{}';
      const localFlags = JSON.parse(currentLocal);
      localFlags[flag] = enabled;
      await AsyncStorage.setItem('localFeatureFlags', JSON.stringify(localFlags));
    }
  }

  async refresh(): Promise<void> {
    await this.fetchRemoteFlags();
  }
}

export const featureFlagService = FeatureFlagService.getInstance();

// React hook for feature flags
import { useState, useEffect } from 'react';

export const useFeatureFlag = (flag: keyof FeatureFlags): boolean => {
  const [isEnabled, setIsEnabled] = useState(featureFlagService.isEnabled(flag));

  useEffect(() => {
    const checkFlag = () => {
      setIsEnabled(featureFlagService.isEnabled(flag));
    };

    // Check immediately
    checkFlag();

    // Set up periodic refresh in development
    let interval: NodeJS.Timeout;
    if (appConfig.isDevelopment) {
      interval = setInterval(checkFlag, 5000);
    }

    return () => {
      if (interval) {
        clearInterval(interval);
      }
    };
  }, [flag]);

  return isEnabled;
};
```

### Configuration Testing

**CREATE** configuration testing utilities:

```typescript
// __tests__/config/ConfigManager.test.ts
import { ConfigManager } from '@config/env';

describe('ConfigManager', () => {
  let configManager: ConfigManager;

  beforeEach(() => {
    // Reset singleton
    (ConfigManager as any).instance = undefined;
    configManager = ConfigManager.getInstance();
  });

  describe('Environment Configuration', () => {
    it('should load development configuration correctly', () => {
      process.env.ENVIRONMENT = 'development';
      const config = configManager.getConfig();
      
      expect(config.environment).toBe('development');
      expect(config.isDevelopment).toBe(true);
      expect(config.features.debugMode).toBe(true);
    });

    it('should load production configuration correctly', () => {
      process.env.ENVIRONMENT = 'production';
      const config = configManager.getConfig();
      
      expect(config.environment).toBe('production');
      expect(config.isProduction).toBe(true);
      expect(config.features.debugMode).toBe(false);
    });
  });

  describe('Configuration Validation', () => {
    it('should validate API URL format', () => {
      expect(() => {
        process.env.API_BASE_URL = 'invalid-url';
        ConfigManager.getInstance();
      }).toThrow('Invalid API base URL');
    });

    it('should validate API timeout', () => {
      expect(() => {
        process.env.API_TIMEOUT = '500';
        ConfigManager.getInstance();
      }).toThrow('API timeout must be at least 1000ms');
    });
  });

  describe('Feature Flags', () => {
    it('should enable beta features in development', () => {
      process.env.ENVIRONMENT = 'development';
      const config = configManager.getConfig();
      
      expect(config.features.betaFeatures).toBe(true);
    });

    it('should disable beta features in production', () => {
      process.env.ENVIRONMENT = 'production';
      process.env.ENABLE_BETA_FEATURES = 'false';
      const config = configManager.getConfig();
      
      expect(config.features.betaFeatures).toBe(false);
    });
  });
});
```

## Anti-Patterns

### **DON'T** implement these configuration anti-patterns

**AVOID** hardcoding configuration values:

```typescript
// ❌ Bad: Hardcoded values
const API_URL = 'https://api.example.com';
const TIMEOUT = 30000;

// ✅ Good: Environment-based configuration
const API_URL = appConfig.apiBaseUrl;
const TIMEOUT = appConfig.apiTimeout;
```

**NEVER** commit sensitive configuration:

```bash
# ❌ Bad: Committing secrets
# .env
API_KEY=secret_key_12345
DATABASE_PASSWORD=super_secret_password

# ✅ Good: Using environment variables
# .env.example
API_KEY=your_api_key_here
DATABASE_PASSWORD=your_database_password
```

**DON'T** skip configuration validation:

```typescript
// ❌ Bad: No validation
const config = {
  apiUrl: process.env.API_URL,
  timeout: process.env.TIMEOUT,
};

// ✅ Good: Proper validation
const config = configManager.getConfig(); // Validates automatically
```

## Validation Checklist

### **MUST** verify

- [ ] Environment variables are properly configured for all environments
- [ ] Sensitive configuration values are not committed to version control
- [ ] Configuration validation is implemented and working
- [ ] Build configuration is optimized for each environment
- [ ] Feature flags are properly implemented and tested
- [ ] Configuration changes don't break application startup
- [ ] API endpoints are correctly configured for each environment
- [ ] Logging levels are appropriate for each environment

### **SHOULD** check

- [ ] Configuration hot reloading works in development
- [ ] Configuration monitoring and alerting is set up
- [ ] Configuration versioning is implemented
- [ ] Configuration rollback mechanisms are available
- [ ] Remote configuration management is considered
- [ ] Configuration documentation is comprehensive
- [ ] Configuration testing covers all scenarios
- [ ] Performance impact of configuration loading is minimal

## References

- [React Native Config](https://github.com/luggit/react-native-config)
- [Environment Variables Best Practices](https://12factor.net/config)
- [React Native Environment Setup](https://reactnative.dev/docs/environment-setup)
- [Metro Configuration](https://metrobundler.dev/docs/configuration)
- [Babel Configuration](https://babeljs.io/docs/en/configuration)
