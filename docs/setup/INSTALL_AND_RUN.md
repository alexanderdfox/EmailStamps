# Install and Run Email Stamp Mail.app Extension

## ✅ Build Successful!

The extension has been built successfully as `EmailStampApp.appex`.

## Installation Steps

### 1. Locate the Built Extension

The extension is located at:
```
/Users/alexanderfox/Desktop/minecraft/EmailStampApp/build/Debug/EmailStampApp.appex
```

### 2. Install to Mail.app

**Option A: Manual Installation**

1. Create the Mail Bundles directory (if it doesn't exist):
   ```bash
   mkdir -p ~/Library/Mail/Bundles
   ```

2. Copy the extension:
   ```bash
   cp -R /Users/alexanderfox/Desktop/minecraft/EmailStampApp/build/Debug/EmailStampApp.appex ~/Library/Mail/Bundles/
   ```

3. Enable Mail.app extensions:
   ```bash
   defaults write com.apple.mail EnableBundles -bool true
   defaults write com.apple.mail BundleCompatibilityVersion -string 14
   ```

4. Restart Mail.app:
   ```bash
   killall Mail
   open -a Mail
   ```

**Option B: Using Xcode (Recommended)**

1. In Xcode, select the **EmailStampApp** scheme
2. Choose **Product → Run** (⌘R)
3. Xcode will automatically install the extension to Mail.app
4. Mail.app will launch automatically

### 3. Verify Installation

1. Open Mail.app
2. Go to **Mail → Settings → Extensions** (or **Mail → Preferences → Extensions**)
3. Look for "Email Stamp Extension" in the list
4. Make sure it's enabled

### 4. Using the Extension

The extension is now installed. However, note that:

- The current implementation is a simplified version without full MailKit integration
- MailKit API integration needs to be completed based on your macOS version
- The extension structure is in place and ready for MailKit API implementation

## Troubleshooting

### Extension Not Appearing

1. **Check if extensions are enabled:**
   ```bash
   defaults read com.apple.mail EnableBundles
   ```
   Should return `1`

2. **Check extension location:**
   ```bash
   ls -la ~/Library/Mail/Bundles/
   ```

3. **Check Mail.app console for errors:**
   ```bash
   log show --predicate 'process == "Mail"' --last 10m | grep -i "emailstamp\|error"
   ```

### Extension Crashes

1. **Check code signing:**
   ```bash
   codesign -dv --verbose=4 ~/Library/Mail/Bundles/EmailStampApp.appex
   ```

2. **Verify entitlements:**
   ```bash
   codesign -d --entitlements - ~/Library/Mail/Bundles/EmailStampApp.appex
   ```

### Rebuild After Changes

1. Make your code changes
2. Build in Xcode (⌘B)
3. Reinstall using one of the methods above
4. Restart Mail.app

## Next Steps

To complete the MailKit integration:

1. Research the exact MailKit API for your macOS version
2. Implement the proper `MEMailExtension` protocol methods
3. Add UI elements (toolbar buttons, menu items) as needed
4. Test with actual email composition

## Current Status

✅ Project builds successfully  
✅ Extension structure created  
✅ Frameworks linked (MailKit, CryptoKit, CoreImage)  
✅ Code signing configured  
⚠️ MailKit API needs final implementation based on macOS version

The foundation is ready - you can now implement the full MailKit functionality!

