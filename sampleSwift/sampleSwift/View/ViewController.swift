//
//  ViewController.swift
//  sampleSwift
//
//  Created by Noeline PAGESY on 21/02/2024.
//

import AppTrackingTransparency
import Foundation
import UIKit

import AxeptioSDK
import FirebaseAnalytics
import GoogleMobileAds

class ViewController: UIViewController {
    @IBOutlet weak var showConsentButton: UIButton!
    @IBOutlet weak var tokenButton: UIButton!
    @IBOutlet weak var userDefaultsButton: UIButton!
    @IBOutlet weak var clearConsentButton: UIButton!
    @IBOutlet weak var googleAdButton: UIButton!
    @IBOutlet weak var googleAdSpinner: UIActivityIndicatorView!
    @IBOutlet weak var consentDebugInfoButton: UIButton!
    
    // New UI elements (created programmatically)
    private let serviceTypeLabel = UILabel()
    private let configurationLabel = UILabel()
    private let settingsButton = UIButton(type: .system)
    private let vendorConsentButton = UIButton(type: .system)
    
    private var interstitial: GADInterstitialAd?
    private let cornerRadius = 24.0
    private weak var observer: NSObjectProtocol?
    private var token: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateServiceIndicators()

        let axeptioEventListener = AxeptioEventListener()

        axeptioEventListener.onGoogleConsentModeUpdate = { consents in
            Analytics.setConsent([
                .analyticsStorage: consents.analyticsStorage == GoogleConsentStatus.granted ? .granted : .denied,
                .adStorage: consents.adStorage == GoogleConsentStatus.granted ? .granted : .denied,
                .adUserData: consents.adUserData == GoogleConsentStatus.granted ? .granted : .denied,
                .adPersonalization: consents.adPersonalization == GoogleConsentStatus.granted ? .granted : .denied
            ])
        }

        axeptioEventListener.onConsentCleared = {
            print("Consent have been cleared")
        }

        axeptioEventListener.onPopupClosedEvent = {
            self.loadAd()
        }

        Axeptio.shared.setEventListener(axeptioEventListener)
        requestTrackingAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateServiceIndicators()
    }
    
    private func setupUI() {
        // Apply corner radius to buttons
        let buttons = [showConsentButton, tokenButton, userDefaultsButton, 
                      clearConsentButton, googleAdButton, consentDebugInfoButton]
        
        buttons.compactMap { $0 }.forEach { button in
            button.layer.cornerRadius = cornerRadius
        }
        
        googleAdSpinner.isHidden = true
        
        // Setup programmatically created UI elements
        setupServiceIndicatorLabels()
        setupNewButtons()
        addElementsToView()
        
        // Setup service-specific button visibility
        updateServiceSpecificButtons()
    }
    
    private func setupServiceIndicatorLabels() {
        // Service Type Label
        serviceTypeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        serviceTypeLabel.textAlignment = .center
        serviceTypeLabel.numberOfLines = 0
        
        // Configuration Label  
        configurationLabel.font = UIFont.systemFont(ofSize: 14)
        configurationLabel.textAlignment = .center
        configurationLabel.numberOfLines = 0
        configurationLabel.textColor = .secondaryLabel
    }
    
    private func setupNewButtons() {
        // Settings Button
        settingsButton.setTitle("⚙️ Settings", for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        settingsButton.backgroundColor = UIColor.systemGray5
        settingsButton.setTitleColor(.label, for: .normal)
        settingsButton.layer.cornerRadius = cornerRadius
        settingsButton.addTarget(self, action: #selector(showSettings), for: .touchUpInside)
        
        // Vendor Consent Button
        vendorConsentButton.setTitle("🏪 Vendor Consent APIs", for: .normal)
        vendorConsentButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        vendorConsentButton.backgroundColor = UIColor.systemBlue
        vendorConsentButton.setTitleColor(.white, for: .normal)
        vendorConsentButton.layer.cornerRadius = cornerRadius
        vendorConsentButton.addTarget(self, action: #selector(showVendorConsent), for: .touchUpInside)
        
        // Set height constraints
        [settingsButton, vendorConsentButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }
    
    private func addElementsToView() {
        // Add labels to the top of the view
        serviceTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        configurationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(serviceTypeLabel)
        view.addSubview(configurationLabel)
        
        // Add buttons to the bottom of the view
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        vendorConsentButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(settingsButton)
        view.addSubview(vendorConsentButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Service labels at top
            serviceTypeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            serviceTypeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            serviceTypeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            configurationLabel.topAnchor.constraint(equalTo: serviceTypeLabel.bottomAnchor, constant: 4),
            configurationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            configurationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Buttons at bottom
            vendorConsentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            vendorConsentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            vendorConsentButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            settingsButton.bottomAnchor.constraint(equalTo: vendorConsentButton.topAnchor, constant: -12),
        ])
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
        Axeptio.shared.showConsentScreen()
    }
    
    @IBAction func showGoogleAd(_ sender: Any) {
        if interstitial != nil {
            interstitial?.present(fromRootViewController: self)
        }
    }

    @IBAction func clearConsent(_ sender: Any) {
        token = Axeptio.shared.axeptioToken
        Axeptio.shared.clearConsent()
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
        let consentData = Axeptio.shared.getConsentDebugInfo(preferenceKey:nil)
        
        let debugViewController = ConsentDebugViewController(data: consentData as! [String: Any?])
        let navController = UINavigationController(rootViewController: debugViewController)
        self.present(navController, animated: true)
    }
    
    @IBAction func showSettings(_ sender: Any) {
        let configViewController = ConfigurationViewController()
        configViewController.delegate = self
        let navController = UINavigationController(rootViewController: configViewController)
        self.present(navController, animated: true)
    }
    
    @IBAction func showVendorConsent(_ sender: Any) {
        let vendorViewController = VendorConsentViewController()
        let navController = UINavigationController(rootViewController: vendorViewController)
        self.present(navController, animated: true)
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

        guard #available(iOS 14, *) else {
            return
        }
        
        if ATTrackingManager.trackingAuthorizationStatus != .notDetermined {
            return
        }

        ATTrackingManager.requestTrackingAuthorization { [weak self] status in
            let isAuthorized = status == .authorized
            // We need to do that to manage a bug in iOS 17.4 about ATT
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                self?.addObserver()
                return
            }
            if isAuthorized {
                Axeptio.shared.setupUI()
            }
            
            Axeptio.shared.setUserDeniedTracking(denied: !isAuthorized)
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
