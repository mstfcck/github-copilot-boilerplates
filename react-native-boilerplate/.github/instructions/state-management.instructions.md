---
applyTo: '**'
---

# State Management Instructions

This document outlines comprehensive state management patterns, data flow architecture, and best practices for React Native applications using modern state management solutions.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** separate client state from server state with appropriate tools
- **REQUIRED** to implement predictable state updates with immutable patterns
- **SHALL** use proper TypeScript types for all state definitions
- **MUST** implement proper error handling and loading states
- **NEVER** mutate state directly - always use proper update mechanisms
- **REQUIRED** to implement state persistence for critical application data
- **SHALL** optimize re-renders by using proper selectors and memoization
- **MUST** implement proper cleanup to prevent memory leaks
- **REQUIRED** to handle offline state and data synchronization
- **SHALL** implement proper state testing strategies

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** use Zustand for client state and React Query for server state
- **RECOMMENDED** to implement optimistic updates for better user experience
- **ALWAYS** implement proper state normalization for complex data structures
- **DO** implement state middleware for debugging, logging, and persistence
- **SHOULD** use proper state composition patterns for scalability
- **RECOMMENDED** to implement proper cache invalidation strategies
- **DO** implement state-driven UI patterns with loading and error boundaries
- **ALWAYS** implement proper state hydration and dehydration
- **SHOULD** use proper state selectors to prevent unnecessary re-renders

### Optional Enhancements (**MAY** Consider)

- **MAY** implement advanced caching strategies with TTL and background refresh
- **OPTIONAL** to use state machines for complex application flows
- **USE** state devtools for development and debugging
- **IMPLEMENT** state analytics and monitoring in production
- **AVOID** over-engineering simple state requirements

## Implementation Guidance

### Client State Management with Zustand

**USE** Zustand for application client state:

```typescript
// store/authStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import AsyncStorage from '@react-native-async-storage/async-storage';

export interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
  preferences: {
    theme: 'light' | 'dark' | 'system';
    notifications: boolean;
    language: string;
  };
}

interface AuthState {
  // State
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  
  // Actions
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  updateUser: (updates: Partial<User>) => void;
  updatePreferences: (preferences: Partial<User['preferences']>) => void;
  clearError: () => void;
  setLoading: (loading: boolean) => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    immer((set, get) => ({
      // Initial state
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      // Actions
      login: async (email: string, password: string) => {
        set((state) => {
          state.isLoading = true;
          state.error = null;
        });

        try {
          const response = await authService.login(email, password);
          const { user, token } = response;

          // Store token securely
          await secureStorage.setItem('auth_token', token);

          set((state) => {
            state.user = user;
            state.isAuthenticated = true;
            state.isLoading = false;
          });
        } catch (error) {
          set((state) => {
            state.error = error.message || 'Login failed';
            state.isLoading = false;
          });
          throw error;
        }
      },

      logout: () => {
        // Clear secure storage
        secureStorage.removeItem('auth_token');
        
        set((state) => {
          state.user = null;
          state.isAuthenticated = false;
          state.error = null;
        });
      },

      updateUser: (updates: Partial<User>) => {
        set((state) => {
          if (state.user) {
            Object.assign(state.user, updates);
          }
        });
      },

      updatePreferences: (preferences: Partial<User['preferences']>) => {
        set((state) => {
          if (state.user) {
            Object.assign(state.user.preferences, preferences);
          }
        });
      },

      clearError: () => {
        set((state) => {
          state.error = null;
        });
      },

      setLoading: (loading: boolean) => {
        set((state) => {
          state.isLoading = loading;
        });
      },
    })),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        user: state.user,
        isAuthenticated: state.isAuthenticated,
        // Don't persist loading states or errors
      }),
    }
  )
);

// Selectors for optimized re-renders
export const useUser = () => useAuthStore((state) => state.user);
export const useIsAuthenticated = () => useAuthStore((state) => state.isAuthenticated);
export const useAuthLoading = () => useAuthStore((state) => state.isLoading);
export const useAuthError = () => useAuthStore((state) => state.error);
```

**IMPLEMENT** UI state management:

```typescript
// store/uiStore.ts
import { create } from 'zustand';
import { subscribeWithSelector } from 'zustand/middleware';

interface Modal {
  id: string;
  type: 'alert' | 'confirm' | 'custom';
  title: string;
  content?: string;
  onConfirm?: () => void;
  onCancel?: () => void;
  component?: React.ComponentType<any>;
  props?: any;
}

interface Toast {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  message: string;
  duration?: number;
}

interface UIState {
  // Loading states
  globalLoading: boolean;
  loadingStates: Record<string, boolean>;
  
  // Modal management
  modals: Modal[];
  
  // Toast notifications
  toasts: Toast[];
  
  // Network state
  isOnline: boolean;
  
  // App state
  isAppActive: boolean;
  
  // Actions
  setGlobalLoading: (loading: boolean) => void;
  setLoading: (key: string, loading: boolean) => void;
  showModal: (modal: Omit<Modal, 'id'>) => string;
  hideModal: (id: string) => void;
  showToast: (toast: Omit<Toast, 'id'>) => string;
  hideToast: (id: string) => void;
  setOnlineStatus: (isOnline: boolean) => void;
  setAppActive: (isActive: boolean) => void;
}

export const useUIStore = create<UIState>()(
  subscribeWithSelector((set, get) => ({
    // Initial state
    globalLoading: false,
    loadingStates: {},
    modals: [],
    toasts: [],
    isOnline: true,
    isAppActive: true,

    // Actions
    setGlobalLoading: (loading: boolean) => {
      set({ globalLoading: loading });
    },

    setLoading: (key: string, loading: boolean) => {
      set((state) => ({
        loadingStates: {
          ...state.loadingStates,
          [key]: loading,
        },
      }));
    },

    showModal: (modal: Omit<Modal, 'id'>) => {
      const id = `modal_${Date.now()}_${Math.random()}`;
      set((state) => ({
        modals: [...state.modals, { ...modal, id }],
      }));
      return id;
    },

    hideModal: (id: string) => {
      set((state) => ({
        modals: state.modals.filter((modal) => modal.id !== id),
      }));
    },

    showToast: (toast: Omit<Toast, 'id'>) => {
      const id = `toast_${Date.now()}_${Math.random()}`;
      const newToast = { ...toast, id };
      
      set((state) => ({
        toasts: [...state.toasts, newToast],
      }));

      // Auto-hide toast after duration
      const duration = toast.duration || 3000;
      setTimeout(() => {
        get().hideToast(id);
      }, duration);

      return id;
    },

    hideToast: (id: string) => {
      set((state) => ({
        toasts: state.toasts.filter((toast) => toast.id !== id),
      }));
    },

    setOnlineStatus: (isOnline: boolean) => {
      set({ isOnline });
    },

    setAppActive: (isActive: boolean) => {
      set({ isAppActive });
    },
  }))
);

// Specialized selectors
export const useGlobalLoading = () => useUIStore((state) => state.globalLoading);
export const useLoadingState = (key: string) => 
  useUIStore((state) => state.loadingStates[key] || false);
export const useModals = () => useUIStore((state) => state.modals);
export const useToasts = () => useUIStore((state) => state.toasts);
export const useNetworkStatus = () => useUIStore((state) => state.isOnline);
```

### Server State Management with React Query

**USE** React Query for server state:

```typescript
// hooks/api/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { userService } from '@services/userService';
import { User, CreateUserRequest, UpdateUserRequest } from '@types/user';

// Query keys
export const userKeys = {
  all: ['users'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (filters: any) => [...userKeys.lists(), { filters }] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
};

// Fetch users with pagination and filtering
export const useUsers = (params: {
  page?: number;
  limit?: number;
  search?: string;
  status?: 'active' | 'inactive';
}) => {
  return useQuery({
    queryKey: userKeys.list(params),
    queryFn: () => userService.getUsers(params),
    staleTime: 5 * 60 * 1000, // 5 minutes
    gcTime: 10 * 60 * 1000, // 10 minutes
    retry: 3,
    retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
  });
};

// Fetch single user
export const useUser = (userId: string, enabled = true) => {
  return useQuery({
    queryKey: userKeys.detail(userId),
    queryFn: () => userService.getUser(userId),
    enabled: enabled && !!userId,
    staleTime: 10 * 60 * 1000, // 10 minutes
    retry: (failureCount, error: any) => {
      // Don't retry on 404
      if (error?.status === 404) return false;
      return failureCount < 3;
    },
  });
};

// Create user mutation
export const useCreateUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateUserRequest) => userService.createUser(data),
    onSuccess: (newUser) => {
      // Invalidate and refetch users list
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
      
      // Add the new user to the cache
      queryClient.setQueryData(userKeys.detail(newUser.id), newUser);
    },
    onError: (error) => {
      console.error('Failed to create user:', error);
    },
  });
};

// Update user mutation with optimistic updates
export const useUpdateUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateUserRequest }) =>
      userService.updateUser(id, data),
    
    onMutate: async ({ id, data }) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: userKeys.detail(id) });

      // Snapshot previous value
      const previousUser = queryClient.getQueryData(userKeys.detail(id));

      // Optimistically update
      queryClient.setQueryData(userKeys.detail(id), (old: User | undefined) => {
        if (!old) return old;
        return { ...old, ...data };
      });

      return { previousUser, id };
    },
    
    onError: (error, variables, context) => {
      // Rollback on error
      if (context?.previousUser) {
        queryClient.setQueryData(
          userKeys.detail(context.id),
          context.previousUser
        );
      }
    },
    
    onSettled: (data, error, variables) => {
      // Always refetch after error or success
      queryClient.invalidateQueries({ queryKey: userKeys.detail(variables.id) });
    },
  });
};

// Delete user mutation
export const useDeleteUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (userId: string) => userService.deleteUser(userId),
    onSuccess: (_, userId) => {
      // Remove user from cache
      queryClient.removeQueries({ queryKey: userKeys.detail(userId) });
      
      // Invalidate users list
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
    },
  });
};

// Infinite query for large datasets
export const useInfiniteUsers = (params: { search?: string; status?: string }) => {
  return useInfiniteQuery({
    queryKey: [...userKeys.lists(), 'infinite', params],
    queryFn: ({ pageParam = 1 }) =>
      userService.getUsers({ ...params, page: pageParam, limit: 20 }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
    staleTime: 5 * 60 * 1000,
  });
};
```

**IMPLEMENT** offline support and synchronization:

```typescript
// hooks/useOfflineSync.ts
import { useEffect } from 'react';
import { useNetInfo } from '@react-native-community/netinfo';
import { useQueryClient } from '@tanstack/react-query';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface OfflineAction {
  id: string;
  type: 'create' | 'update' | 'delete';
  resource: string;
  data: any;
  timestamp: number;
}

const OFFLINE_QUEUE_KEY = 'offline_actions_queue';

export const useOfflineSync = () => {
  const netInfo = useNetInfo();
  const queryClient = useQueryClient();

  // Queue offline actions
  const queueOfflineAction = async (action: Omit<OfflineAction, 'id' | 'timestamp'>) => {
    const offlineAction: OfflineAction = {
      ...action,
      id: `${Date.now()}_${Math.random()}`,
      timestamp: Date.now(),
    };

    try {
      const existingQueue = await AsyncStorage.getItem(OFFLINE_QUEUE_KEY);
      const queue: OfflineAction[] = existingQueue ? JSON.parse(existingQueue) : [];
      queue.push(offlineAction);
      
      await AsyncStorage.setItem(OFFLINE_QUEUE_KEY, JSON.stringify(queue));
    } catch (error) {
      console.error('Failed to queue offline action:', error);
    }
  };

  // Process offline queue when online
  const processOfflineQueue = async () => {
    try {
      const queueData = await AsyncStorage.getItem(OFFLINE_QUEUE_KEY);
      if (!queueData) return;

      const queue: OfflineAction[] = JSON.parse(queueData);
      if (queue.length === 0) return;

      console.log(`Processing ${queue.length} offline actions`);

      const processedActions: string[] = [];

      for (const action of queue) {
        try {
          await processOfflineAction(action);
          processedActions.push(action.id);
        } catch (error) {
          console.error('Failed to process offline action:', action, error);
          // Keep failed actions in queue for retry
        }
      }

      // Remove processed actions from queue
      const remainingQueue = queue.filter(action => !processedActions.includes(action.id));
      await AsyncStorage.setItem(OFFLINE_QUEUE_KEY, JSON.stringify(remainingQueue));

      // Invalidate relevant queries after sync
      queryClient.invalidateQueries();

    } catch (error) {
      console.error('Failed to process offline queue:', error);
    }
  };

  const processOfflineAction = async (action: OfflineAction) => {
    switch (action.type) {
      case 'create':
        return await handleOfflineCreate(action);
      case 'update':
        return await handleOfflineUpdate(action);
      case 'delete':
        return await handleOfflineDelete(action);
      default:
        throw new Error(`Unknown action type: ${action.type}`);
    }
  };

  const handleOfflineCreate = async (action: OfflineAction) => {
    // Implement create logic based on resource type
    switch (action.resource) {
      case 'user':
        return await userService.createUser(action.data);
      // Add other resources
      default:
        throw new Error(`Unknown resource: ${action.resource}`);
    }
  };

  const handleOfflineUpdate = async (action: OfflineAction) => {
    // Implement update logic
    switch (action.resource) {
      case 'user':
        return await userService.updateUser(action.data.id, action.data);
      default:
        throw new Error(`Unknown resource: ${action.resource}`);
    }
  };

  const handleOfflineDelete = async (action: OfflineAction) => {
    // Implement delete logic
    switch (action.resource) {
      case 'user':
        return await userService.deleteUser(action.data.id);
      default:
        throw new Error(`Unknown resource: ${action.resource}`);
    }
  };

  // Process queue when coming online
  useEffect(() => {
    if (netInfo.isConnected && netInfo.isInternetReachable) {
      processOfflineQueue();
    }
  }, [netInfo.isConnected, netInfo.isInternetReachable]);

  return {
    isOnline: netInfo.isConnected && netInfo.isInternetReachable,
    queueOfflineAction,
    processOfflineQueue,
  };
};
```

### State Composition and Complex State Management

**IMPLEMENT** state composition patterns:

```typescript
// store/index.ts - Root store composition
import { create } from 'zustand';
import { devtools, subscribeWithSelector } from 'zustand/middleware';
import { createAuthSlice, AuthSlice } from './slices/authSlice';
import { createUISlice, UISlice } from './slices/uiSlice';
import { createSettingsSlice, SettingsSlice } from './slices/settingsSlice';

// Combined store type
export type StoreState = AuthSlice & UISlice & SettingsSlice;

// Create the combined store
export const useAppStore = create<StoreState>()(
  devtools(
    subscribeWithSelector((...a) => ({
      ...createAuthSlice(...a),
      ...createUISlice(...a),
      ...createSettingsSlice(...a),
    })),
    { name: 'app-store' }
  )
);

// Slice-specific selectors
export const useAuth = () => useAppStore((state) => ({
  user: state.user,
  isAuthenticated: state.isAuthenticated,
  login: state.login,
  logout: state.logout,
}));

export const useUI = () => useAppStore((state) => ({
  modals: state.modals,
  toasts: state.toasts,
  showModal: state.showModal,
  showToast: state.showToast,
}));

export const useSettings = () => useAppStore((state) => ({
  theme: state.theme,
  language: state.language,
  setTheme: state.setTheme,
  setLanguage: state.setLanguage,
}));

// Store subscription for side effects
useAppStore.subscribe(
  (state) => state.user,
  (user, previousUser) => {
    if (user && !previousUser) {
      console.log('User logged in:', user.email);
      // Analytics, crash reporting setup, etc.
    } else if (!user && previousUser) {
      console.log('User logged out');
      // Cleanup analytics, crash reporting, etc.
    }
  }
);
```

## Anti-Patterns

### **DON'T** implement these state management anti-patterns

**AVOID** direct state mutation:

```typescript
// ❌ Bad: Direct mutation
const updateUser = (newData) => {
  state.user.name = newData.name; // Direct mutation
  state.user.email = newData.email;
};

// ✅ Good: Immutable updates
const updateUser = (newData) => {
  set((state) => {
    state.user = { ...state.user, ...newData };
  });
};
```

**DON'T** mix client and server state:

```typescript
// ❌ Bad: Server data in client state
const useUserStore = create((set) => ({
  users: [], // Server data in client state
  fetchUsers: async () => {
    const users = await api.getUsers();
    set({ users });
  },
}));

// ✅ Good: Separate concerns
const useUsers = () => {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => api.getUsers(),
  });
};
```

**NEVER** ignore loading and error states:

```typescript
// ❌ Bad: No loading/error handling
const UserList = () => {
  const { users } = useUsers();
  
  return (
    <FlatList
      data={users}
      renderItem={({ item }) => <UserItem user={item} />}
    />
  );
};

// ✅ Good: Proper state handling
const UserList = () => {
  const { data: users, isLoading, error } = useUsers();
  
  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;
  
  return (
    <FlatList
      data={users}
      renderItem={({ item }) => <UserItem user={item} />}
    />
  );
};
```

## Validation Checklist

### **MUST** verify

- [ ] Client state and server state are managed with appropriate tools
- [ ] All state updates use immutable patterns
- [ ] TypeScript types are defined for all state
- [ ] Loading and error states are handled properly
- [ ] State persistence works for critical data
- [ ] Offline functionality is implemented where needed
- [ ] State testing covers critical functionality
- [ ] Memory leaks are prevented with proper cleanup

### **SHOULD** check

- [ ] Optimistic updates improve user experience
- [ ] State normalization is used for complex data
- [ ] Cache invalidation strategies are implemented
- [ ] State middleware provides useful debugging info
- [ ] Re-renders are optimized with proper selectors
- [ ] State composition patterns scale well
- [ ] Background refresh keeps data fresh
- [ ] State hydration/dehydration works correctly

## References

- [Zustand Documentation](https://zustand-demo.pmnd.rs/)
- [TanStack Query (React Query)](https://tanstack.com/query/latest)
- [State Management Patterns](https://kentcdodds.com/blog/application-state-management-with-react)
- [React Native State Management](https://reactnative.dev/docs/state)
- [Offline First Architecture](https://www.oreilly.com/library/view/building-mobile-apps/9781491944851/ch04.html)
