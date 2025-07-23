---
applyTo: '**'
---

# Testing Instructions

This document outlines comprehensive testing strategies for React Native applications, covering unit testing, integration testing, end-to-end testing, and mobile-specific testing considerations.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** achieve minimum 80% code coverage for all business logic components
- **REQUIRED** to test user interactions using fireEvent, not implementation details
- **SHALL** write tests that focus on what users can see and interact with
- **MUST** avoid testing component props, state, or internal implementation details
- **NEVER** commit code without corresponding tests for new functionality
- **REQUIRED** to use React Native Testing Library for component testing
- **SHALL** implement proper mocking for external dependencies and native modules
- **MUST** test components from the user perspective, not developer perspective
- **REQUIRED** to test accessibility features and screen reader compatibility
- **SHALL** separate unit, integration, and end-to-end tests appropriately

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** implement visual regression testing for UI components
- **RECOMMENDED** to use end-to-end testing for complete user journeys
- **ALWAYS** test accessibility features with screen readers and voice control
- **DO** implement testing for offline scenarios and network failures
- **SHOULD** use property-based testing for complex business logic
- **RECOMMENDED** to implement load testing for data-heavy components
- **DO** test platform-specific behaviors and features separately
- **ALWAYS** implement proper test cleanup to prevent memory leaks
- **SHOULD** use snapshot testing judiciously for stable UI components

### Optional Enhancements (**MAY** Consider)

- **MAY** implement mutation testing to validate test quality
- **OPTIONAL** to use chaos engineering techniques for resilience testing
- **USE** automated security testing tools in CI/CD pipeline
- **IMPLEMENT** performance benchmarking and regression detection
- **AVOID** over-testing simple getter/setter methods without business logic

## Implementation Guidance

### Debugging and Development Tools

**USE** React Native DevTools for debugging (requires Hermes engine):
- **DO** use React Native DevTools instead of deprecated Flipper
- **ALWAYS** access DevTools via "Open DevTools" in Dev Menu or press 'j' in CLI
- **IMPLEMENT** proper LogBox configuration for development error handling
- **USE** Performance Monitor for frame rate monitoring during development
- **ENSURE** Hermes engine is enabled for DevTools compatibility

### Unit Testing Setup and Patterns

**USE** Jest and React Native Testing Library:

```typescript
// jest.config.js
module.exports = {
  preset: 'react-native',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  transformIgnorePatterns: [
    'node_modules/(?!(react-native|@react-native|react-native-vector-icons|@expo|expo)/)'
  ],
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.tsx',
    '!src/types/**/*',
    '!src/assets/**/*'
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  },
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@components/(.*)$': '<rootDir>/src/components/$1',
    '^@hooks/(.*)$': '<rootDir>/src/hooks/$1',
    '^@services/(.*)$': '<rootDir>/src/services/$1',
    '^@utils/(.*)$': '<rootDir>/src/utils/$1'
  }
};

// jest.setup.js
import 'react-native-gesture-handler/jestSetup';
import '@testing-library/jest-native/extend-expect';

// Mock react-native modules
jest.mock('react-native/Libraries/Animated/NativeAnimatedHelper');
jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock')
);

// Global test utilities
global.__TEST__ = true;
```

**IMPLEMENT** comprehensive component testing:

```typescript
// UserCard.test.tsx
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react-native';
import { UserCard } from '@components/UserCard';
import { User } from '@types/user';

// Test data factory
const createMockUser = (overrides: Partial<User> = {}): User => ({
  id: '1',
  name: 'John Doe',
  email: 'john@example.com',
  avatar: 'https://example.com/avatar.jpg',
  isActive: true,
  ...overrides
});

describe('UserCard Component', () => {
  const mockOnPress = jest.fn();
  const defaultProps = {
    user: createMockUser(),
    onPress: mockOnPress
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  afterEach(() => {
    // Clean up any side effects
    jest.restoreAllMocks();
  });

  describe('Rendering', () => {
    it('should render user information correctly', () => {
      render(<UserCard {...defaultProps} />);
      
      expect(screen.getByText('John Doe')).toBeOnTheScreen();
      expect(screen.getByText('john@example.com')).toBeOnTheScreen();
    });

    it('should render in compact variant by default', () => {
      render(<UserCard {...defaultProps} />);
      
      const container = screen.getByTestId('user-card-container');
      expect(container).toHaveStyle({ height: 60 });
    });

    it('should render in expanded variant when specified', () => {
      render(<UserCard {...defaultProps} variant="expanded" />);
      
      const container = screen.getByTestId('user-card-container');
      expect(container).toHaveStyle({ height: 120 });
    });

    it('should handle missing avatar gracefully', () => {
      const userWithoutAvatar = createMockUser({ avatar: undefined });
      render(<UserCard {...defaultProps} user={userWithoutAvatar} />);
      
      expect(screen.getByTestId('default-avatar')).toBeOnTheScreen();
    });
  });

  describe('Interactions', () => {
    it('should call onPress with user ID when pressed', () => {
      render(<UserCard {...defaultProps} />);
      
      const card = screen.getByTestId('user-card');
      fireEvent.press(card);
      
      expect(mockOnPress).toHaveBeenCalledWith('1');
      expect(mockOnPress).toHaveBeenCalledTimes(1);
    });

    it('should not call onPress when onPress is not provided', () => {
      render(<UserCard user={defaultProps.user} />);
      
      const card = screen.getByTestId('user-card');
      fireEvent.press(card);
      
      // Should not throw error
      expect(mockOnPress).not.toHaveBeenCalled();
    });

    it('should handle rapid successive presses correctly', () => {
      render(<UserCard {...defaultProps} />);
      
      const card = screen.getByTestId('user-card');
      fireEvent.press(card);
      fireEvent.press(card);
      fireEvent.press(card);
      
      // Should only register one press due to debouncing
      expect(mockOnPress).toHaveBeenCalledTimes(1);
    });
  });

  describe('Accessibility', () => {
    it('should have proper accessibility labels', () => {
      render(<UserCard {...defaultProps} />);
      
      const card = screen.getByTestId('user-card');
      expect(card).toHaveAccessibilityRole('button');
      expect(card).toHaveAccessibilityLabel('User card for John Doe');
      expect(card).toHaveAccessibilityHint('Tap to view user profile');
    });

    it('should support accessibility actions', () => {
      render(<UserCard {...defaultProps} />);
      
      const card = screen.getByTestId('user-card');
      expect(card).toHaveAccessibilityActions([
        { name: 'activate', label: 'View profile' }
      ]);
    });
  });

  describe('Edge Cases', () => {
    it('should handle extremely long names gracefully', () => {
      const userWithLongName = createMockUser({
        name: 'A'.repeat(100)
      });
      
      render(<UserCard {...defaultProps} user={userWithLongName} />);
      
      const nameText = screen.getByTestId('user-name');
      expect(nameText).toHaveStyle({ numberOfLines: 2 });
    });

    it('should handle invalid email addresses', () => {
      const userWithInvalidEmail = createMockUser({
        email: 'invalid-email'
      });
      
      render(<UserCard {...defaultProps} user={userWithInvalidEmail} />);
      
      expect(screen.getByText('invalid-email')).toBeOnTheScreen();
    });
  });
});
```

**ENSURE** custom hooks testing:

```typescript
// useUserManagement.test.ts
import { renderHook, act } from '@testing-library/react-native';
import { useUserManagement } from '@hooks/useUserManagement';

describe('useUserManagement Hook', () => {
  it('should initialize with empty selection', () => {
    const { result } = renderHook(() => useUserManagement());
    
    expect(result.current.selectedUsers).toEqual([]);
    expect(result.current.hasSelection).toBe(false);
  });

  it('should toggle user selection correctly', () => {
    const { result } = renderHook(() => useUserManagement());
    
    act(() => {
      result.current.toggleUser('user1');
    });
    
    expect(result.current.selectedUsers).toEqual(['user1']);
    expect(result.current.hasSelection).toBe(true);
  });

  it('should remove user when toggled twice', () => {
    const { result } = renderHook(() => useUserManagement());
    
    act(() => {
      result.current.toggleUser('user1');
      result.current.toggleUser('user1');
    });
    
    expect(result.current.selectedUsers).toEqual([]);
    expect(result.current.hasSelection).toBe(false);
  });

  it('should clear all selections', () => {
    const { result } = renderHook(() => useUserManagement());
    
    act(() => {
      result.current.toggleUser('user1');
      result.current.toggleUser('user2');
      result.current.clearSelection();
    });
    
    expect(result.current.selectedUsers).toEqual([]);
    expect(result.current.hasSelection).toBe(false);
  });

  it('should handle multiple users selection', () => {
    const { result } = renderHook(() => useUserManagement());
    
    act(() => {
      result.current.toggleUser('user1');
      result.current.toggleUser('user2');
      result.current.toggleUser('user3');
    });
    
    expect(result.current.selectedUsers).toEqual(['user1', 'user2', 'user3']);
    expect(result.current.hasSelection).toBe(true);
  });
});
```

### Integration Testing Patterns

**IMPLEMENT** API integration testing:

```typescript
// UserService.test.ts
import { UserService } from '@services/UserService';
import { ApiClient } from '@services/ApiClient';
import { User } from '@types/user';

// Mock the API client
jest.mock('@services/ApiClient');
const mockApiClient = ApiClient as jest.Mocked<typeof ApiClient>;

describe('UserService Integration Tests', () => {
  let userService: UserService;

  beforeEach(() => {
    userService = new UserService();
    jest.clearAllMocks();
  });

  describe('fetchUsers', () => {
    it('should fetch and transform users correctly', async () => {
      const mockApiResponse = {
        data: [
          { id: '1', full_name: 'John Doe', email_address: 'john@example.com' },
          { id: '2', full_name: 'Jane Smith', email_address: 'jane@example.com' }
        ],
        meta: { total: 2, page: 1 }
      };

      mockApiClient.prototype.get.mockResolvedValue(mockApiResponse);

      const result = await userService.fetchUsers({ page: 1, limit: 10 });

      expect(mockApiClient.prototype.get).toHaveBeenCalledWith('/users', {
        params: { page: 1, limit: 10 }
      });

      expect(result.users).toHaveLength(2);
      expect(result.users[0]).toEqual({
        id: '1',
        name: 'John Doe',
        email: 'john@example.com'
      });
    });

    it('should handle API errors gracefully', async () => {
      const apiError = new Error('Network error');
      mockApiClient.prototype.get.mockRejectedValue(apiError);

      await expect(userService.fetchUsers({ page: 1 }))
        .rejects.toThrow('Failed to fetch users');
    });

    it('should handle empty response', async () => {
      mockApiClient.prototype.get.mockResolvedValue({
        data: [],
        meta: { total: 0, page: 1 }
      });

      const result = await userService.fetchUsers({ page: 1 });

      expect(result.users).toEqual([]);
      expect(result.meta.total).toBe(0);
    });
  });

  describe('createUser', () => {
    it('should create user and return transformed data', async () => {
      const newUser = {
        name: 'New User',
        email: 'new@example.com'
      };

      const mockResponse = {
        id: '3',
        full_name: 'New User',
        email_address: 'new@example.com',
        created_at: '2023-01-01T00:00:00Z'
      };

      mockApiClient.prototype.post.mockResolvedValue(mockResponse);

      const result = await userService.createUser(newUser);

      expect(mockApiClient.prototype.post).toHaveBeenCalledWith('/users', {
        full_name: 'New User',
        email_address: 'new@example.com'
      });

      expect(result).toEqual({
        id: '3',
        name: 'New User',
        email: 'new@example.com',
        createdAt: new Date('2023-01-01T00:00:00Z')
      });
    });
  });
});
```

### End-to-End Testing with Detox

**USE** Detox for comprehensive E2E testing:

```typescript
// e2e/loginFlow.test.ts
import { device, element, by, expect as detoxExpect } from 'detox';

describe('Login Flow', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should complete login flow successfully', async () => {
    // Navigate to login screen
    await element(by.id('login-button')).tap();
    
    // Wait for login screen to appear
    await detoxExpect(element(by.id('login-screen'))).toBeVisible();
    
    // Enter credentials
    await element(by.id('email-input')).typeText('test@example.com');
    await element(by.id('password-input')).typeText('password123');
    
    // Submit login
    await element(by.id('submit-button')).tap();
    
    // Wait for loading to complete
    await waitFor(element(by.id('loading-spinner')))
      .toBeNotVisible()
      .withTimeout(5000);
    
    // Verify successful login
    await detoxExpected(element(by.id('dashboard-screen'))).toBeVisible();
    await detoxExpected(element(by.text('Welcome back!'))).toBeVisible();
  });

  it('should handle invalid credentials', async () => {
    await element(by.id('login-button')).tap();
    
    // Enter invalid credentials
    await element(by.id('email-input')).typeText('invalid@example.com');
    await element(by.id('password-input')).typeText('wrongpassword');
    
    await element(by.id('submit-button')).tap();
    
    // Verify error message
    await detoxExpected(element(by.text('Invalid credentials')))
      .toBeVisible();
  });

  it('should support biometric login when available', async () => {
    // Enable biometric login first
    await element(by.id('settings-button')).tap();
    await element(by.id('biometric-toggle')).tap();
    
    // Go back and try biometric login
    await element(by.id('back-button')).tap();
    await element(by.id('biometric-login-button')).tap();
    
    // Simulate biometric authentication success
    await device.setBiometricEnrollment(true);
    await device.matchBiometric();
    
    // Verify successful login
    await detoxExpected(element(by.id('dashboard-screen'))).toBeVisible();
  });

  it('should handle offline login scenario', async () => {
    // Simulate offline condition
    await device.setNetworkCondition('offline');
    
    await element(by.id('login-button')).tap();
    await element(by.id('email-input')).typeText('test@example.com');
    await element(by.id('password-input')).typeText('password123');
    
    await element(by.id('submit-button')).tap();
    
    // Verify offline message
    await detoxExpected(element(by.text('No internet connection')))
      .toBeVisible();
    
    // Restore network and retry
    await device.setNetworkCondition('fast3g');
    await element(by.id('retry-button')).tap();
    
    await detoxExpected(element(by.id('dashboard-screen'))).toBeVisible();
  });
});
```

### Accessibility Testing

**ENSURE** comprehensive accessibility testing:

```typescript
// accessibility.test.tsx
import React from 'react';
import { render, screen } from '@testing-library/react-native';
import { toHaveAccessibilityRole, toHaveAccessibilityLabel } from '@testing-library/jest-native';
import { LoginForm } from '@components/LoginForm';

describe('Accessibility Tests', () => {
  it('should have proper accessibility roles for form elements', () => {
    render(<LoginForm />);
    
    expect(screen.getByTestId('email-input')).toHaveAccessibilityRole('textbox');
    expect(screen.getByTestId('password-input')).toHaveAccessibilityRole('textbox');
    expect(screen.getByTestId('submit-button')).toHaveAccessibilityRole('button');
  });

  it('should have descriptive accessibility labels', () => {
    render(<LoginForm />);
    
    expect(screen.getByTestId('email-input'))
      .toHaveAccessibilityLabel('Email address');
    expect(screen.getByTestId('password-input'))
      .toHaveAccessibilityLabel('Password');
    expect(screen.getByTestId('submit-button'))
      .toHaveAccessibilityLabel('Sign in to your account');
  });

  it('should have proper accessibility hints', () => {
    render(<LoginForm />);
    
    expect(screen.getByTestId('email-input'))
      .toHaveAccessibilityHint('Enter your email address');
    expect(screen.getByTestId('password-input'))
      .toHaveAccessibilityHint('Enter your password');
  });

  it('should have proper accessibility states', () => {
    render(<LoginForm hasError={true} />);
    
    expect(screen.getByTestId('email-input'))
      .toHaveAccessibilityState({ invalid: true });
  });

  it('should support screen reader navigation', () => {
    render(<LoginForm />);
    
    const elements = screen.getAllByRole('textbox');
    expect(elements).toHaveLength(2);
    
    // Test tab order
    expect(elements[0]).toHaveProp('accessibilityTabIndex', 1);
    expect(elements[1]).toHaveProp('accessibilityTabIndex', 2);
  });
});
```

## Anti-Patterns

### **DON'T** implement these testing anti-patterns

**AVOID** testing implementation details:

```typescript
// ❌ Bad: Testing internal state
const { result } = renderHook(() => useCounter());

// Don't test internal state directly
expect(result.current.internalCounter).toBe(0);

// ✅ Good: Test behavior
expect(result.current.count).toBe(0);

act(() => {
  result.current.increment();
});

expect(result.current.count).toBe(1);
```

**DON'T** write brittle snapshot tests:

```typescript
// ❌ Bad: Large snapshot that breaks often
expect(render(<ComplexComponent />)).toMatchSnapshot();

// ✅ Good: Focused assertions
render(<ComplexComponent />);
expect(screen.getByText('Important Text')).toBeOnTheScreen();
expect(screen.getByRole('button')).toBeEnabled();
```

**NEVER** skip cleanup in tests:

```typescript
// ❌ Bad: No cleanup
describe('Timer component', () => {
  it('should update every second', () => {
    render(<Timer />);
    // Timer keeps running after test
  });
});

// ✅ Good: Proper cleanup
describe('Timer component', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
    jest.clearAllTimers();
  });

  it('should update every second', () => {
    render(<Timer />);
    // Timer is properly cleaned up
  });
});
```

## Code Examples

### Performance Testing

```typescript
// Performance.test.tsx
import React from 'react';
import { render } from '@testing-library/react-native';
import { LargeList } from '@components/LargeList';

describe('Performance Tests', () => {
  it('should render large lists efficiently', () => {
    const largeData = Array.from({ length: 10000 }, (_, i) => ({
      id: i,
      name: `Item ${i}`,
      description: `Description for item ${i}`
    }));

    const start = performance.now();
    
    render(<LargeList data={largeData} />);
    
    const end = performance.now();
    const renderTime = end - start;
    
    // Should render within reasonable time (adjust threshold as needed)
    expect(renderTime).toBeLessThan(1000); // 1 second
  });

  it('should handle memory efficiently', () => {
    const initialMemory = process.memoryUsage().heapUsed;
    
    const { unmount } = render(<LargeList data={largeData} />);
    
    unmount();
    
    // Force garbage collection if available
    if (global.gc) {
      global.gc();
    }
    
    const finalMemory = process.memoryUsage().heapUsed;
    const memoryIncrease = finalMemory - initialMemory;
    
    // Memory increase should be minimal after cleanup
    expect(memoryIncrease).toBeLessThan(50 * 1024 * 1024); // 50MB threshold
  });
});
```

### Mock Setup for External Dependencies

```typescript
// __mocks__/react-native-vector-icons.js
export default 'Icon';
export const IconButton = 'IconButton';

// __mocks__/@react-navigation/native.js
export const useNavigation = () => ({
  navigate: jest.fn(),
  goBack: jest.fn(),
  reset: jest.fn()
});

export const useFocusEffect = jest.fn();

// setupTests.ts
import mockAsyncStorage from '@react-native-async-storage/async-storage/jest/async-storage-mock';

jest.mock('@react-native-async-storage/async-storage', () => mockAsyncStorage);

jest.mock('react-native-keychain', () => ({
  setInternetCredentials: jest.fn(() => Promise.resolve()),
  getInternetCredentials: jest.fn(() => Promise.resolve()),
  resetInternetCredentials: jest.fn(() => Promise.resolve())
}));

// Mock native modules
jest.mock('react-native', () => {
  const RN = jest.requireActual('react-native');
  
  RN.NativeModules.SettingsManager = {
    settings: {},
  };
  
  return RN;
});
```

## Validation Checklist

### **MUST** verify

- [ ] All components have corresponding unit tests
- [ ] Custom hooks are thoroughly tested with renderHook
- [ ] Critical user flows have integration tests
- [ ] Accessibility testing covers all interactive elements
- [ ] Error handling is tested for all async operations
- [ ] Platform-specific behaviors are tested separately
- [ ] Test coverage meets minimum 80% threshold
- [ ] All external dependencies are properly mocked

### **SHOULD** check

- [ ] Visual regression tests are in place for stable components
- [ ] End-to-end tests cover complete user journeys
- [ ] Performance tests validate critical rendering paths
- [ ] Offline scenarios are tested
- [ ] Network failure handling is validated
- [ ] Memory leaks are prevented in test cleanup
- [ ] Security-sensitive features have dedicated tests
- [ ] Internationalization is tested with different locales

## References

- [React Native Testing Library](https://callstack.github.io/react-native-testing-library/)
- [Jest Testing Framework](https://jestjs.io/docs/getting-started)
- [Detox End-to-End Testing](https://github.com/wix/Detox)
- [React Testing Best Practices](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)
- [Accessibility Testing Guide](https://reactnative.dev/docs/accessibility)
- [Performance Testing in React Native](https://reactnative.dev/docs/performance)
