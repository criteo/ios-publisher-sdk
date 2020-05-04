//
//  CR_CacheManager.h
//  pubsdk
//
//  Copyright © 2018 Criteo. All rights reserved.
//

#ifndef CR_CacheManager_h
#define CR_CacheManager_h

#import <Foundation/Foundation.h>
#import "CR_CdbBid.h"
#import "CR_CacheAdUnit.h"

@interface CR_CacheManager : NSObject

@property (nonatomic, strong) NSMutableDictionary<CR_CacheAdUnit *, CR_CdbBid *> *bidCache;

- (void) initSlots: (CR_CacheAdUnitArray *) slotIds;

- (CR_CacheAdUnit *)setBid: (CR_CdbBid *) bid;

- (CR_CdbBid *) getBidForAdUnit: (CR_CacheAdUnit *) adUnit;

- (void) removeBidForAdUnit: (CR_CacheAdUnit *) adUnit;

@end

#endif /* CR_CacheManager_h */
