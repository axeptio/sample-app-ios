//
//  AppDelegate.swift
//  sampleSwift
//
//  Created by Noeline PAGESY on 08/02/2024.
//

import UIKit
import AxeptioSDK
import FirebaseCore
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

        Axeptio.shared.initialize(
            targetService: config.targetService,
            clientId: config.clientId,
            cookiesVersion: config.cookiesVersion,
            token: config.token,
            widgetType: config.widgetType,
            widgetPR: config.widgetPR,
            cookiesDurationDays: config.cookiesDuration,
            shouldUpdateCookiesDuration: config.shouldUpdateCookiesDuration
        )

        // Configure ATT popup behavior
        Axeptio.shared.allowPopupDisplayWithRejectedDeviceTrackingPermissions(config.allowPopupWithRejectedATT)

        // Log current configuration for debugging
        print("🔧 Axeptio Configuration:")
        print("   Service: \(config.targetService == AxeptioService.brands ? "Brands" : "Publisher TCF")")
        print("   Client ID: \(config.clientId)")
        print("   Cookies Version: \(config.cookiesVersion)")
        print("   Token: \(config.token?.prefix(10) ?? "None")...")
        print("   Allow popup with denied ATT: \(config.allowPopupWithRejectedATT)")

        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start()

        return true
    }
}
