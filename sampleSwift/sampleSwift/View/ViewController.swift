// swiftlint:disable file_length
//
//  ViewController.swift
//  sampleSwift
//
//  Created by Noeline PAGESY on 21/02/2024.
//

import AppTrackingTransparency
import Foundation
import SwiftUI
import UIKit

import AxeptioSDK
import GoogleMobileAds

class ViewController: UIViewController {
    @IBOutlet weak var showConsentButton: UIButton!
    @IBOutlet weak var tokenButton: UIButton!
    @IBOutlet weak var userDefaultsButton: UIButton!
    @IBOutlet weak var clearConsentButton: UIButton!
    @IBOutlet weak var googleAdButton: UIButton!
    @IBOutlet weak var googleAdSpinner: UIActivityIndicatorView!
    @IBOutlet weak var tcfVendorTestButton: UIButton!
    @IBOutlet weak var consentDebugInfoButton: UIButton!
    @IBOutlet weak var configButton: UIButton!

    // New UI elements (created programmatically)
    private let serviceTypeLabel = UILabel()
    private let configurationLabel = UILabel()
    private let sdkVersionLabel = UILabel()
    private let settingsButton = UIButton(type: .system)
    private let vendorConsentButton = UIButton(type: .system)
    private let swiftUIDemoButton = UIButton(type: .system)

    /// The Axeptio SDK version this sample demonstrates.
    ///
    /// Read from the app's own `CFBundleShortVersionString`: this repo's version tracks the SDK
    /// version it demonstrates (CONTRIBUTING.md, "Versioning Strategy"), so the release bump keeps
    /// this label in step instead of it drifting as a hardcoded string. It cannot be read from the
    /// SDK itself — `AxeptioSDK` exposes no version symbol and its framework `Info.plist` is not
    /// maintained. The authoritative pin is the `axeptio-ios-sdk` XCRemoteSwiftPackageReference
    /// in `project.pbxproj`.
    static var axeptioSDKVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    private var interstitial: GADInterstitialAd?
    private let cornerRadius = 24.0
    private weak var observer: NSObjectProtocol?
    private var token: String?
    private var uiButtons: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Note: setupUI() is called asynchronously after ATT authorization in requestTrackingAuthorization()
        // Do not call setupUI() here directly to avoid double initialization
        updateServiceIndicators()
        loadBasicButtons()

        let axeptioEventListener = AxeptioEventListener()

        // Since SDK 2.3.0, Firebase consent is forwarded codelessly by the SDK's
        // FirebaseConsentForwarder (it detects FIRAnalytics via the Objective-C runtime and
        // calls setConsent itself). A host-app `onGoogleConsentModeUpdate { Analytics.setConsent(...) }`
        // relay is no longer needed here — keeping one would set every GCM v2 signal twice.
        // The same applies to AppsFlyer, Adjust and Singular: link the partner SDK and the
        // SDK forwards consent to it automatically. See README "Codeless consent forwarding".

        axeptioEventListener.onConsentCleared = {
            print("Consent have been cleared")
        }

        axeptioEventListener.onPopupClosedEvent = { [weak self] in
            // Since SDK 2.3.0 this fires at least once after every setupUI() / showConsentScreen()
            // call, even when no popup is shown — so it is a safe place to dismiss a host overlay
            // and integrators no longer need a watchdog timer. Overlapping flows resolved by a
            // single popup dismissal are coalesced into one callback.
            print("[Axeptio] Consent flow resolved — host overlay can be dismissed now")
            self?.loadAd()
        }

        axeptioEventListener.onError = { message in
            // Since SDK 2.4.0 webview load failures are reported here instead of failing
            // silently; invalid configuration (empty clientId / cookiesVersion) also surfaces here.
            print("[Axeptio] SDK error: \(message)")
        }

        Axeptio.shared.setEventListener(axeptioEventListener)
        requestTrackingAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateServiceIndicators()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        styleUIButtons()
    }

    private func updateServiceIndicators() {
        let config = ConfigurationManager.shared.currentConfiguration

        // Update service type label
        serviceTypeLabel.text = "Service: \(config.targetService == .brands ? "Brands" : "Publisher TCF")"
        serviceTypeLabel.textColor = config.targetService == .brands ? .systemOrange : .systemBlue

        // Update configuration label
        let tokenStatus = config.token != nil ? "with token" : "no token"
        configurationLabel.text = "Client: \(config.clientId.prefix(8))... (\(tokenStatus))"
        configurationLabel.textColor = .secondaryLabel

        updateServiceSpecificButtons()
    }

    private func updateServiceSpecificButtons() {
        let config = ConfigurationManager.shared.currentConfiguration
        let isTCF = config.targetService == .publisherTcf

        // Show vendor consent button only for TCF
        vendorConsentButton.isHidden = !isTCF

        // Update button titles based on service
        if isTCF {
            showConsentButton?.setTitle("TCF Consent Dialog", for: .normal)
        } else {
            showConsentButton?.setTitle("Brands Consent Dialog", for: .normal)
        }
    }

    @IBAction func showConsent(_ sender: Any) {
        print("[TEST] Manually calling showConsentScreen() at \(Date())")
        Axeptio.shared.showConsentScreen()
        print("[TEST] showConsentScreen() call completed")
    }

    @IBAction func showGoogleAd(_ sender: Any) {
        if interstitial != nil {
            interstitial?.present(fromRootViewController: self)
        }
    }

    @IBAction func clearConsent(_ sender: Any) {
        token = Axeptio.shared.axeptioToken
        performComprehensiveConsentClear()
    }

    @IBAction func showWebView(_ sender: Any) {
        let alertController = UIAlertController(title: "Enter axeptio token", message: "", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "axeptio token"
        }
        let sourceURL = ConfigurationManager.shared.getWebViewURL()
        let saveAction = UIAlertAction(title: "Open in Browser", style: .default) {  [weak self] _ in
            guard
                let self,
                let sourceURL = URL(string: sourceURL)
            else { return }

            var url: URL = sourceURL
            if let token = alertController.textFields?[0].text, !token.isEmpty {
                url = Axeptio.shared.appendAxeptioTokenToURL(url, token: token)
            } else if let token = Axeptio.shared.axeptioToken {
                url = Axeptio.shared.appendAxeptioTokenToURL(url, token: token)
            }
            let webView = WebViewController(url)
            let navController = UINavigationController(rootViewController: webView)
            present(navController, animated: true)
        }

        alertController.addAction(saveAction)
        alertController.addAction(.init(title: "Cancel", style: .cancel))

        present(alertController, animated: true)
    }

    @IBAction func showConsentDebugInfo(_ sender: Any) {
        let consentData = Axeptio.shared.getConsentDebugInfo(preferenceKey: nil)
        let debugViewController = ConsentDebugViewController(data: (consentData as? [String: Any?]) ?? [:])

        let navController = UINavigationController(rootViewController: debugViewController)
        self.present(navController, animated: true)
    }

    @IBAction func showSettings(_ sender: Any) {
        let remainingDays = Axeptio.shared.getRemainingDaysForConsent()
        let configViewController = ConfigurationViewController()
        configViewController.delegate = self
        configViewController.remainingDays = remainingDays
        let navController = UINavigationController(rootViewController: configViewController)
        self.present(navController, animated: true)
    }

    @IBAction func showVendorConsent(_ sender: Any) {
        let vendorViewController = VendorConsentViewController()
        let navController = UINavigationController(rootViewController: vendorViewController)
        self.present(navController, animated: true)
    }

    @objc func showSwiftUIDemo() {
        let hostingController = UIHostingController(rootView: SwiftUISampleView())
        let navController = UINavigationController(rootViewController: hostingController)
        self.present(navController, animated: true)
    }
}

// MARK: - UI Setup

private extension ViewController {
    func setupUI() {
        let buttons = [showConsentButton, tokenButton, userDefaultsButton,
                       clearConsentButton, googleAdButton, tcfVendorTestButton,
                       consentDebugInfoButton, configButton]

        buttons.compactMap { $0 }.forEach { button in
            button.layer.cornerRadius = cornerRadius
        }

        setupServiceIndicatorLabels()
        googleAdSpinner.isHidden = true
        setupServiceIndicatorLabels()
        setupNewButtons()
        addElementsToView()
        updateServiceSpecificButtons()
    }

    func setupServiceIndicatorLabels() {
        serviceTypeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        serviceTypeLabel.textAlignment = .center
        serviceTypeLabel.numberOfLines = 0

        configurationLabel.font = UIFont.systemFont(ofSize: 14)
        configurationLabel.textAlignment = .center
        configurationLabel.numberOfLines = 0
        configurationLabel.textColor = .secondaryLabel

        sdkVersionLabel.font = UIFont.systemFont(ofSize: 12)
        sdkVersionLabel.textAlignment = .center
        sdkVersionLabel.numberOfLines = 0
        sdkVersionLabel.textColor = .tertiaryLabel
        sdkVersionLabel.text = "Axeptio iOS SDK v\(Self.axeptioSDKVersion)"
    }

    func loadBasicButtons() {
        uiButtons.append(contentsOf: [showConsentButton,
                                      tokenButton,
                                      userDefaultsButton,
                                      clearConsentButton,
                                      googleAdButton,
                                      tcfVendorTestButton,
                                      consentDebugInfoButton,
                                      configButton])

        // Stable identifiers for UI tests: button titles change between TCF and Brands
        // (see updateServiceSpecificButtons), so tests address the controls by identifier.
        showConsentButton?.accessibilityIdentifier = "ax_showConsent"
        tokenButton?.accessibilityIdentifier = "ax_token"
        userDefaultsButton?.accessibilityIdentifier = "ax_userDefaults"
        clearConsentButton?.accessibilityIdentifier = "ax_clearConsent"
        googleAdButton?.accessibilityIdentifier = "ax_googleAd"
        tcfVendorTestButton?.accessibilityIdentifier = "ax_tcfVendorTest"
        consentDebugInfoButton?.accessibilityIdentifier = "ax_consentDebugInfo"
        configButton?.accessibilityIdentifier = "ax_config"
    }

    func styleUIButtons() {
        uiButtons.forEach { button in
            button.titleLabel?.layer.shadowColor = UIColor.black.cgColor
            button.titleLabel?.layer.shadowOffset = CGSize(width: 2.5, height: 2.0)
            button.titleLabel?.layer.shadowRadius = 2.5
            button.titleLabel?.layer.shadowOpacity = 0.9
            button.titleLabel?.layer.masksToBounds = false
            button.layer.cornerRadius = cornerRadius
            button.layer.masksToBounds = true
        }
    }

    func setupNewButtons() {
        settingsButton.setTitle("⚙️ Settings", for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        settingsButton.backgroundColor = UIColor.systemGray5
        settingsButton.setTitleColor(.label, for: .normal)
        settingsButton.layer.cornerRadius = cornerRadius
        settingsButton.addTarget(self, action: #selector(showSettings), for: .touchUpInside)

        vendorConsentButton.setTitle("🏪 TCF Vendor API", for: .normal)
        vendorConsentButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        vendorConsentButton.backgroundColor = UIColor.systemBlue
        vendorConsentButton.setTitleColor(.white, for: .normal)
        vendorConsentButton.layer.cornerRadius = cornerRadius
        vendorConsentButton.addTarget(
            self, action: #selector(showVendorConsent), for: .touchUpInside
        )

        swiftUIDemoButton.setTitle("🔷 SwiftUI Demo", for: .normal)
        swiftUIDemoButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        swiftUIDemoButton.backgroundColor = UIColor.systemIndigo
        swiftUIDemoButton.setTitleColor(.white, for: .normal)
        swiftUIDemoButton.layer.cornerRadius = cornerRadius
        swiftUIDemoButton.addTarget(self, action: #selector(showSwiftUIDemo), for: .touchUpInside)

        [settingsButton, vendorConsentButton, swiftUIDemoButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }

    func addElementsToView() {
        serviceTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        configurationLabel.translatesAutoresizingMaskIntoConstraints = false
        sdkVersionLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(serviceTypeLabel)
        view.addSubview(configurationLabel)
        view.addSubview(sdkVersionLabel)

        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        vendorConsentButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(settingsButton)
        view.addSubview(vendorConsentButton)
        view.addSubview(swiftUIDemoButton)

        NSLayoutConstraint.activate([
            serviceTypeLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            serviceTypeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            serviceTypeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            configurationLabel.topAnchor.constraint(
                equalTo: serviceTypeLabel.bottomAnchor, constant: 4),
            configurationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            configurationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            sdkVersionLabel.topAnchor.constraint(
                equalTo: configurationLabel.bottomAnchor, constant: 4),
            sdkVersionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sdkVersionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            settingsButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            vendorConsentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            vendorConsentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            vendorConsentButton.bottomAnchor.constraint(
                equalTo: settingsButton.topAnchor, constant: -12),

            swiftUIDemoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            swiftUIDemoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            swiftUIDemoButton.bottomAnchor.constraint(
                equalTo: vendorConsentButton.topAnchor, constant: -12)
        ])
    }
}

// MARK: - ConfigurationViewControllerDelegate

extension ViewController: ConfigurationViewControllerDelegate {
    func configurationDidChange() {
        updateServiceIndicators()

        // Show alert that app needs restart for changes to take full effect
        let alert = UIAlertController(
            title: "Configuration Updated",
            message: "Some changes may require restarting the app to take full effect.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ViewController {
    func requestTrackingAuthorization() {
        self.removeObserver()

        // ATT is always available since we require iOS 18+

        if ATTrackingManager.trackingAuthorizationStatus != .notDetermined {
            // ATT already determined - set tracking status BEFORE setupUI so Row J detection works
            let isAuthorized = ATTrackingManager.trackingAuthorizationStatus == .authorized
            Axeptio.shared.setUserDeniedTracking(denied: !isAuthorized)
            Axeptio.shared.setupUI()
            return
        }

        ATTrackingManager.requestTrackingAuthorization { [weak self] status in
            let isAuthorized = status == .authorized
            // Handle ATT status determination bug (fixed in iOS 18+)
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                self?.addObserver()
                return
            }
            // Set tracking status BEFORE setupUI so Row J detection works
            Axeptio.shared.setUserDeniedTracking(denied: !isAuthorized)
            Axeptio.shared.setupUI()
        }
    }

    private func addObserver() {
        self.removeObserver()
        self.observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.requestTrackingAuthorization()
        }
    }

    private func removeObserver() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        self.observer = nil
    }
}

// MARK: - Consent Clearing

private extension ViewController {
    func performComprehensiveConsentClear() {
        print("🧹 [ClearConsent] Starting comprehensive consent clearing...")

        Axeptio.shared.clearConsent()
        print("   ✅ Called Axeptio.shared.clearConsent()")

        let currentConfig = ConfigurationManager.shared.currentConfiguration
        let userDefaults = UserDefaults.standard
        var clearedKeys: [String] = []

        print("   🔧 Current mode: \(currentConfig.targetService == .publisherTcf ? "TCF" : "Brands")")
        print("   🎯 Configuration: \(currentConfig.cookiesVersion)")

        let tcfKeys = TCFFields.allCases.map { $0.rawValue }
        for key in tcfKeys where userDefaults.object(forKey: key) != nil {
            userDefaults.removeObject(forKey: key)
            clearedKeys.append(key)
        }

        let brandsKeys = CookieFields.allCases.map { $0.rawValue }
        for key in brandsKeys where userDefaults.object(forKey: key) != nil {
            userDefaults.removeObject(forKey: key)
            clearedKeys.append(key)
        }

        let additionalKeys = [
            "axeptio_consent_timestamp",
            "axeptio_consent_version",
            "expected_vendor_count"
        ]
        for key in additionalKeys where userDefaults.object(forKey: key) != nil {
            userDefaults.removeObject(forKey: key)
            clearedKeys.append(key)
        }

        userDefaults.synchronize()

        print("   🗑️ Cleared \(clearedKeys.count) UserDefaults keys:")
        for key in clearedKeys {
            print("      - \(key)")
        }
        print("   💾 UserDefaults synchronized")
        print("🧹 [ClearConsent] Comprehensive clearing completed!")

        showConsentClearConfirmation(clearedCount: clearedKeys.count)
    }

    func showConsentClearConfirmation(clearedCount: Int) {
        let originalTitle = clearConsentButton.titleLabel?.text
        let originalBackgroundColor = clearConsentButton.backgroundColor

        clearConsentButton.setTitle("✅ Cleared!", for: .normal)
        clearConsentButton.backgroundColor = .systemGreen
        clearConsentButton.isEnabled = false

        let alert = UIAlertController(
            title: "Consent Cleared Successfully",
            message: """
                ✅ SDK consent cleared
                🗑️ \(clearedCount) UserDefaults keys removed
                💾 Data synchronized

                You can now test fresh consent scenarios.
                """,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Force Clear All", style: .destructive) { [weak self] _ in
            self?.performForceClearAll()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self?.clearConsentButton.setTitle(originalTitle, for: .normal)
                self?.clearConsentButton.backgroundColor = originalBackgroundColor
                self?.clearConsentButton.isEnabled = true
            }
        })

        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.clearConsentButton.setTitle(originalTitle, for: .normal)
                self?.clearConsentButton.backgroundColor = originalBackgroundColor
                self?.clearConsentButton.isEnabled = true
            }
        })

        present(alert, animated: true)
    }

    func performForceClearAll() {
        print("💥 [ForceClearAll] Starting nuclear consent clearing...")

        let userDefaults = UserDefaults.standard
        var allClearedKeys: [String] = []

        Axeptio.shared.clearConsent()

        let allKeys = Array(userDefaults.dictionaryRepresentation().keys)
        let consentRelatedPrefixes = ["IABTCF_", "axeptio_", "consent", "vendor", "tcf", "cmp"]

        for key in allKeys {
            let lowercaseKey = key.lowercased()
            let isConsentRelated = consentRelatedPrefixes.contains { prefix in
                lowercaseKey.contains(prefix.lowercased())
            }

            if isConsentRelated {
                userDefaults.removeObject(forKey: key)
                allClearedKeys.append(key)
            }
        }

        let forceRemoveKeys = (TCFFields.allCases.map { $0.rawValue }) +
            (CookieFields.allCases.map { $0.rawValue }) +
            ["expected_vendor_count", "axeptio_consent_timestamp", "axeptio_consent_version"]

        for key in forceRemoveKeys where !allClearedKeys.contains(key) {
            userDefaults.removeObject(forKey: key)
            allClearedKeys.append(key)
        }

        userDefaults.synchronize()

        print("   💥 Force cleared \(allClearedKeys.count) keys:")
        for key in allClearedKeys.sorted() {
            print("      - \(key)")
        }
        print("💥 [ForceClearAll] Nuclear clearing completed!")

        let alert = UIAlertController(
            title: "Force Clear Completed",
            message: """
                ALL consent data cleared!
                \(allClearedKeys.count) keys removed

                Perfect for testing fresh scenarios.
                """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Excellent", style: .default))
        present(alert, animated: true)
    }
}

// swiftlint:disable identifier_name
extension ViewController: GADFullScreenContentDelegate {
    func loadAd() {
        googleAdButton.isHidden = true

        googleAdSpinner.startAnimating()
        googleAdSpinner.isHidden = false

        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: "ca-app-pub-3940256099942544/4411468910",
            request: request) { [weak self] ad, error in
            guard let self else { return }
            self.googleAdSpinner.stopAnimating()
            self.googleAdSpinner.isHidden = true

            if error != nil {
                self.googleAdButton.isEnabled = false
                self.googleAdButton.isHidden = false
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
            self.googleAdButton.isEnabled = true
            self.googleAdButton.isHidden = false
        }
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadAd()
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {}
}
// swiftlint:enable identifier_name
