# Running Mail.app Extension from Xcode

## Important: Mail Extensions Don't Auto-Install

When you press **⌘R (Run)** in Xcode, Mail.app extensions are **NOT automatically installed** like regular apps. You need to manually install them.

## Quick Setup

### Option 1: Use the Install Script (Recommended)

1. **Build the project** in Xcode (⌘B)

2. **Run the install script:**
   ```bash
   cd EmailStampApp
   ./install_extension.sh
   ```

3. **Restart Mail.app:**
   ```bash
   killall Mail && open -a Mail
   ```

4. **Check Extensions:**
   - Open Mail.app
   - Go to **Mail → Settings → Extensions**
   - Look for "Email Stamp Extension"

### Option 2: Manual Installation

1. **Build in Xcode** (⌘B)

2. **Copy extension manually:**
   ```bash
   mkdir -p ~/Library/Mail/Bundles
   cp -R ~/Desktop/minecraft/EmailStampApp/build/Debug/EmailStampApp.appex ~/Library/Mail/Bundles/
   ```

3. **Enable extensions:**
   ```bash
   defaults write com.apple.mail EnableBundles -bool true
   defaults write com.apple.mail BundleCompatibilityVersion -string 14
   ```

4. **Restart Mail.app**

### Option 3: Create Xcode Run Script

Add a "Run Script" build phase to automatically install:

1. In Xcode, select the **EmailStampApp** target
2. Go to **Build Phases**
3. Click **+** → **New Run Script Phase**
4. Add this script:
   ```bash
   # Install Mail extension after build
   if [ -d "$BUILT_PRODUCTS_DIR/EmailStampApp.appex" ]; then
       mkdir -p ~/Library/Mail/Bundles
       rm -rf ~/Library/Mail/Bundles/EmailStampApp.appex
       cp -R "$BUILT_PRODUCTS_DIR/EmailStampApp.appex" ~/Library/Mail/Bundles/
       defaults write com.apple.mail EnableBundles -bool true
       defaults write com.apple.mail BundleCompatibilityVersion -string 14
       echo "✅ Extension installed to ~/Library/Mail/Bundles/"
   fi
   ```

## Verify Installation

After installing, verify:

```bash
# Check if extension exists
ls -la ~/Library/Mail/Bundles/EmailStampApp.appex

# Check Mail extension settings
defaults read com.apple.mail EnableBundles
defaults read com.apple.mail BundleCompatibilityVersion

# Check extension signature
codesign -dv ~/Library/Mail/Bundles/EmailStampApp.appex
```

## Debugging

If extension still doesn't appear:

1. **Check Console logs:**
   ```bash
   log show --predicate 'process == "Mail"' --last 10m | grep -i "emailstamp\|extension"
   ```

2. **Verify Info.plist:**
   - `NSPrincipalClass` should be `EmailStampExtension`
   - `NSExtensionPointIdentifier` should be `com.apple.mail.extension`

3. **Check bundle identifier:**
   - Should end with `.extension`
   - Should match your development team

4. **Restart Mail.app completely:**
   ```bash
   killall Mail
   sleep 2
   open -a Mail
   ```

## Workflow

For development, use this workflow:

1. Make code changes
2. Build (⌘B)
3. Run install script: `./install_extension.sh`
4. Restart Mail.app
5. Test in Mail.app

## Note

Mail.app extensions run **inside Mail.app's process**, not as a separate app. That's why Xcode's "Run" doesn't work the same way - there's no separate process to launch.

