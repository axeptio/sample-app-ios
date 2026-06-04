//
//  Test0_DiagnosticTest.swift
//  AxeptioSDK Integration Tests
//
//  Diagnostic test to verify button detection and orientation fixes
//  Run this single test first to diagnose issues before running full suite
//
//  Created by Claude Sonnet 4.5 on 29/12/2024.
//  MSK-140: XCUITest diagnostic utilities
//

import XCTest

class Test0_DiagnosticTest: XCTestCase {

    var app: XCUIApplication!
    var helper: AxeptioIntegrationTestsHelper!

    override func setUpWithError() throws {
        continueAfterFailure = false

        // Lock device to portrait orientation
        XCUIDevice.shared.orientation = .portrait

        app = XCUIApplication()
        helper = AxeptioIntegrationTestsHelper(app: app)
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
        helper = nil
    }

    // MARK: - Diagnostic Test: Button Detection

    func testDiagnostic_ClearConsentButtonDetection() throws {
        // Diagnostic test to verify Clear consent button can be found
        print("🔍 Diagnostic Test: Clear Consent Button Detection")

        // Launch app
        print("  [1/4] Launching app...")
        helper.launchApp()
        sleep(2)

        // Check orientation
        let orientation = XCUIDevice.shared.orientation
        print("  [2/4] Device orientation: \(orientation.rawValue) (portrait=1)")
        XCTAssertEqual(orientation, .portrait, "Device should be in portrait orientation")

        // Try to find and tap clear consent button
        print("  [3/4] Attempting to find Clear consent button...")
        let clearResult = helper.tapClearConsentButton(timeout: 5.0)

        // Take screenshot regardless of result
        let screenshot = helper.takeScreenshot(named: "Diagnostic_ClearConsent_\(clearResult ? "Success" : "Failed")")
        add(screenshot)

        print("  [4/4] Result: \(clearResult ? "✅ SUCCESS" : "❌ FAILED")")

        if clearResult {
            print("  ✅ Diagnostic PASSED: Clear consent button was found and tapped")
        } else {
            print("  ❌ Diagnostic FAILED: Clear consent button was NOT found")
            print("  Check the screenshot and debug output above to see what buttons are available")
        }

        // Don't fail the test - this is diagnostic only
        // XCTAssertTrue(clearResult, "Clear consent button should be found")
    }

    // MARK: - Diagnostic Test: Widget Auto-Display

    func testDiagnostic_WidgetAutoDisplay() throws {
        // Diagnostic test to verify widget auto-displays after clearing consent
        print("🔍 Diagnostic Test: Widget Auto-Display")

        // STEP 1: Launch and clear consent
        print("  [1/5] Launching app...")
        helper.launchApp()
        sleep(2)

        print("  [2/5] Clearing consent...")
        let clearResult = helper.tapClearConsentButton(timeout: 5.0)

        let screenshot1 = helper.takeScreenshot(named: "Diagnostic_AutoDisplay_1_AfterClear")
        add(screenshot1)

        if !clearResult {
            print("  ⚠️ Could not clear consent - skipping rest of test")
            return
        }

        // STEP 2: Terminate app
        print("  [3/5] Terminating app...")
        app.terminate()
        sleep(2)

        // STEP 3: Relaunch for auto-display
        print("  [4/5] Relaunching app for auto-display...")
        helper.launchApp()
        sleep(3)

        // STEP 4: Check if widget displays
        print("  [5/5] Checking if widget auto-displays...")
        let widgetDisplayed = helper.isWidgetDisplayed(timeout: 5.0)

        let screenshot2 = helper.takeScreenshot(named: "Diagnostic_AutoDisplay_2_AfterRelaunch")
        add(screenshot2)

        if widgetDisplayed {
            print("  ✅ Diagnostic PASSED: Widget auto-displayed after clearing consent")
        } else {
            print("  ❌ Diagnostic FAILED: Widget did NOT auto-display")
            print("  This suggests either:")
            print("    - Consent was not actually cleared")
            print("    - Widget configuration doesn't auto-display")
            print("    - App state issue")
        }

        // Don't fail the test - this is diagnostic only
        // XCTAssertTrue(widgetDisplayed, "Widget should auto-display after clearing consent")
    }

    // MARK: - Diagnostic Test: Portrait Orientation Lock

    func testDiagnostic_PortraitOrientationLock() throws {
        // Diagnostic test to verify orientation stays portrait
        print("🔍 Diagnostic Test: Portrait Orientation Lock")

        print("  [1/4] Initial orientation: \(XCUIDevice.shared.orientation.rawValue)")

        print("  [2/4] Launching app...")
        helper.launchApp()

        sleep(2)
        let orientationAfterLaunch = XCUIDevice.shared.orientation
        print("  [3/4] Orientation after launch: \(orientationAfterLaunch.rawValue) (portrait=1)")

        sleep(2)
        let orientationAfterWait = XCUIDevice.shared.orientation
        print("  [4/4] Orientation after 2s wait: \(orientationAfterWait.rawValue)")

        let screenshot = helper.takeScreenshot(named: "Diagnostic_Orientation")
        add(screenshot)

        if orientationAfterLaunch == .portrait && orientationAfterWait == .portrait {
            print("  ✅ Diagnostic PASSED: Orientation stayed portrait")
        } else {
            print("  ❌ Diagnostic FAILED: Orientation changed")
            print("    After launch: \(orientationAfterLaunch.rawValue)")
            print("    After wait: \(orientationAfterWait.rawValue)")
        }

        // Don't fail the test - this is diagnostic only
        // XCTAssertEqual(orientationAfterWait, .portrait, "Orientation should stay portrait")
    }
}
