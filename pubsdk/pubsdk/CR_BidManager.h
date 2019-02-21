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

#import "CRAdUnit.h"
#import "ApiHandler.h"
#import "CR_CacheManager.h"
#import "CR_Config.h"
#import "CR_ConfigManager.h"
#import "DeviceInfo.h"
#import "GdprUserConsent.h"
#import "NetworkManager.h"
#import "NetworkManagerDelegate.h"
#import "CR_AppEvents.h"

@interface CR_BidManager : NSObject

@property (nonatomic) id<NetworkManagerDelegate> networkMangerDelegate;

- (instancetype) init NS_UNAVAILABLE;

- (instancetype) initWithApiHandler:(ApiHandler*)apiHandler
                       cacheManager:(CR_CacheManager*)cacheManager
                             config:(CR_Config*)config
                      configManager:(CR_ConfigManager*)configManager
                         deviceInfo:(DeviceInfo*)deviceInfo
                    gdprUserConsent:(GdprUserConsent*)gdprUserConsent
                     networkManager:(NetworkManager*)networkManager
                          appEvents:(CR_AppEvents *)appEvents
                     timeToNextCall:(NSTimeInterval)timeToNextCall
NS_DESIGNATED_INITIALIZER;


- (void) setSlots: (NSArray<CRAdUnit*> *) slots;

- (NSDictionary *) getBids: (NSArray<CRAdUnit*> *) slots;

- (CR_CdbBid *) getBid: (CRAdUnit *) slot;

- (void) prefetchBid: (CRAdUnit *) slotId;

- (void) addCriteoBidToRequest:(id) adRequest
                     forAdUnit:(CRAdUnit *) adUnit;

@end


#endif /* BidManager_h */
