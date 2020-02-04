//
// Created by Aleksandr Pakhmutov on 10/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

@import GoogleMobileAds;


@interface CR_DfpCreativeViewChecker : NSObject <GADBannerViewDelegate, GADInterstitialDelegate>

@property (nonatomic, copy, readonly) NSArray<XCTAttachment *> *attachments;
@property(nonatomic, readonly) XCTestExpectation *adCreativeRenderedExpectation;
@property(nonatomic, readonly) UIWindow *uiWindow;
@property(nonatomic, readonly) DFPBannerView *dfpBannerView;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithBannerWithSize:(GADAdSize)size withAdUnitId:(NSString *)adUnitId;
-(instancetype)initWithInterstitial:(DFPInterstitial *)dfpInterstitial;
-(BOOL)waitAdCreativeRendered;

@end
