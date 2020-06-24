//
//  CR_CdbBidBuilder.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CR_CdbBid;
@class CR_CacheAdUnit;
@class CR_NativeAssets;

NS_ASSUME_NONNULL_BEGIN

#define PROPERTY_DECLARATION(name, type, ownership)                      \
  @property(nonatomic, readonly, copy) CR_CdbBidBuilder * (^name)(type); \
  @property(nonatomic, ownership) type name##Value;

@interface CR_CdbBidBuilder : NSObject

PROPERTY_DECLARATION(zoneId, NSUInteger, assign);
PROPERTY_DECLARATION(placementId, NSString *_Nullable, copy);
PROPERTY_DECLARATION(cpm, NSString *_Nullable, copy);
PROPERTY_DECLARATION(currency, NSString *_Nullable, copy);
PROPERTY_DECLARATION(width, NSUInteger, assign);
PROPERTY_DECLARATION(height, NSUInteger, assign);
PROPERTY_DECLARATION(ttl, NSTimeInterval, assign);
PROPERTY_DECLARATION(creative, NSString *_Nullable, copy);
PROPERTY_DECLARATION(displayUrl, NSString *_Nullable, copy);
PROPERTY_DECLARATION(insertTime, NSDate *_Nullable, copy);
PROPERTY_DECLARATION(nativeAssets, CR_NativeAssets *_Nullable, strong);
PROPERTY_DECLARATION(impressionId, NSString *_Nullable, copy);

/** Shortcut for placementId, width and height of the ad unit. */
@property(nonatomic, readonly, copy) CR_CdbBidBuilder * (^adUnit)(CR_CacheAdUnit *);
@property(nonatomic, readonly, copy) CR_CdbBidBuilder * (^expiredInsertTime)(void);

@property(nonatomic, readonly, strong) CR_CdbBid *build;

@end

#undef PROPERTY_DECLARATION

NS_ASSUME_NONNULL_END
