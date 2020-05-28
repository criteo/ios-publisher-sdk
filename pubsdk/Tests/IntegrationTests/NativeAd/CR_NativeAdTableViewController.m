//
//  CR_NativeAdTableViewController.m
//  pubsdkITests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_NativeAdTableViewCell.h"
#import "CR_NativeAdTableViewController.h"
#import "CRNativeLoader.h"
#import "CRNativeLoader+Internal.h"
#import "CRNativeAdUnit.h"
#import "CRNativeAd.h"
#import "CRMediaView.h"

static NSString * const kAdCellIdentifier = @"AdCell";
static NSString * const kNormalCellIdentifier = @"NormalCell";
static NSString * const kAdCellNibName = @"CR_NativeAdTableViewCell";
static const NSUInteger kAdCellPosition = 10;

@interface CR_NativeAdTableViewController () <CRNativeDelegate>

@property (strong, nonatomic) CRNativeLoader *adLoader;
@property (strong, nonatomic) CRNativeAd *ad;
@property (assign, nonatomic, getter=isAdLoaded) BOOL adLoaded;
@property (strong, nonatomic) CR_NativeAdTableViewCell *lastFilledAdCell;

@end

@implementation CR_NativeAdTableViewController

@synthesize adUnit = _adUnit;

+ (instancetype)nativeAdTableViewControllerWithCriteo:(Criteo *)criteo {
    CR_NativeAdTableViewController *ctrl = [[CR_NativeAdTableViewController alloc] init];
    ctrl.criteo = criteo;
    return ctrl;
}

- (void)setAdUnit:(CRNativeAdUnit *)adUnit {
    if (adUnit != _adUnit) {
        _adUnit = adUnit;
        self.adLoader = (_adUnit) ?
            [[CRNativeLoader alloc] initWithAdUnit:adUnit
                                            criteo:self.criteo] :
            nil;
        self.adLoader.delegate = self;
        [self.adLoader loadAd];
    }
}


- (void)viewDidLoad {
    NSBundle *bundle = [NSBundle bundleForClass:CR_NativeAdTableViewCell.class];
    UINib *adCellNib = [UINib nibWithNibName:kAdCellNibName
                                      bundle:bundle];
    [self.tableView registerNib:adCellNib
         forCellReuseIdentifier:kAdCellIdentifier];
    [self.tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:kNormalCellIdentifier];
}

#pragma mark - Table view data source / delegate

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Height to hide the ad when we are at the top of the table view.
    return CGRectGetHeight(self.view.frame) / (kAdCellPosition * 0.75f);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isAdCell = (indexPath.row == kAdCellPosition);
    if (isAdCell) {
        CR_NativeAdTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAdCellIdentifier
                                                                         forIndexPath:indexPath];
        cell.titleLabel.text = self.ad.title ?: @"No title";
        cell.bodyLabel.text = self.ad.body ?: @"No body";
        cell.productMediaView.placeholder = self.mediaPlaceholder;
        cell.productMediaView.mediaContent = self.ad.productMedia;
        cell.callToActionLabel.text = self.ad.callToAction ?: @"No callToAction";
        cell.advertiserDescriptionLabel.text = self.ad.advertiserDescription ?: @"No advertiserDescription";
        cell.advertiserDomainUrlLabel.text = self.ad.advertiserDomain ?: @"No advertiserDomain";
        cell.advertiserLogoMediaView.placeholder = self.mediaPlaceholder;
        cell.advertiserLogoMediaView.mediaContent = self.ad.advertiserLogoMedia;
        cell.priceLabel.text = self.ad.price ?: @"No price";

        if (self.ad) {
            self.lastFilledAdCell = cell;
        }

        return cell;

    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNormalCellIdentifier
                                                            forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"Cell #%ld", (long)indexPath.row];
    return cell;
}

#pragma mark - CRNativeDelegate

 - (void)nativeLoader:(CRNativeLoader *)loader
         didReceiveAd:(CRNativeAd *)ad {
     self.ad = ad;
     [self.tableView reloadData];
     self.adLoaded = YES;
}

-(void)nativeLoader:(CRNativeLoader *)loader
didFailToReceiveAdWithError:(NSError *)error {

}

- (void)nativeLoaderDidDetectImpression:(CRNativeLoader *)loader {

}

- (void)nativeLoaderDidDetectClick:(CRNativeLoader *)loader {

}

-(void)nativeLoaderWillLeaveApplicationForNativeAd:(CRNativeLoader *)loader {

}

@end
