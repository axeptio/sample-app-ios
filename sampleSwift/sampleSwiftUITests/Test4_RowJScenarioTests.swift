//
//  Test4_RowJScenarioTests.swift
//  AxeptioSDK Integration Tests
//
//  Test Scenario 4: Row J Scenario (MSK-142 Fix)
//  Validates widget auto-display when ATT denied + flag enabled + no consent
//
//  Created by Claude Code on 2025-12-31.
//  MSK-142: Row J bug fix validation
//
//  IMPORTANT: Full Row J testing requires:
//  1. Device/simulator with ATT status = .denied
//  2. allowPopupDisplayWithRejectedDeviceTrackingPermissions = true in config
//  3. No existing consent data
//
//  This test validates the core behavior (auto-display with no consent).
//  Manual testing required to verify the complete Row J scenario with actual ATT denial.
//

import XCTest

class Test4_RowJScenarioTests: XCTestCase {

    var app: XCUIApplication!
    var helper: AxeptioIntegrationTestsHelper!

    override func setUpWithError() throws {
        // Stop immediately when a failure occurs
        continueAfterFailure = false

        // Lock device to portrait orientation
        XCUIDevice.shared.orientation = .portrait

        // Initialize app
        app = XCUIApplication()
        helper = AxeptioIntegrationTestsHelper(app: app)
    }

    override func tearDownWithError() throws {
        // Terminate app after each test
        app.terminate()
        app = nil
        helper = nil
    }

    // MARK: - Row J Core Behavior: Auto-Display with No Consent

    func testRowJ_AutoDisplayWithNoConsent() throws {
        // Test validates the core Row J behavior: auto-display when no consent exists
        // Full Row J scenario (ATT denied + flag enabled) requires manual testing
        print("🧪 Test 4.1: Row J - Auto-Display with No Consent")

        // Given: App launches and consent is cleared
        print("  Launching app...")
        helper.launchApp()
        sleep(2)

        // Clear existing consent to simulate "no consent" state
        print("  Clearing consent...")
        helper.tapClearConsentButton(timeout: 3.0)
        sleep(1)

        // Terminate to reset state
        print("  Terminating app...")
        app.terminate()
        sleep(2)

        // When: App relaunches with no consent
        print("  Relaunching app with no consent...")
        helper.launchApp()
        sleep(2)

        // Then: Widget should auto-display (Row J behavior)
        let widgetDisplayed = helper.isWidgetDisplayed(timeout: 5.0)
        XCTAssertTrue(widgetDisplayed, "Widget should auto-display when no consent exists (Row J core behavior)")

        // Take screenshot for visual verification
        let screenshot = helper.takeScreenshot(named: "Test4_RowJ_AutoDisplay_NoConsent")
        add(screenshot)

        print("✅ Test 4.1 Passed: Widget auto-displayed with no consent")
    }

    // MARK: - Row J User Interaction: Consent Sent Only on User Action

    func testRowJ_ConsentSentOnUserActionOnly() throws {
        // Validates that consent is NOT auto-sent, only sent after user action
        print("🧪 Test 4.2: Row J - Consent Sent Only on User Action")

        // Given: App launches with no consent
        helper.launchApp()
        sleep(2)

        helper.tapClearConsentButton(timeout: 3.0)
        sleep(1)

        app.terminate()
        sleep(2)

        helper.launchApp()
        sleep(2)

        // Verify widget displays
        XCTAssertTrue(helper.isWidgetDisplayed(timeout: 5.0), "Widget should auto-display")

        // Wait a few seconds to ensure NO automatic consent submission occurs
        print("  Waiting to verify no automatic consent submission...")
        sleep(3)

        // Note: Without backend verification, we can only verify the widget is displayed
        // and no crash/freeze occurs. Actual consent submission verification requires
        // either network monitoring or backend integration.

        // The defining assertion of this test — that consent is NOT transmitted before the
        // user acts — cannot be made from a UI test: it needs network interception or
        // backend verification. Reporting a pass here would claim Row J coverage the suite
        // does not actually have, so skip explicitly once the verifiable part is done.
        throw XCTSkip(
            "Partial verification only: widget displayed without crash, but 'no automatic "
            + "consent submission' requires network or backend verification."
        )
    }

    // MARK: - Row J Manual Display: Button Click Should Work

    func testRowJ_ManualDisplayWorks() throws {
        // Validates that manual "Display Consent" button works in Row J scenario
        print("🧪 Test 4.3: Row J - Manual Display Works")

        // Given: App launches with consent cleared
        helper.launchApp()
        sleep(2)

        helper.tapClearConsentButton(timeout: 3.0)
        sleep(1)

        // When: User taps "Display Consent" button manually
        print("  Tapping Display Consent button...")
        helper.tapShowConsentButton(timeout: 3.0)
        sleep(2)

        // Then: Widget should display
        let widgetDisplayed = helper.isWidgetDisplayed(timeout: 5.0)
        XCTAssertTrue(widgetDisplayed, "Widget should display when triggered manually in Row J scenario")

        // Take screenshot
        let screenshot = helper.takeScreenshot(named: "Test4_RowJ_ManualDisplay")
        add(screenshot)

        print("✅ Test 4.3 Passed: Manual display works in Row J scenario")
    }

    // MARK: - Documentation Test: Full Row J Manual Testing Instructions

    func testRowJ_ManualTestingInstructions() throws {
        // This test provides instructions for complete Row J manual validation
        print("📋 Row J Manual Testing Instructions:")
        print("   1. Configure device/simulator with ATT tracking authorization = .denied")
        print("   2. In sample app, enable 'Allow Popup With Rejected ATT' toggle")
        print("   3. Clear all consent data")
        print("   4. Force quit and relaunch app")
        print("   5. VERIFY: Widget auto-displays on launch")
        print("   6. VERIFY: Consent is NOT automatically sent")
        print("   7. VERIFY: Consent is sent only after user accepts/rejects")
        print("")
        print("   Full Row J scenario cannot be automated due to ATT system limitations.")
        print("   These integration tests validate core behavior components.")

        // Always pass - this is documentation
        XCTAssertTrue(true, "Manual testing instructions provided")
    }
}
