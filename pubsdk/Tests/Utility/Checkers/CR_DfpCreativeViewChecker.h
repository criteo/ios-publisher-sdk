//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

@import GoogleMobileAds;


@interface CR_DfpCreativeViewChecker : NSObject <GADBannerViewDelegate, GADInterstitialDelegate>

@property (strong, nonatomic, readonly) XCTestExpectation *adCreativeRenderedExpectation;
@property (weak, nonatomic, readonly) UIWindow *uiWindow;
@property (strong, nonatomic, readonly) DFPBannerView *dfpBannerView;
@property (strong, nonatomic, readonly) DFPInterstitial *dfpInterstitial;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithBannerWithSize:(GADAdSize)size withAdUnitId:(NSString *)adUnitId;
-(instancetype)initWithInterstitial:(DFPInterstitial *)dfpInterstitial;
-(BOOL)waitAdCreativeRendered;
-(BOOL)waitAdCreativeRenderedWithTimeout:(NSTimeInterval)timeout;

@end
