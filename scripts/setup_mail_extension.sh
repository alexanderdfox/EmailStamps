#!/bin/bash

echo "🔧 Setting up Mail Extension for Compose Window..."
echo ""

# Step 1: Enable Mail extensions
echo "1️⃣  Enabling Mail extensions..."
defaults write com.apple.mail EnableBundles -bool true 2>/dev/null || true
defaults write com.apple.mail BundleCompatibilityVersion -string 14 2>/dev/null || true

# Step 2: Create Mail Bundles directory
echo "2️⃣  Creating Mail Bundles directory..."
mkdir -p ~/Library/Mail/Bundles

# Step 3: Install extension if built
if [ -d "build/Debug/EmailStampApp.appex" ]; then
    echo "3️⃣  Installing extension..."
    rm -rf ~/Library/Mail/Bundles/EmailStampApp.appex
    cp -R build/Debug/EmailStampApp.appex ~/Library/Mail/Bundles/
    echo "   ✅ Extension installed to ~/Library/Mail/Bundles/"
else
    echo "3️⃣  ⚠️  Extension not found. Please build first (⌘B in Xcode)"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Restart Mail.app: killall Mail && open -a Mail"
echo "   2. Open Mail → Settings → Extensions"
echo "   3. Find 'Email Stamp Extension' and enable it"
echo "   4. Open a new compose window"
echo "   5. Right-click toolbar → Customize Toolbar"
echo "   6. Add the extension icon to the toolbar"
echo ""
echo "💡 The extension will appear in the Extensions tab once Mail.app is restarted"

