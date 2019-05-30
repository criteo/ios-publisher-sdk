//
//  CR_CacheManager.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/18/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#ifndef CR_CacheManager_h
#define CR_CacheManager_h

#import <Foundation/Foundation.h>
#import "CR_CdbBid.h"
#import "CRCacheAdUnit.h"

@interface CR_CacheManager : NSObject

@property (nonatomic, strong) NSMutableDictionary<CRCacheAdUnit *, CR_CdbBid *> *bidCache;

- (void) initSlots: (NSArray<CRCacheAdUnit*> *) slotIds;

- (void) setBid: (CR_CdbBid *) bid
      forAdUnit: (CRCacheAdUnit *) adUnit;

- (CR_CdbBid *) getBidForAdUnit: (CRCacheAdUnit *) adUnit;

- (void) removeBidForAdUnit: (CRCacheAdUnit *) adUnit;

@end

#endif /* CR_CacheManager_h */
