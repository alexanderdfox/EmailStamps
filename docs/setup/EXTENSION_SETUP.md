# Making Extension Show in Mail.app Extensions Settings

## Overview

For the extension to appear in **Mail → Settings → Extensions**, it needs to:

1. ✅ Properly implement MailKit protocols
2. ✅ Have correct Info.plist configuration
3. ✅ Be installed to `~/Library/Mail/Bundles/`
4. ✅ Have Mail extensions enabled
5. ✅ Be code signed

## Quick Setup

### Step 1: Build the Extension

In Xcode:
- Press **⌘B** to build
- Make sure build succeeds without errors

### Step 2: Run Setup Script

```bash
cd EmailStampApp
./setup_mail_extension.sh
```

This will:
- Enable Mail extensions
- Create the Bundles directory
- Install the extension
- Provide next steps

### Step 3: Restart Mail.app

```bash
killall Mail
open -a Mail
```

### Step 4: Enable Extension in Mail.app

1. Open **Mail.app**
2. Go to **Mail → Settings** (or **Preferences**)
3. Click **Extensions** tab
4. Look for **"Email Stamp Extension"**
5. **Check the box** to enable it

### Step 5: Add to Compose Toolbar (Optional)

1. Open a **new compose window** (⌘N)
2. **Right-click** on the toolbar
3. Select **"Customize Toolbar"**
4. Find your extension's icon
5. **Drag it** into the toolbar
6. Click **Done**

## Verification

### Check Extension is Installed

```bash
ls -la ~/Library/Mail/Bundles/EmailStampApp.appex
```

### Check Mail Extension Settings

```bash
defaults read com.apple.mail EnableBundles
# Should return: 1
```

### Check Extension Signature

```bash
codesign -dv ~/Library/Mail/Bundles/EmailStampApp.appex
```

### Check Console Logs

If extension doesn't appear, check for errors:

```bash
log show --predicate 'process == "Mail"' --last 10m | grep -i "emailstamp\|extension\|error" | tail -20
```

## Troubleshooting

### Extension Not in Extensions List

**Possible causes:**

1. **Info.plist misconfiguration**
   - Check `NSExtensionPointIdentifier` = `com.apple.mail.extension`
   - Check `NSPrincipalClass` = `EmailStampExtension`
   - Check `NSExtensionPrincipalClass` = `EmailStampExtension`

2. **Extension not properly signed**
   - Verify code signing in Xcode
   - Check development team is set

3. **Mail extensions not enabled**
   ```bash
   defaults write com.apple.mail EnableBundles -bool true
   ```

4. **Wrong bundle identifier**
   - Should end with `.extension`
   - Must be unique

5. **macOS version too old**
   - MailKit requires macOS 12.0+
   - Check deployment target

### Extension Appears But Doesn't Work

1. **Check MailKit implementation**
   - Extension must conform to `MEMailExtension`
   - Must implement required methods

2. **Check console for runtime errors**
   ```bash
   log show --predicate 'process == "Mail"' --last 5m
   ```

3. **Verify frameworks are linked**
   - MailKit.framework
   - CryptoKit.framework
   - CoreImage.framework

### Rebuild and Reinstall

If changes were made:

```bash
# 1. Clean build in Xcode (⇧⌘K)
# 2. Build (⌘B)
# 3. Remove old extension
rm -rf ~/Library/Mail/Bundles/EmailStampApp.appex

# 4. Run setup script again
./setup_mail_extension.sh

# 5. Restart Mail.app
killall Mail && open -a Mail
```

## Extension Type: Compose

The extension is configured as a **Compose** extension (`NSExtensionServiceRoleEditor`), which means it:

- Appears in compose windows
- Can modify email content
- Can add toolbar buttons
- Works while writing emails

## Current Configuration

✅ Extension name: "Email Stamp Extension"  
✅ Extension point: `com.apple.mail.extension`  
✅ Service role: Editor (Compose)  
✅ Principal class: `EmailStampExtension`  
✅ Capabilities: Compose Session  

## Next Steps After Setup

Once the extension appears in Extensions:

1. **Test in compose window**
   - Open new email
   - Extension should be available

2. **Implement MailKit methods**
   - Add toolbar buttons
   - Implement stamp functionality
   - Handle compose session events

3. **Customize behavior**
   - Add preferences
   - Configure stamp options
   - Add visual stamp selection

