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
    
    [_googleAdSpinner setHidden:true];

    AxeptioEventListener *axeptioEventListener = [[AxeptioEventListener alloc] init];

    [axeptioEventListener setOnConsentChanged:^{
        [self requestTrackingAuthorization];
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

    if (@available(iOS 14, *)) {
        [self requestTrackingAuthorization];
    }

    [self loadAd];
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

- (void)requestTrackingAuthorization {
    [self removeObserver];

    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            if (status != ATTrackingManagerAuthorizationStatusDenied) {
                return;
            }
            // Nous devons faire cela pour gérer un bogue dans iOS 17.4 concernant l'ATT
            if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusNotDetermined) {
                [self addObserver];
                return;
            }

            [[Axeptio shared] setUserDeniedTracking];
        }];
    }
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
