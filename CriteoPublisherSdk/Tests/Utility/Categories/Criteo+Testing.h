//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteo.h"

@class CR_NetworkCaptor;
@class CR_HttpContent;
@class CR_BidManager;
@class OCMockObject;

FOUNDATION_EXPORT NSString *const CriteoTestingPublisherId;
FOUNDATION_EXPORT NSString *const DemoBannerAdUnitId;
FOUNDATION_EXPORT NSString *const DemoInterstitialAdUnitId;
FOUNDATION_EXPORT NSString *const PreprodBannerAdUnitId;
FOUNDATION_EXPORT NSString *const PreprodInterstitialAdUnitId;
FOUNDATION_EXPORT NSString *const PreprodNativeAdUnitId;

@interface Criteo (Testing)
/** An OCPartialMock set as an id (like in the OCMock library) for API conveniance. */
@property(nonatomic, readonly) id testing_networkManagerMock;
@property(nonatomic, readonly) CR_NetworkCaptor *testing_networkCaptor;
@property(nonatomic, readonly) CR_HttpContent *testing_lastBidHttpContent;
@property(nonatomic, readonly) CR_HttpContent *testing_lastAppEventHttpContent;

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
