---
applyTo: '**'
---

# Enterprise State Management Instructions

This document outlines comprehensive state management patterns, data flow architecture, and best practices for enterprise React Native applications with dynamic module systems, multi-user types, and server-driven configurations.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** implement modular state management supporting dynamic module loading
- **REQUIRED** to separate client state, server state, and module-specific state
- **SHALL** use proper TypeScript types for all state definitions across modules
- **MUST** implement proper error handling and loading states for enterprise scenarios
- **NEVER** mutate state directly - always use proper update mechanisms
- **REQUIRED** to implement state persistence with user-type-specific configurations
- **SHALL** optimize re-renders by using proper selectors and memoization
- **MUST** implement proper cleanup to prevent memory leaks in module lifecycle
- **REQUIRED** to handle offline state and data synchronization for enterprise data
- **SHALL** implement proper state testing strategies for complex enterprise workflows
- **MUST** support real-time state updates across modules
- **REQUIRED** to implement state validation and integrity checks
- **SHALL** support state rollback and recovery mechanisms

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** use Zustand for client state with Redux Toolkit for complex enterprise workflows
- **RECOMMENDED** to implement optimistic updates for enterprise user experience
- **ALWAYS** implement proper state normalization for complex enterprise data structures
- **DO** implement state middleware for debugging, logging, and audit trails
- **SHOULD** use proper state composition patterns for enterprise scalability
- **RECOMMENDED** to implement proper cache invalidation strategies for enterprise data
- **DO** implement state-driven UI patterns with loading and error boundaries
- **ALWAYS** implement proper state hydration and dehydration for enterprise contexts
- **SHOULD** use proper state selectors to prevent unnecessary re-renders
- **RECOMMENDED** to implement cross-module state communication patterns
- **DO** implement state analytics and performance monitoring
- **ALWAYS** implement user-type-specific state isolation

### Optional Enhancements (**MAY** Consider)

- **MAY** implement advanced caching strategies with TTL and background refresh
- **OPTIONAL** to use state machines for complex enterprise business flows
- **USE** state devtools for development and debugging
- **IMPLEMENT** state analytics and monitoring in production
- **AVOID** over-engineering simple state requirements
- **MAY** implement state synchronization across multiple devices
- **OPTIONAL** to implement state versioning and migration strategies

## Implementation Guidance

### Enterprise State Architecture

**USE** this layered state architecture for enterprise applications:

```typescript
// core/state/types/enterpriseState.ts
export interface EnterpriseState {
  // Core application state
  core: CoreState;
  
  // User-specific state
  user: UserState;
  
  // Module-specific states
  modules: ModuleStatesMap;
  
  // Real-time data
  realtime: RealtimeState;
  
  // Offline/sync state
  sync: SyncState;
}

export interface CoreState {
  app: {
    isInitialized: boolean;
    version: string;
    configuration: EnterpriseConfiguration;
    performance: PerformanceMetrics;
  };
  
  navigation: {
    currentRoute: string;
    previousRoute: string;
    navigationStack: string[];
  };
  
  ui: {
    theme: ThemeState;
    modals: Modal[];
    toasts: Toast[];
    loading: LoadingState;
  };
}

export interface UserState {
  profile: UserProfile | null;
  userType: UserType | null;
  permissions: Permission[];
  preferences: UserPreferences;
  session: SessionState;
  authentication: AuthenticationState;
}

export interface ModuleStatesMap {
  [moduleId: string]: ModuleState;
}

export interface ModuleState {
  id: string;
  name: string;
  isLoaded: boolean;
  isActive: boolean;
  data: any;
  ui: ModuleUIState;
  configuration: ModuleConfiguration;
  performance: ModulePerformanceMetrics;
}
```

### Core State Management Store

**IMPLEMENT** enterprise-grade core state management:

```typescript
// core/state/stores/coreStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import { subscribeWithSelector } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface CoreStoreState extends CoreState {
  // Actions
  initializeApp: () => Promise<void>;
  updateConfiguration: (config: Partial<EnterpriseConfiguration>) => void;
  updatePerformanceMetrics: (metrics: Partial<PerformanceMetrics>) => void;
  
  // Navigation actions
  setCurrentRoute: (route: string) => void;
  addToNavigationStack: (route: string) => void;
  clearNavigationStack: () => void;
  
  // UI actions
  setTheme: (theme: ThemeState) => void;
  showModal: (modal: Modal) => void;
  hideModal: (modalId: string) => void;
  showToast: (toast: Toast) => void;
  hideToast: (toastId: string) => void;
  setLoading: (loading: Partial<LoadingState>) => void;
}

export const useCoreStore = create<CoreStoreState>()(
  subscribeWithSelector(
    persist(
      immer((set, get) => ({
        // Initial state
        app: {
          isInitialized: false,
          version: '1.0.0',
          configuration: null,
          performance: {
            memoryUsage: 0,
            cpuUsage: 0,
            networkLatency: 0,
            frameRate: 60
          }
        },
        
        navigation: {
          currentRoute: '',
          previousRoute: '',
          navigationStack: []
        },
        
        ui: {
          theme: {
            mode: 'light',
            colors: {},
            typography: {},
            spacing: {}
          },
          modals: [],
          toasts: [],
          loading: {
            global: false,
            modules: {},
            operations: {}
          }
        },

        // Actions
        initializeApp: async () => {
          set((state) => {
            state.ui.loading.global = true;
          });

          try {
            // Initialize core services
            await Promise.all([
              ConfigurationService.initialize(),
              ModuleRegistryService.initialize(),
              PerformanceMonitoringService.initialize()
            ]);

            set((state) => {
              state.app.isInitialized = true;
              state.ui.loading.global = false;
            });
          } catch (error) {
            console.error('App initialization failed:', error);
            set((state) => {
              state.ui.loading.global = false;
            });
            throw error;
          }
        },

        updateConfiguration: (config: Partial<EnterpriseConfiguration>) => {
          set((state) => {
            if (state.app.configuration) {
              Object.assign(state.app.configuration, config);
            } else {
              state.app.configuration = config as EnterpriseConfiguration;
            }
          });
        },

        updatePerformanceMetrics: (metrics: Partial<PerformanceMetrics>) => {
          set((state) => {
            Object.assign(state.app.performance, metrics);
          });
        },

        setCurrentRoute: (route: string) => {
          set((state) => {
            state.navigation.previousRoute = state.navigation.currentRoute;
            state.navigation.currentRoute = route;
          });
        },

        addToNavigationStack: (route: string) => {
          set((state) => {
            state.navigation.navigationStack.push(route);
            // Keep stack size manageable
            if (state.navigation.navigationStack.length > 10) {
              state.navigation.navigationStack.shift();
            }
          });
        },

        clearNavigationStack: () => {
          set((state) => {
            state.navigation.navigationStack = [];
          });
        },

        setTheme: (theme: ThemeState) => {
          set((state) => {
            state.ui.theme = theme;
          });
        },

        showModal: (modal: Modal) => {
          set((state) => {
            state.ui.modals.push({
              ...modal,
              id: modal.id || `modal_${Date.now()}`
            });
          });
        },

        hideModal: (modalId: string) => {
          set((state) => {
            state.ui.modals = state.ui.modals.filter(modal => modal.id !== modalId);
          });
        },

        showToast: (toast: Toast) => {
          set((state) => {
            state.ui.toasts.push({
              ...toast,
              id: toast.id || `toast_${Date.now()}`
            });
          });
        },

        hideToast: (toastId: string) => {
          set((state) => {
            state.ui.toasts = state.ui.toasts.filter(toast => toast.id !== toastId);
          });
        },

        setLoading: (loading: Partial<LoadingState>) => {
          set((state) => {
            Object.assign(state.ui.loading, loading);
          });
        }
      })),
      {
        name: 'core-storage',
        storage: createJSONStorage(() => AsyncStorage),
        partialize: (state) => ({
          app: {
            version: state.app.version,
            configuration: state.app.configuration
          },
          ui: {
            theme: state.ui.theme
          }
        })
      }
    )
  )
);

// Selectors for optimized access
export const useAppInitialized = () => useCoreStore((state) => state.app.isInitialized);
export const useAppConfiguration = () => useCoreStore((state) => state.app.configuration);
export const useCurrentRoute = () => useCoreStore((state) => state.navigation.currentRoute);
export const useTheme = () => useCoreStore((state) => state.ui.theme);
export const useModals = () => useCoreStore((state) => state.ui.modals);
export const useToasts = () => useCoreStore((state) => state.ui.toasts);
export const useGlobalLoading = () => useCoreStore((state) => state.ui.loading.global);
```

### User State Management

**IMPLEMENT** user-type-specific state management:

```typescript
// core/state/stores/userStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

interface UserStoreState extends UserState {
  // Actions
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => Promise<void>;
  updateProfile: (updates: Partial<UserProfile>) => void;
  updatePreferences: (preferences: Partial<UserPreferences>) => void;
  setUserType: (userType: UserType) => void;
  updatePermissions: (permissions: Permission[]) => void;
  refreshSession: () => Promise<void>;
  
  // Computed properties
  hasPermission: (permission: string) => boolean;
  getModulePermissions: (moduleId: string) => Permission[];
  isSessionValid: () => boolean;
}

export const useUserStore = create<UserStoreState>()(
  persist(
    immer((set, get) => ({
      // Initial state
      profile: null,
      userType: null,
      permissions: [],
      preferences: {
        language: 'en',
        timezone: 'UTC',
        notifications: {
          push: true,
          email: true,
          inApp: true
        },
        accessibility: {
          fontSize: 'medium',
          highContrast: false,
          reduceMotion: false
        }
      },
      session: {
        token: null,
        refreshToken: null,
        expiresAt: null,
        lastActivity: null
      },
      authentication: {
        isAuthenticated: false,
        isLoading: false,
        error: null,
        lastLoginAt: null,
        loginAttempts: 0
      },

      // Actions
      login: async (credentials: LoginCredentials) => {
        set((state) => {
          state.authentication.isLoading = true;
          state.authentication.error = null;
        });

### State Testing Strategies

**IMPLEMENT** comprehensive state testing:

```typescript
// __tests__/state/coreStore.test.ts
import { renderHook, act } from '@testing-library/react-native';
import { useCoreStore } from '@/core/state/stores/coreStore';

describe('CoreStore', () => {
  beforeEach(() => {
    // Reset store state before each test
    useCoreStore.setState({
      app: {
        isInitialized: false,
        version: '1.0.0',
        configuration: null,
        performance: {
          memoryUsage: 0,
          cpuUsage: 0,
          networkLatency: 0,
          frameRate: 60
        }
      },
      navigation: {
        currentRoute: '',
        previousRoute: '',
        navigationStack: []
      },
      ui: {
        theme: {
          mode: 'light',
          colors: {},
          typography: {},
          spacing: {}
        },
        modals: [],
        toasts: [],
        loading: {
          global: false,
          modules: {},
          operations: {}
        }
      }
    });
  });

  it('should initialize app successfully', async () => {
    const { result } = renderHook(() => useCoreStore());

    expect(result.current.app.isInitialized).toBe(false);

    await act(async () => {
      await result.current.initializeApp();
    });

    expect(result.current.app.isInitialized).toBe(true);
    expect(result.current.ui.loading.global).toBe(false);
  });

  it('should manage navigation state correctly', () => {
    const { result } = renderHook(() => useCoreStore());

    act(() => {
      result.current.setCurrentRoute('/dashboard');
    });

    expect(result.current.navigation.currentRoute).toBe('/dashboard');
    expect(result.current.navigation.previousRoute).toBe('');

    act(() => {
      result.current.setCurrentRoute('/profile');
    });

    expect(result.current.navigation.currentRoute).toBe('/profile');
    expect(result.current.navigation.previousRoute).toBe('/dashboard');
  });

  it('should manage modals correctly', () => {
    const { result } = renderHook(() => useCoreStore());

    const modal = {
      type: 'alert' as const,
      title: 'Test Modal',
      content: 'Test content'
    };

    act(() => {
      result.current.showModal(modal);
    });

    expect(result.current.ui.modals).toHaveLength(1);
    expect(result.current.ui.modals[0].title).toBe('Test Modal');

    const modalId = result.current.ui.modals[0].id;

    act(() => {
      result.current.hideModal(modalId);
    });

    expect(result.current.ui.modals).toHaveLength(0);
  });
});
```

**IMPLEMENT** module state testing:

```typescript
// __tests__/state/moduleStateStore.test.ts
import { renderHook, act } from '@testing-library/react-native';
import { useModuleStateStore } from '@/core/state/stores/moduleStateStore';

describe('ModuleStateStore', () => {
  const mockModuleState = {
    id: 'timeTracking',
    name: 'Time Tracking',
    isLoaded: false,
    isActive: false,
    data: null,
    ui: {
      loading: false,
      error: null,
      visible: true
    },
    configuration: {
      id: 'timeTracking',
      enabled: true,
      settings: {}
    },
    performance: {
      loadTime: 0,
      memoryUsage: 0
    }
  };

  beforeEach(() => {
    useModuleStateStore.setState({ modules: {} });
  });

  it('should register and unregister modules', () => {
    const { result } = renderHook(() => useModuleStateStore());

    act(() => {
      result.current.registerModule('timeTracking', mockModuleState);
    });

    expect(result.current.modules.timeTracking).toEqual(mockModuleState);
    expect(result.current.isModuleLoaded('timeTracking')).toBe(false);

    act(() => {
      result.current.unregisterModule('timeTracking');
    });

    expect(result.current.modules.timeTracking).toBeUndefined();
  });

  it('should update module state correctly', () => {
    const { result } = renderHook(() => useModuleStateStore());

    act(() => {
      result.current.registerModule('timeTracking', mockModuleState);
    });

    act(() => {
      result.current.updateModuleState('timeTracking', { 
        isLoaded: true, 
        isActive: true 
      });
    });

    expect(result.current.modules.timeTracking.isLoaded).toBe(true);
    expect(result.current.modules.timeTracking.isActive).toBe(true);
  });
});
```

## Anti-Patterns

**DON'T** implement these state management approaches:

### State Anti-Patterns

- **NEVER** mutate state directly without using proper state management tools
- **AVOID** storing derived data in state that can be computed from existing state
- **DON'T** create deeply nested state structures that are difficult to update
- **NEVER** store non-serializable data (functions, classes) in persisted state
- **AVOID** creating multiple sources of truth for the same data
- **DON'T** ignore loading and error states in state management
- **NEVER** store sensitive data in client-side state without proper security
- **AVOID** creating circular dependencies between different state stores

### Performance Anti-Patterns

- **DON'T** create unnecessary re-renders by subscribing to entire state objects
- **AVOID** storing UI state that should be local component state
- **NEVER** ignore state subscription cleanup in component unmounts
- **DON'T** create expensive computations in state selectors without memoization
- **AVOID** frequent state updates that can cause performance issues
- **NEVER** store large datasets in memory without proper pagination

### Enterprise Anti-Patterns

- **DON'T** couple module state too tightly with specific UI components
- **AVOID** hardcoding user permissions or module configurations in state
- **NEVER** ignore state synchronization issues in multi-user scenarios
- **DON'T** implement state without proper audit trails for enterprise requirements
- **AVOID** state management without proper rollback and recovery mechanisms

## Validation Checklist

**MUST** verify these state management requirements:

### Core State Management
- [ ] State is properly typed with TypeScript interfaces
- [ ] State updates use immutable patterns (Immer integration)
- [ ] State persistence works correctly with AsyncStorage
- [ ] State cleanup prevents memory leaks
- [ ] Loading and error states are properly handled

### Enterprise Requirements
- [ ] Module state isolation works correctly
- [ ] User-type-specific state management is implemented
- [ ] Real-time state updates work across modules
- [ ] Offline state synchronization functions properly
- [ ] State audit trails are maintained for enterprise compliance

### Performance Validation
- [ ] State selectors prevent unnecessary re-renders
- [ ] State subscription cleanup is properly implemented
- [ ] State updates are optimized for performance
- [ ] Memory usage is monitored and optimized
- [ ] State operations don't block the UI thread

### Testing Coverage
- [ ] Unit tests cover all state stores and actions
- [ ] Integration tests verify state interactions
- [ ] Performance tests validate state operation efficiency
- [ ] End-to-end tests verify state persistence and synchronization

## References

- [Zustand Documentation](https://zustand-demo.pmnd.rs/)
- [TanStack Query (React Query)](https://tanstack.com/query/latest)
- [State Management Patterns](https://kentcdodds.com/blog/application-state-management-with-react)
- [React Native State Management](https://reactnative.dev/docs/state)
- [Offline First Architecture](https://www.oreilly.com/library/view/building-mobile-apps/9781491944851/ch04.html)
