//
//  AxeptioIntegrationTestsHelper.swift
//  AxeptioSDK Integration Tests
//
//  Created by Claude Sonnet 4.5 on 29/12/2024.
//  MSK-140: XCUITest-based integration tests for Axeptio SDK
//

import XCTest

/// Helper utilities for Axeptio integration tests
class AxeptioIntegrationTestsHelper {

    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - App Lifecycle

    /// Launch the app with clean state in portrait orientation
    func launchApp() {
        // Aggressively lock orientation to portrait
        XCUIDevice.shared.orientation = .portrait
        app.launch()

        // Re-enforce portrait multiple times during stabilization
        for _ in 0..<3 {
            sleep(1)
            if XCUIDevice.shared.orientation != .portrait {
                print("  [Debug] Correcting orientation back to portrait")
                XCUIDevice.shared.orientation = .portrait
            }
        }
    }

    /// Terminate and relaunch the app
    func relaunchApp() {
        app.terminate()
        sleep(1) // Wait for clean termination
        launchApp() // Use launchApp to get portrait locking
    }

    /// Force device to portrait orientation
    func enforcePortraitOrientation() {
        if XCUIDevice.shared.orientation != .portrait {
            print("  [Debug] Forcing portrait orientation")
            XCUIDevice.shared.orientation = .portrait
            sleep(1)
        }
    }

    /// Wait for the first element matching any of `labels` in any of `queries`.
    ///
    /// The `timeout` is a single budget shared across every label, not granted to each in
    /// turn: waiting `timeout` per label made a 5s call block for 15s across three labels.
    /// Polling (rather than an immediate `.exists` check) matters for web content, where the
    /// consent DOM is populated some time after the enclosing webview starts to exist.
    func waitForFirstMatch(
        labels: [String],
        in queries: [XCUIElementQuery],
        timeout: TimeInterval
    ) -> XCUIElement? {
        let deadline = Date().addingTimeInterval(timeout)

        repeat {
            for query in queries {
                for label in labels where query[label].exists {
                    return query[label]
                }
            }
            Thread.sleep(forTimeInterval: 0.25)
        } while Date() < deadline

        return nil
    }

    /// Tap a native (non-webview) button by accessibility identifier, falling back to a list
    /// of visible titles.
    ///
    /// Identifiers are the reliable path: the main screen retitles its consent button between
    /// TCF and Brands (see `ViewController.updateServiceSpecificButtons`), but the identifiers
    /// set in `loadBasicButtons` never change. Labels are kept only so the helper still works
    /// against an older build of the app that predates the identifiers.
    @discardableResult
    func tapNativeButton(
        identifier: String,
        fallbackLabels: [String] = [],
        timeout: TimeInterval = 5.0
    ) -> Bool {
        // One budget shared across the identifier and every fallback label.
        let deadline = Date().addingTimeInterval(timeout)

        let byId = app.buttons[identifier]
        if byId.waitForExistence(timeout: max(0, deadline.timeIntervalSinceNow)) {
            byId.tap()
            print("✅ Tapped button id='\(identifier)'")
            return true
        }

        for label in fallbackLabels {
            let button = app.buttons[label]
            if button.waitForExistence(timeout: max(0, deadline.timeIntervalSinceNow)) {
                button.tap()
                print("✅ Tapped button label='\(label)'")
                return true
            }
        }

        print("❌ Button not found (id='\(identifier)', labels=\(fallbackLabels.joined(separator: ", ")))")
        return false
    }

    /// Tap the "Consent pop up" button in sampleSwift to trigger widget display
    @discardableResult
    func tapShowConsentButton(timeout: TimeInterval = 5.0) -> Bool {
        tapNativeButton(
            identifier: "ax_showConsent",
            fallbackLabels: ["Consent pop up", "TCF Consent Dialog", "Brands Consent Dialog"],
            timeout: timeout
        )
    }

    /// Alias used by the Row J and re-open suites to manually display the consent widget.
    @discardableResult
    func tapDisplayConsentButton(timeout: TimeInterval = 5.0) -> Bool {
        tapShowConsentButton(timeout: timeout)
    }

    /// Tap the "Clear consent" button in sampleSwift to reset consent state
    @discardableResult
    func tapClearConsentButton(timeout: TimeInterval = 5.0) -> Bool {
        let tapped = tapNativeButton(
            identifier: "ax_clearConsent",
            fallbackLabels: ["Clear consent", "Clear Consent", "clear consent"],
            timeout: timeout
        )
        guard tapped else { return false }

        // Clearing presents a blocking "Consent Cleared Successfully" alert. Dismiss it and
        // confirm it is gone, rather than sleeping and hoping — a lingering alert swallows
        // every subsequent tap in the test.
        let alert = app.alerts.firstMatch
        guard alert.buttons["OK"].waitForExistence(timeout: 3.0) else {
            return true // no confirmation alert in this build — the clear tap still succeeded
        }
        alert.buttons["OK"].tap()

        let dismissed = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: alert as Any
        )
        if XCTWaiter().wait(for: [dismissed], timeout: 3.0) != .completed {
            print("⚠️ Consent-cleared alert did not dismiss")
        }
        return true
    }

    // MARK: - Widget Detection

    /// Check if the Axeptio consent widget is displayed
    /// - Parameter timeout: Maximum time to wait for widget (default: 5 seconds)
    /// - Returns: True if widget is visible
    func isWidgetDisplayed(timeout: TimeInterval = 5.0) -> Bool {
        // Look for WebView or consent-related elements
        let webView = app.webViews.firstMatch
        let exists = webView.waitForExistence(timeout: timeout)

        if exists {
            print("✅ Widget detected: WebView found")
            return true
        }

        // Alternative: Look for specific consent button text
        let acceptButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'accept' OR label CONTAINS[c] 'accepter'")).firstMatch
        if acceptButton.exists {
            print("✅ Widget detected: Accept button found")
            return true
        }

        print("❌ Widget not detected")
        return false
    }

    /// Wait for the widget to disappear
    /// - Parameter timeout: Maximum time to wait (default: 5 seconds)
    /// - Returns: True if widget is no longer visible
    func waitForWidgetToDisappear(timeout: TimeInterval = 5.0) -> Bool {
        let webView = app.webViews.firstMatch

        // Must be waitForNonExistence, not !waitForExistence: the latter returns true
        // immediately when the element is already on screen, so it reported "still visible"
        // without ever waiting, and conversely burned the whole timeout to report success
        // when the widget had never appeared at all.
        let disappeared = webView.waitForNonExistence(timeout: timeout)

        if disappeared {
            print("✅ Widget disappeared")
        } else {
            print("⚠️ Widget still visible after timeout")
        }

        return disappeared
    }

    // MARK: - Consent Actions

    /// Tap the "Accept" button in the consent widget
    /// Tries multiple language variants (English, French)
    /// - Parameter timeout: Maximum time to wait for button (default: 5 seconds)
    /// - Returns: True if button was found and tapped
    @discardableResult
    func tapAcceptButton(timeout: TimeInterval = 5.0) -> Bool {
        // `timeout` is a single budget covering both the webview appearing and its
        // buttons rendering, so the caller's number means what it says.
        let start = Date()

        // Wait for WebView to load
        let webView = app.webViews.firstMatch
        guard webView.waitForExistence(timeout: timeout) else {
            print("❌ WebView not found, cannot tap accept button")
            return false
        }

        // Try multiple button label variations
        let buttonLabels = [
            "OK!",                // Brands consent dialog
            "Accept",
            "Accept all",
            "Accepter",
            "Tout accepter",
            "J'accepte"
        ]

        // Poll for the remaining budget rather than checking .exists once: the webview
        // existing does not mean the consent DOM inside it has rendered yet.
        let remaining = max(0, timeout - Date().timeIntervalSince(start))
        if let button = waitForFirstMatch(
            labels: buttonLabels,
            in: [webView.buttons, app.buttons],
            timeout: remaining
        ) {
            button.tap()
            print("✅ Tapped accept button: '\(button.label)'")
            return true
        }

        // Try finding button with partial match
        let partialMatch = webView.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'accept'")).firstMatch
        if partialMatch.exists {
            partialMatch.tap()
            print("✅ Tapped accept button (partial match)")
            return true
        }

        print("❌ Accept button not found")
        return false
    }

    /// Tap the "Reject" button in the consent widget
    /// - Parameter timeout: Maximum time to wait for button (default: 5 seconds)
    /// - Returns: True if button was found and tapped
    @discardableResult
    func tapRejectButton(timeout: TimeInterval = 5.0) -> Bool {
        // As with tapAcceptButton, `timeout` covers both the webview appearing and its
        // buttons rendering.
        let start = Date()

        let webView = app.webViews.firstMatch
        guard webView.waitForExistence(timeout: timeout) else {
            print("❌ WebView not found, cannot tap reject button")
            return false
        }

        let buttonLabels = [
            "No, thanks",         // Brands consent dialog
            "Reject",
            "Reject all",
            "Refuser",
            "Tout refuser"
        ]

        let remaining = max(0, timeout - Date().timeIntervalSince(start))
        guard let button = waitForFirstMatch(
            labels: buttonLabels,
            in: [webView.buttons, app.buttons],
            timeout: remaining
        ) else {
            print("❌ Reject button not found")
            return false
        }

        button.tap()
        print("✅ Tapped reject button: '\(button.label)'")
        return true
    }

    // MARK: - Screenshots

    /// Take a screenshot with a descriptive name
    /// - Parameter name: Name for the screenshot
    /// - Returns: XCTAttachment with the screenshot
    @discardableResult
    func takeScreenshot(named name: String) -> XCTAttachment {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        print("📸 Screenshot taken: \(name)")
        return attachment
    }

    // MARK: - UserDefaults Helpers

    /// Clear all UserDefaults (requires app to expose this functionality)
    /// Note: This is a placeholder - actual implementation depends on app structure
    func clearUserDefaults() {
        // In a real scenario, you might need to:
        // 1. Uninstall/reinstall the app
        // 2. Have the app expose a debug API
        // 3. Use launch arguments to trigger reset

        print("⚠️ UserDefaults clearing requires app support or reinstall")
    }

    // MARK: - Wait Helpers

    /// Wait for a specific element to appear
    /// - Parameters:
    ///   - element: The UI element to wait for
    ///   - timeout: Maximum wait time
    /// - Returns: True if element appeared
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5.0) -> Bool {
        let exists = element.waitForExistence(timeout: timeout)
        if exists {
            print("✅ Element appeared: \(element.debugDescription)")
        } else {
            print("❌ Element did not appear within \(timeout)s")
        }
        return exists
    }
}
