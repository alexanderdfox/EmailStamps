#!/bin/bash

# Fixed installation script for Email Stamp Extension
# Run from: /Users/alexanderfox/Desktop/minecraft

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build/Debug"
EXT_NAME="EmailStampApp.appex"
TARGET_DIR="$HOME/Library/Mail/Bundles"

echo "📦 Installing Email Stamp Extension..."
echo ""

# Check if extension exists
if [ ! -d "$BUILD_DIR/$EXT_NAME" ]; then
    echo "❌ Extension not found at: $BUILD_DIR/$EXT_NAME"
    echo "   Please build the project first (⌘B in Xcode)"
    exit 1
fi

echo "✅ Found extension at: $BUILD_DIR/$EXT_NAME"
echo ""

# Try to create target directory
echo "📁 Creating Mail Bundles directory..."
if mkdir -p "$TARGET_DIR" 2>/dev/null; then
    echo "   ✅ Directory created"
else
    echo "   ⚠️  Could not create directory (permission issue)"
    echo ""
    echo "   Please create it manually:"
    echo "   1. Open Finder"
    echo "   2. Press ⌘⇧G (Go to Folder)"
    echo "   3. Type: ~/Library/Mail/Bundles"
    echo "   4. Create the folder if it doesn't exist"
    echo ""
    echo "   Or grant Terminal Full Disk Access:"
    echo "   System Settings → Privacy & Security → Full Disk Access → Add Terminal"
    exit 1
fi

# Remove old extension if exists
if [ -d "$TARGET_DIR/$EXT_NAME" ]; then
    echo "🗑️  Removing old extension..."
    rm -rf "$TARGET_DIR/$EXT_NAME"
fi

# Copy extension
echo "📋 Copying extension..."
if cp -R "$BUILD_DIR/$EXT_NAME" "$TARGET_DIR/" 2>/dev/null; then
    echo "   ✅ Extension copied to $TARGET_DIR/"
else
    echo "   ❌ Could not copy extension (permission issue)"
    echo ""
    echo "   Please copy manually:"
    echo "   1. Open Finder"
    echo "   2. Navigate to: $BUILD_DIR"
    echo "   3. Copy $EXT_NAME"
    echo "   4. Paste into: $TARGET_DIR"
    exit 1
fi

# Enable Mail extensions (try both methods)
echo ""
echo "🔧 Enabling Mail extensions..."

# Method 1: Direct defaults write (may not work due to sandboxing)
if defaults write com.apple.mail EnableBundles -bool true 2>/dev/null; then
    echo "   ✅ EnableBundles set"
else
    echo "   ⚠️  Could not set EnableBundles (Mail.app may be sandboxed)"
    echo "   This is OK - Mail.app will enable extensions automatically"
fi

if defaults write com.apple.mail BundleCompatibilityVersion -string 14 2>/dev/null; then
    echo "   ✅ BundleCompatibilityVersion set"
else
    echo "   ⚠️  Could not set BundleCompatibilityVersion"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "📍 Extension location: $TARGET_DIR/$EXT_NAME"
echo ""
echo "📋 Next steps:"
echo "   1. Restart Mail.app:"
echo "      killall Mail && open -a Mail"
echo ""
echo "   2. Enable extension in Mail.app:"
echo "      Mail → Settings → Extensions"
echo "      Find 'Email Stamp Extension' and check the box"
echo ""
echo "   3. Verify extension:"
echo "      ls -la $TARGET_DIR/$EXT_NAME"

