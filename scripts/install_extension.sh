#!/bin/bash

echo "📦 Installing Email Stamp Extension to Mail.app..."
echo ""

# Create Mail Bundles directory
mkdir -p ~/Library/Mail/Bundles

# Find the built extension
EXT_PATH="build/Debug/EmailStampApp.appex"

if [ ! -d "$EXT_PATH" ]; then
    echo "❌ Extension not found at $EXT_PATH"
    echo "   Please build the project first (⌘B in Xcode)"
    exit 1
fi

# Remove old extension if exists
if [ -d ~/Library/Mail/Bundles/EmailStampApp.appex ]; then
    echo "🗑️  Removing old extension..."
    rm -rf ~/Library/Mail/Bundles/EmailStampApp.appex
fi

# Copy new extension
echo "📋 Copying extension..."
cp -R "$EXT_PATH" ~/Library/Mail/Bundles/

# Enable Mail extensions
echo "🔧 Enabling Mail extensions..."
defaults write com.apple.mail EnableBundles -bool true 2>/dev/null || true
defaults write com.apple.mail BundleCompatibilityVersion -string 14 2>/dev/null || true

echo ""
echo "✅ Extension installed!"
echo ""
echo "📍 Location: ~/Library/Mail/Bundles/EmailStampApp.appex"
echo ""
echo "⚠️  Please restart Mail.app:"
echo "   killall Mail && open -a Mail"
echo ""
echo "Then check: Mail → Settings → Extensions"

