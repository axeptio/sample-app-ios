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

    /// Wait for whichever of `candidates` shows up first, sharing one timeout budget.
    ///
    /// The primitive the rest of this helper is built on. `XCUIElement` is a lazy proxy — it
    /// re-queries the accessibility tree on each `.exists` — so a candidate list can be built
    /// up front and re-polled cheaply.
    ///
    /// Two properties matter, and both were bugs here at some point:
    ///
    /// - **One shared budget.** Waiting `timeout` on each candidate in turn makes a 5s call
    ///   block for 15s across three candidates, and — worse — lets an absent early candidate
    ///   swallow the whole budget so a later one that *is* present never gets looked at.
    /// - **Polling, not a single `.exists`.** Web content populates the consent DOM some time
    ///   after the enclosing webview begins to exist, so a one-shot check races the render.
    ///
    /// Candidates are probed in order on every pass, so earlier entries stay preferred without
    /// starving later ones.
    func waitForFirstExisting(_ candidates: [XCUIElement], timeout: TimeInterval) -> XCUIElement? {
        let deadline = Date().addingTimeInterval(timeout)

        repeat {
            for candidate in candidates where candidate.exists {
                return candidate
            }
            Thread.sleep(forTimeInterval: 0.25)
        } while Date() < deadline

        return nil
    }

    /// Convenience over `waitForFirstExisting` for the common "any of these labels, in any of
    /// these queries" case.
    func waitForFirstMatch(
        labels: [String],
        in queries: [XCUIElementQuery],
        timeout: TimeInterval
    ) -> XCUIElement? {
        // Ordered label-major so a preferred label wins over query order.
        let candidates = labels.flatMap { label in queries.map { $0[label] } }
        return waitForFirstExisting(candidates, timeout: timeout)
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
        // Probe the identifier and every fallback label on each poll pass, inside one budget.
        // Waiting on each in turn would let an absent identifier consume the whole timeout —
        // and the fallbacks exist precisely for the build where the identifier is missing, so
        // that ordering starves the only path that could have worked.
        let candidates = [app.buttons[identifier]] + fallbackLabels.map { app.buttons[$0] }

        if let button = waitForFirstExisting(candidates, timeout: timeout) {
            button.tap()
            print("✅ Tapped button '\(button.identifier.isEmpty ? button.label : button.identifier)'")
            return true
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

        // Alternative: look for consent button text. Deliberately broad — this is a
        // presence probe, not an action, so a dismiss control like "Close without accepting
        // cookies" matching is fine and still proves the widget is up. Do not copy the
        // stricter predicate from tapAcceptButton here.
        let consentButton = app.buttons.containing(
            NSPredicate(format: "label CONTAINS[c] 'accept' OR label CONTAINS[c] 'accepter'")
        ).firstMatch
        if consentButton.exists {
            print("✅ Widget detected: consent button found")
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

        // Exact labels, most-current first. These are web copy served from client.axept.io and
        // drift without any change here — "Accept all cookies" was observed live on
        // 2026-08-14, and none of the older entries matched it.
        let buttonLabels = [
            "Accept all cookies", // observed on the Brands widget, 2026-08-14
            "OK!",                // older Brands consent dialog
            "Accept",
            "Accept all",
            "Accepter",
            "Tout accepter",
            "J'accepte"
        ]

        // Exact labels first, then a substring match, all polled inside the same budget.
        //
        // The substring probes are not a last resort — they are load-bearing. The labels above
        // are copy served from client.axept.io, so the widget team can change them without any
        // change in this repository. That has already happened: a verification run tapped
        // accept via the substring probe, not the list. Leaving substring matching as a
        // one-shot check *after* the budget expired meant every copy change cost a full
        // timeout before the thing that actually works was tried.
        // The negation clause is not defensive padding — it is the whole point. A bare
        // `label CONTAINS[c] 'accept'` also matches "Close without accepting cookies", which
        // is a dismiss control and the opposite of consent. That was live: a verification run
        // reported "Tapped accept button" having pressed exactly that, because the old code
        // logged "(partial match)" without the label and hid it.
        let substring = NSPredicate(
            format: """
                (label CONTAINS[c] 'accept' OR label CONTAINS[c] 'accepter' OR label CONTAINS[c] 'agree') \
                AND NOT (label CONTAINS[c] 'without' OR label CONTAINS[c] 'sans' \
                OR label CONTAINS[c] "n'accepte" OR label CONTAINS[c] 'refuse')
                """
        )
        let candidates =
            buttonLabels.flatMap { [webView.buttons[$0], app.buttons[$0]] }
            + [webView.buttons.containing(substring).firstMatch,
               app.buttons.containing(substring).firstMatch]

        let remaining = max(0, timeout - Date().timeIntervalSince(start))
        guard let button = waitForFirstExisting(candidates, timeout: remaining) else {
            print("❌ Accept button not found")
            return false
        }

        button.tap()
        print("✅ Tapped accept button: '\(button.label)'")
        return true
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

        // Same reasoning as tapAcceptButton: exact labels plus a substring probe, one budget.
        // Reject previously had no substring fallback at all, so a copy change on the widget
        // side failed it outright rather than degrading.
        let substring = NSPredicate(
            format: "label CONTAINS[c] 'reject' OR label CONTAINS[c] 'refuser' OR label CONTAINS[c] 'no, thanks'"
        )
        let candidates =
            buttonLabels.flatMap { [webView.buttons[$0], app.buttons[$0]] }
            + [webView.buttons.containing(substring).firstMatch,
               app.buttons.containing(substring).firstMatch]

        let remaining = max(0, timeout - Date().timeIntervalSince(start))
        guard let button = waitForFirstExisting(candidates, timeout: remaining) else {
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
