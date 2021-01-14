//
//  CR_ApiHandler.h
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

#ifndef CR_ApiHandler_h
#define CR_ApiHandler_h

#import <Foundation/Foundation.h>
#import "CR_NetworkManager.h"
#import "CR_CacheAdUnit.h"
#import "CR_CdbRequest.h"
#import "CR_CdbResponse.h"
#import "CR_CdbRequest.h"
#import "CR_Config.h"
#import "CR_DataProtectionConsent.h"
#import "CR_DeviceInfo.h"
#import "CR_BidFetchTracker.h"
#import "CR_FeedbackMessage.h"
#import "CR_UserDataHolder.h"
#import "CR_InternalContextProvider.h"

@class CR_FeedbackStorage;
@class CR_ThreadManager;
@class CR_RemoteConfigRequest;
@class CR_RemoteLogRecord;
@class CR_IntegrationRegistry;
@class CRContextData;

typedef void (^CR_CdbCompletionHandler)(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse,
                                        NSError *error);
typedef void (^CR_BeforeCdbCall)(CR_CdbRequest *cdbRequest);
typedef void (^AHConfigResponse)(NSDictionary *configValues);
typedef void (^AHAppEventsResponse)(NSDictionary *appEventValues, NSDate *receivedAt);
typedef void (^CR_CsmCompletionHandler)(NSError *error);
typedef void (^CR_LogsCompletionHandler)(NSError *error);

@interface CR_ApiHandler : NSObject
@property(strong, nonatomic) CR_NetworkManager *networkManager;
@property(strong, nonatomic) CR_BidFetchTracker *bidFetchTracker;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNetworkManager:(CR_NetworkManager *)networkManager
                       bidFetchTracker:(CR_BidFetchTracker *)bidFetchTracker
                         threadManager:(CR_ThreadManager *)threadManager
                   integrationRegistry:(CR_IntegrationRegistry *)integrationRegistry
                        userDataHolder:(CR_UserDataHolder *)userDataHolder
               internalContextProvider:(CR_InternalContextProvider *)internalContextProvider
    NS_DESIGNATED_INITIALIZER;

/**
 * Calls CDB and get the bid & creative for the adUnit
 * adUnit must have an Id, width and length.
 */
- (void)callCdb:(CR_CacheAdUnitArray *)adUnits
              consent:(CR_DataProtectionConsent *)consent
               config:(CR_Config *)config
           deviceInfo:(CR_DeviceInfo *)deviceInfo
              context:(__unused CRContextData *)contextData
        beforeCdbCall:(CR_BeforeCdbCall)beforeCdbCall
    completionHandler:(CR_CdbCompletionHandler)completionHandler;

/**
 * Builds the CDB response for given Data. This method is intended to mock responses.
 * @param data raw data from network
 * @return CDB response model object instance
 */
- (CR_CdbResponse *)cdbResponseWithData:(NSData *)data;

/**
 * Calls the pub-sdk config endpoint and gets the config values for the publisher
 * NetworkId, AppId/BundleId, sdkVersion must be present in the config
 */
- (void)getConfig:(CR_RemoteConfigRequest *)request
    ahConfigHandler:(AHConfigResponse)ahConfigHandler;

/**
 * Calls the app event endpoint and gets the throttleSec value for the user
 */
- (void)sendAppEvent:(NSString *)event
             consent:(CR_DataProtectionConsent *)consent
              config:(CR_Config *)config
          deviceInfo:(CR_DeviceInfo *)deviceInfo
      ahEventHandler:(AHAppEventsResponse)ahEventHandler;

/**
 * Calls CSM endpoint and send collected metrics
 */
- (void)sendFeedbackMessages:(NSArray<CR_FeedbackMessage *> *)messages
                      config:(CR_Config *)config
                   profileId:(NSNumber *)profileId
           completionHandler:(CR_CsmCompletionHandler)completionHandler;

/**
 * Send Logs to CDB logs endpoint
 */
- (void)sendLogs:(NSArray<CR_RemoteLogRecord *> *)records
               config:(CR_Config *)config
    completionHandler:(CR_CsmCompletionHandler)completionHandler;

/**
 * Exposed for testing only
 */
- (CR_CacheAdUnitArray *)filterRequestAdUnitsAndSetProgressFlags:(CR_CacheAdUnitArray *)adUnits;

@end

#endif /* CR_ApiHandler_h */
