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
#import "CdbBid.h"
#import "CRAdUnit.h"

@interface CR_CacheManager : NSObject

@property (nonatomic, strong) NSMutableDictionary<CRAdUnit *, CdbBid *> *bidCache;

- (void) initSlots: (NSArray<CRAdUnit*> *) slotIds;

- (void) setBid: (CdbBid *) bid
      forAdUnit: (CRAdUnit *) adUnit;

- (CdbBid *) getBid: (CRAdUnit *) slotId;

@end

#endif /* CR_CacheManager_h */
