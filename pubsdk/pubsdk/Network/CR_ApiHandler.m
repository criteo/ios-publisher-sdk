//
//  CR_ApiHandler.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "CR_ApiHandler.h"
#import "CR_ApiQueryKeys.h"
#import "CR_BidRequestSerializer.h"
#import "CR_Gdpr.h"
#import "CR_GdprSerializer.h"
#import "Logging.h"
#import "NSArray+Criteo.h"
#import "CR_ThreadManager.h"
#import "NSString+CriteoUrl.h"
#import "CR_FeedbacksSerializer.h"

static NSUInteger const maxAdUnitsPerCdbRequest = 8;

@interface CR_ApiHandler ()

@property(strong, nonatomic, readonly) CR_ThreadManager *threadManager;
@property(strong, nonatomic, readonly) CR_BidRequestSerializer *bidRequestSerializer;
@property(strong, nonatomic, readonly) CR_GdprSerializer *gdprSerializer;
@property(strong, nonatomic, readonly) CR_FeedbacksSerializer *feedbackSerializer;

@end

@implementation CR_ApiHandler

- (instancetype)init {
  NSAssert(false, @"Do not use this initializer");
  return [self initWithNetworkManager:nil bidFetchTracker:nil threadManager:nil];
}

- (instancetype)initWithNetworkManager:(CR_NetworkManager *)networkManager
                       bidFetchTracker:(CR_BidFetchTracker *)bidFetchTracker
                         threadManager:(CR_ThreadManager *)threadManager {
  if (self = [super init]) {
    _networkManager = networkManager;
    _bidFetchTracker = bidFetchTracker;
    _threadManager = threadManager;
    _gdprSerializer = [[CR_GdprSerializer alloc] init];
    _bidRequestSerializer =
        [[CR_BidRequestSerializer alloc] initWithGdprSerializer:_gdprSerializer];
    _feedbackSerializer = [[CR_FeedbacksSerializer alloc] init];
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
      CLog(
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
        beforeCdbCall:(CR_BeforeCdbCall)beforeCdbCall
    completionHandler:(CR_CdbCompletionHandler)completionHandler {
  [self.threadManager dispatchAsyncOnGlobalQueue:^{
    @try {
      [self doCdbApiCall:adUnits
                    consent:consent
                     config:config
                 deviceInfo:deviceInfo
              beforeCdbCall:(CR_BeforeCdbCall)beforeCdbCall
          completionHandler:completionHandler];
    } @catch (NSException *exception) {
      CLogException(exception);
    }
  }];
}

// Method that makes the actual call to CDB
- (void)doCdbApiCall:(CR_CacheAdUnitArray *)adUnits
              consent:(CR_DataProtectionConsent *)consent
               config:(CR_Config *)config
           deviceInfo:(CR_DeviceInfo *)deviceInfo
        beforeCdbCall:(CR_BeforeCdbCall)beforeCdbCall
    completionHandler:(CR_CdbCompletionHandler)completionHandler {
  CR_CacheAdUnitArray *requestAdUnits = [self filterRequestAdUnitsAndSetProgressFlags:adUnits];
  if (requestAdUnits.count == 0) {
    return;
  }

  NSArray<CR_CacheAdUnitArray *> *adUnitChunks =
      [requestAdUnits cr_splitIntoChunks:maxAdUnitsPerCdbRequest];
  for (CR_CacheAdUnitArray *adUnitChunk in adUnitChunks) {
    CR_CdbRequest *cdbRequest = [[CR_CdbRequest alloc] initWithAdUnits:adUnitChunk];

    if (beforeCdbCall) {
      beforeCdbCall(cdbRequest);
    }

    NSURL *url = [self.bidRequestSerializer urlWithConfig:config];
    NSDictionary *body = [self.bidRequestSerializer bodyWithCdbRequest:cdbRequest
                                                               consent:consent
                                                                config:config
                                                            deviceInfo:deviceInfo];
    CLogInfo(@"[INFO][API_] CdbPostCall.start");
    [self.networkManager postToUrl:url
                          postBody:body
                   responseHandler:^(NSData *data, NSError *error) {
                     CLogInfo(@"[INFO][API_] CdbPostCall.finished");
                     if (error == nil) {
                       if (completionHandler) {
                         CR_CdbResponse *cdbResponse =
                             [CR_CdbResponse responseWithData:data receivedAt:[NSDate date]];
                         completionHandler(cdbRequest, cdbResponse, error);
                       }
                     } else {
                       CLog(@"Error on post to CDB : %@", error);
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

- (void)getConfig:(CR_Config *)config ahConfigHandler:(AHConfigResponse)ahConfigHandler {
  if (![config criteoPublisherId] || [config sdkVersion].length == 0 ||
      [config appId].length == 0) {
    CLog(
        @"Config is is missing one of the following required values criteoPublisherId = %@, sdkVersion = %@, appId = %@",
        [config criteoPublisherId], [config sdkVersion], [config appId]);
    if (ahConfigHandler) {
      ahConfigHandler(nil);
    }
  }

  // TODO: Move the url + query building logic to CR_Config class
  NSString *query =
      [NSString stringWithFormat:@"cpId=%@&sdkVersion=%@&appId=%@", [config criteoPublisherId],
                                 [config sdkVersion], [config appId]];
  NSString *urlString = [NSString stringWithFormat:@"%@?%@", config.configUrl, query];
  NSURL *url = [NSURL URLWithString:urlString];
  CLogInfo(@"[INFO][API_] ConfigGetCall.start");
  [self.networkManager getFromUrl:url
                  responseHandler:^(NSData *data, NSError *error) {
                    CLogInfo(@"[INFO][API_] ConfigGetCall.finished");
                    if (error == nil) {
                      if (data && ahConfigHandler) {
                        NSDictionary *configValues = [CR_Config getConfigValuesFromData:data];
                        ahConfigHandler(configValues);
                      } else {
                        CLog(@"Error on get from Config: response from Config was nil");
                      }
                    } else {
                      CLog(@"Error on get from Config : %@", error);
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
  CLogInfo(@"[INFO][API_] AppEventGetCall.start");
  [self.networkManager
           getFromUrl:url
      responseHandler:^(NSData *data, NSError *error) {
        CLogInfo(@"[INFO][API_] AppEventGetCall.finished");
        if (error == nil) {
          if (data && ahEventHandler) {
            NSError *e = nil;
            NSDictionary *response =
                [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingMutableContainers
                                                  error:&e];
            if (!response) {
              CLog(@"Error parsing app event JSON to AppEvents. Error was: %@", e);
            } else {
              ahEventHandler(response, [NSDate date]);
            }
          } else {
            CLog(
                @"Error on get from app events end point; either value is nil: (response: %@) or (ahEventHandler: %p)",
                data, ahEventHandler);
          }
        } else {
          CLog(@"Error on get from app events end point. Error was: %@", error);
        }
      }];
}

- (void)sendFeedbackMessages:(NSArray<CR_FeedbackMessage *> *)messages
                      config:(CR_Config *)config
           completionHandler:(CR_CsmCompletionHandler)completionHandler {
  NSString *urlString = [NSString stringWithFormat:@"%@/%@", [config cdbUrl], [config csmPath]];
  NSURL *url = [NSURL URLWithString:urlString];

  NSDictionary *postBody = [self.feedbackSerializer postBodyForCsm:messages config:config];
  [self.networkManager postToUrl:url
                        postBody:postBody
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
  paramDict[CR_ApiQueryKeys.limitedAdTracking] = consent.isAdTrackingEnabled ? @"0" : @"1";
  paramDict[CR_ApiQueryKeys.gdpr] = [[self base64EncodedJsonForGdpr:consent.gdpr] cr_urlEncode];
  NSString *params = [NSString cr_urlQueryParamsWithDictionary:paramDict];
  return params;
}

- (NSString *)base64EncodedJsonForGdpr:(CR_Gdpr *)gdpr {
  NSDictionary *jsonObject = [self.gdprSerializer dictionaryForGdpr:gdpr];
  if (jsonObject == nil) {
    return nil;
  }
  NSError *error = nil;
  NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&error];
  NSAssert(error == nil, @"Impossible to serialized GDPR: %@ - %@", jsonObject, error);
  NSString *encoded = [data base64EncodedStringWithOptions:0];
  return encoded;
}

@end
