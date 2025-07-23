---
applyTo: '**'
---

# React Native .gitignore Instructions

This document outlines the `.gitignore` file configuration for React Native applications, ensuring that unnecessary files, build artifacts, and sensitive information are excluded from version control.

## Requirements

### Critical Requirements (**MUST** Follow)

- **MUST** exclude all build artifacts and generated files from version control
- **REQUIRED** to exclude sensitive configuration files and secrets
- **SHALL** exclude platform-specific build directories and cache files
- **MUST** exclude dependency directories that can be regenerated
- **NEVER** commit API keys, certificates, or other sensitive data
- **REQUIRED** to exclude IDE and editor specific files
- **SHALL** exclude temporary files and system-generated files
- **MUST** exclude large binary files and assets that should be stored elsewhere
- **REQUIRED** to exclude local environment configuration files
- **SHALL** maintain consistency across development team environments

### Strong Recommendations (**SHOULD** Implement)

- **SHOULD** regularly review and update .gitignore patterns
- **RECOMMENDED** to document why specific patterns are included
- **ALWAYS** test .gitignore patterns before committing changes
- **DO** use specific patterns instead of broad wildcards when possible
- **SHOULD** organize .gitignore sections with clear comments
- **RECOMMENDED** to validate that no sensitive files are accidentally tracked
- **DO** consider platform-specific ignore patterns for team consistency
- **ALWAYS** check for accidentally committed files before pushing

### Optional Enhancements (**MAY** Consider)

- **MAY** use global .gitignore for personal development tools
- **OPTIONAL** to implement automated scanning for sensitive data
- **USE** .gitignore templates for consistent project setup
- **IMPLEMENT** git hooks to validate commits against ignore patterns
- **AVOID** over-complicating ignore patterns for simple use cases

## Implementation Guidance

### Complete .gitignore Configuration

**CREATE** comprehensive .gitignore file for React Native projects:

```gitignore
# React Native .gitignore

# ===========================
# Dependencies
# ===========================
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Package manager lock files (choose one based on your package manager)
# package-lock.json  # Uncomment if using npm
# yarn.lock          # Uncomment if using yarn
# pnpm-lock.yaml     # Uncomment if using pnpm

# ===========================
# React Native
# ===========================

# Metro bundler cache
.metro-health-check*
.metro-cache/

# React Native packager cache
*.tgz

# Temporary files created by Metro
.metro/

# ===========================
# iOS
# ===========================

# Xcode
ios/build/
ios/DerivedData/
ios/Index/
ios/*.xcworkspace/xcuserdata/
ios/*.xcworkspace/xcshareddata/
ios/*.xcodeproj/xcuserdata/
ios/*.xcodeproj/xcshareddata/

# iOS build artifacts
ios/*.ipa
ios/*.dSYM.zip
ios/*.app.dSYM/

# CocoaPods
ios/Pods/
ios/Podfile.lock

# iOS certificates and provisioning profiles
ios/*.mobileprovision
ios/*.p12
ios/*.cer
ios/*.certSigningRequest

# Fastlane
ios/fastlane/report.xml
ios/fastlane/Preview.html
ios/fastlane/screenshots/**/*.png
ios/fastlane/test_output/

# iOS Simulator
ios/build/
*.xcuserstate
*.xcscmblueprint

# ===========================
# Android
# ===========================

# Android build artifacts
android/app/build/
android/build/
android/.gradle/
android/app/release/
android/app/debug/

# Android Studio
android/.idea/
android/*.iml
android/local.properties
android/.externalNativeBuild/
android/.cxx/

# Android signing
android/app/*.keystore
android/app/*.jks
android/key.properties
android/app/google-services.json  # If contains sensitive data
android/app/src/release/

# Android NDK
android/obj/

# Gradle
android/.gradle/
android/gradle/
!android/gradle/wrapper/gradle-wrapper.properties

# ===========================
# Environment & Configuration
# ===========================

# Environment variables
.env
.env.local
.env.development.local
.env.staging.local
.env.production.local
.env.test.local

# Local configuration
config/local.js
config/local.json
src/config/local.ts

# ===========================
# IDE & Editor Files
# ===========================

# Visual Studio Code
.vscode/
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json

# JetBrains IDEs
.idea/
*.swp
*.swo

# Sublime Text
*.sublime-project
*.sublime-workspace

# Vim
*.swp
*.swo
*~

# Emacs
*~
\#*\#
/.emacs.desktop
/.emacs.desktop.lock
*.elc
auto-save-list
tramp
.\#*

# ===========================
# Operating System
# ===========================

# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon?
._*
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk

# Windows
Thumbs.db
Thumbs.db:encryptable
ehthumbs.db
ehthumbs_vista.db
*.stackdump
[Dd]esktop.ini
$RECYCLE.BIN/
*.cab
*.msi
*.msix
*.msm
*.msp
*.lnk

# Linux
*~
.fuse_hidden*
.directory
.Trash-*
.nfs*

# ===========================
# Logs & Debugging
# ===========================

# Application logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*

# Diagnostic reports
report.[0-9]*.[0-9]*.[0-9]*.[0-9]*.json

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov
.nyc_output/

# ESLint cache
.eslintcache

# Prettier cache
.prettiercache

# ===========================
# Testing
# ===========================

# Jest
coverage/
.jest/

# E2E testing
e2e/artifacts/
e2e/screenshots/
e2e/videos/

# Test results
test-results/
test-report.xml

# ===========================
# Build & Distribution
# ===========================

# Build directories
build/
dist/
.expo/
.expo-shared/

# Webpack build
.webpack/

# Rollup build
.rollup.cache/

# Next.js build (if using with Expo)
.next/

# Storybook build outputs
.out
storybook-static

# ===========================
# Assets & Media
# ===========================

# Large media files (consider using Git LFS)
*.mp4
*.mov
*.avi
*.mkv
*.wmv
*.flv
*.webm

# Large image files (adjust based on your needs)
# *.png
# *.jpg
# *.jpeg
# *.gif
# *.bmp
# *.tiff
# *.webp

# Audio files
*.mp3
*.wav
*.aac
*.ogg
*.flac

# ===========================
# Documentation
# ===========================

# Generated documentation
docs/generated/
api-docs/
.docusaurus/

# ===========================
# Miscellaneous
# ===========================

# Backup files
*.bak
*.backup
*.old
*.orig
*.tmp

# Archive files
*.zip
*.tar.gz
*.rar
*.7z

# Database files
*.db
*.sqlite
*.sqlite3

# Cache directories
.cache/
.temp/
.tmp/
temp/
tmp/

# Sentry
.sentryclirc

# Bundle analyzer
bundle-analyzer-report.html

# TypeScript cache
*.tsbuildinfo

# Optional REPL history
.node_repl_history

# Optional npm cache directory
.npm

# Optional yarn cache
.yarn/cache
.yarn/unplugged
.yarn/build-state.yml
.yarn/install-state.gz
.pnp.*

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# dotenv environment variable files
.env.development.local
.env.test.local
.env.production.local
.env.local

# Serverless directories
.serverless/

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# TernJS port file
.tern-port

# Stores VSCode versions used for testing VSCode extensions
.vscode-test

# =================================
# Project Specific
# =================================

# Add your project-specific ignore patterns here
# Example:
# src/config/secrets.ts
# assets/private/
# scripts/deploy-keys/

# Sensitive configuration files
src/config/production.ts
config/secrets.json
certificates/
keys/
secrets/

# Analytics and tracking IDs
google-services.json
GoogleService-Info.plist

# Code signing certificates
*.p12
*.cer
*.mobileprovision
*.keystore
*.jks

# Deployment scripts with sensitive data
deploy/production/
scripts/production/
```

### Environment-Specific Ignore Patterns

**CREATE** environment-specific ignore files:

```gitignore
# .gitignore.local (for local development overrides)
# This file can be included in main .gitignore if needed

# Local development overrides
.env.override
config/local-override.json

# Personal development tools
.personal-notes.md
.todo.md

# Local testing data
test-data/local/
fixtures/personal/

# Development certificates
dev-certificates/
local-keys/
```

```gitignore
# .gitignore.production (production-specific patterns)
# Include this content in main .gitignore for production builds

# Production builds should not include
src/**/*.test.*
src/**/*.spec.*
**/__tests__/
**/__mocks__/
*.test.ts
*.test.tsx
*.spec.ts
*.spec.tsx

# Development-only files
.storybook/
stories/
docs/development/

# Source maps in production
*.map
```

### Git Attributes Configuration

**CREATE** .gitattributes file for consistent handling:

```gitattributes
# .gitattributes

# Set default behavior for all files
* text=auto eol=lf

# Ensure shell scripts have LF endings
*.sh text eol=lf

# Ensure batch files have CRLF endings
*.bat text eol=crlf

# JavaScript and TypeScript files
*.js text eol=lf
*.jsx text eol=lf
*.ts text eol=lf
*.tsx text eol=lf
*.json text eol=lf

# Configuration files
*.yml text eol=lf
*.yaml text eol=lf
*.xml text eol=lf
*.toml text eol=lf

# Documentation
*.md text eol=lf
*.txt text eol=lf

# Images should be treated as binary
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.ico binary
*.svg text eol=lf

# Fonts should be treated as binary
*.ttf binary
*.otf binary
*.woff binary
*.woff2 binary
*.eot binary

# Video and audio files
*.mp4 binary
*.mov binary
*.avi binary
*.mp3 binary
*.wav binary

# Archive files
*.zip binary
*.tar binary
*.gz binary
*.7z binary
*.rar binary

# Mobile app specific files
*.ipa binary
*.apk binary
*.aab binary

# Certificates and keys
*.p12 binary
*.keystore binary
*.jks binary
*.cer binary
*.pem binary

# Database files
*.db binary
*.sqlite binary
*.sqlite3 binary
```

### Validation and Testing

**CREATE** validation script for .gitignore effectiveness:

```bash
#!/bin/bash
# scripts/validate-gitignore.sh

set -e

echo "🔍 Validating .gitignore configuration..."

# Check for accidentally tracked sensitive files
echo "Checking for sensitive files in repository..."

sensitive_patterns=(
    "*.env"
    "*.keystore"
    "*.jks"
    "*.p12"
    "*.mobileprovision"
    "google-services.json"
    "GoogleService-Info.plist"
    "config/secrets*"
    "keys/*"
    "certificates/*"
)

found_sensitive=false
for pattern in "${sensitive_patterns[@]}"; do
    if git ls-files | grep -q "$pattern" 2>/dev/null; then
        echo "⚠️  WARNING: Sensitive files found matching pattern: $pattern"
        git ls-files | grep "$pattern"
        found_sensitive=true
    fi
done

if [ "$found_sensitive" = true ]; then
    echo "❌ Sensitive files found in repository!"
    echo "Please review and remove these files, then update .gitignore"
    exit 1
fi

# Check for large files that should be ignored
echo "Checking for large files that should potentially be ignored..."
large_files=$(find . -type f -size +10M -not -path "./node_modules/*" -not -path "./.git/*" 2>/dev/null || true)

if [ -n "$large_files" ]; then
    echo "⚠️  Large files found (>10MB):"
    echo "$large_files"
    echo "Consider adding these to .gitignore or using Git LFS"
fi

# Check build directories
echo "Checking if build directories are properly ignored..."
build_dirs=("ios/build" "android/app/build" "android/build" "build" "dist")

for dir in "${build_dirs[@]}"; do
    if [ -d "$dir" ] && git check-ignore "$dir" >/dev/null 2>&1; then
        echo "✅ $dir is properly ignored"
    elif [ -d "$dir" ]; then
        echo "⚠️  $dir exists but is not ignored"
    fi
done

# Check for node_modules
if [ -d "node_modules" ] && git check-ignore "node_modules" >/dev/null 2>&1; then
    echo "✅ node_modules is properly ignored"
elif [ -d "node_modules" ]; then
    echo "❌ node_modules exists but is not ignored!"
    exit 1
fi

echo "✅ .gitignore validation completed!"
```

## Anti-Patterns

### **DON'T** implement these .gitignore anti-patterns

**AVOID** committing sensitive files:

```gitignore
# ❌ Bad: Not ignoring sensitive files
# Missing these important patterns:
# .env
# *.keystore
# google-services.json

# ✅ Good: Proper sensitive file patterns
.env*
*.keystore
*.jks
*.p12
google-services.json
GoogleService-Info.plist
```

**NEVER** ignore essential files:

```gitignore
# ❌ Bad: Ignoring essential files
package.json
package-lock.json
src/
README.md

# ✅ Good: Only ignore generated/sensitive files
# Don't ignore source code and essential configuration
```

**DON'T** use overly broad patterns:

```gitignore
# ❌ Bad: Too broad
*
!src/

# ✅ Good: Specific patterns
build/
*.log
node_modules/
```

### Git Repository Cleanup

**IMPLEMENT** cleanup scripts for accidentally committed files:

```bash
#!/bin/bash
# scripts/cleanup-sensitive-files.sh

echo "🧹 Cleaning up accidentally committed sensitive files..."

# Remove files from Git history (use with caution!)
sensitive_files=(
    ".env"
    ".env.production"
    "google-services.json"
    "GoogleService-Info.plist"
    "ios/*.mobileprovision"
    "android/app/*.keystore"
    "android/app/*.jks"
)

for file in "${sensitive_files[@]}"; do
    echo "Removing $file from Git history..."
    git filter-branch --force --index-filter \
        "git rm --cached --ignore-unmatch $file" \
        --prune-empty --tag-name-filter cat -- --all
done

echo "⚠️  WARNING: This script rewrites Git history!"
echo "⚠️  Make sure all team members pull the updated repository!"
echo "⚠️  Consider force-pushing to remote after verification!"
```

## Validation Checklist

### **MUST** verify

- [ ] All sensitive files and directories are properly ignored
- [ ] Build artifacts and generated files are excluded
- [ ] Platform-specific build directories are ignored
- [ ] Environment configuration files are not committed
- [ ] IDE and editor files are appropriately ignored
- [ ] Dependency directories (node_modules) are ignored
- [ ] No large binary files are accidentally tracked
- [ ] Certificate and key files are excluded

### **SHOULD** check

- [ ] .gitignore patterns are organized and documented
- [ ] Global vs project-specific ignore patterns are properly separated
- [ ] .gitattributes file is configured for consistent line endings
- [ ] Validation scripts are available and functional
- [ ] Team members understand and follow ignore patterns
- [ ] Regular audits are performed for accidentally committed files
- [ ] Backup and recovery procedures account for ignored files
- [ ] CI/CD pipelines properly handle ignored files

## References

- [Git Documentation - gitignore](https://git-scm.com/docs/gitignore)
- [GitHub .gitignore Templates](https://github.com/github/gitignore)
- [React Native Gitignore](https://github.com/react-native-community/react-native-template-typescript/blob/main/.gitignore)
- [Atlassian Git Ignore Tutorial](https://www.atlassian.com/git/tutorials/saving-changes/gitignore)
- [Git Attributes Documentation](https://git-scm.com/docs/gitattributes)
