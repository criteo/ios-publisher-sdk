//
// Created by Aleksandr Pakhmutov on 26/11/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteo.h"

@class CR_NetworkCaptor;
@class CR_HttpContent;

FOUNDATION_EXPORT NSString *const CriteoTestingPublisherId;
FOUNDATION_EXPORT NSString *const DemoBannerAdUnitId;
FOUNDATION_EXPORT NSString *const DemoInterstitialAdUnitId;
FOUNDATION_EXPORT NSString *const PreprodBannerAdUnitId;

@interface Criteo (Testing)

@property (nonatomic, readonly) CR_NetworkCaptor *testing_networkCaptor;
@property (nonatomic, readonly) CR_HttpContent *testing_lastBidHttpContent;

+ (Criteo *)testing_criteoWithNetworkCaptor;

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
