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

#import "AdUnit.h"
#import "ApiHandler.h"
#import "CacheManager.h"
#import "Config.h"
#import "ConfigManager.h"
#import "DeviceInfo.h"
#import "GdprUserConsent.h"
#import "NetworkManager.h"

@interface BidManager : NSObject

- (instancetype) init NS_UNAVAILABLE;

- (instancetype) initWithApiHandler:(ApiHandler*)apiHandler
                       cacheManager:(CacheManager*)cacheManager
                             config:(Config*)config
                      configManager:(ConfigManager*)configManager
                         deviceInfo:(DeviceInfo*)deviceInfo
                    gdprUserConsent:(GdprUserConsent*)gdprUserConsent
                     networkManager:(NetworkManager*)networkManager
NS_DESIGNATED_INITIALIZER;


- (void) setSlots: (NSArray<AdUnit*> *) slots;

- (NSDictionary *) getBids: (NSArray<AdUnit*> *) slots;

- (CdbBid *) getBid: (AdUnit *) slot;

- (void) prefetchBid: (AdUnit *) slotId;

- (void) initConfigWithNetworkId:(NSNumber *) networkId;

- (void) addCriteoBidToRequest:(id) adRequest
                     forAdUnit:(AdUnit *) adUnit;

@end


#endif /* BidManager_h */
