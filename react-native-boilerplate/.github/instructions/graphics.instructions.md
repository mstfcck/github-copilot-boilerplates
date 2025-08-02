---
applyTo: '**'
---

# Graphics Instructions

This document outlines high-performance graphics implementation using React Native Skia for advanced 2D graphics, custom animations, and complex UI elements that exceed standard React Native capabilities.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** use React Native Skia for performance-critical graphics operations
- **REQUIRED** to maintain 60+ FPS for all Skia-based animations and interactions
- **SHALL** implement proper Canvas memory management and cleanup
- **MUST** use native driver animations with Reanimated 3+ for optimal performance
- **NEVER** block the JavaScript thread with heavy graphics computations
- **REQUIRED** to implement proper gesture handling with react-native-gesture-handler
- **SHALL** optimize shader compilation and GPU texture usage
- **MUST** implement proper error boundaries for graphics components
- **REQUIRED** to use proper coordinate systems and transformations
- **SHALL** test graphics performance on target devices, not just simulators

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** implement progressive loading for complex graphics and animations
- **RECOMMENDED** to use Canvas snapshots for caching complex graphics
- **ALWAYS** implement proper accessibility for custom graphics components
- **DO** implement gesture tracking for interactive graphics elements
- **SHOULD** use Skia's built-in animation capabilities for smooth transitions
- **RECOMMENDED** to implement custom shaders for specialized visual effects
- **DO** use Lottie animations through Skottie for complex motion graphics
- **ALWAYS** implement proper responsive design for different screen densities
- **SHOULD** use proper color management and theme integration

### Optional Enhancements (**MAY** Consider)

- **MAY** implement advanced shader effects for unique visual experiences
- **OPTIONAL** to use video processing and real-time effects with Skia
- **USE** 3D transformations and perspective effects for immersive UI
- **IMPLEMENT** particle systems and physics-based animations
- **AVOID** over-engineering simple graphics that can be achieved with standard components

## Implementation Guidance

### Basic Skia Canvas Setup

**USE** React Native Skia for high-performance graphics:

```typescript
import React from 'react';
import {
  Canvas,
  Circle,
  Fill,
  Group,
  useCanvasRef,
  useTouchHandler,
  useValue
} from '@shopify/react-native-skia';
import { useWindowDimensions } from 'react-native';

interface SkiaCanvasProps {
  children?: React.ReactNode;
}

export const SkiaCanvas: React.FC<SkiaCanvasProps> = ({ children }) => {
  const { width, height } = useWindowDimensions();
  const canvasRef = useCanvasRef();

  return (
    <Canvas
      style={{ width, height }}
      ref={canvasRef}
      onSize={size => {
        // Handle canvas size changes
        console.log('Canvas size:', size);
      }}
    >
      <Fill color="white" />
      {children}
    </Canvas>
  );
};
```

**IMPLEMENT** interactive graphics with gestures:

```typescript
import React from 'react';
import {
  Canvas,
  Circle,
  Fill,
  useSharedValueEffect,
  useComputedValue
} from '@shopify/react-native-skia';
import {
  GestureDetector,
  Gesture,
  GestureHandlerRootView
} from 'react-native-gesture-handler';
import {
  useSharedValue,
  withSpring,
  runOnJS
} from 'react-native-reanimated';

export const InteractiveCircle: React.FC = () => {
  const translateX = useSharedValue(100);
  const translateY = useSharedValue(100);
  const scale = useSharedValue(1);

  const gesture = Gesture.Pan()
    .onUpdate(event => {
      translateX.value = event.x;
      translateY.value = event.y;
    })
    .onEnd(() => {
      scale.value = withSpring(1);
    });

  const tapGesture = Gesture.Tap()
    .onStart(() => {
      scale.value = withSpring(1.5, {}, () => {
        scale.value = withSpring(1);
      });
    });

  const combinedGesture = Gesture.Simultaneous(gesture, tapGesture);

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <GestureDetector gesture={combinedGesture}>
        <Canvas style={{ flex: 1 }}>
          <Fill color="#f0f0f0" />
          <Group transform={[{ scale }]}>
            <Circle
              cx={translateX}
              cy={translateY}
              r={30}
              color="blue"
            />
          </Group>
        </Canvas>
      </GestureDetector>
    </GestureHandlerRootView>
  );
};
```

**ENSURE** performance optimization with textures:

```typescript
import React from 'react';
import {
  Canvas,
  Image,
  useTexture,
  Group,
  Circle,
  rect
} from '@shopify/react-native-skia';

export const OptimizedGraphics: React.FC = () => {
  // Create texture for reusable graphics
  const texture = useTexture(
    <Group>
      <Circle cx={25} cy={25} r={20} color="red" />
      <Circle cx={25} cy={25} r={15} color="white" />
    </Group>,
    { width: 50, height: 50 }
  );

  return (
    <Canvas style={{ width: 300, height: 300 }}>
      {/* Use texture multiple times for performance */}
      <Image
        image={texture}
        x={50}
        y={50}
        width={50}
        height={50}
      />
      <Image
        image={texture}
        x={150}
        y={150}
        width={50}
        height={50}
      />
    </Canvas>
  );
};
```

### Advanced Animations with Skottie

**IMPLEMENT** Lottie animations with Skottie:

```typescript
import React from 'react';
import {
  Canvas,
  Skottie,
  Skia,
  useClock,
  Group
} from '@shopify/react-native-skia';
import { useDerivedValue } from 'react-native-reanimated';

// Import your Lottie JSON file
const animationJSON = require('./assets/animation.json');

export const SkottieAnimation: React.FC = () => {
  const animation = React.useMemo(() => {
    return Skia.Skottie.Make(JSON.stringify(animationJSON));
  }, []);

  const clock = useClock();

  const frame = useDerivedValue(() => {
    if (!animation) return 0;
    
    const fps = animation.fps();
    const duration = animation.duration();
    const totalFrames = duration * fps;
    
    return Math.floor((clock.value / 1000) * fps) % totalFrames;
  });

  if (!animation) {
    return null;
  }

  return (
    <Canvas style={{ width: 300, height: 300 }}>
      <Group transform={[{ scale: 0.5 }]}>
        <Skottie animation={animation} frame={frame} />
      </Group>
    </Canvas>
  );
};
```

**USE** custom shaders for advanced effects:

```typescript
import React from 'react';
import {
  Canvas,
  Fill,
  Shader,
  Skia,
  vec
} from '@shopify/react-native-skia';

export const CustomShaderExample: React.FC = () => {
  const shader = React.useMemo(() => {
    const source = Skia.RuntimeEffect.Make(`
      uniform float iTime;
      uniform vec2 iResolution;
      
      vec4 main(vec2 pos) {
        vec2 uv = pos / iResolution.xy;
        vec3 col = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0, 2, 4));
        return vec4(col, 1.0);
      }
    `);
    
    return source;
  }, []);

  if (!shader) {
    return null;
  }

  return (
    <Canvas style={{ width: 300, height: 300 }}>
      <Fill>
        <Shader source={shader}>
          <uniforms>
            <uniform name="iTime" value={0} />
            <uniform name="iResolution" value={vec(300, 300)} />
          </uniforms>
        </Shader>
      </Fill>
    </Canvas>
  );
};
```

### Performance Monitoring and Optimization

**IMPLEMENT** performance monitoring for graphics:

```typescript
import React, { useEffect } from 'react';
import {
  Canvas,
  useCanvasRef,
  useTouchHandler
} from '@shopify/react-native-skia';

export const PerformanceMonitoredCanvas: React.FC = () => {
  const canvasRef = useCanvasRef();
  
  useEffect(() => {
    const startTime = performance.now();
    
    return () => {
      const endTime = performance.now();
      console.log(`Canvas lifetime: ${endTime - startTime}ms`);
    };
  }, []);

  const touchHandler = useTouchHandler({
    onStart: (event) => {
      const startTime = performance.now();
      
      // Measure interaction performance
      requestAnimationFrame(() => {
        const frameTime = performance.now() - startTime;
        if (frameTime > 16.67) {
          console.warn(`Slow frame detected: ${frameTime}ms`);
        }
      });
    }
  });

  return (
    <Canvas
      style={{ flex: 1 }}
      ref={canvasRef}
      onTouch={touchHandler}
    >
      {/* Canvas content */}
    </Canvas>
  );
};
```

## Anti-Patterns

### **DON'T** implement these graphics anti-patterns

**NEVER** block the JavaScript thread with heavy computations:

```typescript
// ❌ Bad: Heavy computation on main thread
const HeavyGraphics = () => {
  const heavyCalculation = () => {
    for (let i = 0; i < 1000000; i++) {
      // Heavy computation blocking UI
    }
  };

  return (
    <Canvas onTouch={() => heavyCalculation()}>
      {/* Graphics content */}
    </Canvas>
  );
};

// ✅ Good: Use worklets or defer heavy operations
const OptimizedGraphics = () => {
  const deferredCalculation = () => {
    requestAnimationFrame(() => {
      // Deferred computation
    });
  };

  return (
    <Canvas onTouch={deferredCalculation}>
      {/* Graphics content */}
    </Canvas>
  );
};
```

**AVOID** memory leaks with improper cleanup:

```typescript
// ❌ Bad: No cleanup of resources
const LeakyCanvas = () => {
  const canvasRef = useCanvasRef();
  
  useEffect(() => {
    const interval = setInterval(() => {
      // Creating new textures without cleanup
      const texture = createTexture();
    }, 100);
    
    // Missing cleanup!
  }, []);

  return <Canvas ref={canvasRef} />;
};

// ✅ Good: Proper resource cleanup
const CleanCanvas = () => {
  const canvasRef = useCanvasRef();
  
  useEffect(() => {
    const interval = setInterval(() => {
      const texture = createTexture();
    }, 100);
    
    return () => {
      clearInterval(interval);
      // Cleanup resources
    };
  }, []);

  return <Canvas ref={canvasRef} />;
};
```

## Code Examples

### Interactive Drawing Canvas

```typescript
import React, { useState } from 'react';
import {
  Canvas,
  Path,
  Skia,
  useTouchHandler
} from '@shopify/react-native-skia';

export const DrawingCanvas: React.FC = () => {
  const [paths, setPaths] = useState<string[]>([]);
  const [currentPath, setCurrentPath] = useState<string>('');

  const touchHandler = useTouchHandler({
    onStart: (event) => {
      const path = Skia.Path.Make();
      path.moveTo(event.x, event.y);
      setCurrentPath(path.toSVGString());
    },
    onActive: (event) => {
      const path = Skia.Path.MakeFromSVGString(currentPath);
      if (path) {
        path.lineTo(event.x, event.y);
        setCurrentPath(path.toSVGString());
      }
    },
    onEnd: () => {
      if (currentPath) {
        setPaths(prev => [...prev, currentPath]);
        setCurrentPath('');
      }
    }
  });

  return (
    <Canvas
      style={{ flex: 1 }}
      onTouch={touchHandler}
    >
      {paths.map((pathString, index) => (
        <Path
          key={index}
          path={pathString}
          color="black"
          style="stroke"
          strokeWidth={2}
        />
      ))}
      {currentPath && (
        <Path
          path={currentPath}
          color="red"
          style="stroke"
          strokeWidth={2}
        />
      )}
    </Canvas>
  );
};
```

### Particle System

```typescript
import React, { useEffect } from 'react';
import {
  Canvas,
  Circle,
  Group,
  useLoop
} from '@shopify/react-native-skia';
import { useSharedValue } from 'react-native-reanimated';

interface Particle {
  x: number;
  y: number;
  vx: number;
  vy: number;
  life: number;
}

export const ParticleSystem: React.FC = () => {
  const particles = useSharedValue<Particle[]>([]);
  const loop = useLoop({ duration: 16 }); // 60 FPS

  useEffect(() => {
    const createParticle = (): Particle => ({
      x: Math.random() * 300,
      y: 300,
      vx: (Math.random() - 0.5) * 10,
      vy: -Math.random() * 10 - 5,
      life: 1
    });

    const interval = setInterval(() => {
      particles.value = [
        ...particles.value.slice(-50), // Limit particles
        createParticle()
      ];
    }, 100);

    return () => clearInterval(interval);
  }, []);

  // Update particles based on loop
  const updatedParticles = React.useMemo(() => {
    return particles.value
      .map(particle => ({
        ...particle,
        x: particle.x + particle.vx,
        y: particle.y + particle.vy,
        vy: particle.vy + 0.5, // Gravity
        life: particle.life - 0.02
      }))
      .filter(particle => particle.life > 0);
  }, [loop.current, particles.value]);

  return (
    <Canvas style={{ width: 300, height: 300 }}>
      <Group>
        {updatedParticles.map((particle, index) => (
          <Circle
            key={index}
            cx={particle.x}
            cy={particle.y}
            r={3}
            color={`rgba(255, 100, 100, ${particle.life})`}
          />
        ))}
      </Group>
    </Canvas>
  );
};
```

## Validation Checklist

### **MUST** verify

- [ ] All Skia graphics maintain 60+ FPS performance
- [ ] Proper memory management and resource cleanup implemented
- [ ] Canvas components have appropriate error boundaries
- [ ] Gesture handling is responsive and accurate
- [ ] Graphics work consistently across iOS and Android
- [ ] Accessibility support for custom graphics elements
- [ ] Performance monitoring and optimization in place
- [ ] Shader compilation is optimized for target devices

### **SHOULD** check

- [ ] Complex graphics use texture caching appropriately
- [ ] Animations use native driver where possible
- [ ] Interactive elements provide proper user feedback
- [ ] Graphics adapt to different screen densities
- [ ] Custom shaders are optimized and tested
- [ ] Lottie animations are properly integrated with Skottie
- [ ] Progressive loading for complex graphics
- [ ] Theme integration for colors and styling

## References

- [React Native Skia Documentation](https://shopify.github.io/react-native-skia/)
- [Skia Graphics Library](https://skia.org/)
- [React Native Reanimated](https://docs.swmansion.com/react-native-reanimated/)
- [React Native Gesture Handler](https://docs.swmansion.com/react-native-gesture-handler/)
- [Lottie Animations](https://airbnb.design/lottie/)
- [GPU Performance Best Practices](https://developer.android.com/games/optimize/gpu-performance)
