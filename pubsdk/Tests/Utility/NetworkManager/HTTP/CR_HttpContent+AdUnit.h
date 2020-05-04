//
//  CR_HttpContent+AdUnit.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_CacheAdUnit.h"
#import "CR_HttpContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_HttpContent (AdUnit)

- (BOOL)isHTTPRequestForCacheAdUnits:(CR_CacheAdUnitArray *)cacheAdUnits;
- (BOOL)isHTTPRequestForCacheAdUnit:(CR_CacheAdUnit *)cacheAdUnit;

@end

NS_ASSUME_NONNULL_END
