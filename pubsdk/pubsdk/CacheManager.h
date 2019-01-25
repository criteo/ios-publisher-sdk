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
#import "AdUnit.h"

@interface CacheManager : NSObject

@property (nonatomic, strong) NSMutableDictionary<AdUnit *, CdbBid *> *bidCache;

- (void) initSlots: (NSArray<AdUnit*> *) slotIds;

- (void) setBid: (CdbBid *) bid
      forAdUnit: (AdUnit *) adUnit;

- (CdbBid *) getBid: (AdUnit *) slotId;

@end

#endif /* CacheManager_h */
