#!/bin/bash

echo "🔍 Checking Code Signing Setup for Email Stamp Extension"
echo "========================================================="
echo ""

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode not found. Please install Xcode from the App Store."
    exit 1
else
    echo "✅ Xcode found: $(xcodebuild -version | head -1)"
fi

echo ""
echo "📋 Available Code Signing Identities:"
echo "--------------------------------------"
security find-identity -v -p codesigning | grep "Developer" || echo "⚠️  No Developer certificates found"

echo ""
echo "📦 Project Code Signing Settings:"
echo "----------------------------------"
cd "$(dirname "$0")"
if [ -f "EmailStampApp.xcodeproj/project.pbxproj" ]; then
    xcodebuild -project EmailStampApp.xcodeproj -target EmailStampApp -showBuildSettings 2>/dev/null | grep -E "(CODE_SIGN|DEVELOPMENT_TEAM|PRODUCT_BUNDLE_IDENTIFIER)" | head -10 || echo "⚠️  Could not read project settings"
else
    echo "❌ Project file not found"
fi

echo ""
echo "📄 Entitlements File:"
echo "---------------------"
if [ -f "EmailStampApp.entitlements" ]; then
    echo "✅ Entitlements file found"
    plutil -lint EmailStampApp.entitlements 2>&1 && echo "✅ Entitlements file is valid" || echo "❌ Entitlements file has errors"
else
    echo "❌ Entitlements file not found"
fi

echo ""
echo "💡 Next Steps:"
echo "--------------"
echo "1. Open the project in Xcode:"
echo "   open EmailStampApp.xcodeproj"
echo ""
echo "2. Select the EmailStampApp target"
echo ""
echo "3. Go to 'Signing & Capabilities' tab"
echo ""
echo "4. Check 'Automatically manage signing'"
echo ""
echo "5. Select your Development Team from the dropdown"
echo ""
echo "6. Build the project (⌘B)"

