#!/bin/bash

echo "🔧 Fixing Xcode Logging Issue..."
echo ""

# Set the environment variable to prefer log streaming
defaults write com.apple.dt.Xcode IDEPreferLogStreaming -bool YES

echo "✅ Set IDEPreferLogStreaming=YES"
echo ""
echo "📋 Current setting:"
defaults read com.apple.dt.Xcode IDEPreferLogStreaming 2>/dev/null || echo "Not set"
echo ""
echo "⚠️  Please restart Xcode for changes to take effect"

