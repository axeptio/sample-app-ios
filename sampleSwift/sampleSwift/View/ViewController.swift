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
    
    private var interstitial: GADInterstitialAd?
    private let cornerRadius = 24.0
    private weak var observer: NSObjectProtocol?
    private var token: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        showConsentButton.layer.cornerRadius = cornerRadius
        tokenButton.layer.cornerRadius = cornerRadius
        userDefaultsButton.layer.cornerRadius = cornerRadius
        clearConsentButton.layer.cornerRadius = cornerRadius
        googleAdButton.layer.cornerRadius = cornerRadius
        consentDebugInfoButton?.layer.cornerRadius = cornerRadius
        googleAdSpinner.isHidden = true

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
        let sourceURL = AppDelegate.targetService == .publisherTcf ? "https://google-cmp-partner.axept.io/cmp-for-publishers.html" : "https://static.axept.io/app-sdk-webview-for-brands.html"
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
            present(webView, animated: true)
        }

        alertController.addAction(saveAction)
        alertController.addAction(.init(title: "Cancel", style: .cancel))

        present(alertController, animated: true)
    }
    
    @IBAction func showConsentDebugInfo(_ sender: Any) {
        let consentData = Axeptio.shared.getConsentDebugInfo(preferenceKey:nil)
        
        let debugViewController = ConsentDebugViewController(data: consentData)
        let navController = UINavigationController(rootViewController: debugViewController)
        self.present(navController, animated: true)
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
