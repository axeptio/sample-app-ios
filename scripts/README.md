# QA Testing Scripts

Scripts to help QA team test the Axeptio iOS SDK v2.0.14 with critical fixes.

## Quick Start

```bash
# Navigate to the sample-app-ios directory
cd sample-app-ios

# Run the simple testing script
./scripts/test-sdk-simple.sh
```

## Scripts Available

### `test-sdk-simple.sh` (Recommended)
- **Purpose**: Build and run sample app with SDK v2.0.14 
- **Requirements**: Xcode, iOS Simulator
- **Usage**: `./scripts/test-sdk-simple.sh`
- **Features**: 
  - Automatically finds available iPhone simulator
  - Builds app with test SDK version
  - Installs and launches app
  - Provides testing instructions

### `test-sdk.sh` (Advanced)
- **Purpose**: Interactive script with simulator selection
- **Requirements**: Xcode, iOS Simulator, `jq` (install with `brew install jq`)
- **Usage**: `./scripts/test-sdk.sh`
- **Features**:
  - Lists all available simulators
  - Interactive simulator selection
  - More detailed output

## What's Being Tested

### 🔥 Critical Fix: NSDate Serialization (MSK-84)
**Problem**: Flutter apps crashed with `"Unsupported value: __NSTaggedDate"`  
**Fix**: Convert NSDate objects to ISO8601 strings in `getConsentDebugInfo()`

**Test Steps**:
1. Launch sample app
2. Tap "Consent Debug Info" button
3. ✅ **Should NOT crash** (previously would crash)
4. ✅ Debug data should display with proper date formatting

### 🆕 Feature: Vendor Consent APIs (MSK-83)
**Purpose**: TCF v2.0 compliance with vendor consent parsing

**New APIs Available**:
```swift
Axeptio.shared.getVendorConsents()      // [Int: Bool] - All vendor consents
Axeptio.shared.getConsentedVendors()    // [Int] - Consented vendor IDs  
Axeptio.shared.getRefusedVendors()      // [Int] - Refused vendor IDs
Axeptio.shared.isVendorConsented(123)   // Bool - Check specific vendor
```

## SDK Version Verification

The sample app is configured to use SDK v2.0.14 from the test branch:
- Check `Package.resolved` shows `"version": "2.0.14"`
- Build logs should show `AxeptioSDK: https://github.com/axeptio/axeptio-ios-sdk @ 2.0.14`

## Troubleshooting

### App won't build
```bash
# Clean build and try again
rm -rf build/
./scripts/test-sdk-simple.sh
```

### App won't launch
```bash
# Check if already running, uninstall and retry
SIMULATOR_ID="YOUR_SIMULATOR_ID"  # From script output
xcrun simctl uninstall $SIMULATOR_ID io.axeptio.sampleswift
./scripts/test-sdk-simple.sh
```

### View console logs
```bash
# Replace SIMULATOR_ID with actual ID from script output
xcrun simctl launch --console SIMULATOR_ID io.axeptio.sampleswift
```

### No simulators available
1. Open Xcode
2. Go to Window → Devices and Simulators
3. Click "+" to add a new iPhone simulator
4. Run script again

## Branch Information

- **Current branch**: `test/sdk-v2.0.14`
- **SDK version**: `2.0.14` (test release)
- **Base branch**: `develop`
- **Includes fixes**: MSK-84 (NSDate) + MSK-83 (Vendor Consent)

## Support

If you encounter issues:
1. Check the build logs in `build.log`
2. Ensure Xcode and iOS Simulator are properly installed  
3. Try the troubleshooting steps above
4. Contact the development team with specific error messages