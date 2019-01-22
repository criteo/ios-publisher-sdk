//
//  BidManager.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/17/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#ifndef BidManager_h
#define BidManager_h

#import <Foundation/Foundation.h>
#import "CacheManager.h"
#import "ApiHandler.h"
#import "AdUnit.h"
#import "GdprUserConsent.h"

@interface BidManager : NSObject
@property (strong, nonatomic) CacheManager *cacheManager;
@property (strong, nonatomic) ApiHandler *apiHandler;
@property (strong, nonatomic) NSNumber *networkId;
@property (strong, nonatomic) GdprUserConsent *gdpr;

- (instancetype) init;

- (void) setSlots: (NSArray<AdUnit*> *) slots;

- (NSDictionary *) getBids: (NSArray<AdUnit*> *) slots;

- (CdbBid *) getBid: (AdUnit *) slot;

- (void) prefetchBid: (AdUnit *) slotId;

- (void) setNetworkId:(NSNumber *) networkId;
- (NSNumber *) getNetworkId;

- (void) addCriteoBidToRequest:(id) adRequest
                     forAdUnit:(AdUnit *) adUnit;

@end


#endif /* BidManager_h */
