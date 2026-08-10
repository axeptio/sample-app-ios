//
//  AppDelegate.swift
//  sampleSwift
//
//  Created by Noeline PAGESY on 08/02/2024.
//

import UIKit
import AxeptioSDK
import FirebaseCore
import FirebaseAnalytics
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Dynamic target service based on configuration
    static var targetService: AxeptioService {
        return ConfigurationManager.shared.currentConfiguration.targetService
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Initialize Axeptio with dynamic configuration
        let config = ConfigurationManager.shared.currentConfiguration

        Axeptio.shared.configure(
            token: config.token,
            widgetPR: config.widgetPR,
            cookiesDurationDays: config.cookiesDuration,
            shouldUpdateCookiesDuration: config.shouldUpdateCookiesDuration
        )
        Axeptio.shared.initialize(
            targetService: config.targetService,
            clientId: config.clientId,
            cookiesVersion: config.cookiesVersion,
            widgetType: config.widgetType
        )

        // Configure ATT popup behavior
        Axeptio.shared.allowPopupDisplayWithRejectedDeviceTrackingPermissions(config.allowPopupWithRejectedATT)

        // Configure force show consent debug mode
        Axeptio.shared.setForceShowConsentDebug(config.forceShowConsent)

        // Log current configuration for debugging
        print("🔧 Axeptio Configuration:")
        print("   Service: \(config.targetService == AxeptioService.brands ? "Brands" : "Publisher TCF")")
        print("   Client ID: \(config.clientId)")
        print("   Cookies Version: \(config.cookiesVersion)")
        print("   Token: \(config.token?.prefix(10) ?? "None")...")
        print("   Allow popup with denied ATT: \(config.allowPopupWithRejectedATT)")
        print("   Force show consent (Debug): \(config.forceShowConsent)")

        FirebaseApp.configure()
        // The SDK's codeless Firebase consent forwarder finds FIRAnalytics through the
        // Objective-C runtime (NSClassFromString). That class ships in the static
        // GoogleAppMeasurement archive and is only realized once the app actually references
        // Firebase Analytics — FirebaseApp.configure() and the import alone are not enough.
        // A real Firebase integrator uses Analytics anyway; this call makes the demo
        // representative so the forwarder can fire.
        Analytics.setAnalyticsCollectionEnabled(true)
        GADMobileAds.sharedInstance().start()

        return true
    }
}
