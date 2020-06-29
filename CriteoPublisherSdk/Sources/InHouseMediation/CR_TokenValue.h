//
//  CR_TokenValue.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRAdUnit.h"
#import "CRAdUnit+Internal.h"

@class CR_CdbBid;
@class CR_NativeAssets;

NS_ASSUME_NONNULL_BEGIN

@interface CR_TokenValue : NSObject

/**
 * If this token represents a banner or an interstitial ad, then this property is not null, else it
 * is null.
 */
@property(readonly, nonatomic, nullable) NSString *displayUrl;

/**
 * If this token represents a native ad, then this property is not null. Else it is null.
 */
@property(readonly, nonatomic, nullable) CR_NativeAssets *nativeAssets;

@property(readonly, nonatomic) CRAdUnit *adUnit;

- (instancetype)initWithCdbBid:(CR_CdbBid *)cdbBid adUnit:(CRAdUnit *)adUnit;

- (BOOL)isExpired;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToValue:(CR_TokenValue *)value;

- (NSUInteger)hash;

@end

NS_ASSUME_NONNULL_END
