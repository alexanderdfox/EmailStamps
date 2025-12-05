#!/bin/bash

echo "🔧 Enabling Mail.app Extensions..."
echo ""

# Enable Mail extensions
defaults write com.apple.mail EnableBundles -bool true
defaults write com.apple.mail BundleCompatibilityVersion -string 14

echo "✅ Mail extensions enabled"
echo ""
echo "📋 Current settings:"
echo "   EnableBundles: $(defaults read com.apple.mail EnableBundles 2>/dev/null || echo 'Not set')"
echo "   BundleCompatibilityVersion: $(defaults read com.apple.mail BundleCompatibilityVersion 2>/dev/null || echo 'Not set')"
echo ""
echo "⚠️  Please restart Mail.app for changes to take effect"
echo "   Run: killall Mail && open -a Mail"

