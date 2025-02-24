<h1>
  <img src="https://axeptio.imgix.net/2024/07/e444a7b2-ea3d-4471-a91c-6be23e0c3cbb.png" alt="Descrizione immagine" width="80" style="vertical-align: middle; margin-right: 10px;" />
  Axeptio iOS SDK Documentation
</h1>

![License](https://img.shields.io/badge/license-Apache%202.0-blue) ![iOS version >= 15](https://img.shields.io/badge/iOS%20version-%3E%3D%2015-green) ![Platform](https://img.shields.io/badge/platform-iOS-blue) ![GitHub Stars](https://img.shields.io/github/stars/axeptio/sample-app-ios?style=social) ![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)




Welcome to the **Axeptio iOS SDK Samples project!** This repository provides a comprehensive guide on how to integrate the **Axeptio iOS SDK** into your mobile applications. It showcases two distinct modules: one for **Swift** using Swift Package Manager and one for **Objective-C** using CocoaPods. Below you'll find detailed instructions and code examples to help you integrate and configure the SDK within your iOS app.

## 📑 Table of Contents
1. [GitHub Access Token Documentation](#github-access-token-documentation)
2. [Requirements](#requirements)
3. [Clone the repository](#clone-the-repository)
4. [Adding the SDK](#adding-the-sdk)
   - [Using CocoaPods](#using-cocoapods)
   - [Using Swift Package Manager](#using-swift-package-manager)
5. [Initializing the SDK](#initializing-the-sdk)
   - [Swift](#swift)
   - [Objective-C](#objective-c)
6. [Set up the SDK UI](#set-up-the-sdk-ui)
   - [Swift](#swift)
   - [Objective-C](#objective-c)
     - [Issues with the Consent Popup (Objective-C)](#issues-with-the-consent-popup-objective-c)
   - [SwiftUI Integration](#swiftui-integration)
7. [Axeptio SDK and App Tracking Transparency (ATT) Integration](#axeptio-sdk-and-app-tracking-transparency-att-integration)
   - [Swift Integration](#swift-integration)
   - [Objective-C Integration](#objective-c-integration)
8. [Responsibilities Mobile App vs SDK](#responsibilities-mobile-app-vs-sdk)
9. [Retrieving Stored Consents](#retrieving-stored-consents)
10. [Show Consent Popup on Demand](#show-consent-popup-on-demand)
11. [Clearing Consent from `UserDefaults`](#clearing-consent-from-userdefaults)
12. [Sharing Consent with Webviews](#sharing-consent-with-webviews)
    - [Manual Token Addition](#manual-token-addition)
    - [Automatic Token Addition](#automatic-token-addition)
13. [Events Overview](#events-overview)
14. [Event Descriptions](#event-descriptions)
15. [How to Receive Events](#how-to-receive-events)
16. [Google Consent Mode v2 Integration with Axeptio SDK](#google-consent-mode-v2-integration-with-axeptio-sdk)
17. [Google AdMob Integration with Axeptio SDK](#google-admob-integration-with-axeptio-sdk)

<br><br>

## GitHub Access Token Documentation
When setting up your project or accessing certain GitHub services, you may be prompted to create a GitHub Access Token. However, it's important to note that generating a GitHub access token requires a valid GitHub account and the enabling of two-factor authentication (2FA).

As a developer, you may not be immediately aware of these requirements, which could lead to confusion or authentication issues. To streamline the process, we recommend reviewing the official [GitHub Access Token Documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) for detailed instructions on how to create a token. This guide will also clarify prerequisites such as the need for a validated GitHub account and the necessity of enabling 2FA.

By following these instructions, you'll be able to generate a GitHub Access Token smoothly, reducing any onboarding friction and avoiding potential authentication problems down the line.
<br><br><br>

## 🧐Requirements
The Axeptio iOS SDK is distributed as a pre-compiled binary package, delivered as an `XCFramework`. It supports iOS versions >= 15.

Before starting, make sure you have:

- Xcode >= 15
- CocoaPods or Swift Package Manager for dependency management.

**Note:** Please be aware that it is not possible to test a custom banner without an active and valid Axeptio plan. A valid Axeptio plan is required to configure and preview custom consent banners during development.

Ensure the **following keys** are added to your `Info.plist` file to comply with app tracking and security policies:
```xml
<key>NSUserTrackingUsageDescription</key>
<string>Your data will be used to deliver personalized ads to you.</string>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```
<br><br><br>
## 🔧Clone the Repository
To get started, clone the repository to your local machine:

```bash
git clone https://github.com/axeptio/sample-app-ios
```
<br><br><br>
## Adding the SDK
The package can be added to your project using either **CocoaPods** or **Swift Package Manager**. Both dependency managers for iOS and are supported by the Axeptio SDK.

### Using CocoaPods
If your project uses CocoaPods, you can easily add the Axeptio SDK by following these steps:
##### Prerequisites
- Xcode version 15 or later
- CocoaPods version compatible with XCFrameworks (latest version recommended), if you haven' already, install the latest version of [CocoaPods](https://guides.cocoapods.org/using/getting-started.html)
##### Steps
- Open your `Podfile` in the root directory of your project
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '15.0'
use_frameworks!

target 'MyApp' do
  pod 'AxeptioIOSSDK'
end
```
- run the following command to install the dependency:
```bash
pod install
```

### Using Swift Package Manager
To integrate the Axeptio iOS SDK into your Xcode project using Swift Package Manager, follow these steps:
##### Steps
- Open your Xcode project.
- In the **Project Navigator**, select your project
- Under the **PROJECT** section, navigate to the Package Dependencies tab
- Click the **+** button to add a new package dependency
- In the search bar, paste the following package URL: `https://github.com/axeptio/axeptio-ios-sdk`
- Select the **AxeptioIOSSDK** package from the list of available packages
- Click Add Package.
- In the **Choose Package Products screen**, confirm the selection and click **Add Package** to complete the integration
<br><br><br>
## 🔧Initializing the SDK
To initialize the Axeptio SDK in your iOS project, import the `AxeptioSDK` module into your `AppDelegate` and initialize the SDK with the appropriate configuration. 

### Swift
```swift
import UIKit
import AxeptioSDK

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Registra l'identificatore della cella per UserDefaultsCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserDefaultsCell")
        
        // Chiamata di setupUI per mostrare il popup di consenso quando appropriato
        Axeptio.shared.setupUI()
    }

    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserDefaultsCell", for: indexPath)
        cell.textLabel?.text = "UserDefaults Button"
        return cell
    }
}
```
### Objective-C
```objc
#import "AppDelegate.h"

@import AxeptioSDK;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    AxeptioService targetService = AxeptioServiceBrands; // or AxeptioServicePublisherTcf
    // sample init
    [Axeptio.shared initializeWithTargetService:targetServiceclientId:@"<Your Client ID>" cookiesVersion:@"<Your Cookies Version>"];

    // or with a token set from an other device
    [Axeptio.shared initializeWithTargetService:targetServiceclientId:@"<Your Client ID>" cookiesVersion:@"<Your Cookies Version>" token:@"<Token>"];

    return YES;
}
```
<br><br><br>
## 🔧Set up the SDK UI
> **[!IMPORTANT]** The `setupUI` method should be invoked **only** from your main/entry `UIViewController`, typically once during the application launch. By calling this method, the consent notice and preference views will be displayed **only if necessary** and **once the SDK is fully initialized**.

In order to display the consent and preference views and interact with the user, ensure that the `setupUI` method is called from your main `UIViewController`. The consent popup and preferences management will be shown based on the SDK initialization and the user's consent requirements.

### Swift
```swift
import UIKit

import AxeptioSDK
​
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Axeptio.shared.setupUI()
    }
```
}

### Objective-C
```objc
#import "ViewController.h"
@import AxeptioSDK;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize the UI elements required for consent display
    [Axeptio.shared setupUI];  // Ensure that this is called from your main view controller
}

@end
```
#### 🔧Issues with the Consent Popup (Objective-C)
If the consent popup is not appearing as expected, follow these steps to troubleshoot and resolve the issue:

###### Ensure Correct SDK Initialization in AppDelegate:
Verify that the SDK is properly initialized in the `AppDelegate.m` file with the correct `clientId` and `cookiesVersion`
```objc
#import "AppDelegate.h"
@import AxeptioSDK;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    AxeptioService targetService = AxeptioServiceBrands; // Or use AxeptioServicePublisherTcf if required

    // Initialize with the provided Client ID and Cookies Version
    [Axeptio.shared initializeWithTargetService:targetService
                                    clientId:@"<Your Client ID>"
                                cookiesVersion:@"<Your Cookies Version>"];

    // Optional: Initialize with a Token from another device
    [Axeptio.shared initializeWithTargetService:targetService
                                    clientId:@"<Your Client ID>"
                                cookiesVersion:@"<Your Cookies Version>"
                                          token:@"<Token>"];

    return YES;
}

@end
```
##### Correctly Calling `setupUI` from Main `UIViewController`:
Ensure that the `setupUI` method is called from your main view controller (usually in `viewDidLoad` or a similar lifecycle method) to properly trigger the consent popup display.
```objc
#import "ViewController.h"
@import AxeptioSDK;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Call setupUI to show the consent popup when appropriate
    [Axeptio.shared setupUI];  
}

@end
```

##### Check for Potential UI Blockers
If the consent popup is not showing, check if other views or modals are blocking it. Temporarily disable any other views that might interfere with the consent view to ensure it is not being hidden.

##### Verify Event Logging for Popup Request:
Add a logging statement to confirm that the SDK is triggering the popup:
```objc
[Axeptio.shared setupUI];
NSLog(@"Consent popup triggered successfully");
```
##### Ensure Proper Event Listeners are Set Up
If you are using event listeners to capture actions like the consent popup being closed, ensure that they are properly implemented and assigned.
```objc
AxeptioEventListener *axeptioEventListener = [[AxeptioEventListener alloc] init];
[axeptioEventListener setOnPopupClosedEvent:^{
    NSLog(@"Consent popup closed by the user");
}];
[Axeptio.shared setEventListener:axeptioEventListener];
```
##### SDK Version
Ensure that you are using the latest version of the Axeptio SDK. Outdated versions might contain bugs that affect the popup behavior.

### SwiftUI Integration

##### Create a UIViewController subclass to call `setupUI()`
To integrate the Axeptio SDK into a SwiftUI app, first, create a subclass of `UIViewController` to invoke the SDK's `setupUI()` method. This view controller will later be integrated into SwiftUI using `UIViewControllerRepresentable`.
```swift
import SwiftUI
import AxeptioSDK

// Custom UIViewController to handle the SDK UI
class AxeptioViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Call the setupUI method of the SDK to show the consent popup
        Axeptio.shared.setupUI()
    }
}
```

##### Create a `UIViewControllerRepresentable` struct
Next, create a struct that conforms to the `UIViewControllerRepresentable` protocol to integrate the custom `UIViewController` into the SwiftUI view hierarchy. This struct will allow you to display the `AxeptioViewController` as a SwiftUI view.
```swift
// Struct to integrate AxeptioViewController into SwiftUI
struct AxeptioView: UIViewControllerRepresentable {

    // Create the custom UIViewController
    func makeUIViewController(context: Context) -> some UIViewController {
        return AxeptioViewController()
    }

    // Required method, but not used in this case
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
```
##### Connect with the AppDelegate using `UIApplicationDelegateAdaptor`
In SwiftUI, to properly set up the application and initialize the SDK, you'll need an entry point that implements the initialization logic in the `AppDelegate`. Use `UIApplicationDelegateAdaptor` to connect your `AppDelegate` to the SwiftUI app structure.
```swift
import SwiftUI
import AxeptioSDK

// AppDelegate that initializes the SDK
class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // Initialize the Axeptio SDK with the Client ID and cookies version
        Axeptio.shared.initialize(clientId: "<Your Client ID>", cookiesVersion: "<Your Cookies Version>")

        return true
    }
}

// Main SwiftUI app structure
@main
struct YourSwiftUIApp: App {
    // Bind the AppDelegate to the SwiftUI app structure
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            // Display the AxeptioView which contains the custom UIViewController
            AxeptioView()
        }
    }
}
```
By following these steps, the Axeptio SDK will be correctly integrated into a SwiftUI app, and the logic for displaying the consent popup will be handled inside `viewDidAppear()` within the custom `UIViewController`
<br><br><br>
## 🚀Axeptio SDK and App Tracking Transparency (ATT) Integration

Starting with iOS 14.5, Apple introduced the App Tracking Transparency (ATT) framework, which requires apps to request user consent before tracking their data across other apps and websites. The Axeptio SDK does **not** automatically handle ATT permission requests, and it is your responsibility to ask for user consent for tracking and manage how the Axeptio Consent Management Platform (CMP) interacts with the ATT permission.

This steps will show you how to:

- Request ATT permission.
- Display the Axeptio consent notice after the user has accepted the ATT permission.
- Handle cases where ATT permission is not requested or denied, and show the Axeptio CMP accordingly.

#### Overview

The Axeptio SDK does not ask for the user’s tracking permission using the ATT framework. It is your responsibility to request this permission, and the way in which the ATT framework and Axeptio CMP interact depends on your app's logic.

In apps targeting iOS 14.5 and above, you must use the `ATTrackingManager.requestTrackingAuthorization` function to ask for tracking consent. Based on the user’s response, you can choose to show the Axeptio consent notice.

#### Expected Flow:

1. **ATT Permission**: Show the ATT permission dialog if the iOS version is 14 or later.
2. **Axeptio Consent Notice**: Show the Axeptio consent notice if:
   - iOS version is >= 15.
   - The user accepts the ATT permission.
3. **Fallback**: If the ATT permission cannot be displayed (e.g., restricted, iOS < 14, or user denied permission), you can still show the Axeptio CMP.

## Swift Integration

Below is the complete Swift code to handle the ATT permission and initialize the Axeptio CMP.

#### Request ATT Permission and Show Axeptio CMP

```swift
import UIKit
import AppTrackingTransparency
import AxeptioSDK

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            await handleATTAndInitializeAxeptioCMP()
        }
    }

    private func handleATTAndInitializeAxeptioCMP() async {
        if #available(iOS 14, *) {
            let status = await ATTrackingManager.requestTrackingAuthorization()
            let isAuthorized = (status == .authorized)
            initializeAxeptioCMPUI(granted: isAuthorized)
        } else {
            initializeAxeptioCMPUI(granted: true)  // ATT not required for iOS < 14
        }
    }

    private func initializeAxeptioCMPUI(granted: Bool) {
        if granted {
            // Initialize Axeptio CMP UI if ATT permission is granted
            Axeptio.shared.setupUI()
        } else {
            // Handle case where user denies permission or ATT is restricted
            Axeptio.shared.setUserDeniedTracking()
        }
    }
}
```
#### Key Points:
- `ATTrackingManager.requestTrackingAuthorization`: Requests permission for tracking and returns the status.
- `Axeptio.shared.setupUI()`: Initializes and shows the consent notice once ATT permission is granted.
- **Fallback Handling**: If ATT permission is denied or unavailable, the Axeptio CMP can still be initialized depending on your requirements (e.g., on iOS versions before 14).

#### iOS 14 and Above:
- ATT framework is only available for iOS 14 and later.
- If the app is running on iOS 14+, it will request the ATT permission.
- the user grants permission, you can show the Axeptio consent notice using `Axeptio.shared.setupUI()`.

## Objective-C Integration
For Objective-C, the implementation is quite similar. You’ll request ATT permission and initialize the Axeptio CMP based on the user's response.
#### Request ATT Permission and Show Axeptio CMP

```objc
#import <AppTrackingTransparency/AppTrackingTransparency.h>
@import AxeptioSDK;

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (@available(iOS 14, *)) {
        // Request ATT permission if on iOS >= 14
        [self requestTrackingAuthorization];
    } else {
        // Initialize Axeptio CMP if on iOS < 14 (ATT not required)
        [Axeptio.shared setupUI];
    }
}

- (void)requestTrackingAuthorization {
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        BOOL isAuthorized = (status == ATTrackingManagerAuthorizationStatusAuthorized);
        [self initializeAxeptioCMPUI:isAuthorized];
    }];
}

- (void)initializeAxeptioCMPUI:(BOOL)granted {
    if (granted) {
        // Initialize Axeptio CMP UI if ATT permission is granted
        [Axeptio.shared setupUI];
    } else {
        // Handle case where user denies permission or ATT is restricted
        [Axeptio.shared setUserDeniedTracking];
    }
}

@end
```
#### Key Points:
- `ATTrackingManager.requestTrackingAuthorizationWithCompletionHandler`: This method requests ATT permission and provides a callback with the status of the request.
- `Axeptio.shared.setupUI()`: This method initializes and shows the consent notice after the user has granted ATT permission.
- **Fallback Handling**: Similar to the Swift implementation, you can still show the Axeptio CMP even if the ATT permission is not granted or not available.

#### Importante Notes:
- **ATT Request Flow**: The ATT request must be shown at an appropriate time in your app flow, typically when the user first opens the app or at a point where they can make an informed decision.
- **IOS 14+**: The ATT framework is only available on iOS 14 and later. For earlier versions of iOS, you can proceed with displaying the Axeptio consent notice without needing ATT permission.
- **Data Collection Disclosure**: Apple's App Store guidelines require you to disclose what data your app collects and how it uses it. Ensure your app’s privacy policy is up to date, and provide clear information on what data is being collected for tracking purposes.

#### Useful Links
- [Apple’s App Tracking Transparency Documentation](https://developer.apple.com/documentation/apptrackingtransparency)
- [Apple's App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

<br><br><br>
## Responsibilities Mobile App vs SDK

The integration of the Axeptio SDK into your mobile application involves clear delineation of responsibilities between the mobile app and the SDK itself. Below are the distinct roles for each in handling user consent and tracking.

#### **Mobile Application Responsibilities:**

1. **Managing App Tracking Transparency (ATT) Flow:**
   - The mobile app is responsible for initiating and managing the ATT authorization process on iOS 14 and later. This includes presenting the ATT request prompt at an appropriate time in the app's lifecycle.

2. **Controlling the Display Sequence of ATT and CMP:**
   - The app must determine the appropriate sequence for displaying the ATT prompt and the Axeptio consent management platform (CMP). Specifically, the app should request ATT consent before invoking the Axeptio CMP.

3. **Compliance with App Store Privacy Labels:**
   - The app must ensure accurate and up-to-date declarations of data collection practices according to Apple’s privacy label requirements, ensuring full transparency to users about data usage.

4. **Event Handling and User Consent Updates:**
   - The app is responsible for handling SDK events such as user consent actions. Based on these events, the app must adjust its behavior accordingly, ensuring that user consent is respected across sessions.

#### **Axeptio SDK Responsibilities:**

1. **Displaying the Consent Management Interface:**
   - The Axeptio SDK is responsible for rendering the user interface for the consent management platform (CMP) once triggered. It provides a customizable interface for users to give or revoke consent.

2. **Storing and Managing User Consent Choices:**
   - The SDK securely stores and manages user consent choices, maintaining a persistent record that can be referenced throughout the app's lifecycle.

3. **Sending Consent Status via APIs:**
   - The SDK facilitates communication of the user's consent status through APIs, allowing the app to be updated with the user’s preferences.

4. **No Implicit Handling of ATT Permissions:**
   - The Axeptio SDK does **not** manage the App Tracking Transparency (ATT) permission flow. It is the host app's responsibility to request and handle ATT permissions explicitly before displaying the consent management interface. The SDK functions only once the ATT permission is granted (or bypassed due to platform restrictions).
<br><br><br>
## Retrieving Stored Consents

To retrieve user consent preferences stored by the Axeptio SDK, you can access the data stored in the `UserDefaults`. The SDK automatically stores consent information in `UserDefaults`, making it accessible for the app to retrieve whenever necessary.

#### **Retrieving Consents in Swift:**

In Swift, you can access the stored consents by using the `UserDefaults` API. This allows you to query specific consent keys, such as the one you previously stored when the user made their choices.

```swift
let consent = UserDefaults.standard.object(forKey: "Key")
```
This will return the consent data associated with the provided key. Ensure that you know the specific key associated with the consent data you're trying to access.

#### **Retrieving Consents in Objective-C:**
In Objective-C, you can access the stored consents using the `NSUserDefaults` class. The following code demonstrates how to retrieve the consent data stored in `NSUserDefaults`:
```objc
id consent = [[NSUserDefaults standardUserDefaults] objectForKey:@"Key"];
```
This will return the consent information associated with the specified key.

For a more detailed breakdown of how the Axeptio SDK handles stored consent values, including cookie management and other privacy-related data, please refer to the [Axeptio SDK Documentation](https://support.axeptio.eu/hc/en-gb/articles/8558526367249-Does-Axeptio-deposit-cookies).
<br><br><br>
## Show Consent Popup on Demand

You can request the consent popup to be displayed programmatically at any point in your app’s lifecycle. This can be useful when you need to show the consent screen after a specific user action or event, rather than automatically when the app starts.
- This method will display the consent management platform (CMP) UI based on the user's current consent status.
- Make sure to trigger the consent popup at the appropriate moment to avoid interrupting the user experience.
- The consent popup can be triggered even after the app has been launched and after the consent has already been obtained, allowing you to ask for consent again if necessary.

#### Swift Implementation:
To trigger the consent popup on demand in Swift, you can call the `showConsentScreen()` method on the `Axeptio.shared` instance:

```swift
Axeptio.shared.showConsentScreen()
```
#### Objective-C Implementation

Similarly, in Objective-C, the same method can be invoked to show the consent screen on demand:
```objc
[Axeptio.shared showConsentScreen];
```
<br><br><br>
## Clearing Consent from `UserDefaults`

A method is provided to clear the stored consent information from `UserDefaults`. This allows you to reset the user's consent status and remove any previously stored preferences.
- This method will remove the stored consent data, which may include preferences or other consent-related information stored in UserDefaults.
- It's useful for scenarios where the user needs to update their consent choices or when you want to reset consent state for any other reason.
- Once consent is cleared, the app may re-prompt the user for consent based on the current configuration or flow.

#### Swift Implementation:
To clear the consent from `UserDefaults` in Swift, simply invoke the `clearConsent()` method on the shared `Axeptio` instance:

```swift
Axeptio.shared.clearConsent()
```
#### Objective-C Implementation:
Similarly, in Objective-C, you can call the clearConsent method on the shared Axeptio instance to remove the stored consent:
```objc
[Axeptio.shared clearConsent];
```
<br><br><br>
## Sharing Consent with Webviews

This functionality is available only for the **Publishers Service**. It allows you to pass the consent token to webviews or external URLs to maintain consistency across platforms. You can append the `axeptioToken` to any URL to share the user’s consent status.
##### Key Points:
- **Manual Approach:** Developers can append the `axeptioToken` and query item manually to any URL using the standard `URLComponents` method.
- **Automatic Approach:** Use the `appendAxeptioTokenToURL` function to automatically append the token to any URL.
- **Publisher's Service:** This feature is available only for the Publishers service in Axeptio.
  
### Manual Token Addition
You can manually append the `axeptioToken` to any URL using the `axeptioToken` and `keyAxeptioTokenQueryItem` properties.

#### Swift Implementation:
```swift
// Access the token and query item name
let axeptioToken = Axeptio.shared.axeptioToken
let keyAxeptioTokenQueryItem = Axeptio.shared.keyAxeptioTokenQueryItem

// Append the token to the URL
var urlComponents = URLComponents(string: "<Your URL>")
urlComponents?.queryItems = [
    URLQueryItem(name: keyAxeptioTokenQueryItem, value: axeptioToken)
]

// Construct the updated URL with the appended token
let updatedURL = urlComponents?.url
```

#### Objective-C Implementation:
```objc
// Access the token and query item name
NSString *axeptioToken = [Axeptio.shared axeptioToken];
NSString *keyAxeptioTokenQueryItem = [Axeptio.shared keyAxeptioTokenQueryItem];

// Append the token to the URL
NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:@"<Your URL>"];
urlComponents.queryItems = @[
    [NSURLQueryItem queryItemWithName:keyAxeptioTokenQueryItem value:axeptioToken]
];

// Construct the updated URL with the appended token
NSURL *updatedURL = urlComponents.URL;
```
### Automatic Token Addition
Alternatively, you can use the `appendAxeptioTokenToURL` method to automatically append the token to the URL.

#### Swift Implementation:
```swift
// Automatically append the consent token to the URL
let updatedURL = Axeptio.shared.appendAxeptioTokenToURL("<Your URL>", token: Axeptio.shared.axeptioToken)
```
#### Objective-C Implementation:
```objc
// Automatically append the consent token to the URL
NSURL *updatedURL = [Axeptio.shared appendAxeptioTokenToURL:@"<Your URL>" token:[Axeptio.shared axeptioToken]];
```
### SDK Events - Handling User Consent and Tracking

The Axeptio SDK provides various events to notify your application when the user interacts with the consent management platform (CMP). By subscribing to these events, you can track consent status changes, consent popup visibility, and updates to Google Consent Mode. This section explains how to subscribe to and handle these events.
<br><br><br>
## 🚀Events Overview

#### Available Events
1. **onPopupClosedEvent**  
   This event is triggered when the consent popup is closed. You can use this event to perform actions after the consent popup is dismissed, such as storing consent status or updating app behavior based on user preferences.

2. **onConsentChanged**  
   This event is triggered when the user gives or updates their consent. It allows you to handle the changes in user consent status, enabling you to take appropriate actions in your app.

3. **onGoogleConsentModeUpdate**  
   This event is triggered when the Google Consent V2 status is updated. It allows you to react to changes in Google’s consent mode, which can affect tracking behaviors and user data processing preferences.

### Using AxeptioEventListener to Subscribe to Events

#### Swift Integration

To handle events in Swift, you need to create an `AxeptioEventListener` instance and set event handlers for the desired events.

```swift
let axeptioEventListener = AxeptioEventListener()

// Handle popup closed event
axeptioEventListener.onPopupClosedEvent = {
    // Actions to take when the consent popup is closed
    // Retrieve consents from UserDefaults
    // Check user preferences
    // Run external processes or services based on user consents
}

// Handle consent changed event
axeptioEventListener.onConsentChanged = {
    // Actions to take when the user consent status changes
    // For example, trigger analytics, update UI, or change app behavior
}

// Handle Google Consent Mode update event
axeptioEventListener.onGoogleConsentModeUpdate = { consents in
    // Actions to take when the Google Consent V2 status is updated
    // Example: Update tracking configuration based on new consent mode status
}

Axeptio.shared.setEventListener(axeptioEventListener)
```

#### Objective-C Integration
For Objective-C, you can set up the `AxeptioEventListener` and subscribe to the events similarly.
```objc
AxeptioEventListener *axeptioEventListener = [[AxeptioEventListener alloc] init];

// Handle popup closed event
[axeptioEventListener setOnPopupClosedEvent:^{
    // Actions to take when the consent popup is closed
    // For example, store consent data or update app behavior
}];

// Handle consent changed event
[axeptioEventListener setOnConsentChanged:^{
    // Actions to take when the user changes their consent
    // Example: Update app functionality based on new consent status
}];

// Handle Google Consent Mode update event
[axeptioEventListener setOnGoogleConsentModeUpdate:^(GoogleConsentV2 *consents) {
    // Actions to take when the Google Consent V2 status is updated
    // Example: Adjust app tracking based on Google's updated consent mode
}];

[Axeptio.shared setEventListener:axeptioEventListener];
```
<br><br><br>
## 🚀Event Descriptions

#### `onPopupClosedEvent`
- **Description**: This event is triggered when the consent popup is closed, either by the user granting or denying consent.
- **Use Case**: You can use this event to perform any actions after the user has seen or interacted with the consent popup, such as storing consent preferences, updating the UI, or triggering other processes based on user consent.

#### `onConsentChanged`
- **Description**: This event is triggered when a user’s consent changes. This could happen when a user grants or revokes consent, or updates their consent preferences.
- **Use Case**: You can use this event to track changes in user consent status, update app behavior based on new consent, or trigger specific services according to user preferences.

#### `onGoogleConsentModeUpdate`
- **Description**: This event is triggered when the Google Consent Mode is updated. It provides information on how Google’s consent management framework has changed, such as when a user grants or withdraws consent for Google’s tracking technologies.
- **Use Case**: If your app integrates with Google services (e.g., Google Analytics or AdSense), you can use this event to update your tracking configuration or handle user data processing preferences according to Google’s consent mode.

### Event Handling Best Practices

#### Popup Visibility
Ensure that the consent popup is shown at an appropriate time to avoid interrupting the user experience. Use `onPopupClosedEvent` to determine when the user has seen or interacted with the consent popup, and avoid displaying it again unnecessarily.

#### User Consent Flow
Consider how the `onConsentChanged` event integrates into your app’s data processing workflow. Ensure that your app adapts its behavior according to the user’s preferences, such as enabling/disabling tracking or collecting personal data.

#### Google Consent Mode
Use the `onGoogleConsentModeUpdate` event to monitor and respond to changes in Google’s consent status. This ensures that your app aligns with Google’s tracking and data collection policies based on the user’s consent.

By using `AxeptioEventListener` to listen for consent-related events, you can effectively manage user consent in your app, ensure compliance with privacy regulations, and improve the user experience. The SDK triggers these events based on user actions, so you can tailor your app’s functionality to respect the user’s consent preferences.

### Event Handling with the Axeptio SDK

Integrating Axeptio into your iOS app includes managing user consent and cookie configuration events. To facilitate this, the Axeptio SDK triggers events that can be received by the host app. In this section, we'll explore how to receive and manage these events, including options for handling them via callbacks, publishers (using Combine), and delegates.

#### Event Types

Some of the events Axeptio can send include:

- **app:cookies:ready**: Indicates that the SDK is ready to manage consent for cookies, with a payload describing the current state (e.g., whether the CMP is visible or not).

  Example payload:
```json
  {
    "name": "app:cookies:ready",
    "payload": "{\"showCmp\":false,\"reason\":\"The subscription does not allow the use of the SDK app mode\"}"
  }
 ```
These events are sent by the system to notify the host app that the user has interacted with the consent system or that an action related to consent has been completed.
<br><br><br>

## How to Receive Events

To listen for events sent by the SDK, you can use one of the following approaches:

#### Callback (Closure)
The simplest way to receive events is by using a closure callback. You can define a property of type closure to handle the event and its associated payload.
**Implementation Example:**
```swift
public class Axeptio {
    public var onEventReceived: ((Result<Payload, Error>) -> Void)?
    
    func someMethod() {
        // Send success event
        onEventReceived?(.success(payloadObject))
        
        // Send failure event
        onEventReceived?(.failure(error))
    }
}

// *** Usage in host app:
Axeptio.shared.onEventReceived = { [weak self] result in
    switch result {
    case .success(let payload):
        // Handle the received payload
    case .failure(let error):
        // Handle the error
    }
}
```
In this example, the host app can listen to the event and respond accordingly, either by handling the payload or managing errors.
#### Publisher (Combine Framework)
If your app uses the Combine framework, you can take advantage of a PassthroughSubject to send and receive events. This approach is helpful if your app is already designed to use Combine.
**Implementation Example**
```swift
import Combine

public class Axeptio {
    public static let shared = Axeptio()
    public var onConsentEvent = PassthroughSubject<Payload, Never>()
    
    func someMethod() {
        // Send the event via publisher
        onConsentEvent.send(payloadObject)
    }
}

// *** Usage in host app:
Axeptio.shared.onConsentEvent
    .sink { [weak self] event in
        // Handle the received event
    }
```
In this case, the host app uses the `sink` method to receive the payload and handle the event.
#### Delegate (Protocol)
Another possible approach is to use a **delegate protocol** to receive events. This method is particularly useful if you want to centralize event management in a delegate object.

**Implementation Example:**
```swift
public protocol AxeptioEventDelegate: AnyObject {
    func didReceiveEvent(_ event: Payload)
    func didFailWithError(_ error: Error)
}

public class Axeptio {
    public static let shared = Axeptio()
    public weak var delegate: AxeptioEventDelegate?
    
    func someMethod() {
        // Notify the delegate of the event
        delegate?.didReceiveEvent(payloadObject)
        
        // Notify the delegate of an error
        delegate?.didFailWithError(error)
    }
}

// *** Usage in host app:
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegate
        Axeptio.shared.delegate = self
    }
}

// MARK: - AxeptioEventDelegate methods
extension ViewController: AxeptioEventDelegate {
    func didReceiveEvent(_ event: Payload) {
        // Handle the received event
    }
    
    func didFailWithError(_ error: Error) {
        // Handle the error
    }
}
```
In this example, the host app implements the AxeptioEventDelegate protocol and receives events through the delegate.




<br><br><br>
## 🚀Google Consent Mode v2 Integration with Axeptio SDK

This steps explains how to integrate Google Consent Mode v2 with the Axeptio SDK for managing user consent within your iOS application. It covers Firebase Analytics integration and provides code examples in both Swift and Objective-C.

#### Prerequisites

Before starting the integration, ensure that:

- Firebase Analytics is already added to your iOS project.
  - [Firebase Analytics SDK Documentation](https://firebase.google.com/docs/analytics)
  
- You have integrated the [Axeptio SDK](https://www.axeptio.eu/en/).
  - [Axeptio SDK Documentation](https://support.axeptio.eu/hc/en-gb)

#### Overview

When user consent is collected through your Consent Management Platform (CMP), the Axeptio SDK triggers the necessary events and updates Firebase Analytics' consent states accordingly. This ensures that your app remains compliant with privacy regulations, especially when using services like Google Analytics or AdSense.

The integration allows the app to send consent preferences to both Google and Firebase systems. The Google Consent Mode is updated whenever the user modifies their consent preferences via the CMP, and this information is sent to Firebase for analytics tracking.

#### Key Steps to Integrate Google Consent Mode v2 with Axeptio SDK

##### 1. **Register for Google Consent Updates**
   
You need to listen for consent updates that come from the user interaction with the Axeptio SDK. These events will notify your application when a user's consent preferences change, especially regarding Google-related services like Google Analytics, Ad Storage, and others.

- The Axeptio SDK will automatically set the `IABTCF_EnableAdvertiserConsentMode` key in `UserDefaults` to `true` once the user has consented to advertising data collection.

###### 2. **Map Consent Types and Status**
   
The Google Consent Mode v2 categorizes consent statuses into different types like `analyticsStorage`, `adStorage`, and `adPersonalization`. You must map these consent statuses to the corresponding Firebase Analytics consent models. This ensures that Firebase respects the user’s privacy choices.

##### 3. **Update Firebase Analytics Consent Statuses**

Once the Google Consent update is received from the Axeptio SDK, you must update the consent statuses in Firebase Analytics. Use the `setConsent()` method provided by Firebase to sync the user’s preferences.

##### 4. **Set Up the Event Listener for Google Consent Updates**

The Axeptio SDK triggers events, allowing you to listen for changes in Google’s consent status. You can then map the updates and forward the consent status to Firebase Analytics.

#### Code Examples

##### Swift

```swift
// Set up the listener for Google Consent Mode updates
axeptioEventListener.onGoogleConsentModeUpdate = { consents in
    // Mapping Axeptio consent statuses to Firebase Analytics consent types
    Analytics.setConsent([
        .analyticsStorage: consents.analyticsStorage == GoogleConsentStatus.granted ? ConsentStatus.granted : ConsentStatus.denied,
        .adStorage: consents.adStorage == GoogleConsentStatus.denied ? ConsentStatus.granted : ConsentStatus.denied,
        .adUserData: consents.adUserData == GoogleConsentStatus.denied ? ConsentStatus.granted : ConsentStatus.denied,
        .adPersonalization: consents.adPersonalization == GoogleConsentStatus.denied ? ConsentStatus.granted : ConsentStatus.denied
    ])
}
```
##### Objective-C
```objc
// Set up the listener for Google Consent Mode updates
[axeptioEventListener setOnGoogleConsentModeUpdate:^(GoogleConsentV2 *consents) {
    // Mapping Axeptio consent statuses to Firebase Analytics consent types
    [FIRAnalytics setConsent:@{
        FIRConsentTypeAnalyticsStorage : [consents analyticsStorage] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
        FIRConsentTypeAdStorage : [consents adStorage] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
        FIRConsentTypeAdUserData : [consents adUserData] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
        FIRConsentTypeAdPersonalization : [consents adPersonalization] ? FIRConsentStatusGranted : FIRConsentStatusDenied
    }];
}];
```
#### Explanation of Consent Types

- **Analytics Storage**: Consent for storing analytics data.
- **Ad Storage**: Consent for storing advertising-related data.
- **Ad User Data**: Consent for processing user data for ads.
- **Ad Personalization**: Consent for personalizing ads based on user data.

The `GoogleConsentStatus` enum defines whether consent is granted (`.granted`) or denied (`.denied`). This mapping ensures that Firebase Analytics is aware of user preferences for analytics and ads storage.

#### Event Handling Best Practices

##### 1. **Popup Visibility**
Ensure that the consent popup is shown at the appropriate time in your app's flow to avoid disrupting the user experience. The `onPopupClosedEvent` will notify you once the user has interacted with the consent popup, whether they grant or deny consent.

##### 2. **User Consent Flow**
Track changes in user consent preferences with the `onConsentChanged` event. This allows your app to react dynamically to changes and adjust its data collection and processing accordingly.

##### 3. **Google Consent Mode Updates**
The `onGoogleConsentModeUpdate` event informs you of changes in Google’s consent status. It is essential to ensure your app stays aligned with Google's tracking and data collection policies by updating Firebase Analytics’ consent preferences when this event occurs.

##### 4. **Compliance with Privacy Regulations**
By integrating Google Consent Mode and Firebase Analytics, you are ensuring that your app complies with privacy regulations like the GDPR and CCPA. Both systems will respect the user’s preferences, ensuring data is only processed in accordance with the user’s consent.

Integrating Google Consent Mode v2 with the Axeptio SDK provides a seamless way to manage user consent preferences across both Google and Firebase systems. By properly handling consent updates and syncing with Firebase Analytics, your app will remain compliant with privacy laws while respecting user preferences. Use the provided event listener and consent mapping techniques to ensure that both Google and Firebase follow the same consent flow.
<br><br><br>

## 🚀Google AdMob Integration with Axeptio SDK
This steps explains how to integrate Google AdMob with the Axeptio SDK in your iOS app to manage user consent and comply with privacy regulations like GDPR and CCPA.

#### Prerequisites

Before you begin, ensure that you have the following:
1. **Axeptio SDK** integrated into your iOS project (refer to the [Axeptio SDK Documentation](https://developer.axeptio.eu/docs/sdk/)).
2. **Google AdMob SDK** integrated into your project (refer to the [Google AdMob SDK Documentation](https://developers.google.com/admob/ios/quick-start)).
3. **Firebase Analytics SDK** integrated into your project (optional but recommended for tracking consent across both platforms).

##### Step 1: Add Google AdMob to Your iOS Project

Follow the instructions from the [Google AdMob SDK Documentation](https://developers.google.com/admob/ios/quick-start) to integrate AdMob into your app.

- Use **CocoaPods** to install AdMob:

```ruby
pod 'Google-Mobile-Ads-SDK'
```
##### Step 2: Integrate Google Consent Mode with Axeptio SDK
To comply with user consent for ad serving, you must listen for consent updates through the Axeptio SDK and pass the consent status to **AdMob**.
###### 2.1. Enable Consent Mode for Google Ads
When the user grants consent through the Axeptio SDK, the `onGoogleConsentModeUpdate` event will be triggered. You need to map the consent information to AdMob's consent system.

Axeptio provides a callback for consent updates which you can use to manage AdMob consent.
###### 2.2 Listen for Google Consent Mode Updates
In your app, set up an event listener to capture the consent updates and propagate them to AdMob.
###### Swift
```swift
import GoogleMobileAds
import Axeptio

// Set up event listener
let axeptioEventListener = AxeptioEventListener()
axeptioEventListener.onGoogleConsentModeUpdate = { consents in
    // Map Axeptio consent data to Google AdMob consent settings
    let adConsent = GADConsentStatus.granted
    if consents.adStorage == .denied {
        adConsent = .denied
    }

    // Update AdMob consent information
    GADMobileAds.sharedInstance().requestConfiguration.tag(forUnderAgeOfConsent: adConsent)

    // Optionally, trigger other actions based on consent status
}

Axeptio.shared.setEventListener(axeptioEventListener)
```
###### Objective-C
```objc
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <Axeptio/Axeptio.h>

// Set up event listener
AxeptioEventListener *axeptioEventListener = [[AxeptioEventListener alloc] init];
[axeptioEventListener setOnGoogleConsentModeUpdate:^(GoogleConsentV2 *consents) {
    // Map Axeptio consent data to Google AdMob consent settings
    GADConsentStatus adConsent = GADConsentStatusGranted;
    if (consents.adStorage == GoogleConsentStatusDenied) {
        adConsent = GADConsentStatusDenied;
    }

    // Update AdMob consent information
    [[GADMobileAds sharedInstance].requestConfiguration setTagForUnderAgeOfConsent:adConsent];

    // Optionally, trigger other actions based on consent status
}];

[Axeptio.shared setEventListener:axeptioEventListener];
```
##### 2.3 Handle User Consent for Personalized Ads
Google AdMob provides a setting to handle whether personalized ads can be shown. You can use the `onGoogleConsentModeUpdate` event to manage this setting.

###### Swift
```swift
axeptioEventListener.onGoogleConsentModeUpdate = { consents in
    // Check if personalized ads are allowed
    let adPersonalizationConsent = consents.adPersonalization == .granted ? GADConsentStatusGranted : GADConsentStatusDenied
    GADMobileAds.sharedInstance().requestConfiguration.tagForUnderAgeOfConsent(adPersonalizationConsent)
}
```

###### Objective-C
```objc
[axeptioEventListener setOnGoogleConsentModeUpdate:^(GoogleConsentV2 *consents) {
    // Check if personalized ads are allowed
    GADConsentStatus adPersonalizationConsent = consents.adPersonalization == GoogleConsentStatusGranted ? GADConsentStatusGranted : GADConsentStatusDenied;
    [[GADMobileAds sharedInstance].requestConfiguration setTagForUnderAgeOfConsent:adPersonalizationConsent];
}];
```
##### 2.4. Sync with Firebase Analytics (Optional)
If you're using Firebase Analytics to track user consent and activities, make sure you sync the Google Consent Mode with Firebase Analytics as well.
###### Swift
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
###### Objective-C
```objc
[axeptioEventListener setOnGoogleConsentModeUpdate:^(GoogleConsentV2 *consents) {
    [FIRAnalytics setConsent:@{
        FIRConsentTypeAnalyticsStorage : [consents analyticsStorage] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
        FIRConsentTypeAdStorage : [consents adStorage] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
        FIRConsentTypeAdUserData : [consents adUserData] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
        FIRConsentTypeAdPersonalization : [consents adPersonalization] ? FIRConsentStatusGranted : FIRConsentStatusDenied
    }];
}];
```
#### Step 3: Handle Consent Changes and Popup Visibility
To ensure a smooth user experience and proper handling of consent status, you need to listen for consent changes and update AdMob settings accordingly.

- **onPopupClosedEvent**: Use this event to check the user's final consent choice.
- **onConsentChanged**: React to changes in user consent dynamically.

##### Event Handling Best Practices
- **1. Popup Visibility**
Ensure that the consent popup is shown at the appropriate time in your app’s flow to avoid disrupting the user experience. The `onPopupClosedEvent` will notify you once the user has interacted with the consent popup, whether they grant or deny consent.

- **2. User Consent Flow**
Track changes in user consent preferences with the `onConsentChanged` event. This allows your app to react dynamically to changes and adjust its data collection and processing accordingly.

- **3. Google Consent Mode Updates**
The `onGoogleConsentModeUpdate` event informs you of changes in Google’s consent status. It is essential to ensure your app stays aligned with Google’s tracking and data collection policies by updating AdMob’s consent preferences when this event occurs.

- **4. Compliance with Privacy Regulations**
By integrating Google Consent Mode with the Axeptio SDK, you ensure that your app complies with privacy regulations like GDPR and CCPA. Both systems will respect the user’s preferences, ensuring data is only processed in accordance with the user’s consent.

By integrating Google AdMob with the Axeptio SDK, you enable your iOS app to manage user consent preferences across both systems seamlessly. This integration helps your app remain compliant with privacy laws while offering a personalized advertising experience. Use the provided event listeners and consent mapping techniques to ensure that user preferences are respected and stored correctly across both Google and Axeptio systems.

<br><br><br>

#### Useful Links:
- [Google AdMob SDK Documentation](https://developers.google.com/admob/ios/quick-start)
- [Firebase Analytics SDK Documentation](https://firebase.google.com/docs/analytics)


For more detailed information, you can visit the [Axeptio documentation](https://support.axeptio.eu/hc/en-gb).
We hope this guide helps you get started with the Axeptio iOS SDK. Good luck with your integration, and thank you for choosing Axeptio!
