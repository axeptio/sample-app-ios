//
//  ConfigurationManager.swift
//  sampleSwift
//
//  Created by Claude on 28/08/2025.
//

import Foundation
import AxeptioSDK

protocol ConfigurationViewControllerDelegate: AnyObject {
    func configurationDidChange()
}

struct CustomerConfiguration {
    let clientId: String
    let cookiesVersion: String
    let token: String?
    let widgetType: WidgetType
    let widgetPR: String?
    let targetService: AxeptioService
    let allowPopupWithRejectedATT: Bool

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
        static let widgetType = "axeptio.config.widgetType"
        static let widgetPR = "axeptio.config.widgetPR"
        static let targetService = "axeptio.config.targetService"
        static let allowPopupWithRejectedATT = "axeptio.config.allowPopupWithRejectedATT"
        static let hasCustomConfiguration = "axeptio.config.hasCustom"
    }
    
    // Default configurations for quick testing
    static let presetConfigurations: [String: CustomerConfiguration] = [
        "Default Brands": CustomerConfiguration(
            clientId: "5fbfa806a0787d3985c6ee5f",
            cookiesVersion: "insideapp-brands",
            token: "5sj42u50ta2ys8c3nhjkxi",
            widgetType: .production,
            widgetPR: nil,
            targetService: .brands,
            allowPopupWithRejectedATT: false
        ),
        "Default TCF": CustomerConfiguration(
            clientId: "5fbfa806a0787d3985c6ee5f",
            cookiesVersion: "google cmp partner program sandbox-en-EU",
            token: "5sj42u50ta2ys8c3nhjkxi",
            widgetType: .production,
            widgetPR: nil,
            targetService: .publisherTcf,
            allowPopupWithRejectedATT: false
        ),
        "Test Brands (No Token)": CustomerConfiguration(
            clientId: "5fbfa806a0787d3985c6ee5f",
            cookiesVersion: "insideapp-brands",
            token: nil,
            widgetType: .production,
            widgetPR: nil,
            targetService: .brands,
            allowPopupWithRejectedATT: false
        ),
        "Test TCF (No Token)": CustomerConfiguration(
            clientId: "5fbfa806a0787d3985c6ee5f",
            cookiesVersion: "google cmp partner program sandbox-en-EU",
            token: nil,
            widgetType: .production,
            widgetPR: nil,
            targetService: .publisherTcf,
            allowPopupWithRejectedATT: false
        ),
        "Brands (Allow Popup w/ Denied ATT)": CustomerConfiguration(
            clientId: "5fbfa806a0787d3985c6ee5f",
            cookiesVersion: "insideapp-brands",
            token: "5sj42u50ta2ys8c3nhjkxi",
            widgetType: .production,
            widgetPR: nil,
            targetService: .brands,
            allowPopupWithRejectedATT: true
        ),
        "TCF (Allow Popup w/ Denied ATT)": CustomerConfiguration(
            clientId: "5fbfa806a0787d3985c6ee5f",
            cookiesVersion: "google cmp partner program sandbox-en-EU",
            token: "5sj42u50ta2ys8c3nhjkxi",
            widgetType: .production,
            widgetPR: nil,
            targetService: .publisherTcf,
            allowPopupWithRejectedATT: true
        )
    ]
    
    private init() {}
    
    // MARK: - Current Configuration
    
    var currentConfiguration: CustomerConfiguration {
        get {
            let clientId = userDefaults.string(forKey: Keys.clientId) ?? "5fbfa806a0787d3985c6ee5f"
            let cookiesVersion = userDefaults.string(forKey: Keys.cookiesVersion) ?? "insideapp-brands"
            let token = userDefaults.string(forKey: Keys.token)
            let widgetType = WidgetType(rawValue: userDefaults.integer(forKey: Keys.widgetType))
            let widgetPR = userDefaults.string(forKey: Keys.widgetPR)
            let serviceRawValue = userDefaults.integer(forKey: Keys.targetService)
            let targetService: AxeptioService = serviceRawValue == 1 ? .publisherTcf : .brands
            let allowPopupWithRejectedATT = userDefaults.bool(forKey: Keys.allowPopupWithRejectedATT)

            return CustomerConfiguration(
                clientId: clientId,
                cookiesVersion: cookiesVersion,
                token: token?.isEmpty == false ? token : nil,
                widgetType: widgetType ?? .production,
                widgetPR: widgetPR?.isEmpty == false ? widgetPR : nil,
                targetService: targetService,
                allowPopupWithRejectedATT: allowPopupWithRejectedATT
            )
        }
        set {
            userDefaults.set(newValue.clientId, forKey: Keys.clientId)
            userDefaults.set(newValue.cookiesVersion, forKey: Keys.cookiesVersion)
            userDefaults.set(newValue.token, forKey: Keys.token)
            userDefaults.set(newValue.widgetType.rawValue, forKey: Keys.widgetType)
            userDefaults.set(newValue.widgetPR, forKey: Keys.widgetPR)
            userDefaults.set(newValue.targetService == .publisherTcf ? 1 : 0, forKey: Keys.targetService)
            userDefaults.set(newValue.allowPopupWithRejectedATT, forKey: Keys.allowPopupWithRejectedATT)
            userDefaults.set(true, forKey: Keys.hasCustomConfiguration)
        }
    }
    
    var hasCustomConfiguration: Bool {
        return userDefaults.bool(forKey: Keys.hasCustomConfiguration)
    }
    
    // MARK: - Configuration Management
    
    func loadPresetConfiguration(_ presetName: String) {
        guard let config = Self.presetConfigurations[presetName] else { return }
        currentConfiguration = config
    }
    
    func resetToDefault() {
        userDefaults.removeObject(forKey: Keys.clientId)
        userDefaults.removeObject(forKey: Keys.cookiesVersion)
        userDefaults.removeObject(forKey: Keys.token)
        userDefaults.removeObject(forKey: Keys.widgetType)
        userDefaults.removeObject(forKey: Keys.widgetPR)
        userDefaults.removeObject(forKey: Keys.targetService)
        userDefaults.removeObject(forKey: Keys.allowPopupWithRejectedATT)
        userDefaults.removeObject(forKey: Keys.hasCustomConfiguration)
    }
    
    // MARK: - Validation
    
    func validateConfiguration(_ config: CustomerConfiguration) -> [String] {
        var errors: [String] = []
        
        if config.clientId.isEmpty {
            errors.append("Client ID is required")
        } else if config.clientId.count < 10 {
            errors.append("Client ID appears to be too short")
        }
        
        if config.cookiesVersion.isEmpty {
            errors.append("Cookies Version is required")
        }
        
        // Token validation is optional
        if let token = config.token, !token.isEmpty && token.count < 10 {
            errors.append("Token appears to be too short")
        }
        
        // Widget PR Validation is also optional
        if let widgetVerison = config.widgetPR, !widgetVerison.isEmpty && widgetVerison.count < 5 {
            errors.append("Widget Version appears to be too short")
        }
        
        return errors
    }
    
    // MARK: - Display Helpers
    
    var currentServiceDisplayName: String {
        return currentConfiguration.targetService == .brands ? "Brands" : "Publisher TCF"
    }
    
    var currentServiceColor: String {
        return currentConfiguration.targetService == .brands ? "AxeptioYellow" : "AxeptioBlueLight"
    }
    
    // MARK: - WebView URLs
    
    func getWebViewURL() -> String {
        switch currentConfiguration.targetService {
        case .brands:
            return "https://static.axept.io/app-sdk-webview-for-brands.html"
        case .publisherTcf:
            return "https://google-cmp-partner.axept.io/cmp-for-publishers.html"
        }
    }
}
