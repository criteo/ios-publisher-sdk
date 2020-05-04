//
//  CR_BidFetchTracker.h
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_CacheAdUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_BidFetchTracker : NSObject

- (BOOL) trySetBidFetchInProgressForAdUnit:(CR_CacheAdUnit *)adUnit;
- (void) clearBidFetchInProgressForAdUnit:(CR_CacheAdUnit *)adUnit;

@end

NS_ASSUME_NONNULL_END
