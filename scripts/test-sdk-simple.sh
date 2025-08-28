#!/bin/bash

# Axeptio iOS SDK Testing Script (Simple Version)
# This script builds and runs the sample app with the test SDK version for QA testing

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_PATH="sampleSwift/sampleSwift.xcodeproj"
SCHEME="sampleSwift"
BUNDLE_ID="io.axeptio.sampleswift"
BUILD_CONFIG="Debug"

echo -e "${BLUE}📱 Axeptio iOS SDK v2.0.14 Testing Script${NC}"
echo -e "${YELLOW}This script will build and run the sample app with the test SDK${NC}\n"

# Find a default iPhone simulator
echo -e "${BLUE}🔍 Finding iPhone simulator...${NC}"

# Use a known working iPhone 14 simulator UDID
SIMULATOR_UDID="E14F31CA-C05B-4FA2-98D3-662D9B0A689C"
SIMULATOR_NAME="iPhone 14"

# Verify the simulator exists
if ! xcrun simctl list devices | grep -q "$SIMULATOR_UDID"; then
    # Fallback to first available iPhone (including Pro/Plus models)
    SIMULATOR_INFO=$(xcrun simctl list devices | grep -E "iPhone" | grep -v unavailable | head -n1)
    if [ -z "$SIMULATOR_INFO" ]; then
        echo -e "${RED}❌ No iPhone simulators found${NC}"
        echo "Please open Xcode and create an iPhone simulator"
        exit 1
    fi
    # Extract UDID (the part in parentheses)
    SIMULATOR_UDID=$(echo "$SIMULATOR_INFO" | sed -n 's/.*(\([^)]*\)).*/\1/p')
    SIMULATOR_NAME=$(echo "$SIMULATOR_INFO" | sed 's/ *(.*//' | sed 's/^ *//')
fi

echo -e "${GREEN}✅ Using simulator: $SIMULATOR_NAME${NC}"

# Boot simulator if needed
echo -e "${BLUE}🚀 Starting simulator...${NC}"
xcrun simctl boot "$SIMULATOR_UDID" 2>/dev/null || true

# Open Simulator app
open -a Simulator

# Wait for simulator to be ready
echo -e "${BLUE}⏳ Waiting for simulator to boot...${NC}"
xcrun simctl bootstatus "$SIMULATOR_UDID" -b

# Build the app
echo -e "${BLUE}🔨 Building sample app with SDK v2.0.14...${NC}"
echo -e "${YELLOW}⏱️  This may take a few minutes on first build...${NC}"

if xcodebuild -project "$PROJECT_PATH" \
               -scheme "$SCHEME" \
               -configuration "$BUILD_CONFIG" \
               -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
               -derivedDataPath "./build" \
               build > build.log 2>&1; then
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
else
    echo -e "${RED}❌ Build failed. Check build.log for details.${NC}"
    tail -n 20 build.log
    exit 1
fi

# Install the app
echo -e "${BLUE}📲 Installing app...${NC}"
xcrun simctl install "$SIMULATOR_UDID" "./build/Build/Products/$BUILD_CONFIG-iphonesimulator/sampleSwift.app"

# Launch the app
echo -e "${BLUE}🚀 Launching sample app...${NC}"
if xcrun simctl launch "$SIMULATOR_UDID" "$BUNDLE_ID" > /dev/null 2>&1; then
    echo -e "${GREEN}🎉 Sample app is now running!${NC}"
else
    echo -e "${RED}❌ Failed to launch app. It may already be running.${NC}"
fi

echo -e "\n${BLUE}📋 QA Testing Guide:${NC}"
echo -e "${YELLOW}1. Configuration Management:${NC}"
echo -e "   • Service type shown at top (Brands/TCF)"
echo -e "   • Tap '⚙️ Settings' to test different configurations"
echo -e "   • Try preset configurations and custom customer settings"
echo -e ""
echo -e "${YELLOW}2. NSDate Serialization Fix (MSK-84):${NC}"
echo -e "   • Tap 'Consent Debug Info' button"
echo -e "   • App should NOT crash with __NSTaggedDate error"
echo -e "   • Date values highlighted in orange, ISO8601 format"
echo -e ""
echo -e "${YELLOW}3. TCF Vendor API (MSK-83):${NC}"
echo -e "   • Switch to TCF mode if needed (Settings)"
echo -e "   • Tap '🏪 TCF Vendor API' button"
echo -e "   • Test specific vendor IDs and view consent data"
echo -e "   • Real-time updates as consent changes"
echo -e ""
echo -e "${YELLOW}4. Service Differentiation:${NC}"
echo -e "   • Brands: No vendor button, brands-specific features"
echo -e "   • TCF: Vendor button visible, TCF-specific features"
echo -e ""
echo -e "${YELLOW}5. SDK Version Check:${NC}"
echo -e "   • Verify SDK v2.0.14 is being used"
echo -e "   • Check Package.resolved shows correct version"
echo -e ""
echo -e "${BLUE}🔧 Troubleshooting:${NC}"
echo -e "   • View logs: xcrun simctl launch --console $SIMULATOR_UDID $BUNDLE_ID"
echo -e "   • Reset app: xcrun simctl uninstall $SIMULATOR_UDID $BUNDLE_ID"
echo -e "   • Clean build: rm -rf build/ && ./scripts/test-sdk-simple.sh"