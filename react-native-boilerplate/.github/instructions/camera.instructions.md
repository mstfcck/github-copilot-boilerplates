---
applyTo: '**'
---

# Camera Instructions

This document outlines advanced camera implementation using React Native Vision Camera 4+ with high-performance frame processing, real-time effects, and integration with React Native Skia for custom visual processing.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** use React Native Vision Camera 4+ for all camera functionality
- **REQUIRED** to request proper camera permissions before accessing camera features
- **SHALL** implement proper camera session management and lifecycle handling
- **MUST** handle camera errors gracefully with proper user feedback
- **NEVER** block the JavaScript thread with heavy frame processing operations
- **REQUIRED** to implement proper memory management for camera frames and buffers
- **SHALL** support both photo capture and video recording with optimal quality settings
- **MUST** implement proper focus, exposure, and white balance controls
- **REQUIRED** to test camera functionality on real devices, not simulators
- **SHALL** implement proper orientation handling for camera preview and captures

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** implement real-time frame processing using Skia for custom effects
- **RECOMMENDED** to use hardware acceleration for image processing when available
- **ALWAYS** implement proper loading states and error handling for camera operations
- **DO** implement camera preview optimization for different screen sizes
- **SHOULD** use proper image compression and format optimization for captures
- **RECOMMENDED** to implement advanced camera features like HDR, night mode, and stabilization
- **DO** implement proper face detection and object tracking capabilities
- **ALWAYS** implement proper accessibility features for camera controls
- **SHOULD** use proper threading for intensive camera processing operations

### Optional Enhancements (**MAY** Consider)

- **MAY** implement custom camera filters and real-time effects using Skia
- **OPTIONAL** to integrate machine learning models for object detection and recognition
- **USE** barcode and QR code scanning capabilities with proper validation
- **IMPLEMENT** advanced video features like slow motion and time-lapse
- **AVOID** implementing complex camera features that compromise performance

## Implementation Guidance

### Basic Camera Setup

**USE** React Native Vision Camera for modern camera functionality:

```typescript
import React, { useEffect, useState, useRef } from 'react';
import {
  View,
  StyleSheet,
  Text,
  TouchableOpacity,
  Alert
} from 'react-native';
import {
  Camera,
  useCameraDevice,
  useCameraPermission,
  useMicrophonePermission,
  PhotoFile,
  VideoFile,
  Frame
} from 'react-native-vision-camera';

interface CameraViewProps {
  onPhotoCapture?: (photo: PhotoFile) => void;
  onVideoCapture?: (video: VideoFile) => void;
}

export const CameraView: React.FC<CameraViewProps> = ({
  onPhotoCapture,
  onVideoCapture
}) => {
  const camera = useRef<Camera>(null);
  const [isActive, setIsActive] = useState(true);
  const [isRecording, setIsRecording] = useState(false);

  const { hasPermission: hasCameraPermission, requestPermission: requestCameraPermission } = useCameraPermission();
  const { hasPermission: hasMicrophonePermission, requestPermission: requestMicrophonePermission } = useMicrophonePermission();

  const device = useCameraDevice('back', {
    physicalDevices: ['ultra-wide-angle-camera', 'wide-angle-camera', 'telephoto-camera']
  });

  useEffect(() => {
    const requestPermissions = async () => {
      if (!hasCameraPermission) {
        const granted = await requestCameraPermission();
        if (!granted) {
          Alert.alert('Permission denied', 'Camera permission is required');
          return;
        }
      }

      if (!hasMicrophonePermission) {
        await requestMicrophonePermission();
      }
    };

    requestPermissions();
  }, [hasCameraPermission, hasMicrophonePermission]);

  const takePhoto = async () => {
    try {
      if (!camera.current) return;

      const photo = await camera.current.takePhoto({
        qualityPrioritization: 'quality',
        enableAutoRedEyeReduction: true,
        enableAutoStabilization: true,
        enableShutterSound: true
      });

      onPhotoCapture?.(photo);
    } catch (error) {
      console.error('Failed to take photo:', error);
      Alert.alert('Error', 'Failed to take photo');
    }
  };

  const startRecording = async () => {
    try {
      if (!camera.current) return;

      setIsRecording(true);
      camera.current.startRecording({
        onRecordingFinished: (video) => {
          setIsRecording(false);
          onVideoCapture?.(video);
        },
        onRecordingError: (error) => {
          setIsRecording(false);
          console.error('Recording error:', error);
          Alert.alert('Error', 'Failed to record video');
        }
      });
    } catch (error) {
      setIsRecording(false);
      console.error('Failed to start recording:', error);
    }
  };

  const stopRecording = async () => {
    try {
      if (!camera.current) return;
      await camera.current.stopRecording();
    } catch (error) {
      console.error('Failed to stop recording:', error);
    }
  };

  if (!device) {
    return (
      <View style={styles.container}>
        <Text>Camera not available</Text>
      </View>
    );
  }

  if (!hasCameraPermission) {
    return (
      <View style={styles.container}>
        <Text>Camera permission required</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Camera
        ref={camera}
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={isActive}
        photo={true}
        video={true}
        audio={hasMicrophonePermission}
        enableZoomGesture={true}
        photoQualityBalance="quality"
        videoQualityBalance="quality"
      />
      
      <View style={styles.controls}>
        <TouchableOpacity
          style={styles.captureButton}
          onPress={takePhoto}
          disabled={isRecording}
        >
          <Text style={styles.buttonText}>Photo</Text>
        </TouchableOpacity>
        
        <TouchableOpacity
          style={[styles.captureButton, { backgroundColor: isRecording ? 'red' : 'blue' }]}
          onPress={isRecording ? stopRecording : startRecording}
        >
          <Text style={styles.buttonText}>
            {isRecording ? 'Stop' : 'Record'}
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'black'
  },
  controls: {
    position: 'absolute',
    bottom: 50,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingHorizontal: 50
  },
  captureButton: {
    backgroundColor: 'white',
    paddingVertical: 15,
    paddingHorizontal: 25,
    borderRadius: 50,
    minWidth: 80,
    alignItems: 'center'
  },
  buttonText: {
    color: 'black',
    fontWeight: 'bold'
  }
});
```

**IMPLEMENT** real-time frame processing with Skia:

```typescript
import React, { useCallback } from 'react';
import {
  Camera,
  Frame,
  runOnJS,
  useFrameProcessor
} from 'react-native-vision-camera';
import {
  Canvas,
  Image,
  useCanvasRef,
  Skia
} from '@shopify/react-native-skia';
import { Worklets } from 'react-native-worklets-core';

interface FrameProcessorCameraProps {
  onFrameProcessed?: (processedFrame: string) => void;
}

export const FrameProcessorCamera: React.FC<FrameProcessorCameraProps> = ({
  onFrameProcessed
}) => {
  const canvasRef = useCanvasRef();

  // Worklet for frame processing
  const processFrame = Worklets.createRunOnJS((frame: Frame) => {
    'worklet';
    
    try {
      // Convert frame to Skia image
      const image = Skia.Image.MakeImageFromViewTag(frame.image);
      if (!image) return;

      // Apply custom processing
      const surface = Skia.Surface.MakeOffscreen(frame.width, frame.height);
      if (!surface) return;

      const canvas = surface.getCanvas();
      
      // Apply filters or effects
      const paint = Skia.Paint();
      paint.setColorFilter(
        Skia.ColorFilter.MakeMatrix([
          0.3, 0.6, 0.1, 0, 0, // Red channel
          0.3, 0.6, 0.1, 0, 0, // Green channel  
          0.3, 0.6, 0.1, 0, 0, // Blue channel
          0,   0,   0,   1, 0  // Alpha channel
        ])
      );

      canvas.drawImage(image, 0, 0, paint);
      surface.flush();

      const processedImage = surface.makeImageSnapshot();
      const base64 = processedImage.encodeToBase64();
      
      runOnJS(onFrameProcessed)?.(base64);
    } catch (error) {
      console.error('Frame processing error:', error);
    }
  });

  const frameProcessor = useFrameProcessor((frame) => {
    'worklet';
    processFrame(frame);
  }, []);

  return (
    <Camera
      frameProcessor={frameProcessor}
      fps={30}
      // ... other camera props
    />
  );
};
```

**ENSURE** advanced camera controls:

```typescript
import React, { useState, useCallback } from 'react';
import {
  View,
  StyleSheet,
  TouchableOpacity,
  Text,
  Slider
} from 'react-native';
import {
  Camera,
  useCameraDevice,
  CameraPosition,
  Flash,
  VideoQuality,
  PhotoQuality
} from 'react-native-vision-camera';

interface AdvancedCameraControlsProps {
  position?: CameraPosition;
  onPositionChange?: (position: CameraPosition) => void;
}

export const AdvancedCameraControls: React.FC<AdvancedCameraControlsProps> = ({
  position = 'back',
  onPositionChange
}) => {
  const [flash, setFlash] = useState<Flash>('off');
  const [zoom, setZoom] = useState(1);
  const [exposure, setExposure] = useState(0);
  const [focusPoint, setFocusPoint] = useState<{ x: number; y: number } | null>(null);

  const device = useCameraDevice(position, {
    physicalDevices: ['ultra-wide-angle-camera', 'wide-angle-camera', 'telephoto-camera']
  });

  const handleFocus = useCallback((event: any) => {
    const { locationX, locationY } = event.nativeEvent;
    setFocusPoint({ x: locationX, y: locationY });
  }, []);

  const toggleFlash = useCallback(() => {
    setFlash(current => {
      switch (current) {
        case 'off': return 'on';
        case 'on': return 'auto';
        case 'auto': return 'off';
        default: return 'off';
      }
    });
  }, []);

  const switchCamera = useCallback(() => {
    const newPosition = position === 'back' ? 'front' : 'back';
    onPositionChange?.(newPosition);
  }, [position, onPositionChange]);

  if (!device) {
    return (
      <View style={styles.container}>
        <Text>Camera not available</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Camera
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={true}
        photo={true}
        video={true}
        zoom={zoom}
        exposure={exposure}
        flash={flash}
        onTouchStart={handleFocus}
        photoQualityBalance="quality"
        videoQualityBalance="quality"
        enableHighQualityPhotos={true}
        enableDepthData={true}
        enablePortraitEffectsMatteDelivery={true}
      />

      {/* Focus indicator */}
      {focusPoint && (
        <View
          style={[
            styles.focusBox,
            {
              left: focusPoint.x - 25,
              top: focusPoint.y - 25
            }
          ]}
        />
      )}

      {/* Camera controls */}
      <View style={styles.controls}>
        {/* Flash control */}
        <TouchableOpacity style={styles.controlButton} onPress={toggleFlash}>
          <Text style={styles.buttonText}>Flash: {flash}</Text>
        </TouchableOpacity>

        {/* Camera switch */}
        <TouchableOpacity style={styles.controlButton} onPress={switchCamera}>
          <Text style={styles.buttonText}>Switch</Text>
        </TouchableOpacity>

        {/* Zoom control */}
        <View style={styles.sliderContainer}>
          <Text style={styles.sliderLabel}>Zoom: {zoom.toFixed(1)}x</Text>
          <Slider
            style={styles.slider}
            minimumValue={device.minZoom}
            maximumValue={Math.min(device.maxZoom, 10)}
            value={zoom}
            onValueChange={setZoom}
            minimumTrackTintColor="#FFFFFF"
            maximumTrackTintColor="#000000"
            thumbStyle={{ backgroundColor: '#FFFFFF' }}
          />
        </View>

        {/* Exposure control */}
        <View style={styles.sliderContainer}>
          <Text style={styles.sliderLabel}>Exposure: {exposure.toFixed(1)}</Text>
          <Slider
            style={styles.slider}
            minimumValue={device.minExposure}
            maximumValue={device.maxExposure}
            value={exposure}
            onValueChange={setExposure}
            minimumTrackTintColor="#FFFFFF"
            maximumTrackTintColor="#000000"
            thumbStyle={{ backgroundColor: '#FFFFFF' }}
          />
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'black'
  },
  focusBox: {
    position: 'absolute',
    width: 50,
    height: 50,
    borderWidth: 2,
    borderColor: 'white',
    backgroundColor: 'transparent'
  },
  controls: {
    position: 'absolute',
    top: 50,
    left: 20,
    right: 20,
    flexDirection: 'column',
    gap: 10
  },
  controlButton: {
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    paddingVertical: 10,
    paddingHorizontal: 15,
    borderRadius: 25,
    alignSelf: 'flex-start'
  },
  buttonText: {
    color: 'white',
    fontWeight: 'bold'
  },
  sliderContainer: {
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    paddingVertical: 10,
    paddingHorizontal: 15,
    borderRadius: 10
  },
  sliderLabel: {
    color: 'white',
    fontSize: 12,
    marginBottom: 5
  },
  slider: {
    width: 150,
    height: 30
  }
});
```

### Code Scanning and Detection

**IMPLEMENT** barcode and QR code scanning:

```typescript
import React, { useCallback, useState } from 'react';
import { View, Text, StyleSheet, Alert } from 'react-native';
import {
  Camera,
  useCameraDevice,
  useCodeScanner,
  Code
} from 'react-native-vision-camera';

interface CodeScannerProps {
  onCodeScanned?: (codes: Code[]) => void;
  codeTypes?: string[];
}

export const CodeScanner: React.FC<CodeScannerProps> = ({
  onCodeScanned,
  codeTypes = ['qr', 'ean-13', 'ean-8', 'code-128', 'code-39']
}) => {
  const [scannedData, setScannedData] = useState<string | null>(null);
  const [isScanning, setIsScanning] = useState(true);

  const device = useCameraDevice('back');

  const codeScanner = useCodeScanner({
    codeTypes: codeTypes,
    onCodeScanned: (codes) => {
      if (!isScanning) return;

      const code = codes[0];
      if (code) {
        setIsScanning(false);
        setScannedData(code.value);
        onCodeScanned?.(codes);

        Alert.alert(
          'Code Scanned',
          `Type: ${code.type}\nValue: ${code.value}`,
          [
            { text: 'Scan Again', onPress: () => setIsScanning(true) },
            { text: 'OK' }
          ]
        );
      }
    }
  });

  if (!device) {
    return (
      <View style={styles.container}>
        <Text style={styles.errorText}>Camera not available</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Camera
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={isScanning}
        codeScanner={codeScanner}
      />

      {/* Scanning overlay */}
      <View style={styles.overlay}>
        <View style={styles.scanArea}>
          <View style={styles.scanCorner} />
          <View style={[styles.scanCorner, styles.topRight]} />
          <View style={[styles.scanCorner, styles.bottomLeft]} />
          <View style={[styles.scanCorner, styles.bottomRight]} />
        </View>
        
        <Text style={styles.instructionText}>
          Position the code within the frame to scan
        </Text>
        
        {scannedData && (
          <View style={styles.resultContainer}>
            <Text style={styles.resultText}>Last scanned: {scannedData}</Text>
          </View>
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'black'
  },
  errorText: {
    color: 'white',
    textAlign: 'center',
    marginTop: 100
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    justifyContent: 'center'
  },
  scanArea: {
    width: 250,
    height: 250,
    position: 'relative'
  },
  scanCorner: {
    position: 'absolute',
    width: 30,
    height: 30,
    borderColor: 'white',
    borderWidth: 3,
    top: 0,
    left: 0,
    borderRightWidth: 0,
    borderBottomWidth: 0
  },
  topRight: {
    top: 0,
    right: 0,
    left: 'auto',
    borderLeftWidth: 0,
    borderBottomWidth: 0,
    borderRightWidth: 3
  },
  bottomLeft: {
    bottom: 0,
    left: 0,
    top: 'auto',
    borderRightWidth: 0,
    borderTopWidth: 0,
    borderBottomWidth: 3
  },
  bottomRight: {
    bottom: 0,
    right: 0,
    left: 'auto',
    top: 'auto',
    borderLeftWidth: 0,
    borderTopWidth: 0,
    borderRightWidth: 3,
    borderBottomWidth: 3
  },
  instructionText: {
    color: 'white',
    textAlign: 'center',
    marginTop: 30,
    fontSize: 16
  },
  resultContainer: {
    position: 'absolute',
    bottom: 100,
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 10
  },
  resultText: {
    color: 'white',
    textAlign: 'center'
  }
});
```

## Anti-Patterns

### **DON'T** implement these camera anti-patterns

**NEVER** access camera without proper permissions:

```typescript
// ❌ Bad: No permission checking
const BadCamera = () => {
  return (
    <Camera
      // Accessing camera without checking permissions
      device={useCameraDevice('back')}
      isActive={true}
    />
  );
};

// ✅ Good: Proper permission management
const GoodCamera = () => {
  const { hasPermission, requestPermission } = useCameraPermission();

  useEffect(() => {
    if (!hasPermission) {
      requestPermission();
    }
  }, [hasPermission]);

  if (!hasPermission) {
    return <PermissionScreen />;
  }

  return <Camera device={useCameraDevice('back')} isActive={true} />;
};
```

**AVOID** blocking the UI thread with heavy processing:

```typescript
// ❌ Bad: Heavy processing on main thread
const BadFrameProcessor = () => {
  const frameProcessor = useFrameProcessor((frame) => {
    'worklet';
    
    // Heavy computation on UI thread
    for (let i = 0; i < 1000000; i++) {
      // CPU intensive work
    }
  }, []);

  return <Camera frameProcessor={frameProcessor} />;
};

// ✅ Good: Efficient frame processing
const GoodFrameProcessor = () => {
  const frameProcessor = useFrameProcessor((frame) => {
    'worklet';
    
    // Lightweight processing only
    const brightness = frame.pixelFormat === 'yuv' ? 
      calculateBrightness(frame) : 0;
    
    runOnJS(updateBrightness)(brightness);
  }, []);

  return <Camera frameProcessor={frameProcessor} />;
};
```

## Code Examples

### Photo Gallery Integration

```typescript
import React, { useState } from 'react';
import {
  View,
  FlatList,
  Image,
  TouchableOpacity,
  StyleSheet,
  Dimensions
} from 'react-native';
import { PhotoFile } from 'react-native-vision-camera';
import { CameraRoll } from '@react-native-camera-roll/camera-roll';

interface PhotoGalleryProps {
  photos: PhotoFile[];
  onPhotoSelect?: (photo: PhotoFile) => void;
}

export const PhotoGallery: React.FC<PhotoGalleryProps> = ({
  photos,
  onPhotoSelect
}) => {
  const [selectedPhoto, setSelectedPhoto] = useState<PhotoFile | null>(null);
  const screenWidth = Dimensions.get('window').width;
  const itemSize = (screenWidth - 30) / 3;

  const saveToGallery = async (photo: PhotoFile) => {
    try {
      await CameraRoll.save(photo.path, { type: 'photo' });
      console.log('Photo saved to gallery');
    } catch (error) {
      console.error('Failed to save photo:', error);
    }
  };

  const renderPhoto = ({ item }: { item: PhotoFile }) => (
    <TouchableOpacity
      style={[styles.photoItem, { width: itemSize, height: itemSize }]}
      onPress={() => {
        setSelectedPhoto(item);
        onPhotoSelect?.(item);
      }}
      onLongPress={() => saveToGallery(item)}
    >
      <Image
        source={{ uri: `file://${item.path}` }}
        style={styles.photoImage}
        resizeMode="cover"
      />
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <FlatList
        data={photos}
        renderItem={renderPhoto}
        keyExtractor={(item, index) => `${item.path}-${index}`}
        numColumns={3}
        contentContainerStyle={styles.gallery}
        showsVerticalScrollIndicator={false}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'black'
  },
  gallery: {
    padding: 5
  },
  photoItem: {
    margin: 5,
    borderRadius: 8,
    overflow: 'hidden'
  },
  photoImage: {
    width: '100%',
    height: '100%'
  }
});
```

## Validation Checklist

### **MUST** verify

- [ ] Camera permissions are properly requested and handled
- [ ] Camera session is properly managed with lifecycle events
- [ ] Photo and video capture work on both iOS and Android
- [ ] Frame processing maintains optimal performance
- [ ] Error handling is implemented for all camera operations
- [ ] Memory management prevents leaks with camera frames
- [ ] Camera controls are accessible and responsive
- [ ] Real device testing is performed for camera functionality

### **SHOULD** check

- [ ] Advanced camera features like HDR and stabilization work
- [ ] Code scanning detects all required barcode/QR types
- [ ] Skia integration for frame processing is optimized
- [ ] Camera preview adapts to different screen orientations
- [ ] Image compression and quality settings are optimized
- [ ] Face detection and object tracking work accurately
- [ ] Custom camera effects perform smoothly
- [ ] Integration with photo gallery is seamless

## References

- [React Native Vision Camera](https://react-native-vision-camera.com/)
- [React Native Skia](https://shopify.github.io/react-native-skia/)
- [React Native Worklets](https://github.com/margelo/react-native-worklets-core)
- [Camera2 API (Android)](https://developer.android.com/reference/android/hardware/camera2/package-summary)
- [AVFoundation (iOS)](https://developer.apple.com/av-foundation/)
- [Image Processing Best Practices](https://developer.android.com/topic/performance/graphics)
