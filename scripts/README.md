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
5. ✅ Date values should be highlighted in orange and show ISO8601 format

### 🆕 Feature: TCF Vendor API (MSK-83)
**Purpose**: TCF v2.0 compliance with vendor consent parsing

**New APIs Available**:
```swift
Axeptio.shared.getVendorConsents()      // [Int: Bool] - All vendor consents
Axeptio.shared.getConsentedVendors()    // [Int] - Consented vendor IDs  
Axeptio.shared.getRefusedVendors()      // [Int] - Refused vendor IDs
Axeptio.shared.isVendorConsented(123)   // Bool - Check specific vendor
```

**Test Steps**:
1. Configure app for **Publisher TCF** service (see Configuration Testing below)
2. "🏪 TCF Vendor API" button should be visible at bottom
3. Tap button to open vendor testing interface
4. ✅ Should show TCF vendor summary and real-time data
5. Test specific vendor IDs in the input field

### 🎛️ Enhanced Feature: Configuration Management
**Purpose**: Test different customer configurations without code changes

**Test Configurations**:
- **Brands vs TCF**: Switch between service types
- **Token Testing**: Test with/without tokens
- **Customer Projects**: Use real customer client IDs

**Test Steps**:
1. Tap "⚙️ Settings" button at bottom of main screen
2. Try preset configurations (Default Brands, Default TCF, etc.)
3. Create custom configuration with your customer's details
4. ✅ App should restart and show new service type at top
5. ✅ TCF vendor button should only appear for TCF service

## SDK Version Verification

The sample app is configured to use SDK v2.0.14 from the test branch:
- Check `Package.resolved` shows `"version": "2.0.14"`
- Build logs should show `AxeptioSDK: https://github.com/axeptio/axeptio-ios-sdk @ 2.0.14`

## Complete Testing Workflow

### 1. Basic Functionality Test
```bash
./scripts/test-sdk-simple.sh
```
1. App launches successfully
2. Shows service type at top (Brands/TCF)
3. Shows client configuration info

### 2. Configuration Testing
1. Tap "⚙️ Settings" button
2. Test preset configurations:
   - "Default Brands" → Should show Brands service, no vendor button
   - "Default TCF" → Should show TCF service, vendor button appears
3. Test custom configuration with your customer's details
4. Verify app restarts and shows new configuration

### 3. NSDate Fix Testing (MSK-84)
1. Tap "Consent Debug Info" button
2. App should not crash
3. Look for date-related entries (highlighted in orange)
4. Verify dates are in ISO8601 string format
5. Tap "Vendor APIs" button from debug view

### 4. TCF Vendor API Testing (MSK-83)
**Prerequisites**: Must be in TCF mode
1. Tap "🏪 TCF Vendor API" button (bottom of main screen)
2. Verify summary shows vendor counts
3. Test specific vendor ID in input field
4. View vendor lists (consented, refused, all)
5. Check real-time updates after consent changes

### 5. Service Differentiation Testing
**Brands Mode**:
- Main button: "Brands Consent Dialog"
- No TCF vendor button visible
- WebView opens brands-specific URL

**TCF Mode**:
- Main button: "TCF Consent Dialog"  
- TCF vendor button visible
- WebView opens TCF publisher URL
- Debug view highlights TCF vendor fields in blue

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

### Configuration changes not taking effect
- Close and reopen the app completely
- Check console logs for configuration debug output
- Verify settings were saved in Settings app

### View console logs
```bash
# Replace SIMULATOR_ID with actual ID from script output
xcrun simctl launch --console SIMULATOR_ID io.axeptio.sampleswift
```

### TCF vendor data appears empty
- Ensure you're in TCF mode (not Brands)
- Grant consent in the TCF dialog first
- Check that consent popup has appeared and been interacted with

### No simulators available
1. Open Xcode
2. Go to Window → Devices and Simulators
3. Click "+" to add a new iPhone simulator
4. Run script again

## Branch Information

- **Current branch**: `test/sdk-v2.0.14`
- **SDK version**: `2.0.14` (test release)
- **Base branch**: `develop`
- **Includes fixes**: MSK-84 (NSDate) + MSK-83 (TCF Vendor API)

## Support

If you encounter issues:
1. Check the build logs in `build.log`
2. Ensure Xcode and iOS Simulator are properly installed  
3. Try the troubleshooting steps above
4. Contact the development team with specific error messages