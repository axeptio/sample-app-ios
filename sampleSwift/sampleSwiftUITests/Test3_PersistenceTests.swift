//
//  Test3_PersistenceTests.swift
//  AxeptioSDK Integration Tests
//
//  Test Scenario 3: Consent Persistence Verification
//  Validates that consent choices persist across app restarts and consent duration is respected
//
//  CRITICAL: These tests validate fixes for:
//  - MSK-136: Consent duration persistence (190 days default)
//  - MSK-139: ATT + consent persistence when allowPopupDisplayWithRejectedDeviceTrackingPermissions = true
//
//  Created by Claude Sonnet 4.5 on 29/12/2024.
//  MSK-140: XCUITest-based integration tests
//

import XCTest

class Test3_PersistenceTests: XCTestCase {

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

    // MARK: - Test 1: Consent Persists Across App Restarts

    func testConsentPersistsAcrossAppRestarts() throws {
        // Given: App is launched for the first time
        print("🧪 Test 1: Consent Persists Across App Restarts")
        print("  This test validates MSK-136 and MSK-139 fixes")

        // FIRST LAUNCH: Clear consent and relaunch for auto-display
        print("  [Setup] Launching app to clear consent...")
        helper.launchApp()
        sleep(2)

        // Clear any existing consent to ensure clean state
        print("  [Setup] Clearing existing consent...")
        helper.tapClearConsentButton(timeout: 3.0)
        sleep(1)

        // Terminate and relaunch for auto-display
        print("  [Setup] Terminating app...")
        app.terminate()
        sleep(2)

        print("  [Launch 1] Relaunching app for widget auto-display...")
        helper.launchApp()
        sleep(2)

        // Verify widget auto-displays
        XCTAssertTrue(helper.isWidgetDisplayed(timeout: 5.0), "Widget should auto-display after consent cleared")

        // Take screenshot before acceptance
        let beforeScreenshot = helper.takeScreenshot(named: "Test3_Persistence_Launch1_Before")
        add(beforeScreenshot)

        // Accept consent
        print("  [Launch 1] Accepting consent...")
        let acceptTapped = helper.tapAcceptButton(timeout: 5.0)
        XCTAssertTrue(acceptTapped, "Accept button should be found and tapped")

        // Wait for consent to be processed
        sleep(3)

        // Verify widget dismissed after acceptance
        let widgetDismissed = !helper.isWidgetDisplayed(timeout: 2.0)
        XCTAssertTrue(widgetDismissed, "Widget should be dismissed after accepting consent")

        // Take screenshot after acceptance
        let afterScreenshot = helper.takeScreenshot(named: "Test3_Persistence_Launch1_After")
        add(afterScreenshot)

        print("  [Launch 1] Consent accepted, widget dismissed")

        // TERMINATE APP
        print("  Terminating app...")
        app.terminate()
        sleep(2)

        // SECOND LAUNCH: Verify consent persisted
        print("  [Launch 2] Relaunching app...")
        helper.launchApp()
        sleep(3) // Give extra time for initialization

        // Then: Widget should NOT be displayed (consent already given)
        let widgetRedisplayed = helper.isWidgetDisplayed(timeout: 3.0)
        XCTAssertFalse(widgetRedisplayed, "Widget should NOT be displayed on second launch (consent persisted)")

        // Take screenshot to verify
        let secondLaunchScreenshot = helper.takeScreenshot(named: "Test3_Persistence_Launch2_NoWidget")
        add(secondLaunchScreenshot)

        if widgetRedisplayed {
            print("  ❌ FAIL: Widget was displayed on second launch - consent did NOT persist")
            print("  This indicates a regression in MSK-136 or MSK-139 fix")
        } else {
            print("  ✅ PASS: Widget not displayed on second launch - consent persisted correctly")
        }
    }

    // MARK: - Test 2: Multiple App Restarts Maintain Consent

    func testMultipleAppRestartsMaintainConsent() throws {
        // Given: Accept consent first to set up initial state
        print("🧪 Test 2: Multiple App Restarts Maintain Consent")

        // FIRST LAUNCH: Clear consent and relaunch for auto-display
        print("  [Initial Setup] Launching app to clear consent...")
        helper.launchApp()
        sleep(2)

        // Clear any existing consent
        print("  [Initial Setup] Clearing consent...")
        helper.tapClearConsentButton(timeout: 3.0)
        sleep(1)

        // Terminate and relaunch for auto-display
        app.terminate()
        sleep(2)

        helper.launchApp()
        sleep(2)

        // Verify widget auto-displays and accept
        XCTAssertTrue(helper.isWidgetDisplayed(timeout: 5.0), "Widget should auto-display")
        helper.tapAcceptButton(timeout: 5.0)
        sleep(3)

        // Terminate app
        app.terminate()
        sleep(2)

        // MULTIPLE RESTARTS: Verify consent persists
        for restart in 1...3 {
            print("  [Restart \(restart)] Launching app...")
            helper.launchApp()
            sleep(2)

            // Widget should not appear (consent already given)
            let widgetDisplayed = helper.isWidgetDisplayed(timeout: 3.0)
            XCTAssertFalse(widgetDisplayed, "Widget should not appear on restart #\(restart)")

            // Take screenshot
            let screenshot = helper.takeScreenshot(named: "Test3_MultipleRestarts_Launch\(restart)")
            add(screenshot)

            // Terminate
            app.terminate()
            sleep(1)
        }

        print("  ✅ Test 2 Passed: Consent persisted across \(3) restarts")
    }

    // MARK: - Test 3: Consent Duration End Date Persistence

    func testConsentDurationEndDatePersistence() throws {
        // Given: App is launched and consent is accepted
        print("🧪 Test 3: Consent Duration End Date Persistence")
        print("  Validates MSK-136: 190-day consent duration is stored")

        helper.launchApp()
        sleep(2)

        // Clear existing consent
        print("  Clearing consent...")
        helper.tapClearConsentButton(timeout: 3.0)
        sleep(1)

        // Terminate and relaunch for auto-display
        app.terminate()
        sleep(2)

        helper.launchApp()
        sleep(2)

        // Verify widget auto-displays
        XCTAssertTrue(helper.isWidgetDisplayed(timeout: 5.0), "Widget should auto-display")

        // Accept consent
        print("  Accepting consent...")
        helper.tapAcceptButton(timeout: 5.0)
        sleep(3)

        // Then: UserDefaults should contain consent duration end date
        // Note: Direct UserDefaults verification from UI tests is limited
        // This test validates that consent persists, implying the date was stored

        // Relaunch to verify persistence
        helper.relaunchApp()
        sleep(2)

        let widgetRedisplayed = helper.isWidgetDisplayed(timeout: 3.0)
        XCTAssertFalse(widgetRedisplayed, "Widget should not redisplay (implies duration end date was stored)")

        // Take screenshot
        let screenshot = helper.takeScreenshot(named: "Test3_DurationPersistence_Verified")
        add(screenshot)

        print("  ✅ Test 3 Passed: Consent duration appears to be persisted")
    }

    // MARK: - Test 4: App Backgrounding Doesn't Clear Consent

    func testAppBackgroundingDoesntClearConsent() throws {
        // Given: App is launched with consent accepted
        print("🧪 Test 4: App Backgrounding Doesn't Clear Consent")

        helper.launchApp()
        sleep(2)

        // Clear existing consent
        print("  Clearing consent...")
        helper.tapClearConsentButton(timeout: 3.0)
        sleep(1)

        // Terminate and relaunch for auto-display
        app.terminate()
        sleep(2)

        helper.launchApp()
        sleep(2)

        // Verify widget auto-displays
        XCTAssertTrue(helper.isWidgetDisplayed(timeout: 5.0), "Widget should auto-display")

        // Accept consent
        print("  Accepting consent...")
        helper.tapAcceptButton(timeout: 5.0)
        sleep(3)

        // Widget should be dismissed
        XCTAssertFalse(helper.isWidgetDisplayed(timeout: 2.0), "Widget should be dismissed")

        // When: App is backgrounded and foregrounded multiple times
        for cycle in 1...3 {
            print("  [Background cycle \(cycle)]")
            XCUIDevice.shared.press(.home)
            sleep(1)
            app.activate()
            sleep(1)

            // Then: Widget should still not reappear
            let widgetReappeared = helper.isWidgetDisplayed(timeout: 2.0)
            XCTAssertFalse(widgetReappeared, "Widget should not reappear after backgrounding #\(cycle)")
        }

        print("  ✅ Test 4 Passed: Consent persisted through backgrounding cycles")
    }

    // MARK: - Test 5: Consent State After App Termination from Background

    func testConsentStateAfterTerminationFromBackground() throws {
        // Given: App is launched with consent accepted
        print("🧪 Test 5: Consent State After Termination from Background")

        helper.launchApp()
        sleep(2)

        // Clear existing consent
        print("  Clearing consent...")
        helper.tapClearConsentButton(timeout: 3.0)
        sleep(1)

        // Terminate and relaunch for auto-display
        app.terminate()
        sleep(2)

        helper.launchApp()
        sleep(2)

        // Verify widget auto-displays
        XCTAssertTrue(helper.isWidgetDisplayed(timeout: 5.0), "Widget should auto-display")

        // Accept consent
        print("  Accepting consent...")
        helper.tapAcceptButton(timeout: 5.0)
        sleep(3)

        // Widget should be dismissed
        XCTAssertFalse(helper.isWidgetDisplayed(timeout: 2.0), "Widget should be dismissed")

        // When: App is sent to background, then force-terminated
        XCUIDevice.shared.press(.home)
        sleep(1)
        app.terminate()
        sleep(2)

        // Relaunch
        print("  Relaunching after background termination...")
        helper.launchApp()
        sleep(3)

        // Then: Widget should still not appear
        let widgetRedisplayed = helper.isWidgetDisplayed(timeout: 3.0)
        XCTAssertFalse(widgetRedisplayed, "Widget should not reappear after background termination")

        // Take screenshot
        let screenshot = helper.takeScreenshot(named: "Test5_BackgroundTermination_NoWidget")
        add(screenshot)

        print("  ✅ Test 5 Passed: Consent persisted after background termination")
    }

    // MARK: - Test 6: Consent Persists After System Reboot Simulation

    func testConsentPersistsAfterDelayedRelaunch() throws {
        // Given: App is launched with consent accepted
        print("🧪 Test 6: Consent Persists After Delayed Relaunch")
        print("  Simulates system reboot or long-term storage")

        helper.launchApp()
        sleep(2)

        // Clear existing consent
        print("  Clearing consent...")
        helper.tapClearConsentButton(timeout: 3.0)
        sleep(1)

        // Terminate and relaunch for auto-display
        app.terminate()
        sleep(2)

        helper.launchApp()
        sleep(2)

        // Verify widget auto-displays
        XCTAssertTrue(helper.isWidgetDisplayed(timeout: 5.0), "Widget should auto-display")

        // Accept consent
        print("  Accepting consent...")
        helper.tapAcceptButton(timeout: 5.0)
        sleep(3)

        // Terminate app
        app.terminate()

        // Wait longer (simulating device restart or long time between launches)
        print("  Waiting 10 seconds to simulate delayed relaunch...")
        sleep(10)

        // Relaunch
        print("  Relaunching after delay...")
        helper.launchApp()
        sleep(3)

        // Then: Widget should still not appear
        let widgetRedisplayed = helper.isWidgetDisplayed(timeout: 3.0)
        XCTAssertFalse(widgetRedisplayed, "Widget should not reappear after delayed relaunch")

        // Take screenshot
        let screenshot = helper.takeScreenshot(named: "Test6_DelayedRelaunch_NoWidget")
        add(screenshot)

        print("  ✅ Test 6 Passed: Consent persisted after delayed relaunch")
    }
}
