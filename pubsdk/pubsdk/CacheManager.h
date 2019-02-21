//
//  CacheManager.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/18/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#ifndef CacheManager_h
#define CacheManager_h

#import <Foundation/Foundation.h>
#import "CdbBid.h"
#import "CRAdUnit.h"

@interface CacheManager : NSObject

@property (nonatomic, strong) NSMutableDictionary<CRAdUnit *, CdbBid *> *bidCache;

- (void) initSlots: (NSArray<CRAdUnit*> *) slotIds;

- (void) setBid: (CdbBid *) bid
      forAdUnit: (CRAdUnit *) adUnit;

- (CdbBid *) getBid: (CRAdUnit *) slotId;

@end

#endif /* CacheManager_h */
