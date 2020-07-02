//
//  Criteo+Testing.h
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
