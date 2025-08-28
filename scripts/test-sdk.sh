#!/bin/bash

# Axeptio iOS SDK Testing Script
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

# Find available iOS simulators
echo -e "${BLUE}📱 Finding available iOS simulators...${NC}"
SIMULATORS=$(xcrun simctl list devices iPhone --json | jq -r '.devices | to_entries[] | select(.key | contains("iOS")) | .value[] | select(.isAvailable == true) | "\(.udid) \(.name) \(.state)"')

if [ -z "$SIMULATORS" ]; then
    echo -e "${RED}❌ No available iPhone simulators found${NC}"
    echo "Please open Xcode and create an iPhone simulator"
    exit 1
fi

echo -e "${GREEN}Available iPhone simulators:${NC}"
echo "$SIMULATORS" | nl -w2 -s'. '

# Let user select simulator or use first available
if [ -t 0 ]; then  # Check if running interactively
    echo -e "\n${YELLOW}Enter simulator number (or press Enter for first available):${NC} "
    read -r choice
else
    choice="1"
fi

if [ -z "$choice" ]; then
    choice="1"
fi

SELECTED_SIM=$(echo "$SIMULATORS" | sed -n "${choice}p")
if [ -z "$SELECTED_SIM" ]; then
    echo -e "${RED}❌ Invalid choice. Using first available simulator.${NC}"
    SELECTED_SIM=$(echo "$SIMULATORS" | head -n1)
fi

SIMULATOR_UDID=$(echo "$SELECTED_SIM" | awk '{print $1}')
SIMULATOR_NAME=$(echo "$SELECTED_SIM" | awk '{print $2, $3}')
SIMULATOR_STATE=$(echo "$SELECTED_SIM" | awk '{print $NF}')

echo -e "${GREEN}✅ Selected: $SIMULATOR_NAME ($SIMULATOR_UDID)${NC}"

# Boot simulator if not already running
if [ "$SIMULATOR_STATE" != "Booted" ]; then
    echo -e "${BLUE}🚀 Booting simulator...${NC}"
    xcrun simctl boot "$SIMULATOR_UDID"
fi

# Open Simulator app
echo -e "${BLUE}📱 Opening Simulator app...${NC}"
open -a Simulator

# Wait for simulator to be ready
echo -e "${BLUE}⏳ Waiting for simulator to be ready...${NC}"
sleep 5

# Build the app
echo -e "${BLUE}🔨 Building sample app with SDK v2.0.14...${NC}"
echo -e "${YELLOW}This may take a few minutes on first build...${NC}"

xcodebuild -project "$PROJECT_PATH" \
           -scheme "$SCHEME" \
           -configuration "$BUILD_CONFIG" \
           -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
           -derivedDataPath "./build" \
           build

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
else
    echo -e "${RED}❌ Build failed. Please check the errors above.${NC}"
    exit 1
fi

# Install the app
echo -e "${BLUE}📲 Installing app on simulator...${NC}"
xcrun simctl install "$SIMULATOR_UDID" "./build/Build/Products/$BUILD_CONFIG-iphonesimulator/sampleSwift.app"

# Launch the app
echo -e "${BLUE}🚀 Launching sample app...${NC}"
xcrun simctl launch "$SIMULATOR_UDID" "$BUNDLE_ID"

echo -e "${GREEN}🎉 Sample app is now running!${NC}"
echo -e "\n${BLUE}📋 Testing Instructions:${NC}"
echo -e "1. ${YELLOW}NSDate Fix Test:${NC} Tap 'Consent Debug Info' button - should not crash"
echo -e "2. ${YELLOW}Vendor Consent APIs:${NC} Test the new vendor consent methods"
echo -e "3. ${YELLOW}SDK Version:${NC} Check that SDK v2.0.14 is being used"
echo -e "\n${BLUE}💡 Pro tip:${NC} Use 'xcrun simctl launch --console $SIMULATOR_UDID $BUNDLE_ID' to see console logs"