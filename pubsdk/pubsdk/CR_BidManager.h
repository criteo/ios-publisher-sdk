//
//  CR_BidManager.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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
#import "CR_DataProtectionConsent.h"
#import "CR_NetworkManager.h"
#import "CR_NetworkManagerDelegate.h"
#import "CR_AppEvents.h"
#import "CR_TokenCache.h"
#import "CRBidResponse+Internal.h"
#import "CR_FeedbackStorage.h"

@protocol CR_FeedbackDelegate;
@class CR_ThreadManager;

@interface CR_BidManager : NSObject

@property (nonatomic) id<CR_NetworkManagerDelegate> networkManagerDelegate;
@property (nonatomic, readonly) CR_Config *config;
@property (nonatomic, strong) CR_DataProtectionConsent *consent;
@property (nonatomic, strong) CR_ThreadManager *threadManager;

- (instancetype) init NS_UNAVAILABLE;

- (instancetype) initWithApiHandler:(CR_ApiHandler *)apiHandler
                       cacheManager:(CR_CacheManager *)cacheManager
                         tokenCache:(CR_TokenCache *)tokenCache
                             config:(CR_Config *)config
                      configManager:(CR_ConfigManager *)configManager
                         deviceInfo:(CR_DeviceInfo *)deviceInfo
                            consent:(CR_DataProtectionConsent *)consent
                     networkManager:(CR_NetworkManager *)networkManager
                          appEvents:(CR_AppEvents *)appEvents
                     timeToNextCall:(NSTimeInterval)timeToNextCall
                    feedbackDelegate:(id <CR_FeedbackDelegate>)feedbackDelegate
                      threadManager:(CR_ThreadManager *)threadManager
NS_DESIGNATED_INITIALIZER;


- (void)registerWithSlots:(CR_CacheAdUnitArray *)slots;

- (NSDictionary *) getBids: (CR_CacheAdUnitArray *) slots;

- (CR_CdbBid *) getBid: (CR_CacheAdUnit *) slot;

- (CRBidResponse *)bidResponseForCacheAdUnit:(CR_CacheAdUnit *)cacheAdUnit
                                  adUnitType:(CRAdUnitType)adUnitType;

- (void) prefetchBid:(CR_CacheAdUnit *) adUnit;

- (void) prefetchBids:(CR_CacheAdUnitArray *) adUnits;

- (void) addCriteoBidToRequest:(id) adRequest
                     forAdUnit:(CR_CacheAdUnit *) adUnit;

- (void) addCriteoBidToDfpRequest:(id) adRequest
                        forAdUnit:(CR_CacheAdUnit *) adUnit;

- (void) addCriteoBidToMopubRequest:(id) adRequest
                          forAdUnit:(CR_CacheAdUnit *) adUnit;

- (CR_TokenValue *)tokenValueForBidToken:(CRBidToken *)bidToken
                              adUnitType:(CRAdUnitType)adUnitType;

@end


#endif /* BidManager_h */
