//
//  GoogleDFPTableViewController.m
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/9/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import "GoogleDFPTableViewController.h"
#import <Foundation/Foundation.h>
@import GoogleMobileAds;

@interface GoogleDFPTableViewController ()

@property (nonatomic) DFPBannerView *dfpBannerView;

@end

@implementation GoogleDFPTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dfpBannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    //self.dfpBannerView.adUnitID = @"/6499/example/banner";
    self.dfpBannerView.rootViewController = self;

    [self addBannerViewToView:self.dfpBannerView];
    Criteo *criteo = [Criteo sharedCriteo];
    _criteoSdk = criteo;
    [self.criteoSdk registerNetworkId:4916];
}

- (void)addBannerViewToView:(UIView *)bannerView {
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bannerView];
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:bannerView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.bottomLayoutGuide
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:bannerView
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1
                                                              constant:0]
                                ]];
}

# pragma mark - actions

- (IBAction)registerAdUnitClick:(id)sender {

    //NSUInteger networkId = [self.textNetworkId.text intValue];
    //[self.criteoSdk registerNetworkId:networkId];
    [self.criteoSdk registerAdUnits:[self createAdUnits]];
    [self.criteoSdk prefetchAll];
    //self.dfpBannerView.adUnitID = @"/140800857/Endeavour_320x50";
    self.dfpBannerView.adUnitID = self.textAdUnitId.text;
}

- (NSArray<AdUnit*>*) createAdUnits
{

    NSString *adUnitId = self.textAdUnitId.text;
    double width = [self.textAdUnitWidth.text doubleValue];
    double height = [self.textAdUnitHeight.text doubleValue];
    AdUnit *adUnit = [[AdUnit alloc] initWithAdUnitId:adUnitId
                                                 size:CGSizeMake(width, height)];

    return @[ adUnit ];
}

- (IBAction)loadAdClick:(id)sender {
    NSString *adUnitId = self.textAdUnitId.text;
    double width = [self.textAdUnitWidth.text doubleValue];
    double height = [self.textAdUnitHeight.text doubleValue];
    AdUnit *adUnit = [[AdUnit alloc] initWithAdUnitId:adUnitId size:CGSizeMake(width, height)];

    DFPRequest *request = [DFPRequest request];
    //request.testDevices = @[ kGADSimulatorID ];

    /*
     Inside the cache:
     { @"/140800857/Endeavour_320x50", CGSize(320,50) } : { bid: 1.23, creative: @"test_string" }
     */

    [self.criteoSdk addCriteoBidToRequest:request forAdUnit:adUnit];

    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:request.customTargeting];
    dict[@"crt_cpm"] = @"1.00";
    request.customTargeting = dict;

    [self.dfpBannerView loadRequest:request];
    /*
     [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
     */
}

- (IBAction)clearButtonClick:(id)sender {
    self.textAdUnitId.text = @"";
    self.textAdUnitWidth.text = @"";
    self.textAdUnitHeight.text = @"";
}

@end
