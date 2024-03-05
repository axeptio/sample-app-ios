//
//  UserDefaultsTableViewController.m
//  sampleObjectiveC
//
//  Created by Noeline PAGESY on 29/02/2024.
//

#import "UserDefaultsTableViewController.h"

@interface UserDefaultsTableViewController ()

@property(nonatomic, strong) NSArray *keys;
@property(nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation UserDefaultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _keys = @[
        @"IABTCF_CmpSdkID",
        @"IABTCF_CmpSdkVersion",
        @"IABTCF_gdprApplies",
        @"IABCTF_PolicyVersion",
        @"IABTCF_PublisherCC",
        @"IABTCF_PublisherConsent",
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
    _defaults = [NSUserDefaults standardUserDefaults];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_keys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCFCell" forIndexPath:indexPath];
    
    NSString *title = [_keys objectAtIndex:indexPath.row];
    NSString *value = [_defaults stringForKey:title];
    [cell.textLabel setText:title];
    [cell.detailTextLabel setText:value];

    return cell;
}

@end
