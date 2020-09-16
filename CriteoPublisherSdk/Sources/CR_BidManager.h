//
//  CR_BidManager.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
#import "Criteo+Internal.h"

@protocol CR_FeedbackDelegate;
@class CR_HeaderBidding;
@class CR_ThreadManager;

@interface CR_BidManager : NSObject

@property(nonatomic) id<CR_NetworkManagerDelegate> networkManagerDelegate;
@property(nonatomic, readonly) CR_Config *config;
@property(nonatomic, strong) CR_DataProtectionConsent *consent;
@property(nonatomic, strong) CR_ThreadManager *threadManager;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithApiHandler:(CR_ApiHandler *)apiHandler
                      cacheManager:(CR_CacheManager *)cacheManager
                        tokenCache:(CR_TokenCache *)tokenCache
                            config:(CR_Config *)config
                     configManager:(CR_ConfigManager *)configManager
                        deviceInfo:(CR_DeviceInfo *)deviceInfo
                           consent:(CR_DataProtectionConsent *)consent
                    networkManager:(CR_NetworkManager *)networkManager
                         appEvents:(CR_AppEvents *)appEvents
                     headerBidding:(CR_HeaderBidding *)headerBidding
                  feedbackDelegate:(id<CR_FeedbackDelegate>)feedbackDelegate
                     threadManager:(CR_ThreadManager *)threadManager NS_DESIGNATED_INITIALIZER;

- (void)registerWithSlots:(CR_CacheAdUnitArray *)slots;

- (NSDictionary *)getBids:(CR_CacheAdUnitArray *)slots;

- (CR_CdbBid *)getBid:(CR_CacheAdUnit *)slot;

- (CRBidResponse *)bidResponseForCacheAdUnit:(CR_CacheAdUnit *)cacheAdUnit
                                  adUnitType:(CRAdUnitType)adUnitType;

- (void)prefetchBidForAdUnit:(CR_CacheAdUnit *)adUnit;
- (void)prefetchBidsForAdUnits:(CR_CacheAdUnitArray *)adUnits;
- (void)fetchLiveBidForAdUnit:(CR_CacheAdUnit *)adUnit
           bidResponseHandler:(CR_BidResponseHandler)responseHandler;

- (void)addCriteoBidToRequest:(id)adRequest forAdUnit:(CR_CacheAdUnit *)adUnit;

- (CR_TokenValue *)tokenValueForBidToken:(CRBidToken *)bidToken adUnitType:(CRAdUnitType)adUnitType;

@end

#endif /* BidManager_h */
