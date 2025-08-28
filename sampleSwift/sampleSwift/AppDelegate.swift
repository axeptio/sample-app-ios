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

// MARK: - Configuration Management

protocol ConfigurationViewControllerDelegate: AnyObject {
    func configurationDidChange()
}

struct CustomerConfiguration {
    let clientId: String
    let cookiesVersion: String
    let token: String?
    let targetService: AxeptioService
    
    var displayName: String {
        return "\(targetService == .brands ? "Brands" : "TCF"): \(cookiesVersion)"
    }
}

class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    private let userDefaults = UserDefaults.standard
    
    // UserDefaults keys
    private enum Keys {
        static let clientId = "axeptio.config.clientId"
        static let cookiesVersion = "axeptio.config.cookiesVersion"
        static let token = "axeptio.config.token"
        static let targetService = "axeptio.config.targetService"
        static let hasCustomConfiguration = "axeptio.config.hasCustom"
    }
    
    // Default configurations for quick testing
    static let presetConfigurations: [String: CustomerConfiguration] = [
        "Default Brands": CustomerConfiguration(
            clientId: "5fbfa806a0787d3985c6ee5f",
            cookiesVersion: "insideapp-brands",
            token: "5sj42u50ta2ys8c3nhjkxi",
            targetService: .brands
        ),
        "Default TCF": CustomerConfiguration(
            clientId: "5fbfa806a0787d3985c6ee5f",
            cookiesVersion: "google cmp partner program sandbox-en-EU",
            token: "5sj42u50ta2ys8c3nhjkxi",
            targetService: .publisherTcf
        )
    ]
    
    private init() {}
    
    // MARK: - Current Configuration
    
    var currentConfiguration: CustomerConfiguration {
        get {
            let clientId = userDefaults.string(forKey: Keys.clientId) ?? "5fbfa806a0787d3985c6ee5f"
            let cookiesVersion = userDefaults.string(forKey: Keys.cookiesVersion) ?? "insideapp-brands"
            let token = userDefaults.string(forKey: Keys.token)
            let serviceRawValue = userDefaults.integer(forKey: Keys.targetService)
            let targetService: AxeptioService = serviceRawValue == 1 ? .publisherTcf : .brands
            
            return CustomerConfiguration(
                clientId: clientId,
                cookiesVersion: cookiesVersion,
                token: token?.isEmpty == false ? token : nil,
                targetService: targetService
            )
        }
        set {
            userDefaults.set(newValue.clientId, forKey: Keys.clientId)
            userDefaults.set(newValue.cookiesVersion, forKey: Keys.cookiesVersion)
            userDefaults.set(newValue.token, forKey: Keys.token)
            userDefaults.set(newValue.targetService == .publisherTcf ? 1 : 0, forKey: Keys.targetService)
            userDefaults.set(true, forKey: Keys.hasCustomConfiguration)
        }
    }
    
    func getWebViewURL() -> String {
        switch currentConfiguration.targetService {
        case .brands:
            return "https://static.axept.io/app-sdk-webview-for-brands.html"
        case .publisherTcf:
            return "https://google-cmp-partner.axept.io/cmp-for-publishers.html"
        }
    }
}

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
        
        if let token = config.token {
            Axeptio.shared.initialize(
                targetService: config.targetService,
                clientId: config.clientId,
                cookiesVersion: config.cookiesVersion,
                token: token
            )
        } else {
            Axeptio.shared.initialize(
                targetService: config.targetService,
                clientId: config.clientId,
                cookiesVersion: config.cookiesVersion
            )
        }
        
        // Log current configuration for debugging
        print("🔧 Axeptio Configuration:")
        print("   Service: \(config.targetService == .brands ? "Brands" : "Publisher TCF")")
        print("   Client ID: \(config.clientId)")
        print("   Cookies Version: \(config.cookiesVersion)")
        print("   Token: \(config.token?.prefix(10) ?? "None")...")
        
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start()

        return true
    }
}
