---
applyTo: '**'
---

# Deployment Instructions

This document outlines deployment strategies, build processes, and CI/CD pipeline configuration for React Native applications across different platforms and environments.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** implement automated build and deployment pipelines
- **REQUIRED** to separate deployment configurations for development, staging, and production
- **SHALL** implement proper code signing and certificate management
- **MUST** implement automated testing before deployment
- **NEVER** deploy without proper testing and quality gates
- **REQUIRED** to implement proper environment variable management in CI/CD
- **SHALL** implement proper rollback mechanisms for failed deployments
- **MUST** implement proper monitoring and alerting for deployments
- **REQUIRED** to implement proper artifact management and versioning
- **SHALL** implement proper security scanning in deployment pipeline

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** use containerization for consistent deployment environments
- **RECOMMENDED** to implement blue-green or canary deployment strategies
- **ALWAYS** implement proper deployment notifications and reporting
- **DO** implement automated performance testing in deployment pipeline
- **SHOULD** implement proper dependency vulnerability scanning
- **RECOMMENDED** to implement infrastructure as code for deployment environments
- **DO** implement proper backup and disaster recovery procedures
- **ALWAYS** implement deployment approval workflows for production
- **SHOULD** implement automated documentation generation during deployment

### Optional Enhancements (**MAY** Consider)

- **MAY** implement advanced deployment strategies like feature flags
- **OPTIONAL** to use advanced monitoring and observability tools
- **USE** deployment automation tools for complex infrastructure
- **IMPLEMENT** advanced security scanning and compliance checks
- **AVOID** over-engineering deployment for simple applications

## Implementation Guidance

### CI/CD Pipeline Configuration

**IMPLEMENT** comprehensive CI/CD pipeline using GitHub Actions:

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  release:
    types: [published]

env:
  NODE_VERSION: '18'
  JAVA_VERSION: '11'
  XCODE_VERSION: '14.2'

jobs:
  # Code Quality and Testing
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linting
        run: npm run lint

      - name: Run type checking
        run: npm run type-check

      - name: Run unit tests
        run: npm run test:unit -- --coverage

      - name: Run integration tests
        run: npm run test:integration

      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}

      - name: Security audit
        run: npm audit --audit-level moderate

  # iOS Build and Deploy
  ios-build:
    runs-on: macos-latest
    needs: test
    if: github.event_name == 'push' || github.event_name == 'release'
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: ${{ env.XCODE_VERSION }}

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
          bundler-cache: true

      - name: Install dependencies
        run: npm ci

      - name: Install CocoaPods
        run: |
          cd ios
          pod install --deployment

      - name: Configure environment
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            cp .env.production .env
          elif [[ "${{ github.ref }}" == "refs/heads/develop" ]]; then
            cp .env.staging .env
          else
            cp .env.development .env
          fi

      - name: Setup iOS certificates and provisioning profiles
        env:
          IOS_CERTIFICATE_BASE64: ${{ secrets.IOS_CERTIFICATE_BASE64 }}
          IOS_CERTIFICATE_PASSWORD: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
          IOS_PROVISIONING_PROFILE_BASE64: ${{ secrets.IOS_PROVISIONING_PROFILE_BASE64 }}
        run: |
          # Create certificates directory
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          
          # Install certificate
          echo $IOS_CERTIFICATE_BASE64 | base64 --decode > certificate.p12
          security create-keychain -p "" build.keychain
          security import certificate.p12 -k build.keychain -P $IOS_CERTIFICATE_PASSWORD -T /usr/bin/codesign
          security list-keychains -s build.keychain
          security default-keychain -s build.keychain
          security unlock-keychain -p "" build.keychain
          security set-key-partition-list -S apple-tool:,apple: -s -k "" build.keychain
          
          # Install provisioning profile
          echo $IOS_PROVISIONING_PROFILE_BASE64 | base64 --decode > profile.mobileprovision
          cp profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/

      - name: Build iOS app
        run: |
          cd ios
          if [[ "${{ github.event_name }}" == "release" ]]; then
            xcodebuild -workspace YourApp.xcworkspace -scheme YourApp -configuration Release -archivePath YourApp.xcarchive archive
            xcodebuild -exportArchive -archivePath YourApp.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath ./build
          else
            xcodebuild -workspace YourApp.xcworkspace -scheme YourApp -configuration Debug -destination 'generic/platform=iOS Simulator' build
          fi

      - name: Upload to TestFlight (Release only)
        if: github.event_name == 'release'
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
        run: |
          cd ios/build
          xcrun altool --upload-app --type ios --file YourApp.ipa --apiKey $APP_STORE_CONNECT_API_KEY

  # Android Build and Deploy
  android-build:
    runs-on: ubuntu-latest
    needs: test
    if: github.event_name == 'push' || github.event_name == 'release'
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: ${{ env.JAVA_VERSION }}

      - name: Setup Android SDK
        uses: android-actions/setup-android@v3

      - name: Install dependencies
        run: npm ci

      - name: Configure environment
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            cp .env.production .env
          elif [[ "${{ github.ref }}" == "refs/heads/develop" ]]; then
            cp .env.staging .env
          else
            cp .env.development .env
          fi

      - name: Setup Android keystore
        env:
          ANDROID_KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
          ANDROID_KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          ANDROID_KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
          ANDROID_KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
        run: |
          echo $ANDROID_KEYSTORE_BASE64 | base64 --decode > android/app/release.keystore
          echo "MYAPP_UPLOAD_STORE_FILE=release.keystore" >> android/gradle.properties
          echo "MYAPP_UPLOAD_KEY_ALIAS=$ANDROID_KEY_ALIAS" >> android/gradle.properties
          echo "MYAPP_UPLOAD_STORE_PASSWORD=$ANDROID_KEYSTORE_PASSWORD" >> android/gradle.properties
          echo "MYAPP_UPLOAD_KEY_PASSWORD=$ANDROID_KEY_PASSWORD" >> android/gradle.properties

      - name: Build Android app
        run: |
          cd android
          if [[ "${{ github.event_name }}" == "release" ]]; then
            ./gradlew assembleRelease bundleRelease
          else
            ./gradlew assembleDebug
          fi

      - name: Upload to Google Play (Release only)
        if: github.event_name == 'release'
        env:
          GOOGLE_PLAY_SERVICE_ACCOUNT_JSON: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON }}
        run: |
          echo $GOOGLE_PLAY_SERVICE_ACCOUNT_JSON | base64 --decode > service-account.json
          # Use fastlane or Google Play CLI to upload
          npx @google-cloud/storage service-account.json
          # Upload AAB to Google Play Console

  # E2E Testing
  e2e-test:
    runs-on: macos-latest
    needs: [ios-build, android-build]
    if: github.event_name == 'push' && github.ref == 'refs/heads/develop'
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build iOS for testing
        run: |
          cd ios
          xcodebuild -workspace YourApp.xcworkspace -scheme YourApp -configuration Debug -sdk iphonesimulator -derivedDataPath build

      - name: Run Detox E2E tests
        run: |
          npm run e2e:ios
          npm run e2e:android

      - name: Upload E2E test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: e2e-test-results
          path: e2e/results/

  # Deployment notification
  notify-deployment:
    runs-on: ubuntu-latest
    needs: [ios-build, android-build]
    if: always()
    steps:
      - name: Notify Slack
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          channel: '#deployments'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Deployment Scripts and Automation

**CREATE** deployment automation scripts:

```bash
#!/bin/bash
# scripts/deploy.sh

set -e

# Configuration
ENVIRONMENT=${1:-staging}
PLATFORM=${2:-both}

echo "🚀 Starting deployment for $ENVIRONMENT environment on $PLATFORM platform(s)"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    echo "❌ Invalid environment. Use: development, staging, or production"
    exit 1
fi

# Load environment configuration
case $ENVIRONMENT in
    "development")
        ENV_FILE=".env.development"
        ;;
    "staging")
        ENV_FILE=".env.staging"
        ;;
    "production")
        ENV_FILE=".env.production"
        ;;
esac

if [[ ! -f $ENV_FILE ]]; then
    echo "❌ Environment file $ENV_FILE not found"
    exit 1
fi

cp $ENV_FILE .env
echo "✅ Environment configuration loaded: $ENV_FILE"

# Pre-deployment checks
echo "🔍 Running pre-deployment checks..."

# Check if all required environment variables are set
if [[ $ENVIRONMENT == "production" ]]; then
    required_vars=("API_BASE_URL" "SENTRY_DSN" "ANALYTICS_KEY")
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            echo "❌ Required environment variable $var is not set"
            exit 1
        fi
    done
fi

# Run tests
echo "🧪 Running tests..."
npm run test:unit
npm run test:integration

# Security audit
echo "🔒 Running security audit..."
npm audit --audit-level moderate

# Build and deploy iOS
if [[ $PLATFORM == "ios" || $PLATFORM == "both" ]]; then
    echo "📱 Building and deploying iOS..."
    ./scripts/deploy-ios.sh $ENVIRONMENT
fi

# Build and deploy Android
if [[ $PLATFORM == "android" || $PLATFORM == "both" ]]; then
    echo "🤖 Building and deploying Android..."
    ./scripts/deploy-android.sh $ENVIRONMENT
fi

echo "✅ Deployment completed successfully!"

# Post-deployment tasks
echo "📊 Running post-deployment tasks..."

# Send deployment notification
if command -v curl &> /dev/null; then
    curl -X POST "$WEBHOOK_URL" \
         -H "Content-Type: application/json" \
         -d "{\"text\":\"🚀 Deployment completed for $ENVIRONMENT environment\"}"
fi

# Update deployment tracking
echo "$(date): Deployed $ENVIRONMENT to $PLATFORM" >> deployments.log
```

```bash
#!/bin/bash
# scripts/deploy-ios.sh

set -e

ENVIRONMENT=$1
BUILD_NUMBER=$(date +%Y%m%d%H%M%S)

echo "🍎 Starting iOS deployment for $ENVIRONMENT environment"

# Navigate to iOS directory
cd ios

# Clean previous builds
echo "🧹 Cleaning previous builds..."
xcodebuild clean -workspace YourApp.xcworkspace -scheme YourApp

# Install dependencies
echo "📦 Installing CocoaPods dependencies..."
pod install --deployment

# Build configuration
case $ENVIRONMENT in
    "development"|"staging")
        CONFIGURATION="Debug"
        EXPORT_METHOD="ad-hoc"
        ;;
    "production")
        CONFIGURATION="Release"
        EXPORT_METHOD="app-store"
        ;;
esac

# Build app
echo "🔨 Building iOS app..."
xcodebuild -workspace YourApp.xcworkspace \
           -scheme YourApp \
           -configuration $CONFIGURATION \
           -archivePath "YourApp.xcarchive" \
           archive

# Export IPA
echo "📦 Exporting IPA..."
xcodebuild -exportArchive \
           -archivePath "YourApp.xcarchive" \
           -exportOptionsPlist "ExportOptions-$ENVIRONMENT.plist" \
           -exportPath "./build"

# Upload to distribution
case $ENVIRONMENT in
    "development"|"staging")
        echo "📤 Uploading to TestFlight (Internal Testing)..."
        xcrun altool --upload-app \
                     --type ios \
                     --file "./build/YourApp.ipa" \
                     --username "$APPLE_ID" \
                     --password "$APPLE_APP_PASSWORD"
        ;;
    "production")
        echo "📤 Uploading to App Store..."
        xcrun altool --upload-app \
                     --type ios \
                     --file "./build/YourApp.ipa" \
                     --username "$APPLE_ID" \
                     --password "$APPLE_APP_PASSWORD"
        ;;
esac

echo "✅ iOS deployment completed!"

# Cleanup
rm -rf YourApp.xcarchive
rm -rf build
```

### Docker Configuration for Development

**IMPLEMENT** containerized development environment:

```dockerfile
# Dockerfile.dev
FROM node:18-alpine

# Install system dependencies
RUN apk add --no-cache \
    bash \
    git \
    openssh \
    python3 \
    make \
    g++ \
    openjdk11

# Install Android SDK
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

RUN mkdir -p ${ANDROID_HOME} && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip && \
    unzip -q commandlinetools-linux-8512546_latest.zip -d ${ANDROID_HOME} && \
    rm commandlinetools-linux-8512546_latest.zip

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY metro.config.js ./
COPY babel.config.js ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Expose Metro bundler port
EXPOSE 8081

# Start Metro bundler
CMD ["npm", "start"]

# docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "8081:8081"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    networks:
      - app-network

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: yourapp_dev
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge
```

### Release Management

**IMPLEMENT** semantic versioning and release automation:

```json
// package.json (release configuration)
{
  "scripts": {
    "release": "semantic-release",
    "release:dry": "semantic-release --dry-run",
    "version:patch": "npm version patch && npm run build:changelog",
    "version:minor": "npm version minor && npm run build:changelog",
    "version:major": "npm version major && npm run build:changelog",
    "build:changelog": "conventional-changelog -p angular -i CHANGELOG.md -s"
  },
  "release": {
    "branches": ["main"],
    "plugins": [
      "@semantic-release/commit-analyzer",
      "@semantic-release/release-notes-generator",
      "@semantic-release/changelog",
      "@semantic-release/npm",
      "@semantic-release/github"
    ]
  }
}
```

```javascript
// release.config.js
module.exports = {
  branches: [
    'main',
    { name: 'develop', prerelease: 'beta' },
    { name: 'alpha', prerelease: true }
  ],
  plugins: [
    ['@semantic-release/commit-analyzer', {
      preset: 'angular',
      releaseRules: [
        { type: 'docs', scope: 'README', release: 'patch' },
        { type: 'refactor', release: 'patch' },
        { type: 'style', release: 'patch' },
        { scope: 'no-release', release: false }
      ]
    }],
    ['@semantic-release/release-notes-generator', {
      preset: 'angular',
      writerOpts: {
        commitsSort: ['subject', 'scope']
      }
    }],
    ['@semantic-release/changelog', {
      changelogFile: 'CHANGELOG.md'
    }],
    ['@semantic-release/exec', {
      prepareCmd: 'npm run build:version ${nextRelease.version}'
    }],
    ['@semantic-release/github', {
      assets: [
        { path: 'android/app/build/outputs/bundle/release/*.aab', label: 'Android App Bundle' },
        { path: 'ios/build/*.ipa', label: 'iOS App Archive' }
      ]
    }]
  ]
};
```

## Anti-Patterns

### **DON'T** implement these deployment anti-patterns

**AVOID** manual deployment processes:

```bash
# ❌ Bad: Manual deployment
scp app.ipa user@server:/deploy/
ssh user@server "deploy app.ipa"

# ✅ Good: Automated CI/CD pipeline
git push origin main # Triggers automated deployment
```

**NEVER** deploy without proper testing:

```yaml
# ❌ Bad: Deploy without tests
deploy:
  runs-on: ubuntu-latest
  steps:
    - name: Deploy immediately
      run: deploy.sh

# ✅ Good: Test before deploy
deploy:
  runs-on: ubuntu-latest
  needs: [test, security-scan, build]
  steps:
    - name: Deploy after validation
      run: deploy.sh
```

**DON'T** ignore rollback capabilities:

```bash
# ❌ Bad: No rollback plan
deploy_new_version() {
  rm -rf old_version
  install new_version
}

# ✅ Good: Rollback capability
deploy_new_version() {
  backup_current_version
  install_new_version
  if ! health_check; then
    rollback_to_previous_version
  fi
}
```

## Validation Checklist

### **MUST** verify

- [ ] Automated CI/CD pipeline is configured and working
- [ ] All environments (development, staging, production) are properly configured
- [ ] Code signing and certificate management is implemented
- [ ] Automated testing runs before deployment
- [ ] Rollback mechanisms are in place and tested
- [ ] Environment variable management is secure
- [ ] Monitoring and alerting are configured for deployments
- [ ] Artifact management and versioning are implemented

### **SHOULD** check

- [ ] Blue-green or canary deployment strategies are considered
- [ ] Deployment notifications and reporting are configured
- [ ] Performance testing is included in deployment pipeline
- [ ] Dependency vulnerability scanning is implemented
- [ ] Infrastructure as code is used for deployment environments
- [ ] Backup and disaster recovery procedures are documented
- [ ] Deployment approval workflows are configured for production
- [ ] Documentation is automatically generated during deployment

## References

- [React Native CI/CD Best Practices](https://reactnative.dev/docs/ci-cd)
- [GitHub Actions for React Native](https://github.com/actions/starter-workflows)
- [Fastlane for React Native](https://docs.fastlane.tools/getting-started/cross-platform/react-native/)
- [CodePush for React Native](https://docs.microsoft.com/en-us/appcenter/distribution/codepush/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [Google Play Console API](https://developers.google.com/android-publisher)
