#import <_types.h>
//
//  CR_ApiHandler.m
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

#import <WebKit/WebKit.h>
#import "CR_ApiHandler.h"
#import "CR_ApiQueryKeys.h"
#import "CR_BidRequestSerializer.h"
#import "CR_Gdpr.h"
#import "CR_GdprSerializer.h"
#import "CR_Logging.h"
#import "CR_ThreadManager.h"
#import "NSString+CriteoUrl.h"
#import "CR_FeedbacksSerializer.h"
#import "CR_RemoteConfigRequest.h"
#import "CR_IntegrationRegistry.h"
#import "CR_Logging.h"
#import "CR_RemoteLogRecordSerializer.h"

static NSUInteger const maxAdUnitsPerCdbRequest = 8;

@interface CR_ApiHandler ()

@property(strong, nonatomic, readonly) CR_ThreadManager *threadManager;
@property(strong, nonatomic, readonly) CR_BidRequestSerializer *bidRequestSerializer;
@property(strong, nonatomic, readonly) CR_GdprSerializer *gdprSerializer;
@property(strong, nonatomic, readonly) CR_FeedbacksSerializer *feedbackSerializer;
@property(strong, nonatomic, readonly) CR_RemoteLogRecordSerializer *logSerializer;
@property(strong, nonatomic, readonly) CR_IntegrationRegistry *integrationRegistry;

@end

@implementation CR_ApiHandler

- (instancetype)initWithNetworkManager:(CR_NetworkManager *)networkManager
                       bidFetchTracker:(CR_BidFetchTracker *)bidFetchTracker
                         threadManager:(CR_ThreadManager *)threadManager
                   integrationRegistry:(CR_IntegrationRegistry *)integrationRegistry
                        userDataHolder:(CR_UserDataHolder *)userDataHolder
               internalContextProvider:(CR_InternalContextProvider *)internalContextProvider {
  if (self = [super init]) {
    _networkManager = networkManager;
    _bidFetchTracker = bidFetchTracker;
    _threadManager = threadManager;
    _gdprSerializer = [[CR_GdprSerializer alloc] init];
    _integrationRegistry = integrationRegistry;
    _bidRequestSerializer =
        [[CR_BidRequestSerializer alloc] initWithGdprSerializer:_gdprSerializer
                                                 userDataHolder:userDataHolder
                                        internalContextProvider:internalContextProvider];
    _feedbackSerializer = [[CR_FeedbacksSerializer alloc] init];
    _logSerializer = [[CR_RemoteLogRecordSerializer alloc] init];
  }
  return self;
}

// Filter out bad ad units, or ones that are already being fetched. The ones that pass have their
// "BidFetchInProgress" flags set in bidFetchTracker.
- (CR_CacheAdUnitArray *)filterRequestAdUnitsAndSetProgressFlags:(CR_CacheAdUnitArray *)adUnits {
  MutableCR_CacheAdUnitArray *requestAdUnits = [MutableCR_CacheAdUnitArray new];
  for (CR_CacheAdUnit *adUnit in adUnits) {
    if (adUnit.isValid) {
      if ([self.bidFetchTracker trySetBidFetchInProgressForAdUnit:adUnit]) {
        [requestAdUnits addObject:adUnit];
      }
    } else {
      CRLogWarn(
          @"Bidding",
          @"AdUnit is missing one of the following required values adUnitId = %@, width = %f, height = %f",
          adUnit.adUnitId, adUnit.size.width, adUnit.size.height);
    }
  }

  return requestAdUnits;
}

// Wrapper method to make the cdb call async
- (void)callCdb:(CR_CacheAdUnitArray *)adUnits
              consent:(CR_DataProtectionConsent *)consent
               config:(CR_Config *)config
           deviceInfo:(CR_DeviceInfo *)deviceInfo
              context:(CRContextData *)contextData
        beforeCdbCall:(CR_BeforeCdbCall)beforeCdbCall
    completionHandler:(CR_CdbCompletionHandler)completionHandler {
  [self.threadManager dispatchAsyncOnGlobalQueue:^{
    @try {
      [self doCdbApiCall:adUnits
                    consent:consent
                     config:config
                 deviceInfo:deviceInfo
                    context:contextData
              beforeCdbCall:(CR_BeforeCdbCall)beforeCdbCall
          completionHandler:completionHandler];
    } @catch (NSException *exception) {
      CRLogException(@"BidRequest", exception, @"Failed requesting bid");
    }
  }];
}

// Method that makes the actual call to CDB
- (void)doCdbApiCall:(CR_CacheAdUnitArray *)adUnits
              consent:(CR_DataProtectionConsent *)consent
               config:(CR_Config *)config
           deviceInfo:(CR_DeviceInfo *)deviceInfo
              context:(CRContextData *)contextData
        beforeCdbCall:(CR_BeforeCdbCall)beforeCdbCall
    completionHandler:(CR_CdbCompletionHandler)completionHandler {
  CR_CacheAdUnitArray *requestAdUnits = [self filterRequestAdUnitsAndSetProgressFlags:adUnits];
  if (requestAdUnits.count == 0) {
    return;
  }

  NSNumber *profileId = self.integrationRegistry.profileId;
  NSArray<CR_CacheAdUnitArray *> *adUnitChunks =
      [requestAdUnits cr_splitIntoChunks:maxAdUnitsPerCdbRequest];
  for (CR_CacheAdUnitArray *adUnitChunk in adUnitChunks) {
    CR_CdbRequest *cdbRequest = [[CR_CdbRequest alloc] initWithProfileId:profileId
                                                                 adUnits:adUnitChunk];

    if (beforeCdbCall) {
      beforeCdbCall(cdbRequest);
    }

    NSURL *url = [self.bidRequestSerializer urlWithConfig:config];
    NSDictionary *body = [self.bidRequestSerializer bodyWithCdbRequest:cdbRequest
                                                               consent:consent
                                                                config:config
                                                            deviceInfo:deviceInfo
                                                               context:contextData];
    [self.networkManager postToUrl:url
                              body:body
                        logWithTag:@"BidRequest"
                   responseHandler:^(NSData *data, NSError *error) {
                     if (error == nil) {
                       if (completionHandler) {
                         CR_CdbResponse *cdbResponse = [self cdbResponseWithData:data];
                         completionHandler(cdbRequest, cdbResponse, error);
                       }
                     } else {
                       if (completionHandler) {
                         completionHandler(cdbRequest, nil, error);
                       }
                     }
                     for (CR_CacheAdUnit *adUnit in adUnitChunk) {
                       [self.bidFetchTracker clearBidFetchInProgressForAdUnit:adUnit];
                     }
                   }];
  }
}

- (CR_CdbResponse *)cdbResponseWithData:(NSData *)data {
  return [CR_CdbResponse responseWithData:data receivedAt:[NSDate date]];
}

- (void)getConfig:(CR_RemoteConfigRequest *)request
    ahConfigHandler:(AHConfigResponse)ahConfigHandler {
  NSURL *url = [NSURL URLWithString:request.configUrl];

  CRLogDebug(@"Config", @"Getting remote config");
  [self.networkManager
            postToUrl:url
                 body:request.postBody
      responseHandler:^(NSData *data, NSError *error) {
        CRLogDebug(@"Config", @"Received config");
        if (error == nil) {
          if (data.length && ahConfigHandler) {
            NSDictionary *configValues = [CR_Config getConfigValuesFromData:data];
            ahConfigHandler(configValues);
          } else {
            CRLogInfo(@"Config",
                      @"Error on get from Config: response from Config was nil or empty");
          }
        } else {
          CRLogInfo(@"Config", @"Error on get from Config : %@", error);
        }
      }];
}

- (void)sendAppEvent:(NSString *)event
             consent:(CR_DataProtectionConsent *)consent
              config:(CR_Config *)config
          deviceInfo:(CR_DeviceInfo *)deviceInfo
      ahEventHandler:(AHAppEventsResponse)ahEventHandler {
  NSString *query = [self urlQueryParamsForAppEventWithEvent:event
                                                     consent:consent
                                                      config:config
                                                  deviceInfo:deviceInfo];
  NSString *urlString = [NSString
      stringWithFormat:@"%@/%@?%@", [config appEventsUrl], [config appEventsSenderId], query];
  NSURL *url = [NSURL URLWithString:urlString];
  CRLogDebug(@"AppEvent", @"[INFO][API_] AppEventGetCall.start");
  [self.networkManager
           getFromUrl:url
      responseHandler:^(NSData *data, NSError *error) {
        CRLogDebug(@"AppEvent", @"[INFO][API_] AppEventGetCall.finished");
        if (error == nil) {
          if (data.length && ahEventHandler) {
            NSError *e = nil;
            NSDictionary *response =
                [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingMutableContainers
                                                  error:&e];
            if (!response) {
              CRLogWarn(@"AppEvent", @"Error parsing app event JSON to AppEvents. Error was: %@",
                        e);
            } else {
              ahEventHandler(response, [NSDate date]);
            }
          } else {
            CRLogInfo(
                @"AppEvent",
                @"Error on get from app events end point; either value is nil or empty: (response: %@) or (ahEventHandler: %p)",
                data, ahEventHandler);
          }
        } else {
          CRLogInfo(@"AppEvent", @"Error on get from app events end point. Error was: %@", error);
        }
      }];
}

- (void)sendFeedbackMessages:(NSArray<CR_FeedbackMessage *> *)messages
                      config:(CR_Config *)config
                   profileId:(NSNumber *)profileId
           completionHandler:(CR_CsmCompletionHandler)completionHandler {
  if (messages.count == 0) {
    return;
  }

  NSString *urlString = [NSString stringWithFormat:@"%@/%@", [config cdbUrl], [config csmPath]];
  NSURL *url = [NSURL URLWithString:urlString];

  NSDictionary *postBody = [self.feedbackSerializer postBodyForCsm:messages
                                                            config:config
                                                         profileId:profileId];
  [self.networkManager postToUrl:url
                            body:postBody
                 responseHandler:^(NSData *data, NSError *error) {
                   if (completionHandler) {
                     completionHandler(error);
                   }
                 }];
}

- (void)sendLogs:(NSArray<CR_RemoteLogRecord *> *)records
               config:(CR_Config *)config
    completionHandler:(CR_LogsCompletionHandler)completionHandler {
  if (records.count == 0) {
    return;
  }

  NSString *urlString = [config.cdbUrl stringByAppendingPathComponent:config.logsPath];
  NSURL *url = [NSURL URLWithString:urlString];

  NSArray *body = [self.logSerializer serializeRecords:records];
  [self.networkManager postToUrl:url
                            body:body
                 responseHandler:^(NSData *data, NSError *error) {
                   if (completionHandler) {
                     completionHandler(error);
                   }
                 }];
}

#pragma mark - Private

- (NSString *)urlQueryParamsForAppEventWithEvent:(NSString *)event
                                         consent:(CR_DataProtectionConsent *)consent
                                          config:(CR_Config *)config
                                      deviceInfo:(CR_DeviceInfo *)deviceInfo {
  NSMutableDictionary<NSString *, NSString *> *paramDict = [[NSMutableDictionary alloc] init];
  paramDict[CR_ApiQueryKeys.idfa] = deviceInfo.deviceId;
  paramDict[CR_ApiQueryKeys.eventType] = event;
  paramDict[CR_ApiQueryKeys.appId] = config.appId;
  paramDict[CR_ApiQueryKeys.trackingAuthorizationStatus] =
      consent.trackingAuthorizationStatus.stringValue;
  paramDict[CR_ApiQueryKeys.gdprConsentForGum] = consent.gdpr.consentString;
  NSString *params = [NSString cr_urlQueryParamsWithDictionary:paramDict];
  return params;
}

@end
