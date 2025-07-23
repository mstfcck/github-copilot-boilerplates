---
applyTo: '**'
---

# Enterprise Architecture Instructions

This document outlines architectural patterns, modular design principles, and implementation guidelines for enterprise-level React Native applications with dynamic module configuration and multi-user-type support.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** implement modular architecture with runtime configuration-based activation
- **REQUIRED** to support multiple user types with role-based module access
- **SHALL** implement lazy loading and performance-optimized module activation
- **MUST** separate business logic from presentation using clean architecture principles
- **NEVER** hardcode module configurations - all modules must be server-configurable
- **REQUIRED** to implement proper module dependency management and isolation
- **SHALL** use TypeScript strict mode with comprehensive type safety
- **MUST** implement proper error boundaries and module failure isolation
- **REQUIRED** to follow the specified enterprise folder structure exactly
- **SHALL** implement proper module lifecycle management (activate/deactivate)

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** implement module caching and preloading strategies for performance
- **RECOMMENDED** to use micro-frontend patterns for large module isolation
- **ALWAYS** implement proper module configuration validation
- **DO** implement module health monitoring and performance tracking
- **SHOULD** use dependency injection for module service management
- **RECOMMENDED** to implement module hot-swapping capabilities
- **DO** implement proper module state isolation and communication
- **ALWAYS** implement comprehensive logging and monitoring per module
- **SHOULD** implement module-specific analytics and usage tracking

### Optional Enhancements (**MAY** Consider)

- **MAY** implement A/B testing framework for module features
- **OPTIONAL** to use module federation for advanced modular architecture
- **USE** advanced caching strategies for module assets and data
- **IMPLEMENT** module update mechanisms without app store releases
- **AVOID** over-engineering simple modules with unnecessary complexity

## Enterprise Application Architecture Overview

**MUST** follow this enterprise architecture pattern:

```typescript
// Enterprise App Structure
interface EnterpriseApp {
  core: CoreSystem;           // Authentication, navigation, config management
  modules: ModuleRegistry;    // Dynamic module system
  userTypes: UserTypeSystem;  // Role-based access and UI variations
  configuration: ConfigurationManager; // Server-driven configuration
}

// User Type System
interface UserType {
  id: string;
  name: string;
  permissions: Permission[];
  availableModules: ModuleConfig[];
  ui: UserInterface;
}

// Module System
interface Module {
  id: string;
  name: string;
  version: string;
  dependencies: string[];
  userTypes: string[];
  screens: Screen[];
  services: Service[];
  assets: Asset[];
}
```

## Mandatory Enterprise React Native Folder Structure

```text
enterprise-react-native-app/
├── android/                       # Android native platform
│   ├── app/                       # Android application module
│   │   ├── src/
│   │   │   ├── main/
│   │   │   │   ├── java/com/enterpriseapp/        # Java/Kotlin source
│   │   │   │   │   ├── modules/                   # Custom native modules
│   │   │   │   │   │   ├── biometrics/           # Biometric authentication
│   │   │   │   │   │   ├── camera/               # Camera integration
│   │   │   │   │   │   ├── security/             # Security modules
│   │   │   │   │   │   └── analytics/            # Native analytics
│   │   │   │   │   ├── utils/                    # Android utilities
│   │   │   │   │   └── MainApplication.java      # Application entry
│   │   │   │   ├── res/                          # Android resources
│   │   │   │   │   ├── drawable/                 # Drawable resources
│   │   │   │   │   ├── layout/                   # Layout files
│   │   │   │   │   ├── values/                   # Values (strings, colors)
│   │   │   │   │   └── xml/                      # XML configurations
│   │   │   │   └── AndroidManifest.xml           # App manifest
│   │   │   ├── debug/                            # Debug configurations
│   │   │   └── release/                          # Release configurations
│   │   ├── build.gradle                          # App build configuration
│   │   └── proguard-rules.pro                    # ProGuard rules
│   ├── gradle/                                   # Gradle wrapper
│   ├── build.gradle                              # Project build config
│   ├── settings.gradle                           # Project settings
│   └── gradle.properties                         # Gradle properties
├── ios/                           # iOS native platform
│   ├── EnterpriseApp/             # iOS application target
│   │   ├── AppDelegate.h/.m       # App delegate
│   │   ├── Info.plist             # App configuration
│   │   ├── LaunchScreen.storyboard # Launch screen
│   │   ├── main.m                 # Entry point
│   │   ├── Images.xcassets        # Image assets
│   │   └── NativeModules/         # Custom native modules
│   │       ├── BiometricsModule.h/.m    # Biometric authentication
│   │       ├── CameraModule.h/.m        # Camera integration
│   │       ├── SecurityModule.h/.m      # Security modules
│   │       └── AnalyticsModule.h/.m     # Native analytics
│   ├── EnterpriseApp.xcodeproj/   # Xcode project
│   ├── EnterpriseApp.xcworkspace/ # Xcode workspace
│   ├── Podfile                    # CocoaPods dependencies
│   └── Podfile.lock              # Locked dependencies
├── src/                          # React Native source code
│   ├── core/                     # Core enterprise systems
│   │   ├── moduleSystem/         # Dynamic module management
│   │   │   ├── registry/         # Module registry and loader
│   │   │   ├── lifecycle/        # Module lifecycle management
│   │   │   ├── communication/    # Inter-module communication
│   │   │   └── validation/       # Module validation and integrity
│   │   ├── userTypes/            # User type management
│   │   │   ├── services/         # User type services
│   │   │   ├── permissions/      # Permission management
│   │   │   └── ui/               # User-specific UI configurations
│   │   ├── configuration/        # Server-driven configuration
│   │   │   ├── services/         # Configuration services
│   │   │   ├── validation/       # Configuration validation
│   │   │   └── cache/            # Configuration caching
│   │   ├── api/                  # API layer and networking
│   │   │   ├── clients/          # HTTP clients
│   │   │   ├── interceptors/     # Request/response interceptors
│   │   │   └── cache/            # API response caching
│   │   ├── state/                # Enterprise state management
│   │   │   ├── stores/           # Zustand stores
│   │   │   ├── queries/          # TanStack Query setup
│   │   │   ├── realtime/         # WebSocket and real-time state
│   │   │   └── offline/          # Offline state synchronization
│   │   ├── auth/                 # Authentication system
│   │   │   ├── services/         # Auth services
│   │   │   ├── providers/        # Auth providers
│   │   │   ├── biometrics/       # Biometric authentication
│   │   │   └── guards/           # Route guards
│   │   ├── navigation/           # Navigation system
│   │   │   ├── navigators/       # Navigation configurations
│   │   │   ├── guards/           # Navigation guards
│   │   │   ├── params/           # Navigation parameter types
│   │   │   └── deepLinking/      # Deep linking configuration
│   │   ├── device/               # Device integration layer
│   │   │   ├── camera/           # Camera services
│   │   │   ├── location/         # GPS and location services
│   │   │   ├── sensors/          # Device sensors
│   │   │   ├── notifications/    # Push notifications
│   │   │   ├── storage/          # Secure storage (Keychain/Keystore)
│   │   │   ├── network/          # Network connectivity
│   │   │   └── permissions/      # Runtime permissions
│   │   ├── security/             # Security layer
│   │   │   ├── encryption/       # Data encryption
│   │   │   ├── certificates/     # Certificate pinning
│   │   │   ├── keychain/         # Keychain/Keystore management
│   │   │   └── biometrics/       # Biometric security
│   │   ├── performance/          # Performance monitoring
│   │   │   ├── monitoring/       # Performance monitoring
│   │   │   ├── analytics/        # Analytics integration
│   │   │   ├── profiling/        # Performance profiling
│   │   │   ├── memory/           # Memory management
│   │   │   └── battery/          # Battery optimization
│   │   └── platform/             # Platform abstraction layer
│   │       ├── interfaces/       # Platform interfaces
│   │       ├── android/          # Android-specific implementations
│   │       ├── ios/              # iOS-specific implementations
│   │       └── common/           # Cross-platform implementations
│   ├── modules/                  # Business modules (dynamically loaded)
│   │   ├── timeTracking/         # Time tracking module
│   │   │   ├── screens/          # Time tracking screens
│   │   │   │   ├── TimeTrackingScreen.tsx
│   │   │   │   ├── TimeTrackingScreen.android.tsx    # Android-specific
│   │   │   │   └── TimeTrackingScreen.ios.tsx        # iOS-specific
│   │   │   ├── components/       # Module-specific components
│   │   │   │   ├── TimeClock/
│   │   │   │   ├── TimeEntry/
│   │   │   │   └── TimeReport/
│   │   │   ├── services/         # Time tracking services
│   │   │   │   ├── timeTrackingService.ts
│   │   │   │   ├── timeTrackingService.android.ts
│   │   │   │   └── timeTrackingService.ios.ts
│   │   │   ├── hooks/            # Module-specific hooks
│   │   │   ├── types/            # Time tracking types
│   │   │   ├── store/            # Module state management
│   │   │   ├── assets/           # Module assets
│   │   │   └── native/           # Native module bridge
│   │   │       ├── TimeTrackingModule.android.ts
│   │   │       └── TimeTrackingModule.ios.ts
│   │   ├── scheduling/           # Employee scheduling module
│   │   │   ├── screens/
│   │   │   ├── components/
│   │   │   ├── services/
│   │   │   ├── hooks/
│   │   │   ├── types/
│   │   │   ├── store/
│   │   │   ├── assets/
│   │   │   └── native/
│   │   ├── payroll/              # Payroll processing module
│   │   │   ├── screens/
│   │   │   ├── components/
│   │   │   ├── services/
│   │   │   ├── hooks/
│   │   │   ├── types/
│   │   │   ├── store/
│   │   │   ├── assets/
│   │   │   └── native/
│   │   ├── communication/        # Team communication module
│   │   │   ├── screens/
│   │   │   ├── components/
│   │   │   ├── services/
│   │   │   ├── hooks/
│   │   │   ├── types/
│   │   │   ├── store/
│   │   │   ├── assets/
│   │   │   └── native/
│   │   ├── analytics/            # Business analytics module
│   │   │   ├── screens/
│   │   │   ├── components/
│   │   │   ├── services/
│   │   │   ├── hooks/
│   │   │   ├── types/
│   │   │   ├── store/
│   │   │   ├── assets/
│   │   │   └── native/
│   │   └── profile/              # User profile management
│   │       ├── screens/
│   │       ├── components/
│   │       ├── services/
│   │       ├── hooks/
│   │       ├── types/
│   │       ├── store/
│   │       ├── assets/
│   │       └── native/
│   ├── shared/                   # Shared components and utilities
│   │   ├── components/           # Reusable UI components
│   │   │   ├── ui/               # Basic UI components
│   │   │   │   ├── Button/
│   │   │   │   │   ├── Button.tsx
│   │   │   │   │   ├── Button.android.tsx
│   │   │   │   │   └── Button.ios.tsx
│   │   │   │   ├── Input/
│   │   │   │   ├── Modal/
│   │   │   │   └── SafeArea/
│   │   │   ├── forms/            # Form components
│   │   │   ├── layout/           # Layout components
│   │   │   ├── feedback/         # Loading, error, success components
│   │   │   └── platform/         # Platform-specific components
│   │   │       ├── android/      # Material Design components
│   │   │       └── ios/          # iOS Human Interface components
│   │   ├── hooks/                # Shared custom hooks
│   │   │   ├── device/           # Device-related hooks
│   │   │   ├── platform/         # Platform-specific hooks
│   │   │   └── common/           # Common hooks
│   │   ├── utils/                # Utility functions
│   │   │   ├── platform/         # Platform utilities
│   │   │   ├── device/           # Device utilities
│   │   │   ├── security/         # Security utilities
│   │   │   └── performance/      # Performance utilities
│   │   ├── constants/            # Application constants
│   │   │   ├── platform.ts       # Platform constants
│   │   │   ├── device.ts         # Device constants
│   │   │   └── common.ts         # Common constants
│   │   ├── types/                # Shared TypeScript types
│   │   │   ├── platform/         # Platform-specific types
│   │   │   ├── device/           # Device-related types
│   │   │   └── common/           # Common types
│   │   ├── assets/               # Shared assets
│   │   │   ├── images/           # Images
│   │   │   │   ├── android/      # Android-specific images
│   │   │   │   └── ios/          # iOS-specific images
│   │   │   ├── fonts/            # Fonts
│   │   │   ├── icons/            # Icons
│   │   │   └── animations/       # Lottie animations
│   │   └── themes/               # Theme definitions
│   │       ├── light/            # Light theme
│   │       ├── dark/             # Dark theme
│   │       ├── android/          # Material Design theme
│   │       └── ios/              # iOS theme
│   ├── types/                    # Global TypeScript definitions
│   │   ├── global.d.ts           # Global declarations
│   │   ├── navigation.d.ts       # Navigation types
│   │   ├── platform.d.ts         # Platform types
│   │   └── modules.d.ts          # Module types
│   └── assets/                   # Global application assets
│       ├── images/               # Global images
│       ├── fonts/                # Global fonts
│       ├── sounds/               # Sound files
│       └── data/                 # Static data files
├── __tests__/                    # Test files
│   ├── core/                     # Core system tests
│   │   ├── moduleSystem/
│   │   ├── device/
│   │   ├── security/
│   │   └── platform/
│   ├── modules/                  # Module-specific tests
│   │   ├── timeTracking/
│   │   ├── scheduling/
│   │   └── payroll/
│   ├── shared/                   # Shared component tests
│   │   ├── components/
│   │   ├── hooks/
│   │   └── utils/
│   ├── platform/                 # Platform-specific tests
│   │   ├── android/
│   │   └── ios/
│   └── e2e/                      # End-to-end tests
│       ├── android/              # Android E2E tests
│       ├── ios/                  # iOS E2E tests
│       └── shared/               # Cross-platform E2E tests
├── docs/                         # Documentation
│   ├── architecture/             # Architecture documentation
│   │   ├── mobile-patterns.md
│   │   ├── platform-specific.md
│   │   └── native-modules.md
│   ├── modules/                  # Module documentation
│   ├── platform/                 # Platform-specific docs
│   │   ├── android/
│   │   └── ios/
│   └── deployment/               # Deployment guides
│       ├── android-deployment.md
│       └── ios-deployment.md
├── scripts/                      # Build and utility scripts
│   ├── android/                  # Android build scripts
│   ├── ios/                      # iOS build scripts
│   └── common/                   # Common scripts
├── .env                          # Environment variables
├── .env.android                  # Android-specific environment
├── .env.ios                      # iOS-specific environment
├── app.json                      # App configuration
├── metro.config.js              # Metro bundler configuration
├── babel.config.js              # Babel configuration
├── react-native.config.js       # React Native configuration
├── package.json                 # Dependencies and scripts
├── tsconfig.json                # TypeScript configuration
├── index.js                     # Application entry point
├── App.tsx                      # Root App component
└── README.md                    # Project documentation
```

## Enterprise Module System Implementation

### Module Configuration Schema

**MUST** implement this module configuration pattern:

```typescript
// types/module.types.ts
export interface ModuleConfig {
  id: string;
  name: string;
  version: string;
  description: string;
  enabled: boolean;
  userTypes: UserType[];
  dependencies: string[];
  lazy: boolean;
  preload: boolean;
  screens: ModuleScreen[];
  permissions: Permission[];
  assets: ModuleAsset[];
  settings: ModuleSettings;
}

export interface ModuleScreen {
  id: string;
  name: string;
  component: string;
  userTypes: UserType[];
  permissions: Permission[];
  navigationOptions: NavigationOptions;
}

export interface UserType {
  id: 'employer' | 'employee';
  name: string;
  permissions: Permission[];
}

// Module configuration example
// modules/timeTracking/module.config.ts
import { ModuleConfig, UserType } from '@/types/module.types';

export const timeTrackingModule: ModuleConfig = {
  id: 'timeTracking',
  name: 'Time Tracking',
  version: '1.0.0',
  description: 'Employee time tracking and management',
  enabled: true,
  userTypes: ['employer', 'employee'],
  dependencies: [],
  lazy: true,
  preload: false,
  screens: [
    {
      id: 'clockInOut',
      name: 'Clock In/Out',
      component: 'ClockInOut',
      userTypes: ['employee'],
      permissions: ['time.track'],
      navigationOptions: {
        title: 'Clock In/Out',
        headerShown: true
      }
    },
    {
      id: 'timeTrackingDashboard',
      name: 'Time Tracking Dashboard',
      component: 'TimeTrackingDashboard',
      userTypes: ['employer'],
      permissions: ['time.manage'],
      navigationOptions: {
        title: 'Time Tracking',
        headerShown: true
      }
    }
  ],
  permissions: [
    'time.track',
    'time.view',
    'time.manage',
    'time.approve'
  ],
  assets: [
    {
      id: 'timeIcon',
      type: 'icon',
      path: 'modules/timeTracking/assets/time-icon.svg'
    }
  ],
  settings: {
    autoClockOut: true,
    breakReminders: true,
    geoTracking: false
  }
};
```

### Module Registry Implementation

**IMPLEMENT** centralized module registry:

```typescript
// core/moduleSystem/registry/ModuleRegistry.ts
import { ModuleConfig } from '@/types/module.types';
import { UserType } from '@/types/userType.types';

export class ModuleRegistry {
  private modules: Map<string, ModuleConfig> = new Map();
  private loadedModules: Map<string, any> = new Map();
  private activeModules: Set<string> = new Set();

  constructor() {
    this.initializeModules();
  }

  private async initializeModules(): Promise<void> {
    // Load module configurations from server
    const configs = await this.fetchModuleConfigurations();
    configs.forEach(config => {
      this.modules.set(config.id, config);
    });
  }

  async activateModule(
    moduleId: string, 
    userType: UserType, 
    userPermissions: string[]
  ): Promise<void> {
    const config = this.modules.get(moduleId);
    
    if (!config) {
      throw new Error(`Module ${moduleId} not found`);
    }

    if (!this.canActivateModule(config, userType, userPermissions)) {
      throw new Error(`Insufficient permissions for module ${moduleId}`);
    }

    if (config.lazy && !this.loadedModules.has(moduleId)) {
      await this.loadModule(moduleId);
    }

    this.activeModules.add(moduleId);
  }

  private canActivateModule(
    config: ModuleConfig, 
    userType: UserType, 
    userPermissions: string[]
  ): boolean {
    // Check user type access
    if (!config.userTypes.includes(userType)) {
      return false;
    }

    // Check permissions
    const requiredPermissions = config.permissions;
    return requiredPermissions.every(permission => 
      userPermissions.includes(permission)
    );
  }

  private async loadModule(moduleId: string): Promise<void> {
    try {
      // Dynamic import for lazy loading
      const module = await import(`@/modules/${moduleId}`);
      this.loadedModules.set(moduleId, module);
    } catch (error) {
      console.error(`Failed to load module ${moduleId}:`, error);
      throw error;
    }
  }

  getActiveModules(): ModuleConfig[] {
    return Array.from(this.activeModules)
      .map(id => this.modules.get(id))
      .filter(Boolean) as ModuleConfig[];
  }

  getModuleScreens(
    userType: UserType, 
    userPermissions: string[]
  ): ModuleScreen[] {
    const activeModules = this.getActiveModules();
    const screens: ModuleScreen[] = [];

    activeModules.forEach(module => {
      const userScreens = module.screens.filter(screen => 
        screen.userTypes.includes(userType) &&
        screen.permissions.every(permission => 
          userPermissions.includes(permission)
        )
      );
      screens.push(...userScreens);
    });

    return screens;
  }
}
```

### User Type System Implementation

**IMPLEMENT** user type management:

```typescript
// core/userTypes/services/userTypeService.ts
import { UserType, UserInterface } from '@/types/userType.types';

export class UserTypeService {
  private userTypeConfigs: Map<string, UserType> = new Map();
  private userInterfaces: Map<string, UserInterface> = new Map();

  async initializeUserTypes(): Promise<void> {
    // Fetch user type configurations from server
    const configs = await this.fetchUserTypeConfigurations();
    
    configs.forEach(config => {
      this.userTypeConfigs.set(config.id, config);
    });

    // Initialize user interfaces
    await this.initializeUserInterfaces();
  }

  private async initializeUserInterfaces(): Promise<void> {
    const interfaces = await this.fetchUserInterfaces();
    
    interfaces.forEach(ui => {
      this.userInterfaces.set(ui.userTypeId, ui);
    });
  }

  getUserType(userTypeId: string): UserType | null {
    return this.userTypeConfigs.get(userTypeId) || null;
  }

  getUserInterface(userTypeId: string): UserInterface | null {
    return this.userInterfaces.get(userTypeId) || null;
  }

  getAvailableModules(userTypeId: string): string[] {
    const userType = this.getUserType(userTypeId);
    return userType?.availableModules || [];
  }

  getUserPermissions(userTypeId: string): string[] {
    const userType = this.getUserType(userTypeId);
    return userType?.permissions.map(p => p.id) || [];
  }

  validateModuleAccess(
    userTypeId: string, 
    moduleId: string
  ): boolean {
    const availableModules = this.getAvailableModules(userTypeId);
    return availableModules.includes(moduleId);
  }
}

// types/userType.types.ts
export interface UserType {
  id: string;
  name: string;
  description: string;
  permissions: Permission[];
  availableModules: string[];
  ui: UserInterfaceConfig;
  settings: UserTypeSettings;
}

export interface UserInterface {
  userTypeId: string;
  theme: ThemeConfig;
  navigation: NavigationConfig;
  layout: LayoutConfig;
  components: ComponentConfig[];
}

export interface UserInterfaceConfig {
  primaryColor: string;
  secondaryColor: string;
  navigationStyle: 'tab' | 'drawer' | 'stack';
  dashboardLayout: 'grid' | 'list' | 'cards';
  menuStyle: 'horizontal' | 'vertical' | 'floating';
}

// Example user type configurations
export const employerUserType: UserType = {
  id: 'employer',
  name: 'Employer',
  description: 'Business owner or manager',
  permissions: [
    { id: 'time.manage', name: 'Manage Time Tracking' },
    { id: 'schedule.create', name: 'Create Schedules' },
    { id: 'payroll.process', name: 'Process Payroll' },
    { id: 'analytics.view', name: 'View Analytics' },
    { id: 'employees.manage', name: 'Manage Employees' }
  ],
  availableModules: [
    'timeTracking',
    'scheduling',
    'payroll',
    'analytics',
    'communication',
    'profile'
  ],
  ui: {
    primaryColor: '#1F2937',
    secondaryColor: '#3B82F6',
    navigationStyle: 'drawer',
    dashboardLayout: 'grid',
    menuStyle: 'vertical'
  },
  settings: {
    defaultView: 'dashboard',
    autoLogout: 30,
    notifications: true
  }
};

export const employeeUserType: UserType = {
  id: 'employee',
  name: 'Employee',
  description: 'Team member or worker',
  permissions: [
    { id: 'time.track', name: 'Track Time' },
    { id: 'schedule.view', name: 'View Schedule' },
    { id: 'schedule.request', name: 'Request Schedule Changes' },
    { id: 'communication.send', name: 'Send Messages' },
    { id: 'profile.edit', name: 'Edit Profile' }
  ],
  availableModules: [
    'timeTracking',
    'scheduling',
    'communication',
    'profile'
  ],
  ui: {
    primaryColor: '#059669',
    secondaryColor: '#10B981',
    navigationStyle: 'tab',
    dashboardLayout: 'cards',
    menuStyle: 'horizontal'
  },
  settings: {
    defaultView: 'timeTracking',
    autoLogout: 60,
    notifications: true
  }
};
```

### Dynamic Navigation Implementation

**IMPLEMENT** configuration-driven navigation:

```typescript
// core/navigation/navigators/ModuleNavigator.tsx
import React, { useEffect, useState } from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import { useModuleRegistry } from '@/core/moduleSystem/hooks/useModuleRegistry';
import { useUserType } from '@/core/userTypes/hooks/useUserType';
import { useAuth } from '@/core/auth/hooks/useAuth';
import { ModuleScreen } from '@/types/module.types';

const Stack = createStackNavigator();

export const ModuleNavigator: React.FC = () => {
  const { moduleRegistry } = useModuleRegistry();
  const { userType, permissions } = useUserType();
  const { user } = useAuth();
  const [screens, setScreens] = useState<ModuleScreen[]>([]);

  useEffect(() => {
    if (userType && permissions && user) {
      loadModuleScreens();
    }
  }, [userType, permissions, user]);

  const loadModuleScreens = async () => {
    try {
      // Activate modules based on user configuration
      const userConfig = await fetchUserConfiguration(user.id);
      
      for (const moduleId of userConfig.enabledModules) {
        await moduleRegistry.activateModule(moduleId, userType, permissions);
      }

      // Get available screens for user
      const availableScreens = moduleRegistry.getModuleScreens(
        userType, 
        permissions
      );
      
      setScreens(availableScreens);
    } catch (error) {
      console.error('Failed to load module screens:', error);
    }
  };

  const renderScreen = (screen: ModuleScreen) => {
    // Dynamic component loading
    const ScreenComponent = require(`@/modules/${screen.moduleId}/screens/${screen.component}`).default;
    
    return (
      <Stack.Screen
        key={screen.id}
        name={screen.id}
        component={ScreenComponent}
        options={screen.navigationOptions}
      />
    );
  };

  return (
    <Stack.Navigator>
      {screens.map(renderScreen)}
    </Stack.Navigator>
  );
};
```

### Performance Optimization Implementation

**IMPLEMENT** performance-optimized module loading:

```typescript
// core/moduleSystem/performance/LazyLoader.ts
export class LazyLoader {
  private loadingPromises: Map<string, Promise<any>> = new Map();
  private cache: Map<string, any> = new Map();

  async loadModule(moduleId: string): Promise<any> {
    // Return cached module if available
    if (this.cache.has(moduleId)) {
      return this.cache.get(moduleId);
    }

    // Return existing promise if already loading
    if (this.loadingPromises.has(moduleId)) {
      return this.loadingPromises.get(moduleId);
    }

    // Create new loading promise
    const loadingPromise = this.performLoad(moduleId);
    this.loadingPromises.set(moduleId, loadingPromise);

    try {
      const module = await loadingPromise;
      this.cache.set(moduleId, module);
      return module;
    } finally {
      this.loadingPromises.delete(moduleId);
    }
  }

  private async performLoad(moduleId: string): Promise<any> {
    console.log(`Loading module: ${moduleId}`);
    
    const startTime = Date.now();
    
    try {
      const module = await import(`@/modules/${moduleId}`);
      
      const loadTime = Date.now() - startTime;
      console.log(`Module ${moduleId} loaded in ${loadTime}ms`);
      
      // Track performance metrics
      this.trackModuleLoadTime(moduleId, loadTime);
      
      return module;
    } catch (error) {
      console.error(`Failed to load module ${moduleId}:`, error);
      throw error;
    }
  }

  async preloadModule(moduleId: string): Promise<void> {
    // Preload module in background with lower priority
    requestIdleCallback(() => {
      this.loadModule(moduleId).catch(error => {
        console.warn(`Preload failed for module ${moduleId}:`, error);
      });
    });
  }

  preloadModules(moduleIds: string[]): void {
    moduleIds.forEach(moduleId => {
      this.preloadModule(moduleId);
    });
  }

  private trackModuleLoadTime(moduleId: string, loadTime: number): void {
    // Send performance metrics to analytics
    if (window.analytics) {
      window.analytics.track('Module Load Time', {
        moduleId,
        loadTime,
        timestamp: Date.now()
      });
    }
  }
}
```

### Module Communication System

**IMPLEMENT** inter-module communication:

```typescript
// core/moduleSystem/communication/EventBus.ts
export class EventBus {
  private listeners: Map<string, Function[]> = new Map();

  subscribe(event: string, callback: Function): () => void {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    
    this.listeners.get(event)!.push(callback);
    
    // Return unsubscribe function
    return () => {
      const callbacks = this.listeners.get(event);
      if (callbacks) {
        const index = callbacks.indexOf(callback);
        if (index > -1) {
          callbacks.splice(index, 1);
        }
      }
    };
  }

  emit(event: string, data?: any): void {
    const callbacks = this.listeners.get(event);
    if (callbacks) {
      callbacks.forEach(callback => {
        try {
          callback(data);
        } catch (error) {
          console.error(`Error in event callback for ${event}:`, error);
        }
      });
    }
  }

  emitToModule(
    targetModule: string, 
    event: string, 
    data?: any
  ): void {
    this.emit(`module:${targetModule}:${event}`, data);
  }
}

// Module communication hook
// core/moduleSystem/hooks/useModuleCommunication.ts
import { useContext, useEffect } from 'react';
import { EventBusContext } from '@/core/moduleSystem/providers/EventBusProvider';

export const useModuleCommunication = (moduleId: string) => {
  const eventBus = useContext(EventBusContext);

  const sendToModule = (
    targetModule: string, 
    event: string, 
    data?: any
  ) => {
    eventBus.emitToModule(targetModule, event, data);
  };

  const subscribeToModule = (
    sourceModule: string, 
    event: string, 
    callback: Function
  ) => {
    return eventBus.subscribe(
      `module:${sourceModule}:${event}`, 
      callback
    );
  };

  const broadcast = (event: string, data?: any) => {
    eventBus.emit(`broadcast:${event}`, data);
  };

  const subscribeToBroadcast = (event: string, callback: Function) => {
    return eventBus.subscribe(`broadcast:${event}`, callback);
  };

## Enterprise Anti-Patterns

**DON'T** implement these approaches in enterprise applications:

### Module Anti-Patterns

- **DON'T** hardcode module configurations in source code
- **NEVER** create direct dependencies between modules - use event bus communication
- **AVOID** loading all modules at startup - implement proper lazy loading
- **DON'T** bypass user type permissions for convenience
- **NEVER** share state directly between modules - use proper communication channels
- **AVOID** monolithic module designs - keep modules focused and cohesive
- **DON'T** ignore module lifecycle events - implement proper cleanup

### Performance Anti-Patterns

- **NEVER** load unused modules for current user type
- **AVOID** synchronous module loading that blocks UI
- **DON'T** cache modules indefinitely without memory management
- **NEVER** ignore failed module loads - implement proper error handling
- **AVOID** preloading modules that user cannot access
- **DON'T** create memory leaks in module communication

### Configuration Anti-Patterns

- **NEVER** store sensitive configuration in client-side code
- **AVOID** configuration that doesn't support hot updates
- **DON'T** create configuration dependencies between unrelated modules
- **NEVER** bypass configuration validation for any reason
- **AVOID** configuration formats that don't support versioning

## Validation Checklist

**MUST** verify these enterprise architecture requirements:

### Module System Validation
- [ ] All modules follow the mandatory folder structure
- [ ] Module configurations are server-driven and validated
- [ ] User type permissions are properly enforced
- [ ] Module lazy loading is implemented and tested
- [ ] Inter-module communication uses event bus pattern
- [ ] Module lifecycle management is properly implemented

### Performance Validation
- [ ] Module loading performance is monitored and optimized
- [ ] Memory usage is tracked and managed
- [ ] Only required modules are loaded for each user type
- [ ] Module caching strategies are implemented
- [ ] Background preloading doesn't impact user experience

### Security Validation
- [ ] User type permissions are validated on both client and server
- [ ] Module access is properly restricted based on user configuration
- [ ] Sensitive module configurations are not exposed to unauthorized users
- [ ] All module communications are properly secured

### Configuration Validation
- [ ] Configuration schema validation is implemented
- [ ] Configuration hot reloading is tested
- [ ] Fallback mechanisms work for configuration failures
- [ ] Configuration versioning supports backward compatibility
- [ ] All configuration changes are properly audited

## Code Examples

### Example Module Implementation

```typescript
// modules/timeTracking/TimeTrackingModule.tsx
import React from 'react';
import { ModuleProvider } from '@/core/moduleSystem/providers/ModuleProvider';
import { timeTrackingModule } from './module.config';
import { TimeTrackingStore } from './store/timeTrackingStore';

export const TimeTrackingModule: React.FC = ({ children }) => {
  return (
    <ModuleProvider 
      config={timeTrackingModule}
      store={TimeTrackingStore}
    >
      {children}
    </ModuleProvider>
  );
};

// Export module screens for lazy loading
export { default as ClockInOut } from './screens/employee/ClockInOut';
export { default as TimeTrackingDashboard } from './screens/employer/TimeTrackingDashboard';
export { default as TimeSheet } from './screens/employee/TimeSheet';
export { default as TimeApproval } from './screens/employer/TimeApproval';
```

### Example User Type Configuration

```typescript
// app/config/userType.config.ts
import { UserTypeConfig } from '@/types/userType.types';

export const userTypeConfigurations: UserTypeConfig[] = [
  {
    id: 'employer',
    name: 'Employer',
    description: 'Business owner or manager with full system access',
    permissions: [
      'time.manage',
      'schedule.create',
      'payroll.process',
      'analytics.view',
      'employees.manage',
      'settings.configure'
    ],
    modules: [
      {
        id: 'timeTracking',
        enabled: true,
        settings: {
          canApproveTime: true,
          canEditEmployeeTime: true,
          viewAllEmployees: true
        }
      },
      {
        id: 'scheduling',
        enabled: true,
        settings: {
          canCreateSchedules: true,
          canAssignShifts: true,
          viewAllSchedules: true
        }
      },
      {
        id: 'payroll',
        enabled: true,
        settings: {
          canProcessPayroll: true,
          canViewPayrollReports: true,
          canExportData: true
        }
      }
    ],
    ui: {
      theme: 'employer',
      navigationStyle: 'drawer',
      dashboardLayout: 'grid',
      primaryColor: '#1F2937',
      secondaryColor: '#3B82F6'
    }
  },
  {
    id: 'employee',
    name: 'Employee',
    description: 'Team member with limited system access',
    permissions: [
      'time.track',
      'schedule.view',
      'schedule.request',
      'communication.send',
      'profile.edit'
    ],
    modules: [
      {
        id: 'timeTracking',
        enabled: true,
        settings: {
          canApproveTime: false,
          canEditEmployeeTime: false,
          viewAllEmployees: false
        }
      },
      {
        id: 'scheduling',
        enabled: true,
        settings: {
          canCreateSchedules: false,
          canAssignShifts: false,
          viewAllSchedules: false
        }
      }
    ],
    ui: {
      theme: 'employee',
      navigationStyle: 'tab',
      dashboardLayout: 'cards',
      primaryColor: '#059669',
      secondaryColor: '#10B981'
    }
  }
];
```

This enterprise architecture provides a robust foundation for building scalable, configurable, and performant React Native applications with dynamic module management and multi-user-type support.

## References

### Enterprise Architecture Patterns
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Micro-frontends Architecture](https://micro-frontends.org/)
- [React Native Performance Best Practices](https://reactnative.dev/docs/performance)
- [Enterprise Mobile App Security](https://owasp.org/www-project-mobile-security-testing-guide/)

### Module System Implementation
- [React Navigation Dynamic Screens](https://reactnavigation.org/docs/auth-flow)
- [React Native Code Splitting](https://reactnative.dev/docs/performance#lazy-loading)
- [TypeScript Module System](https://www.typescriptlang.org/docs/handbook/modules.html)
- [Event-Driven Architecture Patterns](https://martinfowler.com/articles/201701-event-driven.html)

### Performance Optimization
- [React Native Bundle Optimization](https://reactnative.dev/docs/performance#bundle-size)
- [React Native Memory Management](https://reactnative.dev/docs/performance#memory)
- [Lazy Loading Best Practices](https://web.dev/lazy-loading-best-practices/)

### Security and Permissions
- [React Native Security Guidelines](https://reactnative.dev/docs/security)
- [Role-Based Access Control (RBAC)](https://auth0.com/intro-to-iam/what-is-role-based-access-control-rbac)
- [Mobile Application Security Verification Standard](https://owasp.org/www-project-mobile-app-security/)

This architecture ensures enterprise-grade scalability, maintainability, and performance while providing the flexibility needed for dynamic module configuration and multi-user-type support.

```
WorkforceManagementApp/
├── android/                           # Android native code
├── ios/                              # iOS native code
├── src/
│   ├── app/                          # Application core initialization
│   │   ├── App.tsx                   # Root application component
│   │   ├── AppRegistry.tsx           # Module and provider registration
│   │   └── config/
│   │       ├── app.config.ts         # Base app configuration
│   │       ├── module.config.ts      # Module configuration schema
│   │       └── userType.config.ts    # User type definitions
│   │
│   ├── core/                         # Core enterprise systems
│   │   ├── auth/                     # Authentication & authorization
│   │   │   ├── providers/
│   │   │   │   ├── AuthProvider.tsx
│   │   │   │   └── PermissionProvider.tsx
│   │   │   ├── services/
│   │   │   │   ├── authService.ts
│   │   │   │   ├── permissionService.ts
│   │   │   │   └── roleService.ts
│   │   │   ├── hooks/
│   │   │   │   ├── useAuth.ts
│   │   │   │   ├── usePermissions.ts
│   │   │   │   └── useUserType.ts
│   │   │   ├── guards/
│   │   │   │   ├── AuthGuard.tsx
│   │   │   │   ├── RoleGuard.tsx
│   │   │   │   └── ModuleGuard.tsx
│   │   │   └── types/
│   │   │       ├── auth.types.ts
│   │   │       ├── permission.types.ts
│   │   │       └── role.types.ts
│   │   │
│   │   ├── configuration/            # Server-driven configuration
│   │   │   ├── providers/
│   │   │   │   ├── ConfigurationProvider.tsx
│   │   │   │   └── ModuleConfigProvider.tsx
│   │   │   ├── services/
│   │   │   │   ├── configurationService.ts
│   │   │   │   ├── moduleConfigService.ts
│   │   │   │   └── userConfigService.ts
│   │   │   ├── hooks/
│   │   │   │   ├── useConfiguration.ts
│   │   │   │   ├── useModuleConfig.ts
│   │   │   │   └── useUserConfig.ts
│   │   │   ├── cache/
│   │   │   │   ├── configCache.ts
│   │   │   │   └── moduleCache.ts
│   │   │   └── types/
│   │   │       ├── configuration.types.ts
│   │   │       └── moduleConfig.types.ts
│   │   │
│   │   ├── navigation/               # Enterprise navigation system
│   │   │   ├── navigators/
│   │   │   │   ├── RootNavigator.tsx
│   │   │   │   ├── AuthNavigator.tsx
│   │   │   │   ├── EmployerNavigator.tsx
│   │   │   │   ├── EmployeeNavigator.tsx
│   │   │   │   └── ModuleNavigator.tsx
│   │   │   ├── guards/
│   │   │   │   ├── NavigationGuard.tsx
│   │   │   │   └── ModuleAccessGuard.tsx
│   │   │   ├── hooks/
│   │   │   │   ├── useNavigation.ts
│   │   │   │   └── useModuleNavigation.ts
│   │   │   └── types/
│   │   │       ├── navigation.types.ts
│   │   │       └── moduleNavigation.types.ts
│   │   │
│   │   ├── moduleSystem/             # Dynamic module management
│   │   │   ├── registry/
│   │   │   │   ├── ModuleRegistry.ts
│   │   │   │   ├── ModuleLoader.ts
│   │   │   │   └── ModuleValidator.ts
│   │   │   ├── lifecycle/
│   │   │   │   ├── ModuleLifecycle.ts
│   │   │   │   ├── ModuleActivator.ts
│   │   │   │   └── ModuleDeactivator.ts
│   │   │   ├── communication/
│   │   │   │   ├── ModuleBridge.ts
│   │   │   │   ├── EventBus.ts
│   │   │   │   └── ModuleMessaging.ts
│   │   │   ├── performance/
│   │   │   │   ├── ModuleMetrics.ts
│   │   │   │   ├── LazyLoader.ts
│   │   │   │   └── ModuleCache.ts
│   │   │   └── types/
│   │   │       ├── module.types.ts
│   │   │       ├── registry.types.ts
│   │   │       └── lifecycle.types.ts
│   │   │
│   │   ├── userTypes/                # User type management system
│   │   │   ├── providers/
│   │   │   │   ├── UserTypeProvider.tsx
│   │   │   │   └── UserInterfaceProvider.tsx
│   │   │   ├── services/
│   │   │   │   ├── userTypeService.ts
│   │   │   │   ├── interfaceService.ts
│   │   │   │   └── permissionMappingService.ts
│   │   │   ├── hooks/
│   │   │   │   ├── useUserType.ts
│   │   │   │   ├── useUserInterface.ts
│   │   │   │   └── useModuleAccess.ts
│   │   │   ├── types/
│   │   │   │   ├── userType.types.ts
│   │   │   │   ├── interface.types.ts
│   │   │   │   └── access.types.ts
│   │   │   └── registry/
│   │   │       ├── userTypeRegistry.ts
│   │   │       └── interfaceRegistry.ts
│   │   │
│   │   ├── api/                      # Enterprise API management
│   │   │   ├── client/
│   │   │   │   ├── apiClient.ts
│   │   │   │   ├── interceptors.ts
│   │   │   │   └── moduleApiClient.ts
│   │   │   ├── services/
│   │   │   │   ├── baseService.ts
│   │   │   │   ├── authApiService.ts
│   │   │   │   └── configApiService.ts
│   │   │   ├── cache/
│   │   │   │   ├── apiCache.ts
│   │   │   │   ├── moduleCache.ts
│   │   │   │   └── offlineCache.ts
│   │   │   └── types/
│   │   │       ├── api.types.ts
│   │   │       └── moduleApi.types.ts
│   │   │
│   │   ├── state/                    # Enterprise state management
│   │   │   ├── stores/
│   │   │   │   ├── authStore.ts
│   │   │   │   ├── configStore.ts
│   │   │   │   ├── moduleStore.ts
│   │   │   │   └── userTypeStore.ts
│   │   │   ├── middleware/
│   │   │   │   ├── persistMiddleware.ts
│   │   │   │   ├── syncMiddleware.ts
│   │   │   │   └── moduleMiddleware.ts
│   │   │   ├── selectors/
│   │   │   │   ├── authSelectors.ts
│   │   │   │   ├── moduleSelectors.ts
│   │   │   │   └── userTypeSelectors.ts
│   │   │   └── types/
│   │   │       ├── store.types.ts
│   │   │       └── state.types.ts
│   │   │
│   │   ├── monitoring/               # Enterprise monitoring & analytics
│   │   │   ├── performance/
│   │   │   │   ├── PerformanceMonitor.ts
│   │   │   │   ├── ModulePerformance.ts
│   │   │   │   └── UserExperience.ts
│   │   │   ├── analytics/
│   │   │   │   ├── AnalyticsService.ts
│   │   │   │   ├── ModuleAnalytics.ts
│   │   │   │   └── UserAnalytics.ts
│   │   │   ├── logging/
│   │   │   │   ├── Logger.ts
│   │   │   │   ├── ModuleLogger.ts
│   │   │   │   └── ErrorLogger.ts
│   │   │   └── types/
│   │   │       ├── monitoring.types.ts
│   │   │       └── analytics.types.ts
│   │   │
│   │   └── utils/                    # Core utilities
│   │       ├── constants/
│   │       ├── helpers/
│   │       ├── validators/
│   │       └── formatters/
│   │
│   ├── modules/                      # Feature modules (dynamically activated)
│   │   ├── shared/                   # Shared components and utilities
│   │   │   ├── components/
│   │   │   │   ├── ui/               # Reusable UI components
│   │   │   │   │   ├── Button/
│   │   │   │   │   │   ├── Button.tsx
│   │   │   │   │   │   ├── Button.types.ts
│   │   │   │   │   │   ├── Button.styles.ts
│   │   │   │   │   │   └── index.ts
│   │   │   │   │   ├── Input/
│   │   │   │   │   ├── Card/
│   │   │   │   │   ├── Modal/
│   │   │   │   │   └── DataTable/
│   │   │   │   ├── layout/           # Layout components
│   │   │   │   │   ├── Header/
│   │   │   │   │   ├── Sidebar/
│   │   │   │   │   ├── Footer/
│   │   │   │   │   └── Container/
│   │   │   │   ├── forms/            # Form components
│   │   │   │   │   ├── FormField/
│   │   │   │   │   ├── FormValidation/
│   │   │   │   │   └── FormSubmit/
│   │   │   │   └── charts/           # Chart components
│   │   │   │       ├── LineChart/
│   │   │   │       ├── BarChart/
│   │   │   │       └── PieChart/
│   │   │   ├── hooks/
│   │   │   │   ├── useApi.ts
│   │   │   │   ├── useForm.ts
│   │   │   │   ├── useValidation.ts
│   │   │   │   └── useLocalStorage.ts
│   │   │   ├── utils/
│   │   │   │   ├── dateUtils.ts
│   │   │   │   ├── formatUtils.ts
│   │   │   │   └── validationUtils.ts
│   │   │   └── types/
│   │   │       ├── common.types.ts
│   │   │       └── shared.types.ts
│   │   │
│   │   ├── timeTracking/             # Time Tracking Module
│   │   │   ├── module.config.ts      # Module configuration
│   │   │   ├── screens/
│   │   │   │   ├── employer/         # Employer-specific screens
│   │   │   │   │   ├── TimeTrackingDashboard.tsx
│   │   │   │   │   ├── EmployeeTimeReports.tsx
│   │   │   │   │   └── TimeApproval.tsx
│   │   │   │   └── employee/         # Employee-specific screens
│   │   │   │       ├── ClockInOut.tsx
│   │   │   │       ├── TimeSheet.tsx
│   │   │   │       └── BreakTracker.tsx
│   │   │   ├── components/
│   │   │   │   ├── TimeCard/
│   │   │   │   ├── ClockInterface/
│   │   │   │   └── TimeChart/
│   │   │   ├── services/
│   │   │   │   ├── timeTrackingService.ts
│   │   │   │   └── timeValidationService.ts
│   │   │   ├── hooks/
│   │   │   │   ├── useTimeTracking.ts
│   │   │   │   └── useTimeValidation.ts
│   │   │   ├── store/
│   │   │   │   ├── timeTrackingStore.ts
│   │   │   │   └── timeTrackingSelectors.ts
│   │   │   └── types/
│   │   │       └── timeTracking.types.ts
│   │   │
│   │   ├── scheduling/               # Scheduling Module
│   │   │   ├── module.config.ts
│   │   │   ├── screens/
│   │   │   │   ├── employer/
│   │   │   │   │   ├── ScheduleCreation.tsx
│   │   │   │   │   ├── ScheduleManagement.tsx
│   │   │   │   │   └── ScheduleReports.tsx
│   │   │   │   └── employee/
│   │   │   │       ├── MySchedule.tsx
│   │   │   │       ├── ScheduleRequests.tsx
│   │   │   │       └── AvailabilitySettings.tsx
│   │   │   ├── components/
│   │   │   │   ├── Calendar/
│   │   │   │   ├── ShiftCard/
│   │   │   │   └── ScheduleGrid/
│   │   │   ├── services/
│   │   │   │   ├── schedulingService.ts
│   │   │   │   └── availabilityService.ts
│   │   │   ├── hooks/
│   │   │   │   ├── useScheduling.ts
│   │   │   │   └── useAvailability.ts
│   │   │   ├── store/
│   │   │   │   ├── schedulingStore.ts
│   │   │   │   └── schedulingSelectors.ts
│   │   │   └── types/
│   │   │       └── scheduling.types.ts
│   │   │
│   │   ├── payroll/                  # Payroll Module (Employer Only)
│   │   │   ├── module.config.ts
│   │   │   ├── screens/
│   │   │   │   └── employer/         # Only employer screens
│   │   │   │       ├── PayrollDashboard.tsx
│   │   │   │       ├── PayrollProcessing.tsx
│   │   │   │       ├── PayrollReports.tsx
│   │   │   │       └── PayrollSettings.tsx
│   │   │   ├── components/
│   │   │   │   ├── PayrollTable/
│   │   │   │   ├── PayrollSummary/
│   │   │   │   └── PayslipGenerator/
│   │   │   ├── services/
│   │   │   │   ├── payrollService.ts
│   │   │   │   └── payrollCalculationService.ts
│   │   │   ├── hooks/
│   │   │   │   ├── usePayroll.ts
│   │   │   │   └── usePayrollCalculation.ts
│   │   │   ├── store/
│   │   │   │   ├── payrollStore.ts
│   │   │   │   └── payrollSelectors.ts
│   │   │   └── types/
│   │   │       └── payroll.types.ts
│   │   │
│   │   ├── communication/            # Communication Module
│   │   │   ├── module.config.ts
│   │   │   ├── screens/
│   │   │   │   ├── shared/           # Common screens for both user types
│   │   │   │   │   ├── MessagingHub.tsx
│   │   │   │   │   ├── Announcements.tsx
│   │   │   │   │   └── Notifications.tsx
│   │   │   │   ├── employer/
│   │   │   │   │   ├── BroadcastMessage.tsx
│   │   │   │   │   └── TeamCommunication.tsx
│   │   │   │   └── employee/
│   │   │   │       └── DirectMessages.tsx
│   │   │   ├── components/
│   │   │   │   ├── MessageCard/
│   │   │   │   ├── ChatInterface/
│   │   │   │   └── AnnouncementBanner/
│   │   │   ├── services/
│   │   │   │   ├── messagingService.ts
│   │   │   │   └── notificationService.ts
│   │   │   ├── hooks/
│   │   │   │   ├── useMessaging.ts
│   │   │   │   └── useNotifications.ts
│   │   │   ├── store/
│   │   │   │   ├── communicationStore.ts
│   │   │   │   └── communicationSelectors.ts
│   │   │   └── types/
│   │   │       └── communication.types.ts
│   │   │
│   │   ├── analytics/                # Analytics Module (Employer Focus)
│   │   │   ├── module.config.ts
│   │   │   ├── screens/
│   │   │   │   ├── employer/
│   │   │   │   │   ├── AnalyticsDashboard.tsx
│   │   │   │   │   ├── ProductivityReports.tsx
│   │   │   │   │   ├── CostAnalysis.tsx
│   │   │   │   │   └── TrendsAnalysis.tsx
│   │   │   │   └── employee/
│   │   │   │       ├── PersonalInsights.tsx
│   │   │   │       └── PerformanceMetrics.tsx
│   │   │   ├── components/
│   │   │   │   ├── AnalyticsChart/
│   │   │   │   ├── MetricCard/
│   │   │   │   └── ReportGenerator/
│   │   │   ├── services/
│   │   │   │   ├── analyticsService.ts
│   │   │   │   └── reportingService.ts
│   │   │   ├── hooks/
│   │   │   │   ├── useAnalytics.ts
│   │   │   │   └── useReporting.ts
│   │   │   ├── store/
│   │   │   │   ├── analyticsStore.ts
│   │   │   │   └── analyticsSelectors.ts
│   │   │   └── types/
│   │   │       └── analytics.types.ts
│   │   │
│   │   └── profile/                  # Profile Management Module
│   │       ├── module.config.ts
│   │       ├── screens/
│   │       │   ├── shared/           # Common profile screens
│   │       │   │   ├── ProfileView.tsx
│   │       │   │   ├── ProfileEdit.tsx
│   │       │   │   └── PasswordChange.tsx
│   │       │   ├── employer/
│   │       │   │   ├── CompanyProfile.tsx
│   │       │   │   └── BillingSettings.tsx
│   │       │   └── employee/
│   │       │       ├── PersonalInfo.tsx
│   │       │       └── EmergencyContacts.tsx
│   │       ├── components/
│   │       │   ├── ProfileCard/
│   │       │   ├── EditForm/
│   │       │   └── AvatarUpload/
│   │       ├── services/
│   │       │   ├── profileService.ts
│   │       │   └── avatarService.ts
│   │       ├── hooks/
│   │       │   ├── useProfile.ts
│   │       │   └── useAvatar.ts
│   │       ├── store/
│   │       │   ├── profileStore.ts
│   │       │   └── profileSelectors.ts
│   │       └── types/
│   │           └── profile.types.ts
│   │
│   ├── assets/                       # Static assets
│   │   ├── images/
│   │   │   ├── common/               # Shared images
│   │   │   ├── employer/             # Employer-specific images
│   │   │   └── employee/             # Employee-specific images
│   │   ├── icons/
│   │   │   ├── common/
│   │   │   ├── modules/              # Module-specific icons
│   │   │   └── userTypes/            # User type specific icons
│   │   ├── fonts/
│   │   └── animations/
│   │
│   ├── styles/                       # Global styling system
│   │   ├── themes/
│   │   │   ├── defaultTheme.ts
│   │   │   ├── employerTheme.ts
│   │   │   └── employeeTheme.ts
│   │   ├── components/               # Component-specific styles
│   │   ├── layouts/                  # Layout-specific styles
│   │   └── utilities/                # Style utilities
│   │
│   └── types/                        # Global TypeScript types
│       ├── global.types.ts
│       ├── module.types.ts
│       ├── userType.types.ts
│       ├── navigation.types.ts
│       └── api.types.ts
│
├── docs/                             # Documentation
│   ├── architecture/
│   │   ├── module-system.md
│   │   ├── user-types.md
│   │   └── configuration.md
│   ├── modules/
│   │   ├── module-development-guide.md
│   │   └── module-configuration.md
│   └── deployment/
│       ├── module-deployment.md
│       └── configuration-deployment.md
│
├── scripts/                          # Build and deployment scripts
│   ├── module-generator.js
│   ├── config-validator.js
│   └── build-modules.js
│
├── __tests__/                        # Test files
│   ├── core/
│   ├── modules/
│   └── integration/
│
├── .env.example                      # Environment variables template
├── module.config.json               # Module configuration schema
├── user-types.config.json           # User type definitions
└── package.json
```
│   │   │   │
│   │   │   ├── inventory/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── InventoryListScreen.tsx
│   │   │   │   │   └── AddProductScreen.tsx
│   │   │   │   ├── components/
│   │   │   │   └── services/
│   │   │   │
│   │   │   ├── analytics/
│   │   │   │   ├── screens/
│   │   │   │   ├── components/
│   │   │   │   └── services/
│   │   │   │
│   │   │   └── settings/
│   │   │       ├── screens/
│   │   │       ├── components/
│   │   │       └── services/
│   │   │
│   │   └── modules/                  # Pluggable modules
│   │       ├── payment/
│   │       │   ├── index.ts
│   │       │   ├── screens/
│   │       │   ├── components/
│   │       │   ├── services/
│   │       │   └── module.config.ts
│   │       │
│   │       ├── delivery/
│   │       │   ├── index.ts
│   │       │   ├── screens/
│   │       │   ├── components/
│   │       │   └── module.config.ts
│   │       │
│   │       └── loyalty/
│   │           ├── index.ts
│   │           ├── screens/
│   │           ├── components/
│   │           └── module.config.ts
│   │
│   ├── infrastructure/               # Infrastructure layer
│   │   ├── feature-flags/
│   │   │   ├── FeatureFlagService.ts
│   │   │   ├── flags.config.ts
│   │   │   └── hooks/
│   │   │       └── useFeatureFlag.ts
│   │   │
│   │   ├── analytics/
│   │   │   ├── AnalyticsService.ts
│   │   │   ├── providers/
│   │   │   │   ├── FirebaseAnalytics.ts
│   │   │   │   └── MixpanelAnalytics.ts
│   │   │   └── events/
│   │   │       └── analyticsEvents.ts
│   │   │
│   │   ├── monitoring/
│   │   │   ├── ErrorBoundary.tsx
│   │   │   ├── CrashReporting.ts
│   │   │   └── PerformanceMonitoring.ts
│   │   │
│   │   ├── storage/
│   │   │   ├── SecureStorage.ts
│   │   │   ├── AsyncStorage.ts
│   │   │   └── DatabaseService.ts
│   │   │
│   │   └── notifications/
│   │       ├── NotificationService.ts
│   │       ├── handlers/
│   │       └── types/
│   │
│   ├── design-system/                # Design system
│   │   ├── theme/
│   │   │   ├── colors/
│   │   │   │   ├── palette.ts
│   │   │   │   ├── customer.colors.ts
│   │   │   │   └── merchant.colors.ts
│   │   │   ├── typography/
│   │   │   │   └── typography.ts
│   │   │   ├── spacing/
│   │   │   │   └── spacing.ts
│   │   │   └── themes/
│   │   │       ├── customerTheme.ts
│   │   │       └── merchantTheme.ts
│   │   │
│   │   ├── components/               # Design system components
│   │   │   ├── primitives/
│   │   │   │   ├── Box/
│   │   │   │   ├── Text/
│   │   │   │   └── Flex/
│   │   │   └── patterns/
│   │   │       ├── Forms/
│   │   │       └── Lists/
│   │   │
│   │   └── assets/
│   │       ├── icons/
│   │       ├── images/
│   │       └── animations/
│   │
│   └── types/                        # Global TypeScript types
│       ├── models/
│       │   ├── user.types.ts
│       │   ├── product.types.ts
│       │   └── order.types.ts
│       ├── api/
│       └── common/
│
├── scripts/                          # Build and utility scripts
│   ├── generate-module.js
│   ├── feature-flag-sync.js
│   └── env-setup.js
│
├── __tests__/
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── .env.development
├── .env.staging
├── .env.production
├── package.json
├── tsconfig.json
├── babel.config.js
├── metro.config.js
└── README.md
```

## Anti-Patterns

### **DON'T** implement these approaches

**AVOID** God Components with too many responsibilities:

```typescript
// ❌ Bad: Component doing too much
const UserDashboard = () => {
  // Authentication logic
  const [user, setUser] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  
  // Data fetching logic
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  
  // UI state
  const [selectedTab, setSelectedTab] = useState(0);
  const [isModalOpen, setIsModalOpen] = useState(false);
  
  // Network requests
  const fetchUsers = async () => { /* ... */ };
  const updateUser = async (user) => { /* ... */ };
  
  // Render logic with 200+ lines
  return (/* massive render method */);
};

// ✅ Good: Separated concerns
const UserDashboard = () => {
  return (
    <AuthenticatedLayout>
      <UserDashboardTabs />
      <UserManagementContainer />
    </AuthenticatedLayout>
  );
};
```

**DON'T** use prop drilling extensively:

```typescript
// ❌ Bad: Prop drilling
const App = () => {
  const [theme, setTheme] = useState('light');
  return <Dashboard theme={theme} setTheme={setTheme} />;
};

const Dashboard = ({ theme, setTheme }) => (
  <UserProfile theme={theme} setTheme={setTheme} />
);

const UserProfile = ({ theme, setTheme }) => (
  <Settings theme={theme} setTheme={setTheme} />
);

// ✅ Good: Context for global state
const ThemeContext = createContext();

const App = () => (
  <ThemeProvider>
    <Dashboard />
  </ThemeProvider>
);
```

**NEVER** directly manipulate state:

```typescript
// ❌ Bad: Direct mutation
const TodoList = () => {
  const [todos, setTodos] = useState([]);
  
  const addTodo = (text) => {
    todos.push({ id: Date.now(), text }); // Direct mutation
    setTodos(todos);
  };
};

// ✅ Good: Immutable updates
const TodoList = () => {
  const [todos, setTodos] = useState([]);
  
  const addTodo = (text) => {
    setTodos(prev => [...prev, { id: Date.now(), text }]);
  };
};
```

## Code Examples

### Error Boundary Implementation

```typescript
interface ErrorBoundaryState {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends React.Component<
  React.PropsWithChildren<{}>,
  ErrorBoundaryState
> {
  constructor(props: React.PropsWithChildren<{}>) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    // Report to crash analytics
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />;
    }

    return this.props.children;
  }
}
```

### Performance Optimization Patterns

```typescript
// Memoized component
export const UserItem = React.memo<UserItemProps>(({ user, onPress }) => {
  const handlePress = useCallback(() => {
    onPress(user.id);
  }, [onPress, user.id]);

  return (
    <Pressable onPress={handlePress}>
      <Text>{user.name}</Text>
    </Pressable>
  );
});

// Memoized selector
const useOptimizedUserList = () => {
  const users = useSelector(state => state.users.list);
  
  return useMemo(() => 
    users.filter(user => user.isActive).sort((a, b) => a.name.localeCompare(b.name)),
    [users]
  );
};
```

## Validation Checklist

### **MUST** verify

- [ ] All components have proper TypeScript interfaces
- [ ] Error boundaries are implemented for major sections
- [ ] No direct state mutations in any component
- [ ] Custom hooks follow naming conventions (use*)
- [ ] All async operations have proper error handling
- [ ] Components have single responsibility
- [ ] Proper cleanup is implemented for effects
- [ ] No memory leaks from unhandled subscriptions

### **SHOULD** check

- [ ] Components are properly memoized where needed
- [ ] Context is used appropriately (not for frequently changing data)
- [ ] Lazy loading is implemented for large components
- [ ] Accessibility props are present on interactive elements
- [ ] Performance profiling shows no unnecessary re-renders
- [ ] Code splitting is implemented for different sections
- [ ] Loading states are consistent across the application
- [ ] Error states provide meaningful user feedback

## References

- [React Native Official Documentation](https://reactnative.dev/docs/getting-started)
- [React Patterns and Best Practices](https://react.dev/learn)
- [TypeScript React Cheatsheet](https://github.com/typescript-cheatsheets/react-typescript-cheatsheet)
- [React Native Performance](https://reactnative.dev/docs/performance)
- [Component Design Patterns](https://kentcdodds.com/blog/compound-components)
- [Custom Hooks Patterns](https://usehooks.com/)
- [React Native Navigation](https://reactnavigation.org/docs/getting-started)
