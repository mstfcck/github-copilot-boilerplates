# React Native Boilerplate - AI Development Assistant

A comprehensive React Native boilerplate designed to accelerate cross-platform mobile application development with AI-guided best practices, modern architecture patterns, and production-ready configurations.

This boilerplate provides a solid foundation for building scalable, maintainable, and high-performance React Native applications using TypeScript, Expo, and industry-standard development practices.

## Core Principles and Guidelines

**MUST** follow these fundamental principles:
- **New Architecture First**: Leverage React Native's New Architecture (Fabric + TurboModules + JSI) for optimal performance
- **Cross-Platform Consistency**: Ensure consistent behavior across iOS and Android platforms
- **Type Safety**: Use TypeScript for all application code to prevent runtime errors
- **Component Composition**: Favor composition over inheritance for reusable UI components
- **State Management**: Implement predictable state management with proper data flow
- **Performance First**: Optimize for performance from the beginning, not as an afterthought
- **Security by Design**: Implement security best practices at every application layer
- **Accessibility**: Ensure applications are accessible to users with disabilities
- **Testability**: Write testable code with comprehensive test coverage
- **Modularity**: Organize code into focused, loosely coupled modules
- **Clean Architecture**: Separate business logic from UI components and external dependencies

## Technology Stack Specifications

**MUST** use these technologies:
- **React Native 0.76+** with New Architecture (Fabric, TurboModules, JSI) enabled by default
- **Node.js 18.18+** (minimum required version for React Native development)
- **Expo SDK 52+** using `npx create-expo-app@latest` for project initialization
- **React 18+** with hooks and functional components as the primary programming model
- **TypeScript 5.0+** for static type checking and enhanced developer experience
- **React Navigation 6+** for navigation and routing with type-safe navigation patterns
- **React Hook Form 7+** for performant form handling with validation
- **React Query 5+** for server state management and data fetching
- **Zustand 4+** for client-side state management with TypeScript support
- **React Native Reanimated 3+** for smooth, native animations
- **React Native Gesture Handler 2+** for advanced gesture handling
- **Expo Router** for file-based routing with deep linking support
- **NativeWind** for Tailwind CSS styling in React Native
- **React Native Testing Library** for component testing
- **Jest** for unit and integration testing
- **Detox** for end-to-end testing on real devices and simulators

## Architecture Decision Framework

**ALWAYS** consider these architectural questions:
1. **Component Architecture**: How should components be structured to maximize reusability and maintainability?
2. **State Management Strategy**: What state belongs in local component state vs global state management?
3. **Navigation Patterns**: How should navigation be structured to support deep linking and state persistence?
4. **Data Flow Architecture**: How should data flow between components, services, and external APIs?
5. **Platform-Specific Implementation**: When should platform-specific code be used vs cross-platform solutions?
6. **Performance Optimization**: How can bundle size, memory usage, and rendering performance be optimized?
7. **Offline Capability**: How should the app handle offline scenarios and data synchronization?
8. **Security Architecture**: How should sensitive data be handled and protected across platforms?
9. **Internationalization Strategy**: How should the app support multiple languages and locales?
10. **Error Handling Patterns**: How should errors be caught, logged, and presented to users?
11. **Testing Strategy**: How should unit, integration, and end-to-end tests be structured?
12. **Code Organization**: How should files and folders be organized for scalability and maintainability?

## Development Standards

**ENSURE** all code follows these standards:
- Use functional components with hooks instead of class components
- Implement proper TypeScript types and interfaces for all props and state
- Follow React Native performance best practices for list rendering and animations
- Use proper error boundaries to prevent app crashes
- Implement proper loading and error states for all asynchronous operations
- Follow consistent code formatting with ESLint and Prettier
- Use semantic versioning and conventional commit messages
- Implement proper keyboard handling and form validation
- Use proper accessibility labels and roles for screen readers
- Follow platform design guidelines (Material Design for Android, Human Interface Guidelines for iOS)

**DO** implement these patterns:
- **Container/Presenter Pattern**: Separate business logic from presentation logic
- **Custom Hooks Pattern**: Extract and reuse stateful logic across components
- **Compound Component Pattern**: Create flexible and reusable component APIs
- **Error Boundary Pattern**: Implement error boundaries to catch and handle errors gracefully
- **Lazy Loading Pattern**: Implement code splitting and lazy loading for performance optimization
- **Repository Pattern**: Abstract data access logic behind clean interfaces
- **Observer Pattern**: Use state management solutions that support reactive updates
- **Factory Pattern**: Create configurable component factories for consistent UI
- **Strategy Pattern**: Implement platform-specific behaviors with a common interface
- **Decorator Pattern**: Use Higher-Order Components for cross-cutting concerns

**DON'T** implement these anti-patterns:
- **God Components**: Avoid components with too many responsibilities
- **Prop Drilling**: Don't pass props through multiple component layers unnecessarily
- **Inline Styles**: Avoid inline styles that can't be optimized or reused
- **Direct Manipulation**: Don't directly manipulate DOM elements or native views
- **Synchronous Storage**: Avoid synchronous storage operations that block the main thread
- **Memory Leaks**: Don't create subscriptions or timers without proper cleanup
- **Platform Assumptions**: Don't assume platform-specific behaviors without proper checks
- **Hardcoded Strings**: Avoid hardcoded text that can't be internationalized
- **Unhandled Promises**: Don't leave async operations without proper error handling
- **Tight Coupling**: Avoid dependencies that make components hard to test or reuse

## Quality Requirements

**MUST** include for every feature:
- **Comprehensive TypeScript Types**: All props, state, and API responses must have proper types
- **Unit Tests**: Every component and utility function must have corresponding unit tests
- **Integration Tests**: Critical user flows must have integration tests
- **Accessibility Testing**: All interactive elements must be accessible and testable
- **Performance Testing**: Components must meet performance benchmarks for rendering
- **Cross-Platform Testing**: Features must work consistently on both iOS and Android
- **Error Handling**: All async operations must have proper error handling and user feedback
- **Loading States**: All data fetching operations must show appropriate loading states
- **Security Validation**: All user inputs must be validated and sanitized
- **Responsive Design**: UI must adapt to different screen sizes and orientations

**SHOULD** consider:
- **End-to-End Tests**: Critical user journeys should have E2E test coverage
- **Visual Regression Tests**: UI components should have visual testing for consistency
- **Performance Monitoring**: Implement performance monitoring in production
- **Crash Reporting**: Use crash reporting tools to monitor application stability
- **Analytics Integration**: Track user behavior and application performance metrics
- **Internationalization**: Support multiple languages and locale-specific formatting
- **Dark Mode Support**: Implement consistent dark mode theming across the application
- **Offline Support**: Cache critical data for offline usage scenarios
- **Push Notifications**: Implement push notification handling for user engagement
- **Deep Linking**: Support deep linking for improved user experience

**NICE TO HAVE**:
- **Storybook Integration**: Document components with interactive examples
- **Performance Profiling**: Regular performance audits and optimization
- **Advanced Animation**: Smooth transitions and micro-interactions for enhanced UX
- **Biometric Authentication**: Support fingerprint and face recognition where appropriate
- **Advanced Caching**: Implement sophisticated caching strategies for optimal performance
- **Custom Native Modules**: Platform-specific functionality through native module integration
- **Code Generation**: Automated code generation for repetitive patterns
- **Advanced Testing**: Property-based testing and mutation testing for critical logic
- **Progressive Enhancement**: Graceful degradation for older devices and OS versions
- **Machine Learning Integration**: On-device ML capabilities for enhanced features

## Sub-Instructions

Reference to modular instruction files:
- **[Architecture Guide](./instructions/architecture.instructions.md)**: Component architecture and design patterns
- **[Security Guide](./instructions/security.instructions.md)**: Mobile security best practices and implementation
- **[Testing Guide](./instructions/testing.instructions.md)**: Comprehensive testing strategies for React Native
- **[Performance Guide](./instructions/performance.instructions.md)**: Optimization techniques and monitoring
- **[UI/UX Guide](./instructions/ui-ux.instructions.md)**: Design system implementation and accessibility
- **[Navigation Guide](./instructions/navigation.instructions.md)**: Navigation patterns and deep linking
- **[State Management Guide](./instructions/state-management.instructions.md)**: State management patterns and best practices
- **[Platform-Specific Guide](./instructions/platform-specific.instructions.md)**: iOS and Android specific implementations
- **[Configuration Guide](./instructions/configuration.instructions.md)**: Environment and build configuration
- **[Deployment Guide](./instructions/deployment.instructions.md)**: Build and deployment strategies
- **[Coding Standards](./instructions/coding-standards.instructions.md)**: Code quality and formatting standards
- **[Git Ignore Guide](./instructions/gitignore.instructions.md)**: Version control best practices
