---
applyTo: '**'
---

# Navigation Instructions

This document outlines comprehensive navigation patterns, deep linking implementation, and routing strategies for React Native applications using React Navigation and Expo Router.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** implement type-safe navigation with proper TypeScript definitions
- **REQUIRED** to support deep linking with URL parameter validation
- **SHALL** implement proper navigation state persistence across app restarts
- **MUST** handle navigation edge cases like rapid navigation and back button behavior
- **NEVER** create navigation loops or unreachable screens
- **REQUIRED** to implement proper authentication-based navigation guards
- **SHALL** support both tab-based and stack-based navigation patterns
- **MUST** implement proper screen transitions and animation configurations
- **REQUIRED** to handle navigation accessibility with screen reader support
- **SHALL** implement proper navigation testing strategies

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** implement nested navigation structures for complex app flows
- **RECOMMENDED** to use Expo Router for file-based routing where appropriate
- **ALWAYS** implement proper loading states during navigation transitions
- **DO** implement navigation analytics and user flow tracking
- **SHOULD** optimize navigation performance with lazy loading
- **RECOMMENDED** to implement custom navigation components for brand consistency
- **DO** handle navigation errors gracefully with fallback screens
- **ALWAYS** implement proper navigation reset patterns for authentication flows
- **SHOULD** support gesture-based navigation where platform appropriate

### Optional Enhancements (**MAY** Consider)

- **MAY** implement advanced navigation animations and custom transitions
- **OPTIONAL** to use navigation-based code splitting and route-level lazy loading
- **USE** navigation middleware for logging, analytics, and debugging
- **IMPLEMENT** advanced deep linking with dynamic routing
- **AVOID** over-engineering simple navigation flows

## Implementation Guidance

### Type-Safe Navigation Setup

**USE** proper TypeScript navigation types:

```typescript
// types/navigation.ts
import { NavigatorScreenParams } from '@react-navigation/native';
import { StackScreenProps } from '@react-navigation/stack';
import { BottomTabScreenProps } from '@react-navigation/bottom-tabs';

// Root Stack Parameter List
export type RootStackParamList = {
  Auth: NavigatorScreenParams<AuthStackParamList>;
  Main: NavigatorScreenParams<MainTabParamList>;
  Modal: { title: string; content?: string };
  Profile: { userId: string };
  Settings: undefined;
};

// Authentication Stack
export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
  ResetPassword: { token: string };
};

// Main Tab Navigator
export type MainTabParamList = {
  Home: undefined;
  Search: NavigatorScreenParams<SearchStackParamList>;
  Notifications: undefined;
  Profile: undefined;
};

// Search Stack (nested in tab)
export type SearchStackParamList = {
  SearchHome: undefined;
  SearchResults: { query: string; filters?: string[] };
  SearchFilters: undefined;
};

// Screen Props Types
export type RootStackScreenProps<T extends keyof RootStackParamList> = 
  StackScreenProps<RootStackParamList, T>;

export type AuthStackScreenProps<T extends keyof AuthStackParamList> = 
  StackScreenProps<AuthStackParamList, T>;

export type MainTabScreenProps<T extends keyof MainTabParamList> = 
  BottomTabScreenProps<MainTabParamList, T>;

// Navigation hook types
declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
}

// Custom navigation hooks
import { useNavigation, useRoute } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';

export const useTypedNavigation = <T extends keyof RootStackParamList>() => {
  return useNavigation<StackNavigationProp<RootStackParamList, T>>();
};

export const useTypedRoute = <T extends keyof RootStackParamList>() => {
  return useRoute<RouteProp<RootStackParamList, T>>();
};
```

**IMPLEMENT** navigation container with proper configuration:

```typescript
// navigation/NavigationContainer.tsx
import React, { useEffect, useRef, useState } from 'react';
import { NavigationContainer, NavigationState } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { RootStackParamList } from '@types/navigation';
import { useAuth } from '@hooks/useAuth';
import { AuthNavigator } from './AuthNavigator';
import { MainNavigator } from './MainNavigator';
import { LoadingScreen } from '@screens/LoadingScreen';

const Stack = createStackNavigator<RootStackParamList>();
const NAVIGATION_PERSISTENCE_KEY = 'NAVIGATION_STATE_V1';

export const AppNavigationContainer: React.FC = () => {
  const { isAuthenticated, isLoading } = useAuth();
  const [isReady, setIsReady] = useState(false);
  const [initialState, setInitialState] = useState<NavigationState | undefined>();
  const navigationRef = useRef(null);

  // Restore navigation state
  useEffect(() => {
    const restoreState = async () => {
      try {
        const savedStateString = await AsyncStorage.getItem(NAVIGATION_PERSISTENCE_KEY);
        const state = savedStateString ? JSON.parse(savedStateString) : undefined;

        if (state !== undefined) {
          setInitialState(state);
        }
      } catch (e) {
        console.warn('Failed to restore navigation state:', e);
      } finally {
        setIsReady(true);
      }
    };

    if (!isReady) {
      restoreState();
    }
  }, [isReady]);

  // Save navigation state
  const handleStateChange = async (state: NavigationState | undefined) => {
    if (state) {
      try {
        await AsyncStorage.setItem(NAVIGATION_PERSISTENCE_KEY, JSON.stringify(state));
      } catch (e) {
        console.warn('Failed to save navigation state:', e);
      }
    }
  };

  if (!isReady || isLoading) {
    return <LoadingScreen />;
  }

  return (
    <NavigationContainer
      ref={navigationRef}
      initialState={initialState}
      onStateChange={handleStateChange}
      onReady={() => {
        // Navigation container is ready
        // Initialize analytics, deep link handling, etc.
      }}
    >
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
          gestureEnabled: true,
          gestureDirection: 'horizontal',
          transitionSpec: {
            open: { animation: 'timing', config: { duration: 300 } },
            close: { animation: 'timing', config: { duration: 300 } },
          },
        }}
      >
        {isAuthenticated ? (
          <>
            <Stack.Screen 
              name="Main" 
              component={MainNavigator}
              options={{ gestureEnabled: false }}
            />
            <Stack.Screen
              name="Profile"
              component={ProfileScreen}
              options={{
                headerShown: true,
                headerTitle: 'Profile',
                presentation: 'modal',
              }}
            />
            <Stack.Screen
              name="Settings"
              component={SettingsScreen}
              options={{
                headerShown: true,
                headerTitle: 'Settings',
              }}
            />
          </>
        ) : (
          <Stack.Screen 
            name="Auth" 
            component={AuthNavigator}
            options={{ gestureEnabled: false }}
          />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};
```

### Deep Linking Implementation

**ENSURE** proper deep linking with validation:

```typescript
// navigation/DeepLinkHandler.tsx
import { useEffect } from 'react';
import { Linking } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { RootStackParamList } from '@types/navigation';

interface DeepLinkConfig {
  screens: {
    Main: {
      screens: {
        Home: 'home',
        Profile: 'profile',
        Search: {
          screens: {
            SearchResults: 'search/:query',
            SearchFilters: 'search/filters',
          },
        },
      },
    },
    Auth: {
      screens: {
        Login: 'login',
        Register: 'register',
        ResetPassword: 'reset-password/:token',
      },
    },
    Profile: 'user/:userId',
    Settings: 'settings',
  },
};

export const linkingConfig = {
  prefixes: ['myapp://', 'https://myapp.com'],
  config: DeepLinkConfig,
  
  // Custom URL parsing
  getStateFromPath: (path: string, config: any) => {
    // Validate and sanitize the path
    const sanitizedPath = sanitizePath(path);
    
    // Check if the path is allowed
    if (!isValidPath(sanitizedPath)) {
      return undefined;
    }
    
    // Parse parameters and validate
    const state = getStateFromPath(sanitizedPath, config);
    
    if (state && state.routes) {
      return validateNavigationState(state);
    }
    
    return state;
  },
  
  // Custom URL generation
  getPathFromState: (state: any, config: any) => {
    return getPathFromState(state, config);
  },
};

// Deep link utilities
const sanitizePath = (path: string): string => {
  // Remove potentially malicious characters
  return path.replace(/[<>]/g, '').trim();
};

const isValidPath = (path: string): boolean => {
  const allowedPaths = [
    /^\/home$/,
    /^\/profile$/,
    /^\/search\/.*$/,
    /^\/login$/,
    /^\/register$/,
    /^\/reset-password\/[a-zA-Z0-9-_]+$/,
    /^\/user\/[a-zA-Z0-9-_]+$/,
    /^\/settings$/,
  ];
  
  return allowedPaths.some(pattern => pattern.test(path));
};

const validateNavigationState = (state: any): any => {
  // Validate navigation state structure
  // Ensure required parameters are present and valid
  
  if (state.routes) {
    state.routes = state.routes.filter((route: any) => {
      // Validate each route
      if (route.name === 'Profile' && route.params?.userId) {
        // Validate userId parameter
        return /^[a-zA-Z0-9-_]+$/.test(route.params.userId);
      }
      
      if (route.name === 'SearchResults' && route.params?.query) {
        // Validate search query
        return route.params.query.length <= 100;
      }
      
      return true;
    });
  }
  
  return state;
};

// Deep link hook for handling incoming links
export const useDeepLinkHandler = () => {
  const navigation = useNavigation();

  useEffect(() => {
    // Handle initial URL if app was opened from a deep link
    Linking.getInitialURL().then((url) => {
      if (url) {
        handleDeepLink(url);
      }
    });

    // Handle incoming URLs while app is running
    const subscription = Linking.addEventListener('url', ({ url }) => {
      handleDeepLink(url);
    });

    return () => {
      subscription.remove();
    };
  }, []);

  const handleDeepLink = (url: string) => {
    console.log('Handling deep link:', url);
    
    // Parse and validate the URL
    try {
      const parsedUrl = new URL(url);
      
      // Add custom logic for handling specific deep links
      if (parsedUrl.pathname.startsWith('/user/')) {
        const userId = parsedUrl.pathname.split('/')[2];
        if (userId && isValidUserId(userId)) {
          navigation.navigate('Profile', { userId });
        }
      }
      
      // Handle other custom deep link logic
      
    } catch (error) {
      console.error('Invalid deep link URL:', error);
    }
  };

  const isValidUserId = (userId: string): boolean => {
    return /^[a-zA-Z0-9-_]{1,50}$/.test(userId);
  };
};
```

### Tab Navigation Implementation

**IMPLEMENT** custom tab navigator:

```typescript
// navigation/TabNavigator.tsx
import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Platform, View, Text } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useTheme } from '@hooks/useTheme';
import { MainTabParamList } from '@types/navigation';
import { HomeScreen } from '@screens/HomeScreen';
import { SearchNavigator } from './SearchNavigator';
import { NotificationsScreen } from '@screens/NotificationsScreen';
import { ProfileScreen } from '@screens/ProfileScreen';
import { TabBarIcon } from '@components/TabBarIcon';

const Tab = createBottomTabNavigator<MainTabParamList>();

export const TabNavigator: React.FC = () => {
  const { theme } = useTheme();
  const insets = useSafeAreaInsets();

  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarIcon: ({ focused, color, size }) => (
          <TabBarIcon 
            name={getTabIconName(route.name)} 
            color={color} 
            size={size} 
            focused={focused}
          />
        ),
        tabBarActiveTintColor: theme.colors.primary[500],
        tabBarInactiveTintColor: theme.colors.textSecondary,
        tabBarStyle: {
          backgroundColor: theme.colors.background,
          borderTopColor: theme.colors.border,
          borderTopWidth: 1,
          paddingBottom: Platform.OS === 'ios' ? insets.bottom : 8,
          height: Platform.OS === 'ios' ? 49 + insets.bottom : 60,
        },
        tabBarLabelStyle: {
          fontSize: 12,
          fontFamily: theme.typography.fonts.primary.medium,
        },
        tabBarItemStyle: {
          paddingTop: 4,
        },
        // Accessibility
        tabBarAccessibilityLabel: getTabAccessibilityLabel(route.name),
        tabBarTestID: `tab-${route.name.toLowerCase()}`,
      })}
    >
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{
          tabBarLabel: 'Home',
          tabBarBadge: undefined, // Can be dynamically set
        }}
      />
      <Tab.Screen
        name="Search"
        component={SearchNavigator}
        options={{
          tabBarLabel: 'Search',
        }}
      />
      <Tab.Screen
        name="Notifications"
        component={NotificationsScreen}
        options={({ route }) => ({
          tabBarLabel: 'Notifications',
          tabBarBadge: getNotificationBadge(), // Dynamic badge
        })}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{
          tabBarLabel: 'Profile',
        }}
      />
    </Tab.Navigator>
  );
};

const getTabIconName = (routeName: string): string => {
  switch (routeName) {
    case 'Home':
      return 'home';
    case 'Search':
      return 'search';
    case 'Notifications':
      return 'bell';
    case 'Profile':
      return 'user';
    default:
      return 'circle';
  }
};

const getTabAccessibilityLabel = (routeName: string): string => {
  switch (routeName) {
    case 'Home':
      return 'Home tab';
    case 'Search':
      return 'Search tab';
    case 'Notifications':
      return 'Notifications tab';
    case 'Profile':
      return 'Profile tab';
    default:
      return `${routeName} tab`;
  }
};

const getNotificationBadge = (): number | undefined => {
  // Get unread notification count from state/context
  // Return undefined to hide badge
  return undefined;
};
```

### Navigation Utilities and Hooks

**USE** navigation utilities for common operations:

```typescript
// utils/navigationUtils.ts
import { CommonActions, StackActions } from '@react-navigation/native';
import { RootStackParamList } from '@types/navigation';

export class NavigationUtils {
  static resetToScreen<T extends keyof RootStackParamList>(
    navigation: any,
    screenName: T,
    params?: RootStackParamList[T]
  ) {
    navigation.dispatch(
      CommonActions.reset({
        index: 0,
        routes: [{ name: screenName, params }],
      })
    );
  }

  static replaceScreen<T extends keyof RootStackParamList>(
    navigation: any,
    screenName: T,
    params?: RootStackParamList[T]
  ) {
    navigation.dispatch(
      StackActions.replace(screenName, params)
    );
  }

  static popToTop(navigation: any) {
    navigation.dispatch(StackActions.popToTop());
  }

  static canGoBack(navigation: any): boolean {
    return navigation.canGoBack();
  }

  static handleBackButton(navigation: any): boolean {
    if (navigation.canGoBack()) {
      navigation.goBack();
      return true;
    }
    return false;
  }
}

// Custom navigation hooks
export const useNavigationHelpers = () => {
  const navigation = useTypedNavigation();

  const navigateWithReset = useCallback(<T extends keyof RootStackParamList>(
    screenName: T,
    params?: RootStackParamList[T]
  ) => {
    NavigationUtils.resetToScreen(navigation, screenName, params);
  }, [navigation]);

  const navigateWithReplace = useCallback(<T extends keyof RootStackParamList>(
    screenName: T,
    params?: RootStackParamList[T]
  ) => {
    NavigationUtils.replaceScreen(navigation, screenName, params);
  }, [navigation]);

  const handleBackPress = useCallback(() => {
    return NavigationUtils.handleBackButton(navigation);
  }, [navigation]);

  return {
    navigateWithReset,
    navigateWithReplace,
    handleBackPress,
    canGoBack: NavigationUtils.canGoBack(navigation),
  };
};

// Navigation state hook
export const useNavigationState = () => {
  const [currentRoute, setCurrentRoute] = useState<string>('');
  const [routeParams, setRouteParams] = useState<any>({});

  useEffect(() => {
    const unsubscribe = navigation.addListener('state', (e) => {
      const state = e.data.state;
      if (state) {
        const route = state.routes[state.index];
        setCurrentRoute(route.name);
        setRouteParams(route.params || {});
      }
    });

    return unsubscribe;
  }, []);

  return {
    currentRoute,
    routeParams,
  };
};
```

## Anti-Patterns

### **DON'T** implement these navigation anti-patterns

**AVOID** navigation without type safety:

```typescript
// ❌ Bad: No type safety
navigation.navigate('Profile', { userId: 123 }); // Should be string
navigation.navigate('UnknownScreen'); // Typo not caught

// ✅ Good: Type-safe navigation
const navigation = useTypedNavigation<'Profile'>();
navigation.navigate('Profile', { userId: '123' });
```

**DON'T** ignore deep link validation:

```typescript
// ❌ Bad: No validation
const handleDeepLink = (url: string) => {
  const userId = url.split('/').pop();
  navigation.navigate('Profile', { userId });
};

// ✅ Good: Proper validation
const handleDeepLink = (url: string) => {
  try {
    const parsedUrl = new URL(url);
    const userId = parsedUrl.pathname.split('/').pop();
    
    if (userId && isValidUserId(userId)) {
      navigation.navigate('Profile', { userId });
    }
  } catch (error) {
    console.error('Invalid deep link:', error);
  }
};
```

**NEVER** create navigation loops:

```typescript
// ❌ Bad: Navigation loop
// Screen A navigates to Screen B
// Screen B navigates back to Screen A
// Creates infinite navigation stack

// ✅ Good: Proper navigation flow with replace or reset
NavigationUtils.replaceScreen(navigation, 'ScreenB');
```

## Validation Checklist

### **MUST** verify

- [ ] All navigation routes have proper TypeScript types
- [ ] Deep linking works with URL parameter validation
- [ ] Navigation state persists across app restarts
- [ ] Authentication-based navigation guards are implemented
- [ ] Navigation accessibility is properly configured
- [ ] Back button behavior is handled correctly
- [ ] Navigation testing covers critical user flows
- [ ] Navigation performance is optimized with lazy loading

### **SHOULD** check

- [ ] Navigation analytics and tracking are implemented
- [ ] Custom navigation animations work smoothly
- [ ] Navigation errors are handled gracefully
- [ ] Tab badges update dynamically
- [ ] Navigation works correctly on different screen sizes
- [ ] Gesture-based navigation is implemented where appropriate
- [ ] Navigation middleware for debugging is available
- [ ] Navigation reset patterns work for authentication flows

## References

- [React Navigation Documentation](https://reactnavigation.org/)
- [Expo Router Documentation](https://expo.github.io/router/docs/)
- [Deep Linking Guide](https://reactnavigation.org/docs/deep-linking/)
- [Navigation Accessibility](https://reactnavigation.org/docs/accessibility/)
- [TypeScript with React Navigation](https://reactnavigation.org/docs/typescript/)
- [Navigation Testing](https://reactnavigation.org/docs/testing/)
