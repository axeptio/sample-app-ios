# ios SDK

**Axeptio** CMP iOS SDK

## Setup

Follow these steps to setup the Axeptio CMP iOS SDK:
* Requirements
* Add the SDK to your project
* Initialize the SDK
* Setup the SDK UI
* App Tracking Transparency (iOS 14.5+)
* Events


### Requirements

We offer our SDK as a pre-compiled binary package as a XCFramework that you can add to your application. We support iOS versions >= 12

### Add the SDK to your project

The package can be added using CocoaPods and Swift Package Manager

#### Using CocoaPods
The package can be added using CocoaPods:

Xcode >= 12 (XCFramework)

1. If you haven' already, install the latest version of CocoaPds.
2. Add this line to your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

target 'MyApp' do
  pod 'AxeptioSDK', '~> 0.5.0'
end
```

#### Swift Package Manager
The iOS SDK is available throught Swift Package Manager as a binary library. In order to integrate it into your iOS project follow the instructions below:

* Open your Xcode project
* Select your project in the **navigator area**
* Select your project in **PROJECT** section
* Select the **Package Dependencies**
* Click on the **+** button
* Copy the package url '' into the search bar
* Select the **tcf-ios-sdk** package from the list
* Click on **Add Package**
* From the **Choose Package Products for the axeptio-ios-sdk-spm** screen click on Add Package


### Initialize the SDK 

In the `AppDelegate`, make sure to import the `AxeptioSDK` module, then call the `initialize` method and pass your API key:


#### Swift
```swift
import UIKit

import AxeptioSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Axeptio.shared.initialize(projectId: "<Your Project ID>", configurationId: "<Your Configuration ID>")

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
    // Override point for customization after application launch.

    [Axeptio.shared initializeWithProjectId:@"<Your Project ID>" configurationId:@"<Your Configuration ID>"];

    return YES;
}

```

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
        
        Axeptio.shared.setupUI(containerController: self)
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
    
    [Axeptio.shared setupUIWithContainerController:self];
}
​
@end
```

The consent pop up will automatically open if the user's consents are expired or haven't been registered yet.

#### SwiftUI


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
    * The iOS version is >= 14
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
                    Axeptio.shared.setupUI(containerController: self)
                }
            }
        } else {
            // Show the Axeptio CMP notice to collect consent from the user as iOS < 14 (no ATT available)
            Axeptio.shared.setupUI(containerController: self)
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
                [Axeptio.shared setupUIWithContainerController:self];
            }
        }];
    } else {
        [Axeptio.shared setupUIWithContainerController:self];
    }
}

@end
```

### Show consent popup demand
Additionally, you can request the consent popup to open on demand.

#### Swift
```swift
Axeptio.shared.showConsentScreen(self)
```
#### Objective-C
```objc
[Axeptio.shared showConsentScreen:self];
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