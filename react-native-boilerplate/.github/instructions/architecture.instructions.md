---
applyTo: '**'
---

# Architecture Instructions

This document outlines the architectural patterns, component organization, and design principles for React Native development using modern cross-platform architecture patterns.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** use functional components with hooks instead of class components
- **REQUIRED** to implement proper TypeScript interfaces for all component props and state
- **SHALL** separate business logic from presentation logic using container/presenter pattern
- **MUST** implement proper error boundaries to prevent app crashes from propagating
- **NEVER** directly mutate state objects or arrays - use immutable update patterns
- **MUST** follow single responsibility principle - each component should have one reason to change
- **REQUIRED** to implement proper cleanup for subscriptions, timers, and event listeners
- **SHALL** use React.memo() for performance optimization of frequently re-rendered components

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** use custom hooks to extract and reuse stateful logic across components
- **RECOMMENDED** to implement compound component patterns for flexible component APIs
- **ALWAYS** use proper loading and error states for all asynchronous operations
- **DO** implement lazy loading for screens and large components to improve initial load time
- **SHOULD** use context sparingly and only for truly global state (theme, auth, locale)
- **RECOMMENDED** to implement proper accessibility support with screen reader compatibility
- **DO** use consistent file and folder naming conventions throughout the project
- **ALWAYS** implement proper TypeScript strict mode configurations
- **SHOULD** use React DevTools and Flipper for debugging and performance monitoring

### Optional Enhancements (**MAY** Consider)

- **MAY** implement advanced animation patterns using React Native Reanimated
- **OPTIONAL** to use code splitting and dynamic imports for improved performance
- **USE** Storybook for component documentation and visual testing
- **IMPLEMENT** advanced error tracking with crash reporting services
- **AVOID** over-engineering simple components with unnecessary abstractions

## Implementation Guidance

### Component Architecture Patterns

**USE** these component organization patterns:

```typescript
// Functional Component with TypeScript
import React, { useCallback, useMemo } from 'react';
import { View, Text, StyleSheet } from 'react-native';

interface UserCardProps {
  user: {
    id: string;
    name: string;
    email: string;
    avatar?: string;
  };
  onPress?: (userId: string) => void;
  variant?: 'compact' | 'expanded';
}

export const UserCard: React.FC<UserCardProps> = ({
  user,
  onPress,
  variant = 'compact'
}) => {
  const handlePress = useCallback(() => {
    onPress?.(user.id);
  }, [onPress, user.id]);

  const containerStyle = useMemo(() => [
    styles.container,
    variant === 'expanded' && styles.expandedContainer
  ], [variant]);

  return (
    <View style={containerStyle}>
      <Text style={styles.name}>{user.name}</Text>
      <Text style={styles.email}>{user.email}</Text>
    </View>
  );
};
```

**IMPLEMENT** container/presenter pattern:

```typescript
// Container Component (Business Logic)
export const UserListContainer: React.FC = () => {
  const { data: users, isLoading, error } = useUsers();
  const { navigateToProfile } = useNavigation();

  const handleUserSelect = useCallback((userId: string) => {
    navigateToProfile(userId);
  }, [navigateToProfile]);

  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;

  return (
    <UserListPresenter
      users={users}
      onUserSelect={handleUserSelect}
    />
  );
};

// Presenter Component (UI Logic)
interface UserListPresenterProps {
  users: User[];
  onUserSelect: (userId: string) => void;
}

export const UserListPresenter: React.FC<UserListPresenterProps> = ({
  users,
  onUserSelect
}) => (
  <FlatList
    data={users}
    renderItem={({ item }) => (
      <UserCard user={item} onPress={onUserSelect} />
    )}
    keyExtractor={(item) => item.id}
  />
);
```

**ENSURE** proper custom hooks implementation:

```typescript
// Custom Hook for User Management
export const useUserManagement = () => {
  const [selectedUsers, setSelectedUsers] = useState<string[]>([]);
  
  const toggleUser = useCallback((userId: string) => {
    setSelectedUsers(prev => 
      prev.includes(userId)
        ? prev.filter(id => id !== userId)
        : [...prev, userId]
    );
  }, []);

  const clearSelection = useCallback(() => {
    setSelectedUsers([]);
  }, []);

  return {
    selectedUsers,
    toggleUser,
    clearSelection,
    hasSelection: selectedUsers.length > 0
  };
};
```

### Folder Structure Architecture

**MUST** organize code using this structure:

```
src/
├── components/           # Reusable UI components
│   ├── common/          # Generic components (Button, Input, etc.)
│   ├── forms/           # Form-specific components
│   └── layout/          # Layout components (Header, Footer, etc.)
├── screens/             # Screen components
│   ├── auth/           # Authentication screens
│   ├── profile/        # Profile-related screens
│   └── settings/       # Settings screens
├── hooks/              # Custom React hooks
│   ├── api/           # API-related hooks
│   ├── navigation/    # Navigation hooks
│   └── storage/       # Storage hooks
├── services/           # Business logic and external services
│   ├── api/           # API service layer
│   ├── storage/       # Storage services
│   └── auth/          # Authentication services
├── store/             # State management
│   ├── slices/        # State slices (if using Redux)
│   └── providers/     # Context providers
├── utils/             # Utility functions
│   ├── validation/    # Validation helpers
│   ├── formatting/    # Data formatting utilities
│   └── constants/     # Application constants
├── types/             # TypeScript type definitions
│   ├── api.ts         # API response types
│   ├── navigation.ts  # Navigation types
│   └── common.ts      # Common types
└── assets/            # Static assets
    ├── images/        # Image assets
    ├── fonts/         # Font files
    └── icons/         # Icon assets
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
