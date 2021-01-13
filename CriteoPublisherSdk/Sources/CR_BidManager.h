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
#import "CRBid+Internal.h"
#import "CR_FeedbackStorage.h"
#import "Criteo+Internal.h"
#import "CRContextData.h"

@protocol CR_FeedbackDelegate;
@class CR_HeaderBidding;
@class CR_ThreadManager;
@class CR_RemoteLogHandler;

@interface CR_BidManager : NSObject

#pragma mark - Properties

@property(nonatomic) id<CR_NetworkManagerDelegate> networkManagerDelegate;
@property(nonatomic, readonly) CR_Config *config;
@property(nonatomic, strong) CR_DataProtectionConsent *consent;
@property(nonatomic, strong) CR_ThreadManager *threadManager;

#pragma mark - Lifecycle

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithApiHandler:(CR_ApiHandler *)apiHandler
                      cacheManager:(CR_CacheManager *)cacheManager
                            config:(CR_Config *)config
                        deviceInfo:(CR_DeviceInfo *)deviceInfo
                           consent:(CR_DataProtectionConsent *)consent
                    networkManager:(CR_NetworkManager *)networkManager
                     headerBidding:(CR_HeaderBidding *)headerBidding
                  feedbackDelegate:(id<CR_FeedbackDelegate>)feedbackDelegate
                     threadManager:(CR_ThreadManager *)threadManager
                  remoteLogHandler:(CR_RemoteLogHandler *)remoteLogHandler;

@end

@interface CR_BidManager (Bidding)

/**
 * Get a bid for an Ad Unit.
 *
 * Depending on `liveBidding` being enabled through configuration, the bid will be either:
 * - Fetched asynchronously using the live bidding strategy (time budget / cache fallback)
 * - Returned synchronously using the cache bidding strategy (prefetch / get from cache)
 *
 * @param adUnit The ad unit to request a bid
 * @param contextData The context for this bid
 * @param responseHandler The block called once bid has been loaded
 * Note: responseHandler is potentially not invoked on main queue
 */
- (void)loadCdbBidForAdUnit:(CR_CacheAdUnit *)adUnit
                withContext:(CRContextData *)contextData
            responseHandler:(CR_CdbBidResponseHandler)responseHandler;

@end

@interface CR_BidManager (CacheBidding)

- (void)prefetchBidsForAdUnits:(CR_CacheAdUnitArray *)adUnits
                   withContext:(CRContextData *)contextData;

@end

@interface CR_BidManager (LiveBidding)

- (void)fetchLiveBidForAdUnit:(CR_CacheAdUnit *)adUnit
                  withContext:(CRContextData *)contextData
              responseHandler:(CR_CdbBidResponseHandler)responseHandler;

@end

@interface CR_BidManager (HeaderBidding)

- (void)enrichAdObject:(id)object withBid:(CRBid *)bid;

@end

#endif /* BidManager_h */
