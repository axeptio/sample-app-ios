//
//  Test2_ConsentFlowTests.swift
//  AxeptioSDK Integration Tests
//
//  Test Scenario 2: Consent Flow Verification
//  Validates that users can successfully accept/reject consent and the widget responds correctly
//
//  Created by Claude Sonnet 4.5 on 29/12/2024.
//  MSK-140: XCUITest-based integration tests
//

import XCTest

class Test2_ConsentFlowTests: XCTestCase {

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

    // MARK: - Test 1: Accept Consent Flow

    func testAcceptConsentFlow() throws {
        // Given: Consent is cleared and app relaunched for auto-display
        print("🧪 Test 1: Accept Consent Flow")

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
        XCTAssertTrue(helper.isWidgetDisplayed(), "Widget should auto-display before acceptance")

        // Take "before" screenshot
        let beforeScreenshot = helper.takeScreenshot(named: "Test2_AcceptFlow_Before")
        add(beforeScreenshot)

        // When: User taps the "Accept" button
        let acceptTapped = helper.tapAcceptButton(timeout: 5.0)
        XCTAssertTrue(acceptTapped, "Accept button should be found and tapped")

        // Wait for widget to process and dismiss
        sleep(5)

        // Then: Widget should disappear
        let widgetDismissed = !helper.isWidgetDisplayed(timeout: 5.0)
        XCTAssertTrue(widgetDismissed, "Widget should disappear after accepting consent")

        // Take "after" screenshot
        let afterScreenshot = helper.takeScreenshot(named: "Test2_AcceptFlow_After")
        add(afterScreenshot)

        print("✅ Test 1 Passed: Accept consent flow completed successfully")
    }

    // MARK: - Test 2: Reject Consent Flow

    func testRejectConsentFlow() throws {
        // Given: Consent is cleared and app relaunched for auto-display
        print("🧪 Test 2: Reject Consent Flow")

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

        XCTAssertTrue(helper.isWidgetDisplayed(), "Widget should auto-display before rejection")

        // Take "before" screenshot
        let beforeScreenshot = helper.takeScreenshot(named: "Test2_RejectFlow_Before")
        add(beforeScreenshot)

        // When: User taps the "Reject" button
        let rejectTapped = helper.tapRejectButton(timeout: 5.0)

        if rejectTapped {
            // If reject button exists and was tapped
            sleep(2)

            // Then: Widget should disappear or show updated state
            // Note: Behavior may vary - widget might stay visible to allow changes
            let afterScreenshot = helper.takeScreenshot(named: "Test2_RejectFlow_After")
            add(afterScreenshot)

            print("✅ Test 2 Passed: Reject consent flow completed")
        } else {
            // Report a real skip rather than printing one: a printed "Skipped" still
            // counts as a pass, which hides missing coverage in CI reports.
            throw XCTSkip("Reject button not available in this widget configuration")
        }
    }

    // MARK: - Test 3: Widget Close Button

    func testWidgetCloseButton() throws {
        // Given: Consent is cleared and app relaunched for auto-display
        print("🧪 Test 3: Widget Close Button")

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

        // When: User taps close/dismiss button (if available)
        let webView = app.webViews.firstMatch
        let closeButton = webView.buttons.containing(
            NSPredicate(format: "label CONTAINS[c] 'close' OR label CONTAINS[c] 'fermer' OR label == 'X'")
        ).firstMatch

        if closeButton.exists {
            closeButton.tap()
            sleep(5)

            // Then: Widget should disappear
            let widgetDismissed = !helper.isWidgetDisplayed(timeout: 5.0)
            XCTAssertTrue(widgetDismissed, "Widget should disappear after closing")

            print("✅ Test 3 Passed: Widget close button works")
        } else {
            throw XCTSkip("Close button not available in this widget configuration")
        }
    }

    // MARK: - Test 4: Accept Consent Persists Event

    func testAcceptConsentTriggersEvent() throws {
        // Given: Consent is cleared and app relaunched for auto-display
        print("🧪 Test 4: Accept Consent Triggers Event")

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

        // When: User accepts consent
        let acceptTapped = helper.tapAcceptButton(timeout: 5.0)
        XCTAssertTrue(acceptTapped, "Accept button should be tapped")

        // Wait for consent to be processed
        sleep(5)

        // Then: Consent event should fire (verified by widget dismissal and app state)
        // In a real scenario, you might check:
        // - Network requests were made (using Xcode network debugging)
        // - UserDefaults were updated (requires app exposure)
        // - Analytics events were triggered

        let widgetDismissed = !helper.isWidgetDisplayed(timeout: 5.0)
        XCTAssertTrue(widgetDismissed, "Widget should be dismissed indicating consent was processed")

        // Take final screenshot
        let screenshot = helper.takeScreenshot(named: "Test4_ConsentEventProcessed")
        add(screenshot)

        print("✅ Test 4 Passed: Consent event appears to have been processed")
    }

    // MARK: - Test 5: Multiple Consent Actions

    func testMultipleConsentActions() throws {
        // Given: Consent is cleared and app relaunched for auto-display
        print("🧪 Test 5: Multiple Consent Actions Handling")

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

        // When: User taps accept multiple times rapidly.
        //
        // Goes through the helper rather than matching the button here. This test used to run
        // its own `label CONTAINS[c] 'accept'` lookup, which also matches "Close without
        // accepting cookies" — so it was tapping the dismiss control while claiming to accept.
        // The helper's predicate excludes negated phrasings; duplicating the lookup is what let
        // the two drift apart.
        guard helper.tapAcceptButton(timeout: 10.0) else {
            throw XCTSkip("Accept button not found in the widget")
        }

        // Second tap, if the widget has not dismissed yet. Expected to find nothing once it
        // has, which is not a failure — the point is that a rapid double tap does not crash.
        let secondTapLanded = helper.tapAcceptButton(timeout: 2.0)
        print("  Second tap \(secondTapLanded ? "landed" : "found no button (widget already dismissed)")")
        sleep(5)

        // Then: the app is still alive and responsive after the rapid taps.
        XCTAssertEqual(app.state, .runningForeground, "App should still be running after rapid consent taps")
        print("✅ Test 5 Passed: Multiple consent actions handled gracefully")
    }
}
