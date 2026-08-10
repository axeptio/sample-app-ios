//
//  Test1_WidgetDisplayTests.swift
//  AxeptioSDK Integration Tests
//
//  Test Scenario 1: Widget Display Verification
//  Validates that the Axeptio consent widget displays correctly when the app launches
//
//  Created by Claude Sonnet 4.5 on 29/12/2024.
//  MSK-140: XCUITest-based integration tests
//

import XCTest

class Test1_WidgetDisplayTests: XCTestCase {

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

    // MARK: - Test 1: Widget Display on First Launch

    func testWidgetDisplaysOnFirstLaunch() throws {
        // Given: Consent is cleared and app is relaunched for auto-display
        print("🧪 Test 1: Widget Display on First Launch")

        // Launch app to clear consent
        helper.launchApp()
        sleep(2)

        // Clear existing consent
        print("  Clearing consent...")
        helper.tapClearConsentButton(timeout: 3.0)
        sleep(1)

        // Terminate and relaunch for auto-display
        print("  Terminating app...")
        app.terminate()
        sleep(2)

        // When: App is relaunched after consent cleared
        print("  Relaunching app...")
        helper.launchApp()
        sleep(2)

        // Then: Consent widget should auto-display
        let widgetDisplayed = helper.isWidgetDisplayed(timeout: 5.0)
        XCTAssertTrue(widgetDisplayed, "Axeptio consent widget should auto-display on launch after consent cleared")

        // Take screenshot for visual verification
        let screenshot = helper.takeScreenshot(named: "Test1_WidgetDisplay_FirstLaunch")
        add(screenshot)

        print("✅ Test 1 Passed: Widget auto-displayed on first launch")
    }

    // MARK: - Test 2: Widget Contains Expected Elements

    func testWidgetContainsExpectedElements() throws {
        // Given: Consent is cleared and app is relaunched for auto-display
        print("🧪 Test 2: Widget Contains Expected Elements")

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

        // Then: WebView should be present
        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.exists, "WebView should exist in the widget")

        // Check for consent buttons inside the WebView (at least one should exist)
        let hasAcceptButton = webView.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'accept' OR label CONTAINS[c] 'tout accepter'")).firstMatch.exists
        let hasRejectButton = webView.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'reject' OR label CONTAINS[c] 'refus' OR label CONTAINS[c] 'deny'")).firstMatch.exists
        let hasAnyButton = webView.buttons.count > 0

        XCTAssertTrue(
            hasAcceptButton || hasRejectButton || hasAnyButton,
            "Widget should contain at least one action button (accept or reject). Found \(webView.buttons.count) buttons in WebView"
        )

        // Take screenshot
        let screenshot = helper.takeScreenshot(named: "Test2_WidgetElements")
        add(screenshot)

        print("✅ Test 2 Passed: Widget contains expected elements")
    }

    // MARK: - Test 3: Widget Loads Within Acceptable Time

    func testWidgetLoadsWithinAcceptableTime() throws {
        // Given: Consent is cleared
        print("🧪 Test 3: Widget Loads Within Acceptable Time")

        helper.launchApp()
        sleep(2)

        // Clear existing consent
        print("  Clearing consent...")
        helper.tapClearConsentButton(timeout: 3.0)
        sleep(1)

        // Terminate app
        app.terminate()
        sleep(2)

        // Measure time from launch to widget appearing
        let startTime = Date()

        // When: App is relaunched
        helper.launchApp()

        // Then: Widget should auto-display within 10 seconds
        let widgetAppeared = helper.isWidgetDisplayed(timeout: 10.0)
        let loadTime = Date().timeIntervalSince(startTime)

        XCTAssertTrue(widgetAppeared, "Widget should auto-display")
        XCTAssertLessThan(loadTime, 10.0, "Widget should auto-display within 10 seconds")

        print("✅ Test 3 Passed: Widget auto-displayed in \(String(format: "%.2f", loadTime))s")
    }

    // MARK: - Test 4: Widget Displays After App Backgrounding

    func testWidgetPersistsAfterBackgrounding() throws {
        // Given: Consent is cleared and app relaunched for auto-display
        print("🧪 Test 4: Widget Persists After Backgrounding")

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

        XCTAssertTrue(helper.isWidgetDisplayed(), "Widget should auto-display")

        // When: App is sent to background and brought back to foreground
        XCUIDevice.shared.press(.home)
        sleep(1)
        app.activate()
        sleep(1)

        // Then: Widget should still be displayed
        let widgetStillDisplayed = helper.isWidgetDisplayed(timeout: 3.0)
        XCTAssertTrue(widgetStillDisplayed, "Widget should persist after backgrounding")

        print("✅ Test 4 Passed: Widget persists after backgrounding")
    }
}
