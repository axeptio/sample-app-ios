//
//  MainViewController.m
//  sampleObjectiveC
//
//  Created by Noeline PAGESY on 29/02/2024.
//

#import "MainViewController.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@import FirebaseAnalytics;
@import GoogleMobileAds;

@import AxeptioSDK;

@interface MainViewController ()<GADFullScreenContentDelegate>

@property(nonatomic, strong) GADInterstitialAd *interstitial;
@property (weak, nonatomic) IBOutlet UIButton *showConsentButton;
@property (weak, nonatomic) IBOutlet UIButton *userDefaultButton;
@property (weak, nonatomic) IBOutlet UIButton *googleAdButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *googleAdSpinner;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [_showConsentButton layer].cornerRadius = 24;
    [_userDefaultButton layer].cornerRadius = 24;
    [_googleAdButton layer].cornerRadius = 24;

    [_googleAdButton setHidden:true];
}

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

    [self loadAd];
}

- (IBAction)showConsent:(id)sender {
    [Axeptio.shared showConsentScreen:self];
}

- (IBAction)showGoogleAd:(id)sender {
    if (self.interstitial) {
        [self.interstitial presentFromRootViewController:self];
    }
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
