//
//  CR_HeaderBidding.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CR_DeviceInfo.h"

@protocol CR_HeaderBiddingDevice;
@class CR_CdbBid;
@class CR_CacheAdUnit;

NS_ASSUME_NONNULL_BEGIN

/**
 * Enrich and clean the header bidding requests with the Criteo Bid.
 *
 * It handles MoPub classes, Google Classes and NSMutableDictionary.
 */
@interface CR_HeaderBidding : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDevice:(id<CR_HeaderBiddingDevice>)device NS_DESIGNATED_INITIALIZER;

/**
 * Add the Criteo bid to the request.
 *
 * @param request is the header bidding request to enrich.
 * @param adUnit is the adUnit on which we bid.
 * @param bid is the bid associated to the adUnit.
 */
- (void)enrichRequest:(id)request withBid:(CR_CdbBid *)bid adUnit:(CR_CacheAdUnit *)adUnit;

@end

/**
 * Represent the device that provides information for computing sizes of the ads.
 *
 * This protocol exists for isolating the CR_HeaderBidding from the properties of the device in the
 * tests.
 */
@protocol CR_HeaderBiddingDevice <NSObject>

- (BOOL)isPhone;

- (BOOL)isInPortrait;

/**
 * The screen size that takes the orientation into account (like UIScreen bound since iOS8).
 */
- (CGSize)screenSize;

@end

@interface CR_DeviceInfo (HeaderBidding) <CR_HeaderBiddingDevice>

@end

NS_ASSUME_NONNULL_END
