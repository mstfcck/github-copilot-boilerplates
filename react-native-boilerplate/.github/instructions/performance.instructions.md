---
applyTo: '**'
---

# Performance Instructions

This document outlines performance optimization strategies, monitoring techniques, and best practices for building high-performance React Native applications.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** achieve 60 FPS performance (16.67ms per frame) on target devices
- **REQUIRED** to use FlatList with getItemLayout for large lists (>100 items)
- **SHALL** implement React.memo() with proper comparison functions to prevent unnecessary re-renders
- **MUST** use native driver for animations (`useNativeDriver: true`)
- **NEVER** use console.log statements in production builds (use babel plugin to remove)
- **REQUIRED** to implement proper memory management and cleanup in useEffect
- **SHALL** test performance in release builds, not development mode
- **MUST** implement InteractionManager for deferring work during animations
- **REQUIRED** to optimize image rendering with proper resize modes and caching
- **SHALL** avoid synchronous storage operations that block the JavaScript thread

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** use Flipper or React DevTools for performance profiling
- **RECOMMENDED** to implement progressive image loading with placeholders
- **ALWAYS** optimize fonts and reduce the number of font variants
- **DO** implement proper startup time optimization techniques
- **SHOULD** use InteractionManager for deferring expensive operations
- **RECOMMENDED** to implement proper error boundaries to prevent crashes
- **DO** monitor memory usage and prevent memory leaks
- **ALWAYS** implement proper deep linking performance optimization
- **SHOULD** use proper navigation optimization techniques

### Optional Enhancements (**MAY** Consider)

- **MAY** implement advanced performance monitoring with analytics
- **OPTIONAL** to use performance budgets and automated testing
- **USE** advanced optimization techniques like preloading and prefetching
- **IMPLEMENT** custom native modules for performance-critical operations
- **AVOID** premature optimization - measure first, optimize second

## Implementation Guidance

### List Rendering Optimization

**USE** FlatList with proper optimization:

```typescript
import React, { useCallback, useMemo, useState } from 'react';
import { FlatList, ListRenderItem, RefreshControl } from 'react-native';

interface OptimizedListProps<T> {
  data: T[];
  renderItem: ListRenderItem<T>;
  keyExtractor: (item: T, index: number) => string;
  onRefresh?: () => void;
  onEndReached?: () => void;
  estimatedItemSize?: number;
}

export const OptimizedList = <T,>({
  data,
  renderItem,
  keyExtractor,
  onRefresh,
  onEndReached,
  estimatedItemSize = 50
}: OptimizedListProps<T>) => {
  const [refreshing, setRefreshing] = useState(false);

  const handleRefresh = useCallback(async () => {
    if (!onRefresh) return;
    
    setRefreshing(true);
    try {
      await onRefresh();
    } finally {
      setRefreshing(false);
    }
  }, [onRefresh]);

  const handleEndReached = useCallback(() => {
    if (onEndReached) {
      onEndReached();
    }
  }, [onEndReached]);

  const refreshControl = useMemo(() => (
    onRefresh ? (
      <RefreshControl
        refreshing={refreshing}
        onRefresh={handleRefresh}
        colors={['#007AFF']} // Android
        tintColor="#007AFF" // iOS
      />
    ) : undefined
  ), [refreshing, handleRefresh, onRefresh]);

  return (
    <FlatList
      data={data}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      refreshControl={refreshControl}
      onEndReached={handleEndReached}
      onEndReachedThreshold={0.5}
      maxToRenderPerBatch={10}
      updateCellsBatchingPeriod={50}
      initialNumToRender={10}
      windowSize={10}
      removeClippedSubviews={true}
      getItemLayout={(data, index) => ({
        length: estimatedItemSize,
        offset: estimatedItemSize * index,
        index,
      })}
      // Performance optimizations
      disableVirtualization={false}
      keyboardShouldPersistTaps="handled"
      showsVerticalScrollIndicator={false}
    />
  );
};

// Memoized list item component
interface UserItemProps {
  user: User;
  onPress: (userId: string) => void;
}

export const UserItem = React.memo<UserItemProps>(({ user, onPress }) => {
  const handlePress = useCallback(() => {
    onPress(user.id);
  }, [onPress, user.id]);

  return (
    <Pressable
      onPress={handlePress}
      style={styles.userItem}
      android_ripple={{ color: '#f0f0f0' }}
    >
      <Image
        source={{ uri: user.avatar }}
        style={styles.avatar}
        resizeMode="cover"
      />
      <View style={styles.userInfo}>
        <Text style={styles.userName}>{user.name}</Text>
        <Text style={styles.userEmail}>{user.email}</Text>
      </View>
    </Pressable>
  );
});
```

### Image Optimization

**IMPLEMENT** progressive image loading:

```typescript
import React, { useState, useCallback } from 'react';
import { View, Image, ImageStyle, StyleSheet } from 'react-native';
import { BlurView } from 'expo-blur';

interface OptimizedImageProps {
  uri: string;
  thumbnailUri?: string;
  style?: ImageStyle;
  resizeMode?: 'cover' | 'contain' | 'stretch' | 'center';
  priority?: 'low' | 'normal' | 'high';
}

export const OptimizedImage: React.FC<OptimizedImageProps> = ({
  uri,
  thumbnailUri,
  style,
  resizeMode = 'cover',
  priority = 'normal'
}) => {
  const [imageLoaded, setImageLoaded] = useState(false);
  const [imageError, setImageError] = useState(false);

  const handleImageLoad = useCallback(() => {
    setImageLoaded(true);
  }, []);

  const handleImageError = useCallback(() => {
    setImageError(true);
  }, []);

  return (
    <View style={[styles.container, style]}>
      {/* Thumbnail/placeholder image */}
      {thumbnailUri && !imageLoaded && (
        <Image
          source={{ uri: thumbnailUri }}
          style={[StyleSheet.absoluteFillObject, style]}
          resizeMode={resizeMode}
          blurRadius={1}
        />
      )}
      
      {/* Main image */}
      <Image
        source={{ 
          uri,
          priority: priority,
          cache: 'force-cache'
        }}
        style={[style, { opacity: imageLoaded ? 1 : 0 }]}
        resizeMode={resizeMode}
        onLoad={handleImageLoad}
        onError={handleImageError}
        // Performance optimizations
        fadeDuration={300}
        loadingIndicatorSource={thumbnailUri ? { uri: thumbnailUri } : undefined}
      />
      
      {/* Error fallback */}
      {imageError && (
        <View style={[StyleSheet.absoluteFillObject, styles.errorContainer]}>
          <Text style={styles.errorText}>Failed to load image</Text>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#f0f0f0',
  },
  errorContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f0f0f0',
  },
  errorText: {
    color: '#666',
    fontSize: 12,
  },
});
```

**ENSURE** proper image caching:

```typescript
import { Image } from 'react-native';
import FastImage from 'react-native-fast-image';

interface ImageCacheManager {
  preloadImages(uris: string[]): Promise<void>;
  clearCache(): Promise<void>;
  getCacheSize(): Promise<number>;
}

export class ImageCacheManager implements ImageCacheManager {
  async preloadImages(uris: string[]): Promise<void> {
    const preloadPromises = uris.map(uri => 
      FastImage.preload([{ uri, priority: FastImage.priority.normal }])
    );
    
    await Promise.all(preloadPromises);
  }

  async clearCache(): Promise<void> {
    await FastImage.clearMemoryCache();
    await FastImage.clearDiskCache();
  }

  async getCacheSize(): Promise<number> {
    // Implement cache size calculation
    return 0; // Placeholder
  }
}

// Usage in component
export const ImageGallery: React.FC<{ images: string[] }> = ({ images }) => {
  useEffect(() => {
    const cacheManager = new ImageCacheManager();
    cacheManager.preloadImages(images.slice(0, 10)); // Preload first 10 images
  }, [images]);

  return (
    <FlatList
      data={images}
      renderItem={({ item }) => (
        <FastImage
          source={{ 
            uri: item,
            priority: FastImage.priority.normal,
            cache: FastImage.cacheControl.immutable
          }}
          style={styles.image}
          resizeMode={FastImage.resizeMode.cover}
        />
      )}
      keyExtractor={(item, index) => `${item}-${index}`}
    />
  );
};
```

### Animation Performance

**USE** React Native Reanimated for smooth animations:

```typescript
import React from 'react';
import { Pressable, View } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  runOnJS,
  interpolateColor,
  useDerivedValue
} from 'react-native-reanimated';

interface AnimatedButtonProps {
  onPress: () => void;
  children: React.ReactNode;
  disabled?: boolean;
}

export const AnimatedButton: React.FC<AnimatedButtonProps> = ({
  onPress,
  children,
  disabled = false
}) => {
  const scale = useSharedValue(1);
  const backgroundColor = useSharedValue(0);

  const animatedStyle = useAnimatedStyle(() => {
    return {
      transform: [{ scale: scale.value }],
      backgroundColor: interpolateColor(
        backgroundColor.value,
        [0, 1],
        ['#007AFF', '#0056CC']
      ),
    };
  });

  const handlePressIn = () => {
    scale.value = withSpring(0.95, { damping: 15 });
    backgroundColor.value = withTiming(1, { duration: 150 });
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15 });
    backgroundColor.value = withTiming(0, { duration: 150 });
  };

  const handlePress = () => {
    if (!disabled) {
      runOnJS(onPress)();
    }
  };

  return (
    <Pressable
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      onPress={handlePress}
      disabled={disabled}
    >
      <Animated.View style={[styles.button, animatedStyle]}>
        {children}
      </Animated.View>
    </Pressable>
  );
};

// Complex animation with gesture handling
import { PanGestureHandler, State } from 'react-native-gesture-handler';

export const SwipeableCard: React.FC<{ onSwipe: (direction: 'left' | 'right') => void }> = ({
  onSwipe
}) => {
  const translateX = useSharedValue(0);
  const opacity = useSharedValue(1);

  const gestureHandler = useAnimatedGestureHandler({
    onStart: () => {
      // Prepare for gesture
    },
    onActive: (event) => {
      translateX.value = event.translationX;
      opacity.value = 1 - Math.abs(event.translationX) / 300;
    },
    onEnd: (event) => {
      const shouldSwipe = Math.abs(event.translationX) > 150;
      
      if (shouldSwipe) {
        const direction = event.translationX > 0 ? 'right' : 'left';
        translateX.value = withTiming(event.translationX > 0 ? 400 : -400);
        opacity.value = withTiming(0);
        runOnJS(onSwipe)(direction);
      } else {
        translateX.value = withSpring(0);
        opacity.value = withSpring(1);
      }
    }
  });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
    opacity: opacity.value,
  }));

  return (
    <PanGestureHandler onGestureEvent={gestureHandler}>
      <Animated.View style={[styles.card, animatedStyle]}>
        {/* Card content */}
      </Animated.View>
    </PanGestureHandler>
  );
};
```

### Memory Management

**IMPLEMENT** proper cleanup and memory management:

```typescript
import React, { useEffect, useRef, useState } from 'react';
import { AppState, AppStateStatus } from 'react-native';

export const MemoryEfficientComponent: React.FC = () => {
  const [data, setData] = useState<any[]>([]);
  const subscriptionsRef = useRef<Array<() => void>>([]);
  const timersRef = useRef<NodeJS.Timeout[]>([]);

  useEffect(() => {
    // Setup subscriptions and timers
    const subscription = SomeEventEmitter.on('data', handleDataUpdate);
    const timer = setInterval(updateData, 5000);

    // Store references for cleanup
    subscriptionsRef.current.push(() => subscription.remove());
    timersRef.current.push(timer);

    return () => {
      // Cleanup all subscriptions
      subscriptionsRef.current.forEach(cleanup => cleanup());
      subscriptionsRef.current = [];

      // Cleanup all timers
      timersRef.current.forEach(timer => clearInterval(timer));
      timersRef.current = [];
    };
  }, []);

  // Handle app state changes for memory optimization
  useEffect(() => {
    const handleAppStateChange = (nextAppState: AppStateStatus) => {
      if (nextAppState === 'background') {
        // Clear non-essential data when app goes to background
        setData(prevData => prevData.slice(0, 50)); // Keep only first 50 items
      }
    };

    const subscription = AppState.addEventListener('change', handleAppStateChange);

    return () => {
      subscription?.remove();
    };
  }, []);

  const handleDataUpdate = useCallback((newData: any) => {
    setData(prevData => {
      // Limit data size to prevent memory issues
      const updatedData = [...prevData, newData];
      return updatedData.length > 1000 
        ? updatedData.slice(-1000) // Keep only last 1000 items
        : updatedData;
    });
  }, []);

  return (
    {/* Component JSX */}
  );
};

// Memory monitoring utility
export class MemoryMonitor {
  private static instance: MemoryMonitor;
  private memoryCheckInterval: NodeJS.Timeout | null = null;

  static getInstance(): MemoryMonitor {
    if (!MemoryMonitor.instance) {
      MemoryMonitor.instance = new MemoryMonitor();
    }
    return MemoryMonitor.instance;
  }

  startMonitoring(callback: (memoryInfo: any) => void): void {
    this.memoryCheckInterval = setInterval(() => {
      if (__DEV__) {
        // Get memory information (platform-specific implementation needed)
        const memoryInfo = this.getMemoryInfo();
        callback(memoryInfo);

        if (memoryInfo.used > memoryInfo.total * 0.8) {
          console.warn('High memory usage detected:', memoryInfo);
        }
      }
    }, 10000); // Check every 10 seconds
  }

  stopMonitoring(): void {
    if (this.memoryCheckInterval) {
      clearInterval(this.memoryCheckInterval);
      this.memoryCheckInterval = null;
    }
  }

  private getMemoryInfo() {
    // Platform-specific memory information
    return {
      used: 0,
      total: 0,
      available: 0
    };
  }
}
```

### Bundle Optimization

**ENSURE** proper code splitting and lazy loading:

```typescript
import React, { Suspense, lazy } from 'react';
import { ActivityIndicator, View } from 'react-native';

// Lazy load screens
const ProfileScreen = lazy(() => import('@screens/ProfileScreen'));
const SettingsScreen = lazy(() => import('@screens/SettingsScreen'));
const DashboardScreen = lazy(() => import('@screens/DashboardScreen'));

// Loading component
const LoadingFallback: React.FC = () => (
  <View style={styles.loadingContainer}>
    <ActivityIndicator size="large" color="#007AFF" />
  </View>
);

// Navigation with lazy loading
export const AppNavigator: React.FC = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen 
          name="Dashboard" 
          component={() => (
            <Suspense fallback={<LoadingFallback />}>
              <DashboardScreen />
            </Suspense>
          )} 
        />
        <Stack.Screen 
          name="Profile" 
          component={() => (
            <Suspense fallback={<LoadingFallback />}>
              <ProfileScreen />
            </Suspense>
          )} 
        />
        <Stack.Screen 
          name="Settings" 
          component={() => (
            <Suspense fallback={<LoadingFallback />}>
              <SettingsScreen />
            </Suspense>
          )} 
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

// Dynamic imports for large libraries
export const useLargeLibrary = () => {
  const [library, setLibrary] = useState(null);

  useEffect(() => {
    const loadLibrary = async () => {
      const { default: LargeLibrary } = await import('large-library');
      setLibrary(new LargeLibrary());
    };

    loadLibrary();
  }, []);

  return library;
};
```

## Anti-Patterns

### **DON'T** implement these performance killers

**AVOID** blocking the main thread:

```typescript
// ❌ Bad: Blocking main thread
const processLargeDataset = (data: any[]) => {
  return data.map(item => {
    // Heavy computation on main thread
    return heavyProcessing(item);
  });
};

// ✅ Good: Use InteractionManager
import { InteractionManager } from 'react-native';

const processLargeDatasetOptimized = async (data: any[]) => {
  return new Promise((resolve) => {
    InteractionManager.runAfterInteractions(() => {
      const result = data.map(item => heavyProcessing(item));
      resolve(result);
    });
  });
};
```

**DON'T** create unnecessary re-renders:

```typescript
// ❌ Bad: Creates new objects on every render
const BadComponent = ({ items }: { items: any[] }) => {
  return (
    <FlatList
      data={items}
      renderItem={({ item }) => <Item item={item} />}
      keyExtractor={(item) => item.id}
      // This creates new object on every render!
      style={{ flex: 1, backgroundColor: 'white' }}
    />
  );
};

// ✅ Good: Stable references
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white'
  }
});

const GoodComponent = ({ items }: { items: any[] }) => {
  const renderItem = useCallback(({ item }) => (
    <Item item={item} />
  ), []);

  const keyExtractor = useCallback((item) => item.id, []);

  return (
    <FlatList
      data={items}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      style={styles.container}
    />
  );
};
```

**NEVER** ignore image optimization:

```typescript
// ❌ Bad: No image optimization
<Image 
  source={{ uri: 'https://example.com/huge-image.jpg' }}
  style={{ width: 100, height: 100 }}
/>

// ✅ Good: Proper sizing and optimization
<FastImage
  source={{
    uri: 'https://example.com/optimized-image-100x100.jpg',
    priority: FastImage.priority.normal,
    cache: FastImage.cacheControl.immutable
  }}
  style={{ width: 100, height: 100 }}
  resizeMode={FastImage.resizeMode.cover}
/>
```

## Validation Checklist

### **MUST** verify

- [ ] Lists with >100 items use FlatList with proper optimization
- [ ] Images are properly sized and cached
- [ ] Animations use native drivers where possible
- [ ] No synchronous operations block the main thread
- [ ] Memory leaks are prevented with proper cleanup
- [ ] Components use React.memo() where appropriate
- [ ] Large datasets are virtualized
- [ ] Bundle size is optimized with code splitting

### **SHOULD** check

- [ ] 60 FPS is maintained during animations and scrolling
- [ ] Memory usage stays within acceptable limits
- [ ] App startup time is optimized
- [ ] Network requests are properly cached
- [ ] Heavy computations use InteractionManager
- [ ] Performance profiling is regularly conducted
- [ ] Image loading is progressive with placeholders
- [ ] Unnecessary re-renders are eliminated

## References

- [React Native Performance](https://reactnative.dev/docs/performance)
- [React Native Reanimated](https://docs.swmansion.com/react-native-reanimated/)
- [Flipper Performance Profiling](https://fbflipper.com/)
- [React DevTools Profiler](https://reactjs.org/blog/2018/09/10/introducing-the-react-profiler.html)
- [FastImage Library](https://github.com/DylanVann/react-native-fast-image)
- [Bundle Optimization Guide](https://reactnative.dev/docs/ram-bundles-inline-requires)
