//
//  CR_BidManager.h
//  pubsdk
//
//  Created by Adwait Kulkarni on 12/17/18.
//  Copyright © 2018 Criteo. All rights reserved.
//

#ifndef CR_BidManager_h
#define CR_BidManager_h

#import <Foundation/Foundation.h>

#import "CR_CacheAdUnit.h"
#import "CR_ApiHandler.h"
#import "CR_CacheManager.h"
#import "CR_Config.h"
#import "CR_ConfigManager.h"
#import "CR_DeviceInfo.h"
#import "CR_GdprUserConsent.h"
#import "CR_NetworkManager.h"
#import "CR_NetworkManagerDelegate.h"
#import "CR_AppEvents.h"

@interface CR_BidManager : NSObject

@property (nonatomic) id<CR_NetworkManagerDelegate> networkMangerDelegate;

- (instancetype) init NS_UNAVAILABLE;

- (instancetype) initWithApiHandler:(CR_ApiHandler*)apiHandler
                       cacheManager:(CR_CacheManager*)cacheManager
                             config:(CR_Config*)config
                      configManager:(CR_ConfigManager*)configManager
                         deviceInfo:(CR_DeviceInfo*)deviceInfo
                    gdprUserConsent:(CR_GdprUserConsent*)gdprUserConsent
                     networkManager:(CR_NetworkManager*)networkManager
                          appEvents:(CR_AppEvents *)appEvents
                     timeToNextCall:(NSTimeInterval)timeToNextCall
NS_DESIGNATED_INITIALIZER;


- (void) setSlots: (NSArray<CR_CacheAdUnit*> *) slots;

- (NSDictionary *) getBids: (NSArray<CR_CacheAdUnit*> *) slots;

- (CR_CdbBid *) getBid: (CR_CacheAdUnit *) slot;

- (void) prefetchBid: (CR_CacheAdUnit *) slotId;

- (void) addCriteoBidToRequest:(id) adRequest
                     forAdUnit:(CR_CacheAdUnit *) adUnit;

- (void) addCriteoBidToDfpRequest:(id) adRequest
                        forAdUnit:(CR_CacheAdUnit *) adUnit;

- (void) addCriteoBidToMopubRequest:(id) adRequest
                          forAdUnit:(CR_CacheAdUnit *) adUnit;

@end


#endif /* BidManager_h */
