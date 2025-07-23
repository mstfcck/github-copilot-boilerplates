---
applyTo: '**'
---

# UI/UX Instructions

This document outlines comprehensive UI/UX design implementation guidelines for React Native applications, covering design systems, accessibility, responsive design, and cross-platform user experience considerations.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** implement consistent design system with standardized components and tokens
- **REQUIRED** to support both light and dark mode themes
- **SHALL** ensure accessibility compliance with WCAG 2.1 AA standards
- **MUST** implement responsive design for different screen sizes and orientations
- **NEVER** ignore platform-specific design guidelines (Material Design, Human Interface Guidelines)
- **REQUIRED** to implement proper typography scaling and font accessibility
- **SHALL** provide proper touch targets with minimum 44pt/44dp hit areas
- **MUST** implement proper focus management and keyboard navigation
- **REQUIRED** to support screen readers and voice control
- **SHALL** implement consistent spacing, colors, and visual hierarchy

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** implement haptic feedback for enhanced user experience
- **RECOMMENDED** to use animation and micro-interactions for visual feedback
- **ALWAYS** provide loading states and progress indicators
- **DO** implement proper error states with actionable recovery options
- **SHOULD** follow platform conventions for navigation patterns
- **RECOMMENDED** to implement gesture-based interactions where appropriate
- **DO** provide visual feedback for all user interactions
- **ALWAYS** implement proper contrast ratios for accessibility
- **SHOULD** support dynamic type and text scaling preferences

### Optional Enhancements (**MAY** Consider)

- **MAY** implement advanced animation libraries for complex interactions
- **OPTIONAL** to use lottie animations for detailed visual feedback
- **USE** custom illustrations and iconography for brand consistency
- **IMPLEMENT** advanced accessibility features like voice commands
- **AVOID** over-animating interfaces that could cause motion sickness

## Implementation Guidance

### Design System Implementation

**USE** a comprehensive design system structure:

```typescript
// tokens/colors.ts
export const colors = {
  // Base palette
  primary: {
    50: '#EBF8FF',
    100: '#BEE3F8',
    500: '#3182CE',
    600: '#2B77CB',
    900: '#1A365D',
  },
  secondary: {
    50: '#F7FAFC',
    100: '#EDF2F7',
    500: '#718096',
    600: '#4A5568',
    900: '#1A202C',
  },
  // Semantic colors
  success: '#38A169',
  warning: '#D69E2E',
  error: '#E53E3E',
  info: '#3182CE',
  
  // Theme-specific colors
  light: {
    background: '#FFFFFF',
    surface: '#F7FAFC',
    text: '#1A202C',
    textSecondary: '#4A5568',
    border: '#E2E8F0',
  },
  dark: {
    background: '#1A202C',
    surface: '#2D3748',
    text: '#F7FAFC',
    textSecondary: '#A0AEC0',
    border: '#4A5568',
  }
};

// tokens/typography.ts
export const typography = {
  fonts: {
    primary: {
      regular: 'System',
      medium: 'System-Medium',
      semiBold: 'System-SemiBold',
      bold: 'System-Bold',
    },
    mono: 'Menlo',
  },
  sizes: {
    xs: 12,
    sm: 14,
    base: 16,
    lg: 18,
    xl: 20,
    '2xl': 24,
    '3xl': 30,
    '4xl': 36,
  },
  lineHeights: {
    tight: 1.2,
    normal: 1.4,
    relaxed: 1.6,
  },
  letterSpacing: {
    tight: -0.05,
    normal: 0,
    wide: 0.05,
  }
};

// tokens/spacing.ts
export const spacing = {
  0: 0,
  1: 4,
  2: 8,
  3: 12,
  4: 16,
  5: 20,
  6: 24,
  8: 32,
  10: 40,
  12: 48,
  16: 64,
  20: 80,
  24: 96,
};

// Theme provider
import React, { createContext, useContext, useEffect, useState } from 'react';
import { useColorScheme } from 'react-native';

interface Theme {
  colors: typeof colors.light;
  typography: typeof typography;
  spacing: typeof spacing;
  isDark: boolean;
}

interface ThemeContextType {
  theme: Theme;
  toggleTheme: () => void;
  setTheme: (theme: 'light' | 'dark' | 'system') => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const systemColorScheme = useColorScheme();
  const [themeMode, setThemeMode] = useState<'light' | 'dark' | 'system'>('system');

  const isDark = themeMode === 'system' ? systemColorScheme === 'dark' : themeMode === 'dark';

  const theme: Theme = {
    colors: isDark ? colors.dark : colors.light,
    typography,
    spacing,
    isDark,
  };

  const toggleTheme = () => {
    setThemeMode(current => current === 'light' ? 'dark' : 'light');
  };

  const setTheme = (newTheme: 'light' | 'dark' | 'system') => {
    setThemeMode(newTheme);
  };

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
};
```

**IMPLEMENT** consistent component styling:

```typescript
// components/Button.tsx
import React from 'react';
import { Pressable, Text, ViewStyle, TextStyle, ActivityIndicator } from 'react-native';
import { useTheme } from '@hooks/useTheme';

interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  size?: 'small' | 'medium' | 'large';
  disabled?: boolean;
  loading?: boolean;
  fullWidth?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
}

export const Button: React.FC<ButtonProps> = ({
  title,
  onPress,
  variant = 'primary',
  size = 'medium',
  disabled = false,
  loading = false,
  fullWidth = false,
  leftIcon,
  rightIcon,
}) => {
  const { theme } = useTheme();

  const getButtonStyle = (): ViewStyle => {
    const baseStyle: ViewStyle = {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
      borderRadius: 8,
      minHeight: size === 'small' ? 32 : size === 'large' ? 48 : 40,
      paddingHorizontal: theme.spacing[size === 'small' ? 3 : size === 'large' ? 6 : 4],
      ...(fullWidth && { width: '100%' }),
    };

    switch (variant) {
      case 'primary':
        return {
          ...baseStyle,
          backgroundColor: disabled ? theme.colors.primary[200] : theme.colors.primary[500],
        };
      case 'secondary':
        return {
          ...baseStyle,
          backgroundColor: disabled ? theme.colors.secondary[100] : theme.colors.secondary[500],
        };
      case 'outline':
        return {
          ...baseStyle,
          backgroundColor: 'transparent',
          borderWidth: 1,
          borderColor: disabled ? theme.colors.border : theme.colors.primary[500],
        };
      case 'ghost':
        return {
          ...baseStyle,
          backgroundColor: 'transparent',
        };
    }
  };

  const getTextStyle = (): TextStyle => {
    const baseStyle: TextStyle = {
      fontSize: theme.typography.sizes[size === 'small' ? 'sm' : size === 'large' ? 'lg' : 'base'],
      fontFamily: theme.typography.fonts.primary.medium,
    };

    switch (variant) {
      case 'primary':
        return {
          ...baseStyle,
          color: '#FFFFFF',
        };
      case 'secondary':
        return {
          ...baseStyle,
          color: '#FFFFFF',
        };
      case 'outline':
      case 'ghost':
        return {
          ...baseStyle,
          color: disabled ? theme.colors.textSecondary : theme.colors.primary[500],
        };
    }
  };

  return (
    <Pressable
      style={({ pressed }) => [
        getButtonStyle(),
        pressed && { opacity: 0.8 },
        disabled && { opacity: 0.6 },
      ]}
      onPress={onPress}
      disabled={disabled || loading}
      accessible={true}
      accessibilityRole="button"
      accessibilityLabel={title}
      accessibilityState={{ disabled: disabled || loading }}
      accessibilityHint={loading ? 'Loading, please wait' : undefined}
    >
      {leftIcon && !loading && leftIcon}
      
      {loading ? (
        <ActivityIndicator 
          size="small" 
          color={variant === 'primary' || variant === 'secondary' ? '#FFFFFF' : theme.colors.primary[500]} 
        />
      ) : (
        <Text style={getTextStyle()}>{title}</Text>
      )}
      
      {rightIcon && !loading && rightIcon}
    </Pressable>
  );
};
```

### Accessibility Implementation

**ENSURE** comprehensive accessibility support:

```typescript
// components/AccessibleText.tsx
import React from 'react';
import { Text, TextProps, TextStyle } from 'react-native';
import { useTheme } from '@hooks/useTheme';

interface AccessibleTextProps extends TextProps {
  variant?: 'h1' | 'h2' | 'h3' | 'body' | 'caption' | 'overline';
  color?: string;
  align?: 'left' | 'center' | 'right';
  weight?: 'regular' | 'medium' | 'semiBold' | 'bold';
  semanticRole?: 'header' | 'text' | 'summary';
}

export const AccessibleText: React.FC<AccessibleTextProps> = ({
  children,
  variant = 'body',
  color,
  align = 'left',
  weight = 'regular',
  semanticRole = 'text',
  style,
  ...props
}) => {
  const { theme } = useTheme();

  const getTextStyle = (): TextStyle => {
    let fontSize: number;
    let lineHeight: number;
    let letterSpacing: number = 0;

    switch (variant) {
      case 'h1':
        fontSize = theme.typography.sizes['4xl'];
        lineHeight = fontSize * theme.typography.lineHeights.tight;
        break;
      case 'h2':
        fontSize = theme.typography.sizes['3xl'];
        lineHeight = fontSize * theme.typography.lineHeights.tight;
        break;
      case 'h3':
        fontSize = theme.typography.sizes['2xl'];
        lineHeight = fontSize * theme.typography.lineHeights.normal;
        break;
      case 'body':
        fontSize = theme.typography.sizes.base;
        lineHeight = fontSize * theme.typography.lineHeights.normal;
        break;
      case 'caption':
        fontSize = theme.typography.sizes.sm;
        lineHeight = fontSize * theme.typography.lineHeights.normal;
        break;
      case 'overline':
        fontSize = theme.typography.sizes.xs;
        lineHeight = fontSize * theme.typography.lineHeights.normal;
        letterSpacing = theme.typography.letterSpacing.wide;
        break;
    }

    return {
      fontSize,
      lineHeight,
      letterSpacing,
      fontFamily: theme.typography.fonts.primary[weight],
      color: color || theme.colors.text,
      textAlign: align,
    };
  };

  const getAccessibilityProps = () => {
    switch (semanticRole) {
      case 'header':
        return {
          accessibilityRole: 'header' as const,
          accessibilityLevel: variant === 'h1' ? 1 : variant === 'h2' ? 2 : 3,
        };
      case 'summary':
        return {
          accessibilityRole: 'summary' as const,
        };
      default:
        return {
          accessibilityRole: 'text' as const,
        };
    }
  };

  return (
    <Text
      style={[getTextStyle(), style]}
      {...getAccessibilityProps()}
      {...props}
    >
      {children}
    </Text>
  );
};

// Accessibility utilities
export const AccessibilityUtils = {
  // Announce to screen readers
  announceForAccessibility: (message: string) => {
    // Implementation depends on platform
    // iOS: Use announceForAccessibility
    // Android: Use announce
  },

  // Check if screen reader is enabled
  isScreenReaderEnabled: async (): Promise<boolean> => {
    // Platform-specific implementation
    return false;
  },

  // Focus management
  setAccessibilityFocus: (ref: React.RefObject<any>) => {
    if (ref.current) {
      ref.current.setAccessibilityFocus?.();
    }
  },
};

// High contrast mode support
export const useHighContrast = () => {
  const { theme } = useTheme();
  const [isHighContrast, setIsHighContrast] = useState(false);

  useEffect(() => {
    // Check system preference for high contrast
    // Implementation depends on platform capabilities
  }, []);

  const getContrastColors = () => {
    if (!isHighContrast) return theme.colors;

    return {
      ...theme.colors,
      text: '#000000',
      background: '#FFFFFF',
      primary: '#0000FF',
      border: '#000000',
    };
  };

  return {
    isHighContrast,
    colors: getContrastColors(),
  };
};
```

### Responsive Design Implementation

**IMPLEMENT** responsive design patterns:

```typescript
// hooks/useResponsiveLayout.ts
import { useState, useEffect } from 'react';
import { Dimensions, ScaledSize } from 'react-native';

interface ScreenInfo {
  width: number;
  height: number;
  scale: number;
  fontScale: number;
}

interface BreakpointsType {
  small: number;
  medium: number;
  large: number;
  xlarge: number;
}

const breakpoints: BreakpointsType = {
  small: 320,
  medium: 768,
  large: 1024,
  xlarge: 1440,
};

export const useResponsiveLayout = () => {
  const [screenInfo, setScreenInfo] = useState<ScreenInfo>(() => {
    const { width, height, scale, fontScale } = Dimensions.get('window');
    return { width, height, scale, fontScale };
  });

  useEffect(() => {
    const subscription = Dimensions.addEventListener('change', ({ window }) => {
      setScreenInfo({
        width: window.width,
        height: window.height,
        scale: window.scale,
        fontScale: window.fontScale,
      });
    });

    return () => subscription?.remove();
  }, []);

  const isSmall = screenInfo.width < breakpoints.medium;
  const isMedium = screenInfo.width >= breakpoints.medium && screenInfo.width < breakpoints.large;
  const isLarge = screenInfo.width >= breakpoints.large && screenInfo.width < breakpoints.xlarge;
  const isXLarge = screenInfo.width >= breakpoints.xlarge;

  const isTablet = screenInfo.width >= breakpoints.medium;
  const isDesktop = screenInfo.width >= breakpoints.large;
  const isPortrait = screenInfo.height > screenInfo.width;
  const isLandscape = screenInfo.width > screenInfo.height;

  const getResponsiveValue = <T>(values: {
    small?: T;
    medium?: T;
    large?: T;
    xlarge?: T;
    default: T;
  }): T => {
    if (isXLarge && values.xlarge !== undefined) return values.xlarge;
    if (isLarge && values.large !== undefined) return values.large;
    if (isMedium && values.medium !== undefined) return values.medium;
    if (isSmall && values.small !== undefined) return values.small;
    return values.default;
  };

  return {
    screenInfo,
    breakpoints: {
      isSmall,
      isMedium,
      isLarge,
      isXLarge,
      isTablet,
      isDesktop,
      isPortrait,
      isLandscape,
    },
    getResponsiveValue,
  };
};

// Responsive grid component
interface GridProps {
  children: React.ReactNode;
  columns?: number | { small?: number; medium?: number; large?: number };
  spacing?: number;
}

export const ResponsiveGrid: React.FC<GridProps> = ({
  children,
  columns = 1,
  spacing = 16,
}) => {
  const { getResponsiveValue } = useResponsiveLayout();

  const columnCount = typeof columns === 'number' 
    ? columns 
    : getResponsiveValue({
        small: columns.small,
        medium: columns.medium,
        large: columns.large,
        default: 1,
      });

  const childrenArray = React.Children.toArray(children);

  return (
    <View style={styles.grid}>
      {childrenArray.map((child, index) => {
        const isLastInRow = (index + 1) % columnCount === 0;
        const isLastRow = Math.floor(index / columnCount) === Math.floor((childrenArray.length - 1) / columnCount);

        return (
          <View
            key={index}
            style={[
              styles.gridItem,
              {
                width: `${100 / columnCount}%`,
                paddingRight: isLastInRow ? 0 : spacing / 2,
                paddingLeft: index % columnCount === 0 ? 0 : spacing / 2,
                marginBottom: isLastRow ? 0 : spacing,
              },
            ]}
          >
            {child}
          </View>
        );
      })}
    </View>
  );
};
```

### Platform-Specific UI Patterns

**ENSURE** platform-appropriate design:

```typescript
// components/PlatformSpecificHeader.tsx
import React from 'react';
import { View, Text, StyleSheet, Platform } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useTheme } from '@hooks/useTheme';

interface HeaderProps {
  title: string;
  leftAction?: React.ReactNode;
  rightAction?: React.ReactNode;
  subtitle?: string;
}

export const PlatformHeader: React.FC<HeaderProps> = ({
  title,
  leftAction,
  rightAction,
  subtitle,
}) => {
  const { theme } = useTheme();
  const insets = useSafeAreaInsets();

  const headerHeight = Platform.select({
    ios: 44,
    android: 56,
    default: 50,
  });

  const getHeaderStyle = () => {
    if (Platform.OS === 'ios') {
      return {
        backgroundColor: theme.colors.background,
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: theme.colors.border,
        shadowColor: '#000000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.1,
        shadowRadius: 2,
      };
    } else {
      return {
        backgroundColor: theme.colors.primary[500],
        elevation: 4,
      };
    }
  };

  const getTitleStyle = () => {
    if (Platform.OS === 'ios') {
      return {
        fontSize: 17,
        fontWeight: '600' as const,
        color: theme.colors.text,
      };
    } else {
      return {
        fontSize: 20,
        fontWeight: '500' as const,
        color: '#FFFFFF',
      };
    }
  };

  return (
    <View
      style={[
        styles.header,
        getHeaderStyle(),
        {
          height: headerHeight + insets.top,
          paddingTop: insets.top,
        },
      ]}
    >
      <View style={styles.headerContent}>
        <View style={styles.leftSection}>
          {leftAction}
        </View>
        
        <View style={styles.centerSection}>
          <Text
            style={getTitleStyle()}
            numberOfLines={1}
            accessibilityRole="header"
            accessibilityLevel={1}
          >
            {title}
          </Text>
          {subtitle && (
            <Text
              style={[
                styles.subtitle,
                { color: Platform.OS === 'ios' ? theme.colors.textSecondary : '#FFFFFF' }
              ]}
              numberOfLines={1}
            >
              {subtitle}
            </Text>
          )}
        </View>
        
        <View style={styles.rightSection}>
          {rightAction}
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  header: {
    justifyContent: 'flex-end',
  },
  headerContent: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    height: Platform.select({
      ios: 44,
      android: 56,
      default: 50,
    }),
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
  subtitle: {
    fontSize: 12,
    marginTop: 2,
  },
});
```

## Anti-Patterns

### **DON'T** implement these UI/UX mistakes

**AVOID** inconsistent design patterns:

```typescript
// ❌ Bad: Inconsistent styling
const InconsistentButton = ({ title, onPress }) => (
  <Pressable
    style={{
      backgroundColor: '#3498db',  // Hardcoded color
      padding: 12,                 // Inconsistent spacing
      borderRadius: 4,             // Different from design system
    }}
    onPress={onPress}
  >
    <Text style={{ color: 'white', fontSize: 14 }}>{title}</Text>
  </Pressable>
);

// ✅ Good: Consistent with design system
const ConsistentButton = ({ title, onPress }) => {
  const { theme } = useTheme();
  
  return (
    <Button
      title={title}
      onPress={onPress}
      variant="primary"
      size="medium"
    />
  );
};
```

**DON'T** ignore accessibility:

```typescript
// ❌ Bad: No accessibility support
<Pressable onPress={handlePress}>
  <Image source={icon} />
</Pressable>

// ✅ Good: Proper accessibility
<Pressable
  onPress={handlePress}
  accessible={true}
  accessibilityRole="button"
  accessibilityLabel="Settings"
  accessibilityHint="Opens the settings screen"
>
  <Image source={icon} />
</Pressable>
```

**NEVER** ignore platform differences:

```typescript
// ❌ Bad: One size fits all
const BadHeader = () => (
  <View style={{ height: 60, backgroundColor: 'blue' }}>
    <Text style={{ fontSize: 18, color: 'white' }}>Title</Text>
  </View>
);

// ✅ Good: Platform-specific implementation
const GoodHeader = () => <PlatformHeader title="Title" />;
```

## Validation Checklist

### **MUST** verify

- [ ] Design system tokens are used consistently throughout the app
- [ ] Both light and dark themes are implemented and tested
- [ ] All interactive elements have minimum 44pt/44dp touch targets
- [ ] Accessibility labels and roles are present on all interactive elements
- [ ] Text contrast ratios meet WCAG 2.1 AA standards
- [ ] App supports dynamic type and font scaling
- [ ] Platform-specific design guidelines are followed
- [ ] Focus management works correctly with keyboard navigation

### **SHOULD** check

- [ ] Responsive design works across different screen sizes
- [ ] Loading states and error states are consistently implemented
- [ ] Animations and transitions feel smooth and purposeful
- [ ] Haptic feedback is implemented for appropriate interactions
- [ ] High contrast mode is supported
- [ ] Screen reader testing has been conducted
- [ ] UI components are documented in Storybook or similar
- [ ] Visual regression testing is in place

## References

- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Material Design Guidelines](https://material.io/design)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [React Native Accessibility](https://reactnative.dev/docs/accessibility)
- [React Navigation Theming](https://reactnavigation.org/docs/themes/)
- [Expo Design System](https://docs.expo.dev/ui-programming/implementing-a-design-system/)
