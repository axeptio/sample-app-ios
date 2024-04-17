# Axeptio iOS SDK

Welcome to the **Axeptio** iOS SDK Samples project! This repository demonstrates how to implement the Axeptio Android SDK in your mobile applications.

## Overview

The project consists of two modules:

* `sampleSwift`: Illustrates the usage of the Axeptio SDK with Swift and Swift Package Manager.
* `sampleObjectiveC`: Demonstrates the integration of the Axeptio SDK with ObjectiveC and CocoaPods.

## Getting Started

**Axeptio** CMP ios sdk

To get started with implementing the Axeptio SDK in your iOS app, follow these steps:

Clone this repository to your local machine:
```shell
git clone https://github.com/axeptio/sample-app-ios
```

# Axeptio SDK implementation

For more details, you can refer to the [Github documentation]()

### Requirements

We offer our SDK as a pre-compiled binary package as a XCFramework that you can add to your application. We support iOS versions >= 15

### Add the SDK to your project

The package can be added using CocoaPods and Swift Package Manager

#### Using CocoaPods
The package can be added using CocoaPods:

Xcode >= 15 (XCFramework)

1. If you haven' already, install the latest version of [CocoaPods](https://guides.cocoapods.org/using/getting-started.html).
2. Add this line to your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '15.0'
use_frameworks!

target 'MyApp' do
  pod 'AxeptioTCFSDK'
end
```

#### Swift Package Manager
The iOS SDK is available throught Swift Package Manager as a binary library. In order to integrate it into your iOS project follow the instructions below:

* Open your Xcode project
* Select your project in the **navigator area**
* Select your project in **PROJECT** section
* Select the **Package Dependencies**
* Click on the **+** button
* Copy the package url 'https://github.com/axeptio/tcf-ios-sdk' into the search bar
* Select the **tcf-ios-sdk** package from the list
* Click on **Add Package**
* From the **Choose Package Products for the tcf-ios-sdk** screen click on Add Package


### Initialize the SDK 

In the `AppDelegate`, make sure to import the `AxeptioSDK` module, then call the `initialize` method and pass your API key, you can also initialize the sdk with the consent already set from an other device with the the token parameter :


#### Swift
```swift
import UIKit

import AxeptioSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // sample init
        Axeptio.shared.initialize(clientId: "<Your Client ID>", cookiesVersion: "<Your Cookies Version>")

        // or with a token set from an other device
        Axeptio.shared.initialize(clientId: "<Your Client ID>", cookiesVersion: "<Your Cookies Version>", token: "<Token>")

        return true
    }
}
```

#### Objective-C
```objc
#import "AppDelegate.h"

@import AxeptioSDK;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // sample init
    [Axeptio.shared initializeWithClientId:@"<Your Client ID>" cookiesVersion:@"<Your Cookeis Version>"];

    // or with a token set from an other device
    [Axeptio.shared initializeWithClientId:@"<Your Client ID>" cookiesVersion:@"<Your Cookeis Version>" token:@"<Token>"];

    return YES;
}

```

The SDK will automatically update the UserDefaults according to the TCFv2 [IAB Requirements](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details)


### Setup the SDK UI
> [!IMPORTANT]
> The setupUI method should be called only from your main/entry UIViewController which in most cases should be once per app launch. Therefore, by calling this method the consent notice and preference views will only be displayed if it is required and only once the SDK is ready.

In order for the SDK to be able to display UI elements and interact with the user, you must provide a reference to your main UIViewController. Make sure to import the Axeptio module and call the setupUI method in Swift, setupUIWithContainerController in Objective-C, of the SDK in the viewDidLoad method of your main UIViewController:

#### Swift 
```swift

import UIKit

import AxeptioSDK
​
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Axeptio.shared.setupUI()
    }
}
```

#### Objective-C
```objc

#import "ViewController.h"

@import AxeptioSDK;
​
@implementation ViewController
​
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Axeptio.shared setupUI];
}
​
@end
```

## SwiftUI

In order to use the Axeptio SDK in a SwiftUI app we suggest the following steps.

### Prepare UIViewController to call setupUI

Create a new Swift file. You can name it `AxeptioView`

```swift
import SwiftUI

import AxeptioSDK

// Create a new class that extends UIViewController.
// We need this to make sure we call the setupUI method when the viewDidAppear method is called.
class AxeptioViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Axeptio.shared.setupUI()
    }
}

// Inside the same file, create a struct that implements the UIViewControllerRepresentable protocol as shown below
struct AxeptioView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let axeptioViewController = AxeptioViewController()
        return axeptioViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
```

Prepare AppDelegate to call initialize method

To be able to use the UIApplicationDelegate functionality in a SwiftUI app and initialize the AxeptioSDK as early as possible, create a class that implements the UIApplicationDelegate.

* Create a new class that extends the UIApplicationDelegate protocol. Inside the `applicationDidFinishLaunchingWithOptions` method, call the Axeptio initialize method.

* Use the `UIApplicationDelegateAdaptor` property wrapper to connect this new struct with the `AppDelegate` class. Make sure this new struct uses the main annotation. Now you are ready to use the new `AxeptioView` struct that you created in the previous steps.

#### SwiftUI
```swift
import SwiftUI

import AxeptioSDK

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Axeptio.shared.initialize(clientId: "<Your Client ID>", cookiesVersion: "<Your Cookies Version>")
        return true
    }
}

@main
struct YourSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AxeptioView()
        }
    }
}
```


## App Tracking Transparency (iOS 14.5+)

The Axeptio SDK does not ask for the user permission for tracking in the ATT framework and it is the responsibility of the app to do so and to decide how the Axeptio CMP and the ATT permission should coexist.

Your app must follow [Apple's guidelines](https://developer.apple.com/app-store/user-privacy-and-data-use/) for disclosing the data collected by your app and asking for the user's permission for tracking. Permission for tracking on iOS can be asked by calling the `ATTrackingManager.requestTrackingAuthorization` function in your app.

### Integrate the CMP notice and ATT permission


#### Show consent popup on demand

This sample shows how to: 
* Show the Axeptio consent notice
* Show the ATT permission request if and only if: 
    * The iOS version is >= 14
    * The user has not made an ATT permission choice before and the choice is not [restricted](https://developer.apple.com/documentation/apptrackingtransparency/attrackingmanager/authorizationstatus/restricted) 

The CMP consent notice will always be displayed and the ATT permission will not show if the user denies consent to all purposes in the Axeptio consent notice. The ATT status will remain notDetermined. If the user denies ATT permission the CMP consent notice will close automatically.

#### Swift 
```swift
import UIKit
import AppTrackingTransparency

import AxeptioSDK
​
class ViewController: UIViewController {
 override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let axeptioEventListener = AxeptioEventListener()
        axeptioEventListener.onConsentChanged = {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    if status == .denied {
                        Axeptio.shared.setUserDeniedTracking()
                    }
                }
            }
        }
        Axeptio.shared.setEventListener(axeptioEventListener)
    }
}

```

#### Objective-C
```objc
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@import AxeptioSDK;

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    AxeptioEventListener *axeptioEventListener = [[AxeptioEventListener alloc] init];

    [axeptioEventListener setOnConsentChanged:^{

        if (@available(iOS 14, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                if (status == ATTrackingManagerAuthorizationStatusDenied) {
                    [Axeptio.shared setUserDeniedTracking];
                }
            }];
        }
    }];
    [Axeptio.shared setEventListener:axeptioEventListener];
}

@end
```


#### Show the ATT permission then the CMP notice if the user accepts the ATT permission

This sample shows how to: 
* Show the ATT permission request if iOS >= 14
* Show the Axeptio consent notice if and only if:: 
    * The iOS version is >= 15
    * The user accepted the ATT permission

The Axeptio consent notice will only be displayed if the user accepts the ATT permission OR the ATT permission cannot be displayed for any reason (restricted or iOS < 14).

#### Swift
```swift
import UIKit
import AppTrackingTransparency

import AxeptioSDK
​
class ViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                if status == .denied {
                    Axeptio.shared.setUserDeniedTracking()
                } else {
                    Axeptio.shared.setupUI()
                }
            }
        } else {
            // Show the Axeptio CMP notice to collect consent from the user as iOS < 14 (no ATT available)
            Axeptio.shared.setupUI()
        }
    }
}
```

#### Objective-C
```objc
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@import AxeptioSDK;

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            if (status == ATTrackingManagerAuthorizationStatusDenied) {
                [Axeptio.shared setUserDeniedTracking];
            } else {
                [Axeptio.shared setupUI];
            }
        }];
    } else {
        [Axeptio.shared setupUI];
    }
}

@end
```

### Show consent popup demand
You can request the consent popup to open on demand.

#### Swift
```swift
Axeptio.shared.showConsentScreen()
```
#### Objective-C
```objc
[Axeptio.shared showConsentScreen];
```

### Clear consent from UserDefault
A methode is available to clear consent from UserDefault.

#### Swift
```swift
Axeptio.shared.clearConsent()
```

#### Objective-C
```objc
[Axeptio.shared  clearConsent];
```

## Share consent with webviews

You can also add the SDK token or any other token to any URL:

- manually with the `axeptionToken` and `keyAxeptioTokenQueryItem` variables:
#### Swift
```swift
Axeptio.shared.axeptioToken
Axeptio.shared.keyAxeptioTokenQueryItem
```

```swift
var urlComponents = URLComponents(string: "<Your URL>")
urlComponents?.queryItems = [URLQueryItem(name: Axeptio.shared.keyAxeptioTokenQueryItem, value: <Axeptio.shared.axeptioToken or Your Token>)]
```
#### Objective-C
```objc
[Axeptio.shared axeptioToken];
[Axeptio.shared keyAxeptioTokenQueryItem];
```

```objc
NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:@"<Your URL>"];
urlComponents.queryItems = @[[NSURLQueryItem queryItemWithName:[Axeptio.shared keyAxeptioTokenQueryItem] value:[Axeptio.shared axeptioToken]]];
```

- automatically with the `appendAxeptioTokenToURL` function:  
#### Swift
```swift
let updatedURL = Axeptio.shared.appendAxeptioTokenToURL(<Your URL>, token: <Axeptio.shared.axeptioToken or Your Token>)
```

#### Objective-C
```objc
NSURL *updatedURL = [[Axeptio shared] appendAxeptioTokenToURL:<Your URL> token:<Axeptio.shared.axeptioToken or Your Token>];
```


## Events

The Axeptio SDK triggers various events to notify you that the user has taken some action.
This section describes what events are available and how to subscribe to them.

### addEventListener

Add an event listener to catch events triggered by the SDK. Events listeners allow you to react to different events of interest. 

When closing, the consent popup will trigger an event which you can listen by setting an AxeptioEventListener.
#### Swift
```swift
let axeptioEventListener = AxeptioEventListener()
axeptioEventListener.onPopupClosedEvent = {
    // The CMP notice is being hidden
    // Do something
}

axeptioEventListener.onConsentChanged = {
    // The consent status of the user has changed.
    // Do something
}

axeptioEventListener.onGoogleConsentModeUpdate = { consents in
    // The Google Consent V2 status
    // Do something
}

Axeptio.shared.setEventListener(axeptioEventListener)
```
#### Objective-C
```objc
 AxeptioEventListener *axeptioEventListener = [[AxeptioEventListener alloc] init];

[axeptioEventListener setOnPopupClosedEvent:^{
    // The CMP notice is being hidden
    // Do something
}];

[axeptioEventListener setOnConsentChanged:^{
    // The consent status of the user has changed.
    // Do something
}];

[axeptioEventListener setOnGoogleConsentModeUpdate:^(GoogleConsentV2 *consents) {
    // The Google Consent V2 status
    // Do something
}];

[Axeptio.shared setEventListener:axeptioEventListener];
```


#### Popup event

`onPopupClosedEvent`
When the consent notice is hidden.

`onConsentChanged`
When a consent is given by the user.

`onGoogleConsentModeUpdate`
When google consent is update bye the user.


## Google Consent Mode v2
Instructions on how to integrate Google Consent Mode with the Axeptio SDK in your Android application.

If you haven't already, add [Firebase Analytics](https://developers.google.com/tag-platform/security/guides/app-consent?hl=fr&consentmode=basic&platform=ios) to your iOS project.
Register to Google Consent updates

Axeptio SDK provides a callback to listen to Google Consent updates. You'll have to map the consent types and status to the corresponding Firebase models. You can then update Firebase analytics consents by calling Firebase analytics' setConsent().

#### Swift
```swift
axeptioEventListener.onGoogleConsentModeUpdate = { consents in
    Analytics.setConsent([
        .analyticsStorage: consents.analyticsStorage == GoogleConsentStatus.granted ? ConsentStatus.granted : ConsentStatus.denied,
        .adStorage: consents.adStorage == GoogleConsentStatus.denied ? ConsentStatus.granted : ConsentStatus.denied,
        .adUserData: consents.adUserData == GoogleConsentStatus.denied ? ConsentStatus.granted : ConsentStatus.denied,
        .adPersonalization: consents.adPersonalization == GoogleConsentStatus.denied ? ConsentStatus.granted : ConsentStatus.denied
    ])
}

```

#### Objective-C
```objective-c
[axeptioEventListener setOnGoogleConsentModeUpdate:^(GoogleConsentV2 *consents) {
      [FIRAnalytics setConsent:@{
        FIRConsentTypeAnalyticsStorage : [consents analyticsStorage] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
        FIRConsentTypeAdStorage : [consents adStorage] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
        FIRConsentTypeAdUserData : [consents adUserData] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
        FIRConsentTypeAdPersonalization : [consents adPersonalization] ? FIRConsentStatusGranted : FIRConsentStatusDenied
    }];
}];
```