//
//  ViewController.h
//  AdViewer
//
//  Created by Yegor Pavlikov on 11/1/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CriteoPublisherSdk;
#import "Criteo+Internal.h"

#define GOOGLEBANNERADUNITID_320x50 @"/140800857/Endeavour_320x50"
#define GOOGLEBANNERADUNITID_300X250 @"/140800857/Endeavour_300x250"
#define MOPUBBANNERADUNITID_320X50 @"bb0577af6858451d8191c2058fe59d03"
#define MOPUBBANNERADUNITID_300X250 @"69942486c90c4cd4b3c627ba613509a3"
#define GOOGLEINTERSTITIALADUNITID @"/140800857/Endeavour_Interstitial_320x480"
#define MOPUBINTERSTITIALADUNITID @"966fbbf95ba24ab990e5f037cc674bbc"
#define GOOGLENATIVEADUNITID_FLUID @"/140800857/Endeavour_Native"


@interface HomePageTableViewController : UITableViewController <NetworkManagerDelegate>

@property (nonatomic, strong) CRBannerAdUnit *googleBannerAdUnit_320x50;
@property (nonatomic, strong) CRBannerAdUnit *googleBannerAdUnit_300x250;
@property (nonatomic, strong) CRInterstitialAdUnit *googleInterstitialAdUnit;
@property (nonatomic, strong) CRNativeAdUnit *googleNativeAdUnit_Fluid;
@property (nonatomic, strong) CRBannerAdUnit *moPubBannerAdUnit_320x50;
@property (nonatomic, strong) CRBannerAdUnit *moPubBannerAdUnit_300x250;
@property (nonatomic, strong) CRInterstitialAdUnit *moPubInterstitialAdUnit;
@property (nonatomic) IBOutlet UITextView *textFeedback;

@end

