# Email Stamp App

A professional, cross-platform email application with cryptographic verification, QR codes, and PGP support.

## Features

- ✨ **Modern UI** - Beautiful, professional interface with dark mode support
- 🔒 **Cryptographic Verification** - SHA256 hashing of email content
- 📱 **Cross-Platform** - Works on macOS, iPhone, and iPad
- 🔐 **PGP Support** - Configure and use PGP signing
- 🎨 **Visual Stamps** - Add custom images to emails
- 📊 **QR Codes** - Automatic QR code generation for verification
- 🛡️ **Secure** - Keychain storage, input validation, secure memory management
- 📝 **Headers & Footers** - Customizable email headers and footers

## Requirements

- **macOS**: 14.0 or later
- **iOS**: 16.0 or later
- **iPadOS**: 16.0 or later

## Quick Start

### macOS

1. Open `EmailStampApp.xcodeproj` in Xcode
2. Select the **EmailStampApp** scheme
3. Build and run (⌘R)

### iOS

1. Open `EmailStampApp.xcodeproj` in Xcode
2. Select the **EmailStampApp-iOS** scheme
3. Choose a simulator or connected device
4. Build and run (⌘R)

## Building from Command Line

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
  -target EmailStampApp-iOS \
  -configuration Debug \
  -sdk iphonesimulator \
  -arch arm64 \
  build
```

## Architecture

```
Sources/EmailStampApp/
├── EmailStampApp.swift    # Main app entry point
├── Models/                # Data models
│   ├── EmailItem.swift
│   └── PGPSettings.swift
├── ViewModels/            # View models
│   └── EmailComposeViewModel.swift
├── Views/                 # SwiftUI views
│   ├── PGPSettingsView.swift
│   └── HeaderFooterSettingsView.swift
├── Utilities/             # Helper utilities
│   ├── Theme.swift        # Dark mode support
│   ├── Platform.swift     # Cross-platform utilities
│   ├── Security.swift     # Security features
│   └── EmailStampGenerator.swift
└── Resources/             # Assets
```

## Documentation

See the `docs/` folder for detailed documentation:
- **guides/** - User guides and tutorials
- **setup/** - Setup and installation instructions
- **troubleshooting/** - Common issues and solutions

## Security

This app implements multiple security measures:
- ✅ Keychain storage for sensitive data
- ✅ Secure memory wiping
- ✅ Input validation and sanitization
- ✅ No password storage in plain text
- ✅ Secure hash generation

## License

Free to use and modify.
