//
//  UserDefaultsTableViewController.m
//  sampleObjectiveC
//
//  Created by Noeline PAGESY on 29/02/2024.
//

#import "UserDefaultsTableViewController.h"
#import "AppDelegate.h"
@import AxeptioSDK;

@interface UserDefaultsTableViewController ()

@property(nonatomic, strong) NSArray *keys;
@property(nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation UserDefaultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AxeptioService currentService = [AppDelegate targetService];

    if (currentService == AxeptioServicePublisherTcf) {
        _keys = @[
            @"IABTCF_CmpSdkID",
            @"IABTCF_CmpSdkVersion",
            @"IABTCF_gdprApplies",
            @"IABTCF_PolicyVersion",
            @"IABTCF_PublisherCC",
            @"IABTCF_PublisherConsent",
            @"IABTCF_PublisherLegitimateInterests",
            @"IABTCF_PublisherCustomPurposesConsents",
            @"IABTCF_PublisherCustomPurposesLegitimateInterests",
            @"IABTCF_PublisherRestrictions",
            @"IABTCF_PurposeConsents",
            @"IABTCF_PurposeLegitimateInterests",
            @"IABTCF_PurposeOneTreatment",
            @"IABTCF_SpecialFeaturesOptIns",
            @"IABTCF_TCString",
            @"IABTCF_UseNonStandardTexts",
            @"IABTCF_VendorConsents",
            @"IABTCF_VendorLegitimateInterests",
            @"IABTCF_AddtlConsent"
        ];
    } else {
        _keys = @[
            @"axeptio_cookies",
            @"axeptio_all_vendors",
            @"axeptio_authorized_vendors"
        ];
    }
    _defaults = [NSUserDefaults standardUserDefaults];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_keys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDefaultsCell" forIndexPath:indexPath];

    NSString *title = [_keys objectAtIndex:indexPath.row];
    NSString *value = [_defaults stringForKey:title];
    [cell.textLabel setText:title];
    [cell.detailTextLabel setText:value];

    return cell;
}

@end
