# Code Signing Setup for Email Stamp Mail.app Extension

This guide explains how to configure code signing for the Mail.app extension.

## Prerequisites

1. **Apple Developer Account**: You need an active Apple Developer account
   - Free account: For development only (7-day certificates)
   - Paid account ($99/year): For distribution and longer-term certificates

2. **Xcode**: Latest version with Command Line Tools installed

## Setup Steps

### 1. Configure Development Team in Xcode

1. Open the project in Xcode:
   ```bash
   open EmailStampApp.xcodeproj
   ```

2. Select the **EmailStampApp** target

3. Go to **Signing & Capabilities** tab

4. Check **"Automatically manage signing"**

5. Select your **Team** from the dropdown:
   - If you don't see your team, click "Add Account..." and sign in with your Apple ID
   - For free accounts: Select your personal team
   - For paid accounts: Select your organization team

### 2. Update Bundle Identifier

The bundle identifier must be unique. Update it in Xcode:

1. In **Signing & Capabilities**, set:
   ```
   Bundle Identifier: com.yourdomain.emailstamp.extension
   ```
   Replace `yourdomain` with your domain or name.

2. Or update in Build Settings:
   ```
   PRODUCT_BUNDLE_IDENTIFIER = com.yourdomain.emailstamp.extension
   ```

### 3. Configure Code Signing Identity

#### For Development (Automatic Signing)

The project is configured for automatic signing. Xcode will:
- Generate a development certificate automatically
- Create a provisioning profile
- Handle code signing during build

#### For Distribution (Manual Signing)

If you need to distribute the extension:

1. **Create a Developer ID Certificate** (for distribution outside App Store):
   - Open Keychain Access
   - Request Certificate from Certificate Authority
   - Download from developer.apple.com
   - Install in Keychain

2. **Or use App Store Certificate** (for Mac App Store):
   - Requires App Store Connect setup
   - More complex process

### 4. Update Project Settings

The project file has been configured with code signing settings. You can verify in Xcode:

**Build Settings → Code Signing:**
- `CODE_SIGN_STYLE = Automatic` (recommended)
- `CODE_SIGN_IDENTITY = Apple Development` (for development)
- `DEVELOPMENT_TEAM = Your Team ID` (set automatically when you select team)

### 5. Verify Entitlements

The `EmailStampApp.entitlements` file is configured with:
- App Sandbox: Disabled (Mail extensions need this)
- User-selected files: Read/Write access
- Application Groups: For sharing data (optional)

### 6. Build and Test

1. Build the project (⌘B)
2. Xcode will automatically:
   - Sign the extension
   - Create provisioning profile
   - Install to Mail.app (if running)

3. Check for signing errors in the build log

## Troubleshooting

### "No signing certificate found"

**Solution:**
1. Go to Xcode → Preferences → Accounts
2. Add your Apple ID
3. Select your team
4. Click "Download Manual Profiles" if needed

### "Provisioning profile doesn't match"

**Solution:**
1. Clean build folder (⇧⌘K)
2. Delete derived data
3. Let Xcode regenerate profiles

### "Code signing is required for product type 'App Extension'"

**Solution:**
1. Ensure you've selected a development team
2. Check that bundle identifier is set
3. Verify entitlements file is included

### Extension Not Loading in Mail.app

**Solution:**
1. Check code signing succeeded:
   ```bash
   codesign -dv --verbose=4 ~/Library/Mail/Bundles/EmailStampApp.appex
   ```

2. Verify extension is signed:
   ```bash
   codesign --verify --verbose ~/Library/Mail/Bundles/EmailStampApp.appex
   ```

3. Check Mail.app console for errors:
   ```bash
   log show --predicate 'process == "Mail"' --last 10m
   ```

## Manual Code Signing (Advanced)

If you need to manually sign the extension:

```bash
# Sign with your Developer ID
codesign --force --sign "Developer ID Application: Your Name" \
  --entitlements EmailStampApp.entitlements \
  EmailStampApp.appex

# Verify signature
codesign --verify --verbose EmailStampApp.appex

# Check entitlements
codesign -d --entitlements - EmailStampApp.appex
```

## Distribution Signing

For distributing the extension:

1. **Developer ID** (for direct distribution):
   - Use "Developer ID Application" certificate
   - Notarize with Apple (required for macOS 10.15+)

2. **Mac App Store**:
   - Use "3rd Party Mac Developer Application" certificate
   - Requires App Store Connect setup

## Notes

- Mail.app extensions **must** be code signed to load
- Development certificates expire after 7 days (free account) or 1 year (paid)
- The extension runs in Mail.app's process, so it needs proper entitlements
- Code signing is automatically handled when using Xcode's automatic signing

## Quick Setup Script

Run this to check your code signing setup:

```bash
#!/bin/bash
echo "Checking code signing setup..."

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode not found"
    exit 1
fi

# Check for signing certificates
security find-identity -v -p codesigning | grep "Developer"

# Check project configuration
cd EmailStampApp
xcodebuild -showBuildSettings | grep -i "code_sign"
```

Save this as `check_signing.sh` and run:
```bash
chmod +x check_signing.sh
./check_signing.sh
```

