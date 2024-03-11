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
    @IBOutlet weak var userDefaultsButton: UIButton!
    @IBOutlet weak var googleAdButton: UIButton!
    @IBOutlet weak var googleAdSpinner: UIActivityIndicatorView!
    
    private var interstitial: GADInterstitialAd?

    override func viewDidLoad() {
        super.viewDidLoad()

        showConsentButton.layer.cornerRadius = 24
        userDefaultsButton.layer.cornerRadius = 24
        googleAdButton.layer.cornerRadius = 24

        googleAdButton.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let axeptioEventListener = AxeptioEventListener()

        axeptioEventListener.onGoogleConsentModeUpdate = { consents in
            Analytics.setConsent([
                .analyticsStorage: consents.analyticsStorage == GoogleConsentStatus.granted ? ConsentStatus.granted : ConsentStatus.denied,
                .adStorage: consents.adStorage == GoogleConsentStatus.denied ? ConsentStatus.granted : ConsentStatus.denied,
                .adUserData: consents.adUserData == GoogleConsentStatus.denied ? ConsentStatus.granted : ConsentStatus.denied,
                .adPersonalization: consents.adPersonalization == GoogleConsentStatus.denied ? ConsentStatus.granted : ConsentStatus.denied
            ])
        }

        axeptioEventListener.onConsentChanged = {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    if status == .denied {
                        Axeptio.shared.setUserDeniedTracking()
                    }
                }
            }
        }

        axeptioEventListener.onPopupClosedEvent = {
            self.loadAd()
        }

        Axeptio.shared.setEventListener(axeptioEventListener)

        loadAd()

        Axeptio.shared.setupUI(containerController: self)
    }

    @IBAction func showConsent(_ sender: Any) {
        Axeptio.shared.showConsentScreen(self)
    }

    @IBAction func showGoogleAd(_ sender: Any) {
        if interstitial != nil {
            interstitial?.present(fromRootViewController: self)
        }
    }
}

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

                if let error = error {
                    print("error loading interstitial \(error.localizedDescription)")
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

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content with error \(error.localizedDescription)")
    }
}
