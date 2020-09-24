//
//  Criteo.h
//  CriteoPublisherSdk
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

#ifndef Criteo_h
#define Criteo_h

#import <Foundation/Foundation.h>
#import <CriteoPublisherSdk/CRAdUnit.h>
#import <CriteoPublisherSdk/CRBidResponse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Criteo : NSObject

/**
 * Use sharedCriteo singleton accessor, do not init your own instance
 * Note: Initialization is expected through registerCriteoPublisherId:
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Criteo shared instance singleton
 * Note: Initialization is expected through registerCriteoPublisherId:
 * @return The Criteo singleton
 */
+ (nonnull instancetype)sharedCriteo;

/** Set a custom opt-out/opt-in with same behaviour as the CCPA (US Privacy). */
- (void)setUsPrivacyOptOut:(BOOL)usPrivacyOptOut;
/** Set the privacy consent string owned by the Mopub SDK. */
- (void)setMopubConsent:(NSString *)mopubConsent;

/**
 * Initialize Criteo singleton
 * @param criteoPublisherId Publisher Identifier
 * @param adUnits AdUnits array
 */
- (void)registerCriteoPublisherId:(NSString *)criteoPublisherId
                      withAdUnits:(NSArray<CRAdUnit *> *)adUnits;
/**
 * Header bidding API, enrich your request with Criteo metadata
 * @param request The request to enrich, supports GAM and MoPub
 * @param adUnit The adUnit related to request
 */
- (void)setBidsForRequest:(id)request withAdUnit:(CRAdUnit *)adUnit;

/**
 * In-House bidding API, provide direct access to a Criteo bid
 * @param adUnit The adUnit related to request
 * @return Bid Response that can later be used for displaying ads
 */
- (CRBidResponse *)getBidResponseForAdUnit:(CRAdUnit *)adUnit;

@end
NS_ASSUME_NONNULL_END

#endif /* Criteo_h */
