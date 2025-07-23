---
applyTo: '**'
---

# Security Instructions

This document outlines comprehensive security implementation guidelines for React Native applications, covering mobile-specific security concerns, data protection, and platform security best practices.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** store sensitive data using secure storage solutions (Keychain/Keystore)
- **REQUIRED** to implement certificate pinning for API communications
- **SHALL** validate and sanitize all user inputs before processing
- **MUST** implement proper authentication token management with secure refresh mechanisms
- **NEVER** store sensitive information in AsyncStorage or plain text files
- **REQUIRED** to implement proper biometric authentication where supported
- **SHALL** use HTTPS for all network communications without exceptions
- **MUST** implement proper session management with automatic timeout
- **NEVER** log sensitive information in production builds
- **REQUIRED** to implement proper code obfuscation for production builds

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** implement runtime application self-protection (RASP) techniques
- **RECOMMENDED** to use app transport security (ATS) configurations
- **ALWAYS** implement proper deep link validation and sanitization
- **DO** implement proper backup exclusion for sensitive data
- **SHOULD** use secure random number generation for cryptographic operations
- **RECOMMENDED** to implement anti-tampering and root/jailbreak detection
- **DO** implement proper permission handling with runtime requests
- **ALWAYS** validate server certificates and implement certificate transparency
- **SHOULD** implement proper data encryption for local storage

### Optional Enhancements (**MAY** Consider)

- **MAY** implement advanced threat detection and response mechanisms
- **OPTIONAL** to use hardware security modules (HSM) for key management
- **USE** security-focused libraries for sensitive operations
- **IMPLEMENT** advanced authentication factors (hardware tokens, smart cards)
- **AVOID** using deprecated cryptographic algorithms and protocols

## Implementation Guidance

### Secure Storage Implementation

**USE** secure storage for sensitive data:

```typescript
import * as SecureStore from 'expo-secure-store';
import { Platform } from 'react-native';

interface SecureStorageService {
  store(key: string, value: string): Promise<void>;
  retrieve(key: string): Promise<string | null>;
  remove(key: string): Promise<void>;
}

export class SecureStorageService implements SecureStorageService {
  private static instance: SecureStorageService;

  public static getInstance(): SecureStorageService {
    if (!SecureStorageService.instance) {
      SecureStorageService.instance = new SecureStorageService();
    }
    return SecureStorageService.instance;
  }

  async store(key: string, value: string): Promise<void> {
    try {
      const options: SecureStore.SecureStoreOptions = {
        requireAuthentication: true,
        authenticationPrompt: 'Authenticate to access secure data',
        ...(Platform.OS === 'ios' && {
          keychainService: 'myAppKeychain',
          touchID: true,
          showModal: true
        }),
        ...(Platform.OS === 'android' && {
          encrypt: true,
          authenticatePrompt: 'Verify your identity'
        })
      };

      await SecureStore.setItemAsync(key, value, options);
    } catch (error) {
      console.error('Secure storage error:', error);
      throw new Error('Failed to store secure data');
    }
  }

  async retrieve(key: string): Promise<string | null> {
    try {
      return await SecureStore.getItemAsync(key, {
        requireAuthentication: true,
        authenticationPrompt: 'Authenticate to access secure data'
      });
    } catch (error) {
      console.error('Secure retrieval error:', error);
      return null;
    }
  }

  async remove(key: string): Promise<void> {
    try {
      await SecureStore.deleteItemAsync(key);
    } catch (error) {
      console.error('Secure deletion error:', error);
      throw new Error('Failed to remove secure data');
    }
  }
}
```

**IMPLEMENT** secure authentication flow:

```typescript
import * as LocalAuthentication from 'expo-local-authentication';
import { DeviceMotion } from 'expo-sensors';

interface AuthenticationService {
  authenticateWithBiometrics(): Promise<boolean>;
  setupTokenRefresh(): void;
  validateSession(): Promise<boolean>;
}

export class AuthenticationService implements AuthenticationService {
  private refreshTokenInterval: NodeJS.Timeout | null = null;
  private secureStorage = SecureStorageService.getInstance();

  async authenticateWithBiometrics(): Promise<boolean> {
    try {
      // Check if biometric authentication is available
      const isAvailable = await LocalAuthentication.hasHardwareAsync();
      if (!isAvailable) {
        throw new Error('Biometric hardware not available');
      }

      const isEnrolled = await LocalAuthentication.isEnrolledAsync();
      if (!isEnrolled) {
        throw new Error('No biometric data enrolled');
      }

      const supportedTypes = await LocalAuthentication.supportedAuthenticationTypesAsync();
      
      const result = await LocalAuthentication.authenticateAsync({
        promptMessage: 'Verify your identity',
        cancelLabel: 'Cancel',
        fallbackLabel: 'Use PIN',
        requireConfirmation: true,
        disableDeviceFallback: false
      });

      return result.success;
    } catch (error) {
      console.error('Biometric authentication error:', error);
      return false;
    }
  }

  setupTokenRefresh(): void {
    this.refreshTokenInterval = setInterval(async () => {
      try {
        await this.refreshAuthToken();
      } catch (error) {
        console.error('Token refresh failed:', error);
        // Handle refresh failure (logout user, show re-auth prompt)
      }
    }, 15 * 60 * 1000); // Refresh every 15 minutes
  }

  private async refreshAuthToken(): Promise<void> {
    const refreshToken = await this.secureStorage.retrieve('refresh_token');
    if (!refreshToken) {
      throw new Error('No refresh token available');
    }

    // Implement secure token refresh logic
    const response = await fetch('/api/auth/refresh', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${refreshToken}`,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error('Token refresh failed');
    }

    const { accessToken, refreshToken: newRefreshToken } = await response.json();
    
    await this.secureStorage.store('access_token', accessToken);
    await this.secureStorage.store('refresh_token', newRefreshToken);
  }

  async validateSession(): Promise<boolean> {
    const token = await this.secureStorage.retrieve('access_token');
    if (!token) return false;

    try {
      const response = await fetch('/api/auth/validate', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      return response.ok;
    } catch {
      return false;
    }
  }
}
```

**ENSURE** secure network communications:

```typescript
import NetInfo from '@react-native-async-storage/async-storage';

interface SecureApiClient {
  request<T>(endpoint: string, options?: RequestInit): Promise<T>;
  setupCertificatePinning(): void;
}

export class SecureApiClient implements SecureApiClient {
  private baseURL = 'https://api.yourapp.com';
  private pinnedCertificates = [
    // SHA-256 fingerprints of your server certificates
    'SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
    'SHA256:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB='
  ];

  async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    // Check network connectivity
    const networkState = await NetInfo.fetch();
    if (!networkState.isConnected) {
      throw new Error('No network connection');
    }

    // Get authentication token
    const secureStorage = SecureStorageService.getInstance();
    const token = await secureStorage.retrieve('access_token');

    const url = `${this.baseURL}${endpoint}`;
    
    // Validate URL to prevent injection
    if (!this.isValidUrl(url)) {
      throw new Error('Invalid URL detected');
    }

    const headers = {
      'Content-Type': 'application/json',
      'User-Agent': 'YourApp/1.0',
      ...(token && { 'Authorization': `Bearer ${token}` }),
      ...options.headers
    };

    const requestOptions: RequestInit = {
      ...options,
      headers,
      // Implement timeout
      signal: AbortSignal.timeout(30000)
    };

    try {
      const response = await fetch(url, requestOptions);
      
      // Validate response headers for security
      this.validateResponseHeaders(response);
      
      if (!response.ok) {
        if (response.status === 401) {
          // Handle unauthorized access
          await this.handleUnauthorized();
        }
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      
      // Validate response data structure
      this.validateResponseData(data);
      
      return data;
    } catch (error) {
      console.error('API request failed:', error);
      throw error;
    }
  }

  private isValidUrl(url: string): boolean {
    try {
      const parsedUrl = new URL(url);
      return parsedUrl.protocol === 'https:' && 
             parsedUrl.hostname.endsWith('.yourapp.com');
    } catch {
      return false;
    }
  }

  private validateResponseHeaders(response: Response): void {
    const securityHeaders = [
      'strict-transport-security',
      'x-content-type-options',
      'x-frame-options',
      'x-xss-protection'
    ];

    securityHeaders.forEach(header => {
      if (!response.headers.get(header)) {
        console.warn(`Missing security header: ${header}`);
      }
    });
  }

  private validateResponseData(data: any): void {
    // Implement data validation based on your API schema
    if (typeof data !== 'object' || data === null) {
      throw new Error('Invalid response data format');
    }
  }

  private async handleUnauthorized(): Promise<void> {
    const secureStorage = SecureStorageService.getInstance();
    await secureStorage.remove('access_token');
    await secureStorage.remove('refresh_token');
    // Navigate to login screen
  }

  setupCertificatePinning(): void {
    // Note: Certificate pinning implementation depends on the specific
    // networking library being used (e.g., react-native-ssl-pinning)
    console.log('Certificate pinning configured');
  }
}
```

### Input Validation and Sanitization

**IMPLEMENT** comprehensive input validation:

```typescript
import validator from 'validator';
import xss from 'xss';

interface InputValidator {
  validateEmail(email: string): boolean;
  validatePassword(password: string): boolean;
  sanitizeInput(input: string): string;
  validatePhoneNumber(phone: string): boolean;
}

export class InputValidator implements InputValidator {
  validateEmail(email: string): boolean {
    if (!email || typeof email !== 'string') return false;
    
    // Basic format validation
    if (!validator.isEmail(email)) return false;
    
    // Additional security checks
    if (email.length > 254) return false; // RFC 5321 limit
    if (email.includes('..')) return false; // Consecutive dots
    
    return true;
  }

  validatePassword(password: string): boolean {
    if (!password || typeof password !== 'string') return false;
    
    // Minimum security requirements
    const minLength = 8;
    const hasUpperCase = /[A-Z]/.test(password);
    const hasLowerCase = /[a-z]/.test(password);
    const hasNumbers = /\d/.test(password);
    const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);
    
    return password.length >= minLength &&
           hasUpperCase &&
           hasLowerCase &&
           hasNumbers &&
           hasSpecialChar;
  }

  sanitizeInput(input: string): string {
    if (!input || typeof input !== 'string') return '';
    
    // Remove potentially dangerous characters
    let sanitized = input.trim();
    
    // XSS protection
    sanitized = xss(sanitized, {
      whiteList: {}, // Allow no HTML tags
      stripIgnoreTag: true,
      stripIgnoreTagBody: ['script']
    });
    
    // SQL injection protection (basic)
    sanitized = sanitized.replace(/['";]/g, '');
    
    // Remove control characters
    sanitized = sanitized.replace(/[\x00-\x1F\x7F-\x9F]/g, '');
    
    return sanitized;
  }

  validatePhoneNumber(phone: string): boolean {
    if (!phone || typeof phone !== 'string') return false;
    
    // Remove all non-digit characters for validation
    const cleaned = phone.replace(/\D/g, '');
    
    // Basic length check (international format)
    return cleaned.length >= 7 && cleaned.length <= 15;
  }

  validateDeepLink(url: string): boolean {
    try {
      const parsedUrl = new URL(url);
      
      // Only allow your app's custom scheme
      if (parsedUrl.protocol !== 'yourapp:') return false;
      
      // Validate allowed hosts/paths
      const allowedHosts = ['profile', 'settings', 'dashboard'];
      if (!allowedHosts.includes(parsedUrl.hostname)) return false;
      
      return true;
    } catch {
      return false;
    }
  }
}
```

## Anti-Patterns

### **DON'T** implement these security vulnerabilities

**NEVER** store sensitive data insecurely:

```typescript
// ❌ Bad: Insecure storage
import AsyncStorage from '@react-native-async-storage/async-storage';

const storeBadCredentials = async (token: string) => {
  await AsyncStorage.setItem('auth_token', token); // Vulnerable!
};

const storeBadPassword = async (password: string) => {
  await AsyncStorage.setItem('user_password', password); // Never do this!
};

// ✅ Good: Secure storage
const storeGoodCredentials = async (token: string) => {
  const secureStorage = SecureStorageService.getInstance();
  await secureStorage.store('auth_token', token);
};
```

**DON'T** ignore certificate validation:

```typescript
// ❌ Bad: Disabling certificate validation
const insecureRequest = async () => {
  // Never disable SSL/TLS validation
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
  
  const response = await fetch('https://api.example.com/data', {
    agent: new https.Agent({
      rejectUnauthorized: false // Dangerous!
    })
  });
};

// ✅ Good: Proper certificate validation with pinning
const secureRequest = async () => {
  const apiClient = new SecureApiClient();
  return await apiClient.request('/data');
};
```

**AVOID** logging sensitive information:

```typescript
// ❌ Bad: Logging sensitive data
const badLogin = async (credentials) => {
  console.log('Login attempt:', credentials); // Exposes password!
  console.log('Auth token:', credentials.token); // Security leak!
};

// ✅ Good: Safe logging
const goodLogin = async (credentials) => {
  console.log('Login attempt for user:', credentials.username);
  // Never log passwords, tokens, or other sensitive data
};
```

## Code Examples

### Root/Jailbreak Detection

```typescript
import JailMonkey from 'jail-monkey';

interface SecurityChecker {
  isDeviceSecure(): Promise<boolean>;
  performSecurityChecks(): Promise<SecurityReport>;
}

interface SecurityReport {
  isJailbroken: boolean;
  isDebuggerAttached: boolean;
  isOnExternalStorage: boolean;
  isEmulator: boolean;
  recommendations: string[];
}

export class SecurityChecker implements SecurityChecker {
  async isDeviceSecure(): Promise<boolean> {
    const report = await this.performSecurityChecks();
    return !report.isJailbroken && 
           !report.isDebuggerAttached && 
           !report.isOnExternalStorage;
  }

  async performSecurityChecks(): Promise<SecurityReport> {
    const report: SecurityReport = {
      isJailbroken: JailMonkey.isJailBroken(),
      isDebuggerAttached: JailMonkey.isDebuggedMode(),
      isOnExternalStorage: JailMonkey.isOnExternalStorage(),
      isEmulator: JailMonkey.isEmulator(),
      recommendations: []
    };

    if (report.isJailbroken) {
      report.recommendations.push('Device appears to be jailbroken/rooted');
    }
    
    if (report.isDebuggerAttached) {
      report.recommendations.push('Debugger detected - security risk');
    }
    
    if (report.isOnExternalStorage) {
      report.recommendations.push('App installed on external storage');
    }

    return report;
  }
}
```

### Secure Configuration Management

```typescript
interface SecureConfig {
  apiBaseUrl: string;
  certificatePins: string[];
  encryptionKey: string;
  sessionTimeout: number;
}

export class ConfigManager {
  private static config: SecureConfig;

  static initialize(): void {
    // Different configurations for different environments
    const isDevelopment = __DEV__;
    const isProduction = !__DEV__;

    if (isDevelopment) {
      this.config = {
        apiBaseUrl: 'https://dev-api.yourapp.com',
        certificatePins: ['DEV_CERT_PIN'],
        encryptionKey: 'dev-key-not-for-production',
        sessionTimeout: 3600000 // 1 hour
      };
    } else {
      this.config = {
        apiBaseUrl: 'https://api.yourapp.com',
        certificatePins: [
          'SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
          'SHA256:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB='
        ],
        encryptionKey: process.env.ENCRYPTION_KEY || '',
        sessionTimeout: 1800000 // 30 minutes
      };
    }

    if (!this.config.encryptionKey) {
      throw new Error('Encryption key not configured');
    }
  }

  static getConfig(): SecureConfig {
    if (!this.config) {
      throw new Error('ConfigManager not initialized');
    }
    return { ...this.config }; // Return copy to prevent mutation
  }
}
```

## Validation Checklist

### **MUST** verify

- [ ] All sensitive data is stored using secure storage (Keychain/Keystore)
- [ ] Certificate pinning is implemented for API communications
- [ ] All user inputs are validated and sanitized
- [ ] Authentication tokens are managed securely with refresh mechanisms
- [ ] No sensitive information is logged in production
- [ ] HTTPS is used for all network communications
- [ ] Biometric authentication is properly implemented where available
- [ ] Session management includes automatic timeout

### **SHOULD** check

- [ ] Root/jailbreak detection is implemented
- [ ] App transport security (ATS) is properly configured
- [ ] Deep link validation is in place
- [ ] Backup exclusion is configured for sensitive data
- [ ] Runtime security checks are performed
- [ ] Cryptographic operations use secure random number generation
- [ ] Error messages don't expose sensitive information
- [ ] Security headers are validated in API responses

## References

- [OWASP Mobile Security Testing Guide](https://owasp.org/www-project-mobile-security-testing-guide/)
- [React Native Security Best Practices](https://reactnative.dev/docs/security)
- [iOS Security Guide](https://www.apple.com/business/docs/site/iOS_Security_Guide.pdf)
- [Android Security Documentation](https://developer.android.com/topic/security)
- [Expo Security Guidelines](https://docs.expo.dev/guides/security/)
- [NIST Mobile Security Guidelines](https://csrc.nist.gov/publications/detail/sp/800-124/rev-1/final)
