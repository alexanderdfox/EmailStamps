# Enable Extension in Mail.app Extensions Settings

## ✅ Build Successful!

The extension has been built and is ready to install.

## Installation Steps

### Step 1: Grant Full Disk Access (if needed)

If you get "Operation not permitted" errors:

1. Open **System Settings** (or **System Preferences**)
2. Go to **Privacy & Security** → **Full Disk Access**
3. Click the **+** button
4. Add **Terminal** (or your terminal app)
5. Enable the toggle for Terminal
6. Try the installation again

### Step 2: Install Extension

**Option A: Manual Installation**

```bash
# Create directory (may need Full Disk Access)
mkdir -p ~/Library/Mail/Bundles

# Copy extension
cp -R ~/Desktop/minecraft/EmailStampApp/build/Debug/EmailStampApp.appex ~/Library/Mail/Bundles/

# Enable Mail extensions
defaults write com.apple.mail EnableBundles -bool true
defaults write com.apple.mail BundleCompatibilityVersion -string 14
```

**Option B: Use Finder**

1. Open Finder
2. Press **⌘⇧G** (Go to Folder)
3. Type: `~/Library/Mail/Bundles`
4. Create the folder if it doesn't exist
5. Copy `EmailStampApp.appex` from:
   ```
   ~/Desktop/minecraft/EmailStampApp/build/Debug/
   ```
6. Paste into `~/Library/Mail/Bundles/`

### Step 3: Restart Mail.app

```bash
killall Mail
open -a Mail
```

### Step 4: Enable in Mail.app Settings

1. Open **Mail.app**
2. Go to **Mail → Settings** (or **Preferences**)
3. Click the **Extensions** tab
4. Look for **"Email Stamp Extension"**
5. **Check the box** to enable it

### Step 5: Verify Extension Appears

The extension should now:
- ✅ Appear in the Extensions list
- ✅ Be enabled (checkbox checked)
- ✅ Be available in compose windows

## Extension Configuration

The extension is configured as:

- **Name**: Email Stamp Extension
- **Type**: Compose Extension (Editor)
- **Bundle ID**: `com.emailstamp.app.extension`
- **Extension Point**: `com.apple.mail.extension`
- **Principal Class**: `EmailStampExtension`

## Using the Extension

Once enabled:

1. **Open a new compose window** (⌘N)
2. The extension is available in the compose session
3. You can add toolbar buttons (right-click toolbar → Customize Toolbar)
4. The extension can modify email content

## Troubleshooting

### Extension Not in Extensions List

1. **Verify installation:**
   ```bash
   ls -la ~/Library/Mail/Bundles/EmailStampApp.appex
   ```

2. **Check Mail extension settings:**
   ```bash
   defaults read com.apple.mail EnableBundles
   # Should return: 1
   ```

3. **Check extension signature:**
   ```bash
   codesign -dv ~/Library/Mail/Bundles/EmailStampApp.appex
   ```

4. **Check Console logs:**
   ```bash
   log show --predicate 'process == "Mail"' --last 10m | grep -i "emailstamp"
   ```

### Permission Denied

If you can't create `~/Library/Mail/Bundles/`:

1. **Grant Full Disk Access** to Terminal/Xcode (see Step 1)
2. **Or use Finder** to create the folder manually
3. **Or use sudo** (not recommended, but works):
   ```bash
   sudo mkdir -p ~/Library/Mail/Bundles
   sudo cp -R build/Debug/EmailStampApp.appex ~/Library/Mail/Bundles/
   sudo chown -R $(whoami) ~/Library/Mail/Bundles/
   ```

### Extension Crashes

1. Check console logs for errors
2. Verify code signing
3. Check that all frameworks are linked
4. Verify macOS version (12.0+ required)

## Next Steps

Once the extension appears in Extensions:

1. **Test functionality** in compose window
2. **Implement MailKit methods** (when MailKit is properly configured)
3. **Add UI elements** (toolbar buttons, menu items)
4. **Customize behavior** (stamp options, preferences)

## Current Status

✅ Extension builds successfully  
✅ Info.plist properly configured  
✅ Extension structure ready  
✅ Installation script created  
⚠️ MailKit API implementation pending (structure ready)  
⚠️ Manual installation required (permission may be needed)

The extension will appear in **Mail → Settings → Extensions** once installed and Mail.app is restarted!

