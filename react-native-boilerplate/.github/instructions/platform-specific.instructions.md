---
applyTo: '**'
---

# Platform-Specific Instructions

This document outlines platform-specific implementation guidelines for React Native applications, covering iOS and Android specific features, platform detection, and cross-platform compatibility patterns.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** implement proper platform detection and conditional rendering
- **REQUIRED** to follow platform-specific design guidelines (HIG for iOS, Material Design for Android)
- **SHALL** handle platform-specific permissions and capabilities properly
- **MUST** implement platform-specific navigation patterns and gestures
- **NEVER** assume cross-platform behavior without testing on both platforms
- **REQUIRED** to implement platform-specific security features appropriately
- **SHALL** handle platform-specific file system and storage differences
- **MUST** implement proper platform-specific styling and theming
- **REQUIRED** to handle platform-specific deep linking and URL schemes
- **SHALL** implement platform-specific push notification handling

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** use platform-specific native modules when performance is critical
- **RECOMMENDED** to implement platform-specific UI components for native feel
- **ALWAYS** test platform-specific features on real devices
- **DO** implement platform-specific accessibility features
- **SHOULD** handle platform-specific keyboard and input behaviors
- **RECOMMENDED** to implement platform-specific sharing and intent handling
- **DO** optimize platform-specific app store requirements
- **ALWAYS** implement platform-specific error handling and crash reporting
- **SHOULD** handle platform-specific background processing differences

### Optional Enhancements (**MAY** Consider)

- **MAY** implement platform-specific advanced features (widgets, shortcuts)
- **OPTIONAL** to use platform-specific development tools and debugging
- **USE** platform-specific analytics and monitoring tools
- **IMPLEMENT** platform-specific performance optimizations
- **AVOID** over-engineering platform differences for minor features

## Implementation Guidance

### Platform Detection and Conditional Logic

**USE** proper platform detection patterns:

```typescript
// utils/platform.ts
import { Platform, Dimensions } from 'react-native';
import DeviceInfo from 'react-native-device-info';

export const PlatformUtils = {
  // Basic platform detection
  isIOS: Platform.OS === 'ios',
  isAndroid: Platform.OS === 'android',
  
  // Version detection
  isIOS14OrLater: Platform.OS === 'ios' && parseInt(Platform.Version as string, 10) >= 14,
  isAndroid10OrLater: Platform.OS === 'android' && Platform.Version >= 29,
  
  // Device type detection
  isTablet: DeviceInfo.isTablet(),
  
  // Screen size detection
  getScreenSize: () => {
    const { width, height } = Dimensions.get('window');
    return { width, height };
  },
  
  // Platform-specific values
  select: <T>(specifics: { ios?: T; android?: T; default: T }): T => {
    return Platform.select({
      ios: specifics.ios ?? specifics.default,
      android: specifics.android ?? specifics.default,
      default: specifics.default,
    });
  },
  
  // Safe area handling
  getStatusBarHeight: () => {
    return Platform.select({
      ios: DeviceInfo.hasNotch() ? 44 : 20,
      android: 24,
      default: 0,
    });
  },
  
  // Navigation bar height (Android)
  getNavigationBarHeight: () => {
    return Platform.OS === 'android' ? 48 : 0;
  },
};

// Platform-specific component wrapper
interface PlatformComponentProps {
  ios?: React.ComponentType<any>;
  android?: React.ComponentType<any>;
  children?: React.ReactNode;
  [key: string]: any;
}

export const PlatformComponent: React.FC<PlatformComponentProps> = ({
  ios: IOSComponent,
  android: AndroidComponent,
  children,
  ...props
}) => {
  if (Platform.OS === 'ios' && IOSComponent) {
    return <IOSComponent {...props}>{children}</IOSComponent>;
  }
  
  if (Platform.OS === 'android' && AndroidComponent) {
    return <AndroidComponent {...props}>{children}</AndroidComponent>;
  }
  
  return children || null;
};
```

### Platform-Specific Styling

**IMPLEMENT** platform-specific design systems:

```typescript
// styles/platformStyles.ts
import { StyleSheet, Platform } from 'react-native';
import { PlatformUtils } from '@utils/platform';

// Platform-specific style helper
export const createPlatformStyles = <T extends Record<string, any>>(
  styles: T
): T => {
  const platformStyles = {} as T;
  
  Object.keys(styles).forEach(key => {
    const style = styles[key];
    
    if (typeof style === 'object' && style !== null) {
      platformStyles[key] = StyleSheet.create({ style })[style];
    } else {
      platformStyles[key] = style;
    }
  });
  
  return platformStyles;
};

// Platform-specific button styles
export const buttonStyles = createPlatformStyles({
  primary: {
    ...Platform.select({
      ios: {
        backgroundColor: '#007AFF',
        borderRadius: 8,
        paddingVertical: 12,
        paddingHorizontal: 24,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
      },
      android: {
        backgroundColor: '#2196F3',
        borderRadius: 4,
        paddingVertical: 14,
        paddingHorizontal: 28,
        elevation: 3,
      },
    }),
  },
  
  text: {
    ...Platform.select({
      ios: {
        fontSize: 16,
        fontWeight: '600',
        color: '#FFFFFF',
        textAlign: 'center' as const,
      },
      android: {
        fontSize: 14,
        fontWeight: '500',
        color: '#FFFFFF',
        textAlign: 'center' as const,
        textTransform: 'uppercase' as const,
      },
    }),
  },
});

// Header styles following platform guidelines
export const headerStyles = createPlatformStyles({
  container: {
    ...Platform.select({
      ios: {
        backgroundColor: '#F8F8F8',
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: '#C7C7CC',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.1,
        shadowRadius: 1,
      },
      android: {
        backgroundColor: '#2196F3',
        elevation: 4,
      },
    }),
    height: PlatformUtils.select({
      ios: 44,
      android: 56,
      default: 50,
    }),
  },
  
  title: {
    ...Platform.select({
      ios: {
        fontSize: 17,
        fontWeight: '600',
        color: '#000',
      },
      android: {
        fontSize: 20,
        fontWeight: '500',
        color: '#FFFFFF',
      },
    }),
  },
});

// Input field styles
export const inputStyles = createPlatformStyles({
  container: {
    ...Platform.select({
      ios: {
        borderWidth: 1,
        borderColor: '#C7C7CC',
        borderRadius: 8,
        paddingHorizontal: 12,
        paddingVertical: 10,
        backgroundColor: '#FFFFFF',
      },
      android: {
        borderBottomWidth: 1,
        borderBottomColor: '#DADCE0',
        paddingHorizontal: 0,
        paddingVertical: 8,
        backgroundColor: 'transparent',
      },
    }),
  },
  
  focused: {
    ...Platform.select({
      ios: {
        borderColor: '#007AFF',
        shadowColor: '#007AFF',
        shadowOffset: { width: 0, height: 0 },
        shadowOpacity: 0.3,
        shadowRadius: 4,
      },
      android: {
        borderBottomColor: '#2196F3',
        borderBottomWidth: 2,
      },
    }),
  },
});
```

### Platform-Specific Components

**CREATE** platform-specific component implementations:

```typescript
// components/PlatformButton.tsx
import React from 'react';
import { Pressable, Text, ViewStyle, TextStyle } from 'react-native';
import { PlatformUtils } from '@utils/platform';

interface PlatformButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

export const PlatformButton: React.FC<PlatformButtonProps> = ({
  title,
  onPress,
  variant = 'primary',
  disabled = false,
}) => {
  const getButtonStyle = (): ViewStyle => {
    const baseStyle = {
      alignItems: 'center' as const,
      justifyContent: 'center' as const,
      paddingVertical: PlatformUtils.select({ ios: 12, android: 14, default: 12 }),
      paddingHorizontal: PlatformUtils.select({ ios: 24, android: 28, default: 24 }),
      borderRadius: PlatformUtils.select({ ios: 8, android: 4, default: 6 }),
    };

    if (Platform.OS === 'ios') {
      return {
        ...baseStyle,
        backgroundColor: variant === 'primary' ? '#007AFF' : '#F2F2F7',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
      };
    } else {
      return {
        ...baseStyle,
        backgroundColor: variant === 'primary' ? '#2196F3' : '#E0E0E0',
        elevation: disabled ? 0 : 3,
      };
    }
  };

  const getTextStyle = (): TextStyle => {
    return {
      fontSize: PlatformUtils.select({ ios: 16, android: 14, default: 15 }),
      fontWeight: PlatformUtils.select({ ios: '600', android: '500', default: '500' }),
      color: variant === 'primary' ? '#FFFFFF' : 
             Platform.OS === 'ios' ? '#007AFF' : '#424242',
      ...(Platform.OS === 'android' && { textTransform: 'uppercase' as const }),
    };
  };

  const getRippleConfig = () => {
    if (Platform.OS === 'android') {
      return {
        color: variant === 'primary' ? 'rgba(255, 255, 255, 0.3)' : 'rgba(0, 0, 0, 0.1)',
        borderless: false,
      };
    }
    return undefined;
  };

  return (
    <Pressable
      style={({ pressed }) => [
        getButtonStyle(),
        disabled && { opacity: 0.6 },
        Platform.OS === 'ios' && pressed && { opacity: 0.8 },
      ]}
      onPress={onPress}
      disabled={disabled}
      android_ripple={getRippleConfig()}
    >
      <Text style={getTextStyle()}>{title}</Text>
    </Pressable>
  );
};

// Platform-specific navigation header
// components/PlatformHeader.tsx
import React from 'react';
import { View, Text, Pressable, StatusBar } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { PlatformUtils } from '@utils/platform';

interface PlatformHeaderProps {
  title: string;
  leftButton?: {
    title: string;
    onPress: () => void;
  };
  rightButton?: {
    title: string;
    onPress: () => void;
  };
}

export const PlatformHeader: React.FC<PlatformHeaderProps> = ({
  title,
  leftButton,
  rightButton,
}) => {
  const insets = useSafeAreaInsets();

  const headerHeight = PlatformUtils.select({
    ios: 44,
    android: 56,
    default: 50,
  });

  if (Platform.OS === 'ios') {
    return (
      <>
        <StatusBar barStyle="dark-content" backgroundColor="#F8F8F8" />
        <View
          style={[
            headerStyles.container,
            { height: headerHeight + insets.top, paddingTop: insets.top },
          ]}
        >
          <View style={styles.headerContent}>
            <View style={styles.leftSection}>
              {leftButton && (
                <Pressable onPress={leftButton.onPress}>
                  <Text style={styles.iosButtonText}>{leftButton.title}</Text>
                </Pressable>
              )}
            </View>
            
            <View style={styles.centerSection}>
              <Text style={headerStyles.title} numberOfLines={1}>
                {title}
              </Text>
            </View>
            
            <View style={styles.rightSection}>
              {rightButton && (
                <Pressable onPress={rightButton.onPress}>
                  <Text style={styles.iosButtonText}>{rightButton.title}</Text>
                </Pressable>
              )}
            </View>
          </View>
        </View>
      </>
    );
  }

  // Android implementation
  return (
    <>
      <StatusBar barStyle="light-content" backgroundColor="#1976D2" />
      <View
        style={[
          headerStyles.container,
          { height: headerHeight + insets.top, paddingTop: insets.top },
        ]}
      >
        <View style={styles.headerContent}>
          <View style={styles.leftSection}>
            {leftButton && (
              <Pressable
                onPress={leftButton.onPress}
                android_ripple={{ color: 'rgba(255, 255, 255, 0.3)', borderless: true }}
              >
                <Text style={styles.androidButtonText}>{leftButton.title}</Text>
              </Pressable>
            )}
          </View>
          
          <View style={styles.centerSection}>
            <Text style={headerStyles.title} numberOfLines={1}>
              {title}
            </Text>
          </View>
          
          <View style={styles.rightSection}>
            {rightButton && (
              <Pressable
                onPress={rightButton.onPress}
                android_ripple={{ color: 'rgba(255, 255, 255, 0.3)', borderless: true }}
              >
                <Text style={styles.androidButtonText}>{rightButton.title}</Text>
              </Pressable>
            )}
          </View>
        </View>
      </View>
    </>
  );
};

const styles = StyleSheet.create({
  headerContent: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    flex: 1,
  },
  leftSection: {
    flex: 1,
    alignItems: 'flex-start',
  },
  centerSection: {
    flex: 2,
    alignItems: 'center',
  },
  rightSection: {
    flex: 1,
    alignItems: 'flex-end',
  },
  iosButtonText: {
    fontSize: 16,
    color: '#007AFF',
    fontWeight: '400',
  },
  androidButtonText: {
    fontSize: 14,
    color: '#FFFFFF',
    fontWeight: '500',
    textTransform: 'uppercase',
  },
});
```

### Platform-Specific Native Module Integration

**IMPLEMENT** platform-specific native modules:

```typescript
// services/PlatformService.ts
import { NativeModules, Platform } from 'react-native';

// iOS specific imports
const { IOSSpecificModule } = NativeModules;

// Android specific imports  
const { AndroidSpecificModule } = NativeModules;

export interface PlatformService {
  getDeviceInfo(): Promise<DeviceInfo>;
  requestPermissions(): Promise<PermissionStatus>;
  openSettings(): void;
  shareContent(content: ShareContent): Promise<void>;
}

interface DeviceInfo {
  model: string;
  version: string;
  isJailbroken?: boolean; // iOS only
  isRooted?: boolean; // Android only
}

interface ShareContent {
  text?: string;
  url?: string;
  image?: string;
}

export class PlatformServiceImpl implements PlatformService {
  async getDeviceInfo(): Promise<DeviceInfo> {
    if (Platform.OS === 'ios') {
      const info = await IOSSpecificModule.getDeviceInfo();
      return {
        model: info.model,
        version: info.version,
        isJailbroken: info.isJailbroken,
      };
    } else if (Platform.OS === 'android') {
      const info = await AndroidSpecificModule.getDeviceInfo();
      return {
        model: info.model,
        version: info.version,
        isRooted: info.isRooted,
      };
    }
    
    throw new Error('Unsupported platform');
  }

  async requestPermissions(): Promise<PermissionStatus> {
    if (Platform.OS === 'ios') {
      return await IOSSpecificModule.requestPermissions();
    } else if (Platform.OS === 'android') {
      return await AndroidSpecificModule.requestPermissions();
    }
    
    return { granted: false };
  }

  openSettings(): void {
    if (Platform.OS === 'ios') {
      IOSSpecificModule.openSettings();
    } else if (Platform.OS === 'android') {
      AndroidSpecificModule.openSettings();
    }
  }

  async shareContent(content: ShareContent): Promise<void> {
    if (Platform.OS === 'ios') {
      return await IOSSpecificModule.shareContent(content);
    } else if (Platform.OS === 'android') {
      return await AndroidSpecificModule.shareContent(content);
    }
  }
}

export const platformService = new PlatformServiceImpl();
```

## Anti-Patterns

### **DON'T** implement these platform anti-patterns

**AVOID** ignoring platform differences:

```typescript
// ❌ Bad: One size fits all
const Button = ({ title, onPress }) => (
  <Pressable
    style={{
      backgroundColor: 'blue',
      padding: 12,
      borderRadius: 4,
    }}
    onPress={onPress}
  >
    <Text style={{ color: 'white' }}>{title}</Text>
  </Pressable>
);

// ✅ Good: Platform-specific implementation
const Button = ({ title, onPress }) => (
  <PlatformButton title={title} onPress={onPress} />
);
```

**DON'T** assume platform capabilities:

```typescript
// ❌ Bad: Assumes all platforms support feature
const openCamera = () => {
  CameraModule.open(); // May not exist on all platforms
};

// ✅ Good: Check platform and capability
const openCamera = () => {
  if (Platform.OS === 'ios' && IOSCameraModule) {
    IOSCameraModule.open();
  } else if (Platform.OS === 'android' && AndroidCameraModule) {
    AndroidCameraModule.open();
  } else {
    showError('Camera not supported on this platform');
  }
};
```

**NEVER** hardcode platform-specific values:

```typescript
// ❌ Bad: Hardcoded values
const styles = StyleSheet.create({
  header: {
    height: 44, // Only correct for iOS
    paddingTop: 20, // Only correct for older iOS devices
  },
});

// ✅ Good: Dynamic platform values
const styles = StyleSheet.create({
  header: {
    height: PlatformUtils.select({ ios: 44, android: 56, default: 50 }),
    paddingTop: PlatformUtils.getStatusBarHeight(),
  },
});
```

## Validation Checklist

### **MUST** verify

- [ ] Platform detection is properly implemented
- [ ] Platform-specific design guidelines are followed
- [ ] Platform-specific permissions are handled correctly
- [ ] Navigation patterns follow platform conventions
- [ ] Cross-platform testing is conducted on both iOS and Android
- [ ] Platform-specific styling matches native apps
- [ ] Platform-specific deep linking works correctly
- [ ] Platform-specific security features are implemented

### **SHOULD** check

- [ ] Platform-specific UI components provide native feel
- [ ] Accessibility features work on both platforms
- [ ] Platform-specific keyboard behaviors are handled
- [ ] Sharing and intent handling work correctly
- [ ] App store requirements are met for both platforms
- [ ] Background processing differences are handled
- [ ] Platform-specific performance optimizations are applied
- [ ] Error handling is platform-appropriate

## References

- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Material Design Guidelines](https://material.io/design)
- [React Native Platform Specific Code](https://reactnative.dev/docs/platform-specific-code)
- [iOS Development Guidelines](https://developer.apple.com/ios/)
- [Android Development Guidelines](https://developer.android.com/guide)
- [React Native Device Info](https://github.com/react-native-device-info/react-native-device-info)
