//
//  AppDelegate.m
//  sampleObjectiveC
//
//  Created by Noeline PAGESY on 29/02/2024.
//

#import "AppDelegate.h"

@import GoogleMobileAds;
@import FirebaseCore;

@import AxeptioSDK;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Axeptio.shared initializeWithClientId:@"5fbfa806a0787d3985c6ee5f" cookiesVersion:@"google cmp partner program sandbox-en-EU"];
    [GADMobileAds.sharedInstance startWithCompletionHandler:nil];
    [FIRApp configure];

    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
