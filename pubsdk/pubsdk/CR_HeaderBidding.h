//
//  CR_HeaderBidding.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//


#import <Foundation/Foundation.h>

@class CR_CdbBid;
@class CR_CacheAdUnit;

NS_ASSUME_NONNULL_BEGIN

/**
 * Enrich and clean the header bidding requests with the Criteo Bid.
 *
 * It handles MoPub classes, Google Classes and NSMutableDictionary.
 */
@interface CR_HeaderBidding : NSObject

/**
 * Add the Criteo bid to the request.
 *
 * @param request is the header bidding request to enrich.
 * @param adUnit is the adUnit on which we bid.
 * @param bid is the bid associated to the adUnit.
 */
- (void)enrichRequest:(id)request
              withBid:(CR_CdbBid *)bid
               adUnit:(CR_CacheAdUnit *)adUnit;

/**
 * @return YES if the given object is a MoPub objects
 */
- (BOOL)isMoPubRequest:(id)request;

/**
 *  Remove all the existing data of Criteo that is already exist in the given request.
 */
- (void)removeCriteoBidsFromMoPubRequest:(id)adRequest;

@end

NS_ASSUME_NONNULL_END
