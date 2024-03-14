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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        Axeptio.shared.initialize(projectId: "5fbfa806a0787d3985c6ee5f", configurationId: "62ac903ddf8cf90ca29d9585")

        FirebaseApp.configure()

        GADMobileAds.sharedInstance().start()

        return true
    }
}

