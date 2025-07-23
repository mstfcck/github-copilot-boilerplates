---
applyTo: '**'
---

# Configuration Instructions

This document outlines environment configuration, build settings, and project configuration management for React Native applications. It covers development, staging, and production environments with proper security and performance configurations.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** implement proper environment variable management with secure storage
- **REQUIRED** to separate configuration for development, staging, and production environments
- **SHALL** implement proper API endpoint configuration with environment switching
- **MUST** secure sensitive configuration values and never commit secrets
- **NEVER** hardcode environment-specific values in source code
- **REQUIRED** to implement proper build configuration for different environments
- **SHALL** implement proper logging configuration with environment-based levels
- **MUST** implement proper feature flag management system
- **REQUIRED** to implement proper app configuration validation
- **SHALL** handle configuration errors gracefully with fallback mechanisms

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** use centralized configuration management system
- **RECOMMENDED** to implement configuration hot reloading for development
- **ALWAYS** validate configuration values at application startup
- **DO** implement configuration schema validation
- **SHOULD** use type-safe configuration interfaces
- **RECOMMENDED** to implement configuration monitoring and alerting
- **DO** implement proper configuration versioning
- **ALWAYS** document all configuration options and their purposes
- **SHOULD** implement configuration testing and validation pipelines

### Optional Enhancements (**MAY** Consider)

- **MAY** implement remote configuration management
- **OPTIONAL** to use configuration as code approaches
- **USE** configuration management tools for complex deployments
- **IMPLEMENT** configuration rollback mechanisms
- **AVOID** over-engineering configuration for simple applications

## Implementation Guidance

### Environment Configuration Management

**USE** proper environment configuration patterns:

```typescript
// config/env.ts
import { Platform } from 'react-native';
import Config from 'react-native-config';

export type Environment = 'development' | 'staging' | 'production';

export interface AppConfig {
  // Environment
  environment: Environment;
  isDevelopment: boolean;
  isStaging: boolean;
  isProduction: boolean;
  
  // API Configuration
  apiBaseUrl: string;
  apiTimeout: number;
  apiRetryAttempts: number;
  
  // Authentication
  authTokenKey: string;
  refreshTokenKey: string;
  authTimeout: number;
  
  // Feature Flags
  features: {
    analytics: boolean;
    crashReporting: boolean;
    debugMode: boolean;
    betaFeatures: boolean;
  };
  
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
