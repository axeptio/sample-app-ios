//
//  sampleSwiftUITests.swift
//  sampleSwiftUITests
//
//  Created by Philippe Le Berre on 29.12.2025.
//

import XCTest

final class sampleSwiftUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface
        // orientation - required for your tests before they run. The setUp method is a
        // good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // measure() runs several launch iterations, which is meaningful cost on a suite that
        // already takes ~30 minutes against the live consent widget. Opt in explicitly when
        // launch performance is what you are actually investigating.
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["AXEPTIO_RUN_PERF_TESTS"] == "1",
            "Set AXEPTIO_RUN_PERF_TESTS=1 to run launch performance measurements."
        )

        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
