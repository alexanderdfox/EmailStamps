# Cross-Platform Setup Guide

## Overview

The Email Stamp App is now configured for cross-platform development supporting both macOS and iOS.

## Targets

### macOS Target: `EmailStampApp`
- **Platform**: macOS 14.0+
- **Bundle ID**: `com.emailstamp.app`
- **Product**: `EmailStampApp.app`

### iOS Target: `StampIOS` (or `EmailStampApp-iOS`)
- **Platform**: iOS 16.0+
- **Bundle ID**: `com.emailstamp.app.ios`
- **Product**: `EmailStampApp-iOS.app`
- **Devices**: iPhone and iPad

## Building

### macOS
```bash
xcodebuild -project EmailStampApp.xcodeproj \
  -target EmailStampApp \
  -configuration Debug \
  -arch arm64 \
  build
```

### iOS Simulator
```bash
xcodebuild -project EmailStampApp.xcodeproj \
  -target StampIOS \
  -configuration Debug \
  -sdk iphonesimulator \
  -arch arm64 \
  build
```

### iOS Device
```bash
xcodebuild -project EmailStampApp.xcodeproj \
  -target StampIOS \
  -configuration Release \
  -sdk iphoneos \
  -arch arm64 \
  build
```

## Platform-Specific Code

The app uses conditional compilation for platform-specific features:

### Navigation
- **macOS**: Uses `HSplitView` for sidebar + content layout
- **iOS**: Uses `NavigationView` for stack-based navigation

### Image Picker
- **macOS**: Uses `NSOpenPanel` for file selection
- **iOS**: Uses `PhotosPicker` for image selection

### Web View
- **macOS**: Uses `NSViewRepresentable` with `WKWebView`
- **iOS**: Uses `UIViewRepresentable` with `WKWebView`

### File Operations
- **macOS**: Uses `NSSavePanel` and `NSOpenPanel`
- **iOS**: Uses `UIActivityViewController` and `PhotosPicker`

## Shared Code

All source files in `Sources/EmailStampApp/` are shared between both targets:
- Models
- ViewModels
- Utilities
- Views (with platform conditionals)

## Configuration

### iOS Deployment Target
- Minimum: iOS 16.0
- Supports: iPhone and iPad

### macOS Deployment Target
- Minimum: macOS 14.0

## Notes

- The iOS target uses a file system synchronized group pointing to `Sources/EmailStampApp`
- Both targets share the same source code
- Platform-specific UI adaptations are handled via `#if os(iOS)` and `#if os(macOS)` conditionals
- Dark mode is supported on both platforms

