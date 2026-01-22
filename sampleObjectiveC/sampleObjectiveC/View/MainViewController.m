//
//  MainViewController.m
//  sampleObjectiveC
//
//  Created by Noeline PAGESY on 29/02/2024.
//

#import "MainViewController.h"
#import "WebViewController.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@import FirebaseAnalytics;
@import GoogleMobileAds;

@import AxeptioSDK;

@interface MainViewController ()<GADFullScreenContentDelegate>

@property(nonatomic, strong) GADInterstitialAd *interstitial;
@property (weak, nonatomic) IBOutlet UIButton *showConsentButton;
@property (weak, nonatomic) IBOutlet UIButton *userDefaultButton;
@property (weak, nonatomic) IBOutlet UIButton *clearConsentButton;
@property (weak, nonatomic) IBOutlet UIButton *googleAdButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *googleAdSpinner;
@property (weak, nonatomic) IBOutlet UIButton *tokenButton;
@property (weak, nonatomic) IBOutlet UIButton *consentDebugInfoButton;
@property (nonatomic, weak) id observer;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [_showConsentButton layer].cornerRadius = 24;
    [_userDefaultButton layer].cornerRadius = 24;
    [_clearConsentButton layer].cornerRadius = 24;
    [_googleAdButton layer].cornerRadius = 24;
    [_tokenButton layer].cornerRadius = 24;
    [_consentDebugInfoButton layer].cornerRadius = 24;
    
    [_googleAdSpinner setHidden:true];

    AxeptioEventListener *axeptioEventListener = [[AxeptioEventListener alloc] init];

    [axeptioEventListener setOnConsentCleared:^{
        NSLog(@"Consent have been cleared");
    }];

    [axeptioEventListener setOnGoogleConsentModeUpdate:^(GoogleConsentV2 *consents) {
        [FIRAnalytics setConsent:@{
            FIRConsentTypeAnalyticsStorage : [consents analyticsStorage] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
            FIRConsentTypeAdStorage : [consents adStorage] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
            FIRConsentTypeAdUserData : [consents adUserData] ? FIRConsentStatusGranted : FIRConsentStatusDenied,
            FIRConsentTypeAdPersonalization : [consents adPersonalization] ? FIRConsentStatusGranted : FIRConsentStatusDenied
        }];
    }];

    [axeptioEventListener setOnPopupClosedEvent:^{
        [self loadAd];
    }];

    [Axeptio.shared setEventListener:axeptioEventListener];

    // ATT is always available since we require iOS 18+
    [self requestTrackingAuthorization];

}

- (IBAction)showConsent:(id)sender {
    [Axeptio.shared showConsentScreen];
}

- (IBAction)clearConsent:(id)sender {
    [Axeptio.shared clearConsent];
}

- (IBAction)showGoogleAd:(id)sender {
    if (self.interstitial) {
        [self.interstitial presentFromRootViewController:self];
    }
}

- (IBAction)showWebView:(id)sender {
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:@"Enter axeptio token"
        message:@""
        preferredStyle:UIAlertControllerStyleAlert
    ];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"axeptio token";
    }];

    UIAlertAction *saveAction = [UIAlertAction
                                 actionWithTitle:@"Open in Browser"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * _Nonnull action) {
        NSURL *sourceURL = [[NSURL alloc] initWithString:@"https://google-cmp-partner.axept.io/cmp-for-publishers.html"];
        NSString *token = [[alertController textFields] objectAtIndex:0].text;

        NSURL *url = sourceURL;
        if (![token isEqualToString:@""]) {
            url = [[Axeptio shared] appendAxeptioTokenToURL:url token:token];
        } else if ([Axeptio shared].axeptioToken)  {
            url = [[Axeptio shared] appendAxeptioTokenToURL:url token:[Axeptio shared].axeptioToken];
        }

        WebViewController *webView = [[WebViewController alloc] initWithURL:url];
        [self presentViewController:webView animated:YES completion:^{}];
    }];

    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}
    ];

    [alertController addAction:saveAction];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:^{}];
}

- (IBAction)showConsentDebugInfo:(id)sender {
    NSDictionary *debugInfo = (NSDictionary *)[Axeptio.shared getConsentDebugInfoWithPreferenceKey:nil];
    
    if (!debugInfo) {
        NSLog(@"debugInfo is not available");
        return;
    }
    
    // Simple implementation: Log the debug info for now
    // In a full implementation, you'd want to create a debug view controller
    NSLog(@"Consent Debug Info: %@", debugInfo);
    
    // Show a simple alert with debug info summary
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:@"Consent Debug Info"
        message:[NSString stringWithFormat:@"Debug data available. Check console for details.\n\nKeys: %lu", (unsigned long)[debugInfo allKeys].count]
        preferredStyle:UIAlertControllerStyleAlert
    ];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:nil];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)requestTrackingAuthorization {
    [self removeObserver];

    // ATT is always available since we require iOS 18+
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        BOOL isAuthorized = (status == ATTrackingManagerAuthorizationStatusAuthorized);
        // Handle ATT status determination bug (fixed in iOS 18+)
        if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusNotDetermined) {
            [self addObserver];
            return;
        }

        if (isAuthorized) {
            [Axeptio.shared setupUI];
        }

        [Axeptio.shared setUserDeniedTrackingWithDenied:!isAuthorized];
    }];
}

- (void)addObserver {
    [self removeObserver];
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                      object:nil
                                                                       queue:[NSOperationQueue mainQueue]
                                                                  usingBlock:^(NSNotification * _Nonnull note) {
        [self requestTrackingAuthorization];
    }];
}

- (void)removeObserver {
    if (self.observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
    }
    self.observer = nil;
}


-(void)loadAd {
    [_googleAdButton setHidden:true];

    [_googleAdSpinner startAnimating];
    [_googleAdSpinner setHidden:false];

    GADRequest *request = [GADRequest request];
    [GADInterstitialAd loadWithAdUnitID:@"ca-app-pub-3940256099942544/4411468910"  request:request
                      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        [self.googleAdSpinner stopAnimating];
        [self.googleAdSpinner setHidden:true];

        if (error) {
            NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
            [self.googleAdButton setEnabled:false];
            [self.googleAdButton setHidden:false];
            return;
        }

        self.interstitial = ad;
        self.interstitial.fullScreenContentDelegate = self;
        [self.googleAdButton setEnabled:true];
        [self.googleAdButton setHidden:false];
    }];
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"Ad did fail to present full screen content.");
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    [self loadAd];
}

@end
