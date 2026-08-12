//
//  Test5_ReopenConsentTests.swift
//  AxeptioSDK Integration Tests
//
//  Test Scenario 5: re-opening the CMP after the user has already answered it (SUP-1009)
//
//  Contract under test: showConsentScreen() must re-present the CMP when consent is already
//  stored AND we are still in the same app process. That is a documented, supported feature
//  ("Show Consent Popup on Demand" in the README).
//
//  ─────────────────────────────────────────────────────────────────────────────────────────
//  THESE TESTS ARE EXPECTED TO FAIL, and the cause is NOT in this repository.
//
//  They are therefore OPT-IN. Left ungated they would turn the nightly permanently red, which
//  trains everyone to ignore it — and a permanently red suite is worth less than no suite.
//
//  To run them, pass the flag through to the *test runner* process (a bare environment
//  variable on the xcodebuild invocation does not reach it):
//
//    TEST_RUNNER_AXEPTIO_RUN_REOPEN_TESTS=1 xcodebuild test \
//      -project sampleSwift.xcodeproj -scheme sampleSwift \
//      -destination 'platform=iOS Simulator,name=iPhone 16' \
//      -only-testing:sampleSwiftUITests/Test5_ReopenConsentTests \
//      -parallel-testing-enabled NO
//
//  Verified on 2026-08-12, iPhone 16 / iOS 26.5 simulator: the suite reaches the re-open
//  assertion — control step passes, widget renders, accept lands, widget closes — and then
//  fails waiting 25s for the CMP to come back. That is the ios-x6b signature, and it means
//  the native path is behaving.
//
//  Tracked upstream as bd ios-x6b. Measured on 2026-08-05, iPhone 16 / iOS 18.6, and
//  reproduced identically on the commit *before* the SUP-1009 native fix, which is what
//  rules the native side out:
//
//    load WITHOUT axeptio_token + showConsentManager=true → showCmp=true → displays  (3/3)
//    load WITH    axeptio_token (scm true or absent)      → cookies:close → never    (6/6)
//                                                            presented
//
//  On re-open the SDK does everything correctly — the URL carries showConsentManager=true,
//  navigation finishes — and then the web widget sends cookies:close ~1.4s later without ever
//  sending showCmp. The fault is on the widget side, served from client.axept.io.
//  ─────────────────────────────────────────────────────────────────────────────────────────
//
//  What a green run would and would not prove: this suite exercises the user-visible re-open
//  contract end to end against a real WKWebView and real UIKit presentation, which no mock
//  can do. It does not stand in for the SDK's own popup-lifecycle unit tests.
//
//  The test process cannot read the app's OSLog (separate processes, and no cross-process
//  OSLogStore on iOS). To correlate a failure with the SDK's own reasoning, capture the log
//  around the run — see "Diagnosing consent display in the field" in the README:
//
//    xcrun simctl spawn <udid> log stream --style compact --level debug \
//      --predicate 'subsystem == "io.axept.ios"' > axeptio.log &
//
//  Pass signature for the line emitted just after the manual re-open:
//    AXEPTIO_CMP_DECISION outcome=presented ... hasConsent=true ... forceShow=true
//
//  NOTE: run with -parallel-testing-enabled NO. The scheme marks this target parallelizable,
//  and Xcode then clones the simulator onto fresh UDIDs, so a log capture pinned to the
//  destination UDID would come back empty.
//

import XCTest

final class Test5_ReopenConsentTests: XCTestCase {

    var app: XCUIApplication!
    var helper: AxeptioIntegrationTestsHelper!

    // Widget boot is network-bound, and the SDK allows a 10s watchdog plus one
    // cache-bypassing retry (~20s worst case) before it gives up. Anything waiting on a
    // widget has to outlast that window, or a slow CDN gets reported as an SDK regression.
    private let widgetAppearTimeout: TimeInterval = 25
    private let widgetVanishTimeout: TimeInterval = 15
    private let acceptTapTimeout: TimeInterval = 10
    private let nativeButtonTimeout: TimeInterval = 10

    /// Deliberately shorter than `widgetAppearTimeout`, and not a mistake.
    ///
    /// This one is a *probe*, not a wait: it asks "did the widget auto-display, or is there
    /// stored consent from an earlier run?". When consent exists nothing will ever appear, so
    /// every second here is dead time added to each test. The full 25s budget exists for the
    /// case where we know a widget is coming; spending it on a question whose answer is
    /// usually "no" would add ~75s to the suite.
    ///
    /// A false negative is self-correcting rather than fatal — we clear consent, relaunch, and
    /// then wait the full `widgetAppearTimeout` — so the cost of being wrong is a slower test,
    /// not a wrong result. 15s is still an order of magnitude above the ~1.5s boot observed on
    /// device.
    private let initialProbeTimeout: TimeInterval = 15

    override func setUpWithError() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["AXEPTIO_RUN_REOPEN_TESTS"] == "1",
            "Set AXEPTIO_RUN_REOPEN_TESTS=1 to run the SUP-1009 re-open suite. It is expected "
            + "to fail until bd ios-x6b is fixed on the web-widget side — see the file header."
        )

        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        app = XCUIApplication()
        helper = AxeptioIntegrationTestsHelper(app: app)
    }

    override func tearDownWithError() throws {
        // tearDown still runs when setUp throws XCTSkip, at which point `app` was never
        // assigned — terminating an implicitly-unwrapped nil would crash the run.
        app?.terminate()
        app = nil
        helper = nil
    }

    // MARK: - 5.1 Core SUP-1009 repro

    func testReopenAfterAcceptInSameProcess() throws {
        print("🧪 Test 5.1: re-open the CMP after accepting, same process")

        // CONTROL. Widget on screen, no stored consent. A failure here is environmental.
        launchWithWidgetDisplayed()
        add(helper.takeScreenshot(named: "SUP1009_1_autoDisplayed"))

        // Accept — consent is now stored, and we stay in the same process.
        XCTAssertTrue(
            helper.tapAcceptButton(timeout: acceptTapTimeout),
            "Accept button not found in the widget — widget/DOM flake, not a SUP-1009 regression"
        )
        XCTAssertTrue(
            helper.waitForWidgetToDisappear(timeout: widgetVanishTimeout),
            "Widget did not close after accepting"
        )
        add(helper.takeScreenshot(named: "SUP1009_2_closedAfterAccept"))

        // onPopupClosedEvent → loadAd() starts an interstitial *load* here. It is never
        // presented without an ax_googleAd tap, but give the main queue a beat so the
        // re-open cannot collide with the ad plumbing.
        sleep(2)

        // THE REGRESSION: same process, consent already stored, user asks for the CMP again.
        XCTAssertTrue(helper.tapShowConsentButton(timeout: nativeButtonTimeout), "ax_showConsent button not found")

        let reopened = waitForConsentUI(timeout: widgetAppearTimeout)
        add(helper.takeScreenshot(named: "SUP1009_3_reopen_\(reopened ? "ok" : "FAILED")"))
        XCTAssertTrue(reopened, """
            showConsentScreen() did not re-present the CMP after an accept in the same \
            process. The widget already loaded AND was accepted earlier in this same run, so \
            the network path is proven — this is not a load flake. Triage from the captured \
            log: 'Received event: cookies:close' with no preceding showCmp is bd ios-x6b (the \
            web widget declining, known and expected until it is fixed server-side); \
            present_failed_on_top / present_failed_busy / present_failed_no_top / \
            watchdog_stuck_hidden would be a NEW native regression; blocked_network / \
            watchdog_boot_timeout is environment.
            """)
    }

    // MARK: - 5.2 Background / foreground variant

    func testReopenAfterBackgroundForeground() throws {
        print("🧪 Test 5.2: re-open the CMP after accept + background/foreground")

        launchWithWidgetDisplayed()
        XCTAssertTrue(
            helper.tapAcceptButton(timeout: acceptTapTimeout),
            "Accept button not found in the widget — widget/DOM flake, not a SUP-1009 regression"
        )
        XCTAssertTrue(
            helper.waitForWidgetToDisappear(timeout: widgetVanishTimeout),
            "Widget did not close after accepting"
        )
        sleep(2)

        // applicationWillEnterForeground re-runs the display decision. With valid stored
        // consent it must leave nothing presented that would block the manual re-open below.
        XCUIDevice.shared.press(.home)
        sleep(3)
        app.activate()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10), "App did not return to the foreground")
        sleep(3)
        XCTAssertFalse(
            app.webViews.firstMatch.exists,
            "Nothing should be displayed on foreground while stored consent is still valid"
        )
        add(helper.takeScreenshot(named: "SUP1009_bg_1_foregrounded"))

        XCTAssertTrue(
            helper.tapShowConsentButton(timeout: nativeButtonTimeout),
            "ax_showConsent button not found after foregrounding"
        )

        let reopened = waitForConsentUI(timeout: widgetAppearTimeout)
        add(helper.takeScreenshot(named: "SUP1009_bg_2_reopen_\(reopened ? "ok" : "FAILED")"))
        XCTAssertTrue(reopened, """
            Background variant: showConsentScreen() did not re-present the CMP after accept → \
            background → foreground. Same triage as 5.1 (cookies:close with no showCmp = bd \
            ios-x6b); additionally check for a stray skipped_valid_consent immediately before \
            the failing line, which would mean the foreground pass consumed the request.
            """)
    }

    // MARK: - 5.3 The fix has to hold for more than one cycle

    func testReopenSurvivesTwoConsecutiveCycles() throws {
        print("🧪 Test 5.3: two consecutive accept → re-open cycles")

        launchWithWidgetDisplayed()

        for cycle in 1...2 {
            XCTAssertTrue(
                helper.tapAcceptButton(timeout: acceptTapTimeout),
                "Cycle \(cycle): accept button not found — widget/DOM flake"
            )
            XCTAssertTrue(
                helper.waitForWidgetToDisappear(timeout: widgetVanishTimeout),
                "Cycle \(cycle): widget did not close after accepting"
            )
            sleep(2)

            XCTAssertTrue(
                helper.tapShowConsentButton(timeout: nativeButtonTimeout),
                "Cycle \(cycle): ax_showConsent not found"
            )
            let reopened = waitForConsentUI(timeout: widgetAppearTimeout)
            add(helper.takeScreenshot(named: "SUP1009_cycle\(cycle)_\(reopened ? "ok" : "FAILED")"))
            XCTAssertTrue(reopened, """
                Cycle \(cycle)/2: the CMP did not come back. Same triage as 5.1. Once ios-x6b \
                is fixed this test earns its keep: passing cycle 1 but failing cycle 2 would \
                mean the presented controller is dismissed while its reference/state is not \
                reset, or the reverse — a native fault this suite is positioned to catch.
                """)
        }
    }
}

// MARK: - Local primitives
//
// Kept private to this class on purpose: the five existing suites have a measured pass rate
// and must not be perturbed. Promote into AxeptioIntegrationTestsHelper only once a second
// suite needs them.
//
// Upstream additionally carried a local `waitForNoWebView`, because
// `helper.waitForWidgetToDisappear()` was `!webView.waitForExistence(timeout:)` — which
// returns immediately while the element is still on screen and so never observes the close.
// That helper is fixed in this repository (it uses waitForNonExistence), so the workaround is
// not reproduced here and the tests call the helper directly.

private extension Test5_ReopenConsentTests {

    /// Leaves the app running with the consent widget on screen and no stored consent.
    /// State-agnostic: the simulator may or may not already hold consent from an earlier run.
    func launchWithWidgetDisplayed(file: StaticString = #filePath, line: UInt = #line) {
        helper.launchApp()
        dismissATTAlertIfPresent()

        // No stored consent → the widget auto-displays and we are already where we want to be.
        if waitForConsentUI(timeout: initialProbeTimeout) { return }

        // Stored consent from an earlier run: clear it and restart to get the auto-display.
        // The native button is only reachable because no widget is covering it.
        XCTAssertTrue(
            helper.tapClearConsentButton(timeout: nativeButtonTimeout),
            "No widget appeared and ax_clearConsent could not be tapped — app is in an unknown state",
            file: file, line: line
        )
        helper.relaunchApp()
        dismissATTAlertIfPresent()
        XCTAssertTrue(
            waitForConsentUI(timeout: widgetAppearTimeout),
            """
            Widget did not auto-display after clearing consent. This is the CONTROL step: treat \
            as an environment/network failure (look for blocked_network or watchdog_boot_timeout \
            in the decision log), not as a SUP-1009 regression.
            """,
            file: file, line: line
        )
    }

    /// True once the consent widget is actually RENDERED — a WKWebView that has controls.
    ///
    /// Deliberately stricter than `helper.isWidgetDisplayed()`. The SUP-1009 failure mode
    /// leaves an orphaned *blank* consent controller presented, so a bare
    /// `app.webViews.firstMatch.exists` check matches that orphan and false-passes on the
    /// buggy build — which would make this whole suite decorative. A blank orphan has no
    /// buttons, and neither does a detached GoogleMobileAds webview.
    func waitForConsentUI(timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            let webView = app.webViews.firstMatch
            // `buttons.firstMatch.exists` rather than `buttons.count > 0`: both answer "does it
            // have at least one control", but count enumerates every match, and this polls twice a
            // second for up to 25s against a web view with a lot of elements.
            if webView.exists && webView.buttons.firstMatch.exists {
                print("✅ Rendered consent UI detected")
                return true
            }
            usleep(500_000)
        } while Date() < deadline

        print("❌ No rendered consent UI after \(timeout)s")
        return false
    }

    /// The ATT prompt is a SpringBoard alert owned by another process, so it is not in `app`'s
    /// element tree. It only appears while ATT is `.notDetermined` for this bundle id — device
    /// state that survives relaunches — so this is usually a no-op. Never fails the test.
    func dismissATTAlertIfPresent(timeout: TimeInterval = 3) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allow = springboard.buttons.matching(
            NSPredicate(format: "label IN {'Allow', 'Allow Tracking', 'Autoriser'}")
        ).firstMatch
        if allow.waitForExistence(timeout: timeout) {
            allow.tap()
            print("ℹ️ Dismissed the ATT prompt")
            sleep(1)
        }
    }
}
