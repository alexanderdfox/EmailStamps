# Email Stamp Mail.app Plugin

A Mail.app extension that adds cryptographic email stamps with QR codes directly in Mail.app's compose window.

## Features

- **Mail.app Integration**: Works directly within Mail.app
- **One-Click Stamping**: Add stamps to emails with a single click
- **SHA256 Hashing**: Cryptographic verification of email content
- **QR Code Generation**: Automatic QR code creation from hash
- **Visual Stamps**: Support for custom stamp images
- **PGP Signature Placeholder**: Optional PGP signature section

## Requirements

- macOS 12.0 or later
- Mail.app
- Xcode 14.0 or later (for building)

## Building the Plugin

1. Open the project in Xcode:
   ```bash
   open EmailStampApp.xcodeproj
   ```

2. Select the "EmailStampApp" scheme

3. Build the project (⌘B)

4. The extension will be built to:
   ```
   ~/Library/Developer/Xcode/DerivedData/EmailStampApp-*/Build/Products/Debug/EmailStampApp.appex
   ```

## Installation

### Method 1: Manual Installation

1. Build the project in Xcode
2. Locate the `.appex` file in the build products
3. Copy it to:
   ```
   ~/Library/Mail/Bundles/EmailStampApp.appex
   ```

4. Enable Mail.app extensions:
   ```bash
   defaults write com.apple.mail EnableBundles -bool true
   defaults write com.apple.mail BundleCompatibilityVersion -string 14
   ```

5. Restart Mail.app

### Method 2: Using Xcode

1. Build and run the extension target
2. Xcode will automatically install it to Mail.app
3. Restart Mail.app to activate

## Usage

1. Open Mail.app and compose a new email
2. Write your email subject and body
3. Click the "Add Stamp" button in the compose window toolbar
4. The email will be automatically updated with:
   - Your email content
   - Visual stamp (if configured)
   - QR code containing the SHA256 hash
   - PGP signature placeholder (if enabled)

## Configuration

The extension can be configured by modifying the `EmailStampGenerator` class:

- **Stamp Image**: Set via `setStampImage(_:)` method
- **PGP Signature**: Toggle via `includePGP` parameter

## Troubleshooting

### Extension Not Appearing

1. Check that Mail.app extensions are enabled:
   ```bash
   defaults read com.apple.mail EnableBundles
   ```
   Should return `1` (enabled)

2. Verify the extension is in the correct location:
   ```bash
   ls -la ~/Library/Mail/Bundles/
   ```

3. Check Mail.app's Console for errors:
   ```bash
   log show --predicate 'process == "Mail"' --last 5m
   ```

### Extension Crashes

1. Check system logs:
   ```bash
   log show --predicate 'process == "Mail"' --last 10m | grep -i "emailstamp"
   ```

2. Verify MailKit framework is available (macOS 12+)

## Development

### Project Structure

- `EmailStampExtension.swift` - Main extension entry point
- `EmailStampGenerator.swift` - Core stamp generation logic
- `EmailStampApp.swift` - Legacy app entry (kept for reference)

### Testing

1. Build the extension
2. Install to Mail.app
3. Compose a test email
4. Click "Add Stamp" button
5. Verify HTML is generated correctly

## License

Free to use and modify.

## Notes

- Mail.app extensions require macOS 12.0+ (MailKit framework)
- The extension runs in Mail.app's process space
- Some MailKit APIs may vary between macOS versions
- The extension needs to be code-signed for distribution

