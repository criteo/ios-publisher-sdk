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

#import "CRAdUnit.h"
#import "ApiHandler.h"
#import "CacheManager.h"
#import "Config.h"
#import "ConfigManager.h"
#import "DeviceInfo.h"
#import "GdprUserConsent.h"
#import "NetworkManager.h"
#import "NetworkManagerDelegate.h"
#import "CR_AppEvents.h"

@interface BidManager : NSObject

@property (nonatomic) id<NetworkManagerDelegate> networkMangerDelegate;

- (instancetype) init NS_UNAVAILABLE;

- (instancetype) initWithApiHandler:(ApiHandler*)apiHandler
                       cacheManager:(CacheManager*)cacheManager
                             config:(Config*)config
                      configManager:(ConfigManager*)configManager
                         deviceInfo:(DeviceInfo*)deviceInfo
                    gdprUserConsent:(GdprUserConsent*)gdprUserConsent
                     networkManager:(NetworkManager*)networkManager
                          appEvents:(CR_AppEvents *)appEvents
                     timeToNextCall:(NSTimeInterval)timeToNextCall
NS_DESIGNATED_INITIALIZER;


- (void) setSlots: (NSArray<CRAdUnit*> *) slots;

- (NSDictionary *) getBids: (NSArray<CRAdUnit*> *) slots;

- (CdbBid *) getBid: (CRAdUnit *) slot;

- (void) prefetchBid: (CRAdUnit *) slotId;

- (void) addCriteoBidToRequest:(id) adRequest
                     forAdUnit:(CRAdUnit *) adUnit;

@end


#endif /* BidManager_h */
