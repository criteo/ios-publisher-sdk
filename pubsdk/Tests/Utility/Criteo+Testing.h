//
// Created by Aleksandr Pakhmutov on 26/11/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteo.h"

@class CR_NetworkCaptor;
@class CR_HttpContent;
@class CR_BidManager;
@class CR_BidManagerBuilder;

FOUNDATION_EXPORT NSString *const CriteoTestingPublisherId;
FOUNDATION_EXPORT NSString *const DemoBannerAdUnitId;
FOUNDATION_EXPORT NSString *const DemoInterstitialAdUnitId;
FOUNDATION_EXPORT NSString *const PreprodBannerAdUnitId;
FOUNDATION_EXPORT NSString *const PreprodInterstitialAdUnitId;
FOUNDATION_EXPORT NSString *const PreprodNativeAdUnitId;

@interface Criteo (Testing)

@property (nonatomic, readonly) CR_NetworkCaptor *testing_networkCaptor;
@property (nonatomic, readonly) CR_HttpContent *testing_lastBidHttpContent;
@property (nonatomic, readonly, strong) CR_BidManagerBuilder *bidManagerBuilder;
@property (nonatomic, readonly, strong) CR_BidManager *bidManager;

+ (Criteo *)testing_criteoWithNetworkCaptor;

- (instancetype)initWithBidManagerBuilder:(CR_BidManagerBuilder *)bidManagerBuilder;

- (void)testing_registerBanner;
- (void)testing_registerInterstitial;
- (void)testing_registerWithAdUnits:(NSArray<CRAdUnit *> *)adUnits;

/**
 Return YES if all the HTTP calls have finished before a timeout.
 */
- (BOOL)testing_waitForRegisterHTTPResponses;

- (void)testing_registerBannerAndWaitForHTTPResponses;
- (void)testing_registerInterstitialAndWaitForHTTPResponses;
- (void)testing_registerAndWaitForHTTPResponseWithAdUnits:(NSArray<CRAdUnit *> *)adUnits;

@end
