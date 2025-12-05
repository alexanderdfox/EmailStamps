# Install Extension via Finder (No Terminal Permissions Needed)

If you're getting "Operation not permitted" errors, use Finder instead:

## Step 1: Locate the Extension

1. Open **Finder**
2. Navigate to:
   ```
   ~/Desktop/minecraft/EmailStampApp/build/Debug/
   ```
   Or press **⌘⇧G** and paste:
   ```
   /Users/alexanderfox/Desktop/minecraft/EmailStampApp/build/Debug
   ```
3. You should see **EmailStampApp.appex**

## Step 2: Create Mail Bundles Directory

1. In Finder, press **⌘⇧G** (Go to Folder)
2. Type: `~/Library/Mail/Bundles`
3. Click **Go**
4. If the folder doesn't exist, create it:
   - Right-click in the Library/Mail folder
   - Select **New Folder**
   - Name it **Bundles**

## Step 3: Copy Extension

1. **Copy** `EmailStampApp.appex` from the build/Debug folder
2. **Paste** it into `~/Library/Mail/Bundles/`
3. You should now have:
   ```
   ~/Library/Mail/Bundles/EmailStampApp.appex
   ```

## Step 4: Enable Mail Extensions

**Option A: Via Mail.app (Recommended)**

1. Open **Mail.app**
2. Go to **Mail → Settings** (or **Preferences**)
3. Click **Extensions** tab
4. Mail.app will automatically detect the extension
5. **Check the box** to enable it

**Option B: Via Terminal (if you have permissions)**

```bash
defaults write com.apple.mail EnableBundles -bool true
defaults write com.apple.mail BundleCompatibilityVersion -string 14
```

## Step 5: Restart Mail.app

1. **Quit Mail.app** completely (⌘Q)
2. **Reopen Mail.app**
3. Go to **Mail → Settings → Extensions**
4. Your extension should appear!

## Verify Installation

Check that the extension exists:

```bash
ls -la ~/Library/Mail/Bundles/EmailStampApp.appex
```

If you see the file, installation was successful!

## Troubleshooting

### Extension Still Doesn't Appear

1. **Check file permissions:**
   - Right-click `EmailStampApp.appex`
   - Get Info
   - Make sure you have Read & Write access

2. **Check code signing:**
   - The extension must be properly signed
   - Build it in Xcode with your development team selected

3. **Check Console:**
   - Open **Console.app**
   - Filter by "Mail"
   - Look for errors related to your extension

### Mail.app Won't Enable Extensions

Some macOS versions require extensions to be enabled manually:

1. Open **Mail.app**
2. **Mail → Settings → Extensions**
3. If you see a message about enabling extensions, click **Enable**
4. You may need to enter your password

## Alternative: Use Xcode Run Script

Add this to Xcode to auto-install after each build:

1. Select **EmailStampApp** target
2. **Build Phases** → **+** → **New Run Script Phase**
3. Paste:
   ```bash
   mkdir -p ~/Library/Mail/Bundles
   cp -R "$BUILT_PRODUCTS_DIR/EmailStampApp.appex" ~/Library/Mail/Bundles/ 2>/dev/null || true
   ```
4. Move it **after** "Copy Bundle Resources"

Now every build auto-installs!

