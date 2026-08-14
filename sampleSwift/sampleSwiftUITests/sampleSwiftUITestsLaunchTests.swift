//
//  sampleSwiftUITestsLaunchTests.swift
//  sampleSwiftUITests
//
//  Created by Philippe Le Berre on 29.12.2025.
//

import XCTest

final class sampleSwiftUITestsLaunchTests: XCTestCase {

    // Must stay `class`: this overrides an XCTestCase class property, and `static` cannot
    // override. The rule does not account for `override`, so this is a false positive.
    // swiftlint:disable:next static_over_final_class
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
