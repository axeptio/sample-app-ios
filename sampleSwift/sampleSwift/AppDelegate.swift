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
    static let targetService: AxeptioService = .brands
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Axeptio.shared.initialize(targetService: AppDelegate.targetService, clientId: "5fbfa806a0787d3985c6ee5f", cookiesVersion: "insideapp-brands")
        // Good token
        // Axeptio.shared.initialize(clientId: "5fbfa806a0787d3985c6ee5f", cookiesVersion: "google cmp partner program sandbox-en-EU", token: "5sj42u50ta2ys8c3nhjkxi")
        // Bad token
        // Axeptio.shared.initialize(clientId: "5fbfa806a0787d3985c6ee5f", cookiesVersion: "google cmp partner program sandbox-en-EU", token: "5sj42u50ta2ys8c3nhjkxidlkdlkmekmdlk")
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start()

        return true
    }
}
