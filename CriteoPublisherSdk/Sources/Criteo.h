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
#import <CriteoPublisherSdk/CRBid.h>

/** Bid response handler, bid can be nil on purpose */
typedef void (^CRBidResponseHandler)(CRBid *_Nullable bid);

NS_ASSUME_NONNULL_BEGIN

@interface Criteo : NSObject

#pragma mark - Lifecycle

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

/**
 * Initialize Criteo singleton
 * @param criteoPublisherId Publisher Identifier
 * @param adUnits AdUnits array
 */
- (void)registerCriteoPublisherId:(NSString *)criteoPublisherId
                      withAdUnits:(NSArray<CRAdUnit *> *)adUnits;

#pragma mark - Consent management

/** Set a custom opt-out/opt-in with same behaviour as the CCPA (US Privacy). */
- (void)setUsPrivacyOptOut:(BOOL)usPrivacyOptOut;

/** Set the privacy consent string owned by the Mopub SDK. */
- (void)setMopubConsent:(NSString *)mopubConsent;

#pragma mark - Bidding

/**
 * Request asynchronously a bid from Criteo
 * @param adUnit The ad unit to request
 * @param responseHandler the handler called on response. Responded bid can be nil.
 * Note: responseHandler is invoked on main queue
 */
- (void)loadBidForAdUnit:(CRAdUnit *)adUnit responseHandler:(CRBidResponseHandler)responseHandler;

#pragma mark App bidding

/**
 * App bidding API, enrich your request with Criteo metadata
 * @param request The request to enrich, supports GAM and MoPub
 * @param adUnit The adUnit related to request
 */
- (void)setBidsForRequest:(id)request withAdUnit:(CRAdUnit *)adUnit;

/**
 * App bidding API, enrich your ad object with Criteo metadata
 * @param object The object to enrich, supports GAM and MoPub
 * @param bid The bid obtained from Criteo
 */
- (void)enrichAdObject:(id)object withBid:(CRBid *)bid;

#pragma mark In-House

/**
 * In-House bidding API, provide direct access to a Criteo bid
 * @param adUnit The adUnit related to request
 * @return Bid Response that can later be used for displaying ads
 */
- (CRBid *)getBidForAdUnit:(CRAdUnit *)adUnit NS_SWIFT_NAME(getBid(for:));

@end
NS_ASSUME_NONNULL_END

#endif /* Criteo_h */
