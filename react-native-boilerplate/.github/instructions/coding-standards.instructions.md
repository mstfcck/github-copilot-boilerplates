---
applyTo: '**'
---

# Coding Standards Instructions

This document outlines comprehensive coding standards, style guidelines, and quality assurance practices for React Native applications using TypeScript, ensuring consistent, maintainable, and high-quality code.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** use TypeScript with strict mode enabled for all source code
- **REQUIRED** to follow ESLint and Prettier configurations consistently
- **SHALL** implement proper error handling patterns throughout the application
- **MUST** write comprehensive JSDoc comments for all public APIs
- **NEVER** use `any` type without proper justification and documentation
- **REQUIRED** to follow established naming conventions for files, functions, and variables
- **SHALL** implement proper component composition and reusability patterns
- **MUST** follow React Native performance best practices
- **REQUIRED** to implement proper accessibility standards
- **SHALL** follow security coding practices and input validation

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** use functional components with hooks instead of class components
- **RECOMMENDED** to implement custom hooks for reusable logic
- **ALWAYS** use proper TypeScript interfaces and types for data structures
- **DO** implement consistent error boundaries and error handling
- **SHOULD** use proper memoization techniques for performance optimization
- **RECOMMENDED** to implement proper testing alongside code development
- **DO** follow SOLID principles in component and service design
- **ALWAYS** implement proper logging and debugging support
- **SHOULD** use consistent patterns for API integration and data fetching

### Optional Enhancements (**MAY** Consider)

- **MAY** implement advanced TypeScript features for type safety
- **OPTIONAL** to use advanced performance monitoring and optimization
- **USE** automated code generation tools where appropriate
- **IMPLEMENT** advanced accessibility features beyond basic requirements
- **AVOID** over-engineering simple components and utilities

## Implementation Guidance

### TypeScript Configuration and Usage

**USE** strict TypeScript configuration:

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "es2018",
    "lib": ["es2018", "esnext.asynciterable"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "baseUrl": "./src",
    "paths": {
      "@components/*": ["components/*"],
      "@screens/*": ["screens/*"],
      "@services/*": ["services/*"],
      "@utils/*": ["utils/*"],
      "@hooks/*": ["hooks/*"],
      "@types/*": ["types/*"],
      "@assets/*": ["assets/*"],
      "@config/*": ["config/*"],
      "@navigation/*": ["navigation/*"],
      "@store/*": ["store/*"]
    }
  },
  "include": [
    "src/**/*",
    "__tests__/**/*",
    "e2e/**/*"
  ],
  "exclude": [
    "node_modules",
    "babel.config.js",
    "metro.config.js",
    "jest.config.js"
  ]
}
```

**IMPLEMENT** comprehensive type definitions:

```typescript
// types/api.ts
export interface ApiResponse<T = any> {
  data: T;
  message: string;
  success: boolean;
  timestamp: string;
  metadata?: {
    page?: number;
    limit?: number;
    total?: number;
  };
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, any>;
  timestamp: string;
}

// types/user.ts
export interface User {
  readonly id: string;
  email: string;
  firstName: string;
  lastName: string;
  avatar?: string;
  preferences: UserPreferences;
  createdAt: string;
  updatedAt: string;
}

export interface UserPreferences {
  theme: 'light' | 'dark' | 'system';
  language: string;
  notifications: NotificationSettings;
}

export interface NotificationSettings {
  push: boolean;
  email: boolean;
  sms: boolean;
  marketing: boolean;
}

// Utility types
export type UserUpdate = Partial<Omit<User, 'id' | 'createdAt' | 'updatedAt'>>;
export type ApiEndpoint = 'users' | 'posts' | 'comments' | 'notifications';
export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';

// Generic types for common patterns
export type AsyncState<T> = {
  data: T | null;
  loading: boolean;
  error: string | null;
};

export type ComponentProps<T = {}> = T & {
  testID?: string;
  accessibilityLabel?: string;
};
```

### ESLint and Prettier Configuration

**CONFIGURE** comprehensive linting and formatting:

```json
// .eslintrc.js
module.exports = {
  root: true,
  extends: [
    '@react-native-community',
    'eslint:recommended',
    '@typescript-eslint/recommended',
    '@typescript-eslint/recommended-requiring-type-checking',
    'prettier',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: './tsconfig.json',
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 2020,
    sourceType: 'module',
  },
  plugins: [
    '@typescript-eslint',
    'react',
    'react-hooks',
    'react-native',
    'import',
    'jsx-a11y',
    'security',
  ],
  rules: {
    // TypeScript specific rules
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/explicit-function-return-type': 'warn',
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/prefer-nullish-coalescing': 'error',
    '@typescript-eslint/prefer-optional-chain': 'error',
    '@typescript-eslint/strict-boolean-expressions': 'error',
    
    // React specific rules
    'react/prop-types': 'off', // Using TypeScript
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
    'react/jsx-uses-react': 'off', // React 17+
    'react/react-in-jsx-scope': 'off', // React 17+
    
    // Import rules
    'import/order': [
      'error',
      {
        groups: [
          'builtin',
          'external',
          'internal',
          'parent',
          'sibling',
          'index',
        ],
        'newlines-between': 'always',
        alphabetize: { order: 'asc', caseInsensitive: true },
      },
    ],
    'import/no-unresolved': 'error',
    'import/no-cycle': 'error',
    
    // Security rules
    'security/detect-object-injection': 'warn',
    'security/detect-non-literal-regexp': 'warn',
    
    // Accessibility rules
    'jsx-a11y/accessible-emoji': 'error',
    'jsx-a11y/alt-text': 'error',
    'jsx-a11y/anchor-has-content': 'error',
    
    // General code quality
    'no-console': 'warn',
    'no-debugger': 'error',
    'prefer-const': 'error',
    'no-var': 'error',
    'object-shorthand': 'error',
    'prefer-template': 'error',
  },
  settings: {
    'import/resolver': {
      typescript: {
        alwaysTryTypes: true,
        project: './tsconfig.json',
      },
    },
  },
  overrides: [
    {
      files: ['**/__tests__/**/*', '**/*.test.*'],
      env: {
        jest: true,
      },
      rules: {
        '@typescript-eslint/no-explicit-any': 'off',
      },
    },
  ],
};

// .prettierrc.js
module.exports = {
  arrowParens: 'avoid',
  bracketSameLine: true,
  bracketSpacing: true,
  singleQuote: true,
  trailingComma: 'es5',
  tabWidth: 2,
  semi: true,
  printWidth: 100,
  endOfLine: 'lf',
  quoteProps: 'as-needed',
  jsxSingleQuote: true,
  embeddedLanguageFormatting: 'auto',
};
```

### Naming Conventions

**FOLLOW** consistent naming patterns:

```typescript
// File naming conventions
// ✅ Good examples:
// UserProfile.tsx (PascalCase for components)
// userService.ts (camelCase for services)
// api.types.ts (lowercase with descriptive suffix)
// UserProfile.test.tsx (component name + .test)
// useUserData.ts (camelCase for hooks with 'use' prefix)

// Variable and function naming
// ✅ Good examples:
const userName = 'john_doe'; // camelCase for variables
const API_BASE_URL = 'https://api.example.com'; // SCREAMING_SNAKE_CASE for constants
const getUserById = (id: string): Promise<User> => { /* */ }; // camelCase for functions

// Component naming
interface UserProfileProps { // PascalCase + Props suffix
  user: User;
  onEdit: () => void; // onEventName for callbacks
  isLoading?: boolean; // boolean props with is/has/can prefix
}

const UserProfile: React.FC<UserProfileProps> = ({ user, onEdit, isLoading = false }) => {
  // Component implementation
};

// Hook naming
const useUserData = (userId: string): AsyncState<User> => {
  // Hook implementation with 'use' prefix
};

// Service and utility naming
class UserService { // PascalCase for classes
  static async fetchUser(id: string): Promise<User> { // static methods in PascalCase
    // Implementation
  }
}

export const formatUserName = (user: User): string => { // camelCase for utility functions
  return `${user.firstName} ${user.lastName}`;
};

// Type and interface naming
interface UserApiResponse extends ApiResponse<User> {} // PascalCase for interfaces
type UserStatus = 'active' | 'inactive' | 'pending'; // PascalCase for types
enum UserRole { // PascalCase for enums
  ADMIN = 'admin',
  USER = 'user',
  MODERATOR = 'moderator',
}

// Constants and configuration
const DEFAULT_TIMEOUT = 5000; // SCREAMING_SNAKE_CASE
const APP_CONFIG = {
  API_URL: 'https://api.example.com',
  RETRY_ATTEMPTS: 3,
} as const; // Use 'as const' for immutable config
```

### Component Structure and Patterns

**IMPLEMENT** consistent component patterns:

```typescript
// components/UserProfile/UserProfile.tsx
import React, { memo, useCallback, useMemo } from 'react';
import { View, Text, StyleSheet } from 'react-native';

import { Button } from '@components/Button';
import { Avatar } from '@components/Avatar';
import { useUserData } from '@hooks/useUserData';
import { formatUserName } from '@utils/userUtils';
import type { ComponentProps, User } from '@types';

/**
 * UserProfile component displays user information with edit functionality
 * 
 * @param user - User object containing profile information
 * @param onEdit - Callback function triggered when edit button is pressed
 * @param isLoading - Loading state indicator
 * @param testID - Test identifier for automated testing
 */
interface UserProfileProps extends ComponentProps {
  user: User;
  onEdit: () => void;
  isLoading?: boolean;
  compact?: boolean;
}

/**
 * A reusable user profile component that displays user information
 * and provides edit functionality with proper accessibility support.
 */
export const UserProfile: React.FC<UserProfileProps> = memo(({
  user,
  onEdit,
  isLoading = false,
  compact = false,
  testID = 'user-profile',
  accessibilityLabel,
}) => {
  // Memoize expensive computations
  const displayName = useMemo(() => formatUserName(user), [user]);
  
  // Memoize callback handlers
  const handleEditPress = useCallback(() => {
    if (!isLoading) {
      onEdit();
    }
  }, [onEdit, isLoading]);

  // Conditional styling based on props
  const containerStyle = useMemo(
    () => [
      styles.container,
      compact && styles.containerCompact,
    ],
    [compact]
  );

  return (
    <View
      style={containerStyle}
      testID={testID}
      accessibilityLabel={accessibilityLabel || `Profile for ${displayName}`}
      accessibilityRole='button'
    >
      <Avatar
        source={{ uri: user.avatar }}
        size={compact ? 'small' : 'medium'}
        testID={`${testID}-avatar`}
      />
      
      <View style={styles.userInfo}>
        <Text
          style={styles.userName}
          numberOfLines={1}
          ellipsizeMode='tail'
          accessibilityRole='text'
        >
          {displayName}
        </Text>
        
        <Text
          style={styles.userEmail}
          numberOfLines={1}
          ellipsizeMode='tail'
          accessibilityRole='text'
        >
          {user.email}
        </Text>
      </View>
      
      <Button
        title='Edit'
        onPress={handleEditPress}
        disabled={isLoading}
        variant='secondary'
        size={compact ? 'small' : 'medium'}
        testID={`${testID}-edit-button`}
        accessibilityLabel={`Edit profile for ${displayName}`}
      />
    </View>
  );
});

UserProfile.displayName = 'UserProfile';

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    backgroundColor: '#FFFFFF',
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  containerCompact: {
    padding: 12,
  },
  userInfo: {
    flex: 1,
    marginLeft: 12,
  },
  userName: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1A1A1A',
    marginBottom: 4,
  },
  userEmail: {
    fontSize: 14,
    color: '#666666',
  },
});

// Export component with proper type
export type { UserProfileProps };
```

### Error Handling Patterns

**IMPLEMENT** comprehensive error handling:

```typescript
// utils/errorHandling.ts
export class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode?: number,
    public isOperational = true
  ) {
    super(message);
    this.name = 'AppError';
    
    // Maintains proper stack trace
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, AppError);
    }
  }
}

export class NetworkError extends AppError {
  constructor(message: string, statusCode?: number) {
    super(message, 'NETWORK_ERROR', statusCode);
    this.name = 'NetworkError';
  }
}

export class ValidationError extends AppError {
  constructor(message: string, public field?: string) {
    super(message, 'VALIDATION_ERROR', 400);
    this.name = 'ValidationError';
  }
}

// Error handling utilities
export const handleApiError = (error: unknown): AppError => {
  if (error instanceof AppError) {
    return error;
  }
  
  if (error instanceof Error) {
    return new AppError(error.message, 'UNKNOWN_ERROR');
  }
  
  return new AppError('An unknown error occurred', 'UNKNOWN_ERROR');
};

// Error boundary component
import React, { Component, ErrorInfo, ReactNode } from 'react';
import { View, Text, StyleSheet } from 'react-native';

import { Button } from '@components/Button';
import { logger } from '@services/logger';

interface ErrorBoundaryState {
  hasError: boolean;
  error?: Error;
}

interface ErrorBoundaryProps {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error, errorInfo: ErrorInfo) => void;
}

export class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo): void {
    logger.error('Error boundary caught error:', error, errorInfo);
    this.props.onError?.(error, errorInfo);
  }

  private handleRetry = (): void => {
    this.setState({ hasError: false, error: undefined });
  };

  render(): ReactNode {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <View style={styles.container}>
          <Text style={styles.title}>Something went wrong</Text>
          <Text style={styles.message}>
            {this.state.error?.message || 'An unexpected error occurred'}
          </Text>
          <Button
            title='Try Again'
            onPress={this.handleRetry}
            style={styles.retryButton}
          />
        </View>
      );
    }

    return this.props.children;
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  message: {
    fontSize: 14,
    textAlign: 'center',
    marginBottom: 20,
  },
  retryButton: {
    marginTop: 10,
  },
});
```

### Documentation Standards

**WRITE** comprehensive JSDoc documentation:

```typescript
/**
 * @fileoverview User service for handling user-related API operations
 * @author Your Name
 * @since 1.0.0
 */

import type { ApiResponse, User, UserUpdate } from '@types';

/**
 * Service class for managing user-related operations
 * 
 * @example
 * ```typescript
 * const user = await UserService.fetchUser('123');
 * const updated = await UserService.updateUser('123', { firstName: 'John' });
 * ```
 */
export class UserService {
  /**
   * Fetches a user by their ID
   * 
   * @param id - The unique identifier for the user
   * @returns Promise that resolves to the user object
   * @throws {NetworkError} When the API request fails
   * @throws {ValidationError} When the user ID is invalid
   * 
   * @example
   * ```typescript
   * try {
   *   const user = await UserService.fetchUser('user-123');
   *   console.log(user.email);
   * } catch (error) {
   *   if (error instanceof NetworkError) {
   *     // Handle network error
   *   }
   * }
   * ```
   */
  static async fetchUser(id: string): Promise<User> {
    if (!id?.trim()) {
      throw new ValidationError('User ID is required', 'id');
    }

    try {
      const response = await api.get<ApiResponse<User>>(`/users/${id}`);
      return response.data.data;
    } catch (error) {
      throw new NetworkError(`Failed to fetch user: ${id}`);
    }
  }

  /**
   * Updates user information
   * 
   * @param id - The user ID to update
   * @param updates - Partial user object with fields to update
   * @returns Promise that resolves to the updated user
   * @throws {ValidationError} When required fields are missing
   * @throws {NetworkError} When the API request fails
   * 
   * @since 1.1.0
   */
  static async updateUser(id: string, updates: UserUpdate): Promise<User> {
    // Implementation with proper validation and error handling
  }
}

/**
 * Custom hook for managing user data with caching and error handling
 * 
 * @param userId - The ID of the user to fetch
 * @param options - Configuration options for the hook
 * @returns Object containing user data, loading state, and error information
 * 
 * @example
 * ```typescript
 * const UserComponent = ({ userId }: { userId: string }) => {
 *   const { user, loading, error, refetch } = useUserData(userId);
 *   
 *   if (loading) return <LoadingSpinner />;
 *   if (error) return <ErrorMessage error={error} />;
 *   if (!user) return <NotFound />;
 *   
 *   return <UserProfile user={user} onRefresh={refetch} />;
 * };
 * ```
 */
export interface UseUserDataOptions {
  /** Whether to automatically refetch on mount */
  enabled?: boolean;
  /** Refetch interval in milliseconds */
  refetchInterval?: number;
}

export interface UseUserDataReturn {
  /** The user data, null if not loaded */
  user: User | null;
  /** Loading state indicator */
  loading: boolean;
  /** Error information if request failed */
  error: string | null;
  /** Function to manually refetch user data */
  refetch: () => Promise<void>;
}
```

## Anti-Patterns

### **DON'T** implement these coding anti-patterns

**AVOID** using `any` type without justification:

```typescript
// ❌ Bad: Using any without justification
const processData = (data: any): any => {
  return data.someProperty.process();
};

// ✅ Good: Proper typing
interface ProcessableData {
  someProperty: {
    process(): string;
  };
}

const processData = (data: ProcessableData): string => {
  return data.someProperty.process();
};
```

**NEVER** ignore TypeScript errors:

```typescript
// ❌ Bad: Ignoring TypeScript errors
// @ts-ignore
const result = user.invalidProperty;

// ✅ Good: Proper type checking
const result = 'invalidProperty' in user ? user.invalidProperty : undefined;
```

**DON'T** write components without proper typing:

```typescript
// ❌ Bad: No proper typing
const UserCard = ({ user, onEdit }) => {
  return <div>{user.name}</div>;
};

// ✅ Good: Proper TypeScript interfaces
interface UserCardProps {
  user: User;
  onEdit: (user: User) => void;
}

const UserCard: React.FC<UserCardProps> = ({ user, onEdit }) => {
  return <View><Text>{user.firstName}</Text></View>;
};
```

## Validation Checklist

### **MUST** verify

- [ ] TypeScript strict mode is enabled and configured properly
- [ ] ESLint and Prettier are configured and running without errors
- [ ] All components have proper TypeScript interfaces
- [ ] Error handling is implemented throughout the application
- [ ] JSDoc documentation is written for all public APIs
- [ ] Naming conventions are followed consistently
- [ ] No `any` types are used without proper justification
- [ ] Accessibility standards are implemented in all components

### **SHOULD** check

- [ ] Custom hooks are implemented for reusable logic
- [ ] Proper memoization techniques are used for performance
- [ ] SOLID principles are followed in component design
- [ ] Consistent patterns are used for API integration
- [ ] Testing is implemented alongside code development
- [ ] Logging and debugging support is properly configured
- [ ] Import statements are organized and consistent
- [ ] Code coverage meets quality standards

## References

- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [ESLint Rules](https://eslint.org/docs/rules/)
- [Prettier Configuration](https://prettier.io/docs/en/configuration.html)
- [React Native Style Guide](https://github.com/airbnb/javascript/tree/master/react)
- [JSDoc Documentation](https://jsdoc.app/)
- [React Native Accessibility](https://reactnative.dev/docs/accessibility)
