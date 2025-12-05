# Troubleshooting: Extension Not Showing in Mail.app

## Issue: Extension doesn't appear when running from Xcode

### Step 1: Enable Mail Extensions

Run the enable script:
```bash
cd EmailStampApp
./enable_mail_extensions.sh
```

Or manually:
```bash
defaults write com.apple.mail EnableBundles -bool true
defaults write com.apple.mail BundleCompatibilityVersion -string 14
```

### Step 2: Install Extension Manually

Xcode's "Run" may not automatically install Mail extensions. Install manually:

```bash
# Create directory if needed
mkdir -p ~/Library/Mail/Bundles

# Copy extension
cp -R build/Debug/EmailStampApp.appex ~/Library/Mail/Bundles/

# Verify it's there
ls -la ~/Library/Mail/Bundles/
```

### Step 3: Restart Mail.app

**Important:** Mail.app must be completely restarted:

```bash
# Kill Mail.app completely
killall Mail

# Wait a moment, then restart
open -a Mail
```

### Step 4: Check Extension in Mail.app

1. Open Mail.app
2. Go to **Mail → Settings** (or **Mail → Preferences**)
3. Click **Extensions** tab
4. Look for "Email Stamp Extension" or your bundle identifier
5. Make sure it's **enabled**

### Step 5: Check Console Logs

If extension still doesn't appear, check for errors:

```bash
# Check Mail.app logs
log show --predicate 'process == "Mail"' --last 10m | grep -i "emailstamp\|extension\|error" | tail -20

# Or use Console.app
open -a Console
# Filter by "Mail" process
```

### Step 6: Verify Code Signing

```bash
# Check if extension is properly signed
codesign -dv --verbose=4 ~/Library/Mail/Bundles/EmailStampApp.appex

# Verify signature
codesign --verify --verbose ~/Library/Mail/Bundles/EmailStampApp.appex
```

### Step 7: Check Bundle Identifier

Make sure the bundle identifier is unique and ends with `.extension`:

- ✅ Good: `com.emailstamp.app.extension`
- ❌ Bad: `com.emailstamp.app`

### Step 8: Verify Info.plist

Check that Info.plist has:
- `NSPrincipalClass` = `EmailStampExtension`
- `NSExtensionPointIdentifier` = `com.apple.mail.extension`
- `NSExtensionPrincipalClass` = `EmailStampExtension`

### Step 9: Check macOS Version

MailKit requires macOS 12.0 or later. Verify:
```bash
sw_vers
```

### Step 10: Rebuild and Reinstall

1. Clean build in Xcode (⇧⌘K)
2. Build again (⌘B)
3. Remove old extension:
   ```bash
   rm -rf ~/Library/Mail/Bundles/EmailStampApp.appex
   ```
4. Copy new extension:
   ```bash
   cp -R build/Debug/EmailStampApp.appex ~/Library/Mail/Bundles/
   ```
5. Restart Mail.app

## Common Issues

### Extension appears but doesn't work

- Check that `EmailStampExtension` class conforms to `MEMailExtension`
- Verify MailKit framework is properly linked
- Check console logs for runtime errors

### "Extension not compatible" error

- Update `BundleCompatibilityVersion` to match your macOS version
- Check minimum deployment target (should be 12.0+)

### Extension crashes on load

- Check code signing
- Verify all frameworks are linked
- Check console for crash logs

## Debug Mode

To see more detailed logs:

```bash
# Enable verbose logging
defaults write com.apple.mail DebugLogging -bool true

# Restart Mail.app
killall Mail && open -a Mail

# Check logs
log show --predicate 'process == "Mail"' --last 5m
```

## Still Not Working?

1. Check Xcode build log for warnings
2. Verify extension builds without errors
3. Check that extension file exists and has correct permissions
4. Try creating a minimal test extension first
5. Check Apple's MailKit documentation for your macOS version

