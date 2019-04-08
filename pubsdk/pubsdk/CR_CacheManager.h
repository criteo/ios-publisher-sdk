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
#import "CRAdUnit.h"

@interface CR_CacheManager : NSObject

@property (nonatomic, strong) NSMutableDictionary<CRAdUnit *, CR_CdbBid *> *bidCache;

- (void) initSlots: (NSArray<CRAdUnit*> *) slotIds;

- (void) setBid: (CR_CdbBid *) bid
      forAdUnit: (CRAdUnit *) adUnit;

- (CR_CdbBid *) getBidForAdUnit: (CRAdUnit *) adUnit;

- (void) removeBidForAdUnit: (CRAdUnit *) adUnit;

@end

#endif /* CR_CacheManager_h */
