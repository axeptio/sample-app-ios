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

    /// Tap the "Consent pop up" button in sampleSwift to trigger widget display
    @discardableResult
    func tapShowConsentButton(timeout: TimeInterval = 5.0) -> Bool {
        // Button label can be "Consent pop up", "TCF Consent Dialog", or "Brands Consent Dialog"
        let buttonLabels = [
            "Consent pop up",
            "TCF Consent Dialog",
            "Brands Consent Dialog"
        ]

        for label in buttonLabels {
            let button = app.buttons[label]
            if button.waitForExistence(timeout: timeout) {
                button.tap()
                print("✅ Tapped '\(label)' button to show widget")
                return true
            }
        }

        print("❌ Show consent button not found (tried: \(buttonLabels.joined(separator: ", ")))")
        return false
    }

    /// Tap the "Clear consent" button in sampleSwift to reset consent state
    @discardableResult
    func tapClearConsentButton(timeout: TimeInterval = 5.0) -> Bool {
        // Try multiple button label variations
        let buttonLabels = [
            "Clear consent",
            "Clear Consent",
            "clear consent"
        ]

        // Debug: report only the button count. Enumerating allElementsBoundByIndex
        // and reading each .label takes a fresh accessibility snapshot per element,
        // which throws "No matches found for Element at index N" whenever an element
        // goes stale mid-iteration (common once the consent webview is on screen).
        print("  [Debug] Available buttons: \(app.buttons.count)")

        for label in buttonLabels {
            let button = app.buttons[label]
            if button.waitForExistence(timeout: timeout / Double(buttonLabels.count)) {
                button.tap()
                print("✅ Tapped '\(label)' button")
                // Wait for the confirmation (button briefly shows "✅ Cleared!")
                sleep(1)
                return true
            }
        }

        // Try partial match as fallback
        let partialMatch = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'clear' AND label CONTAINS[c] 'consent'")).firstMatch
        if partialMatch.exists {
            partialMatch.tap()
            print("✅ Tapped clear consent button (partial match)")
            sleep(1)
            return true
        }

        print("❌ Clear consent button not found (tried: \(buttonLabels.joined(separator: ", ")))")
        return false
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
        let disappeared = !webView.waitForExistence(timeout: timeout)

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

        for label in buttonLabels {
            // Look in WebView first
            let button = webView.buttons[label]
            if button.exists {
                button.tap()
                print("✅ Tapped accept button: '\(label)'")
                return true
            }

            // Also check outside WebView (in case button is native)
            let nativeButton = app.buttons[label]
            if nativeButton.exists {
                nativeButton.tap()
                print("✅ Tapped native accept button: '\(label)'")
                return true
            }
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

        for label in buttonLabels {
            let button = webView.buttons[label]
            if button.exists {
                button.tap()
                print("✅ Tapped reject button: '\(label)'")
                return true
            }
        }

        print("❌ Reject button not found")
        return false
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
