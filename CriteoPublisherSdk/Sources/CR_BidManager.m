//
//  CR_BidManager.m
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

#import "CR_BidManager.h"
#import "Logging.h"
#import "CR_FeedbackController.h"
#import "CR_HeaderBidding.h"
#import "CR_ThreadManager.h"

typedef void (^CR_CdbResponseHandler)(CR_CdbResponse *response);

@interface CR_BidManager ()

@property(nonatomic, assign, readonly) BOOL isInSilenceMode;
@property(nonatomic, strong, readonly) CR_HeaderBidding *headerBidding;
@property(nonatomic, strong, readonly) id<CR_FeedbackDelegate> feedbackDelegate;
@property(nonatomic) NSTimeInterval cdbTimeToNextCall;

@end

@implementation CR_BidManager {
  CR_ApiHandler *apiHandler;
  CR_CacheManager *cacheManager;
  CR_TokenCache *tokenCache;
  CR_Config *config;
  CR_DeviceInfo *deviceInfo;
  CR_NetworkManager *networkManager;
}

// Properties
- (id<CR_NetworkManagerDelegate>)networkManagerDelegate {
  return self->networkManager.delegate;
}

- (void)setNetworkManagerDelegate:(id<CR_NetworkManagerDelegate>)networkManagerDelegate {
  self->networkManager.delegate = networkManagerDelegate;
}

- (instancetype)init {
  NSAssert(false, @"Do not use this initializer");
  return [self initWithApiHandler:nil
                     cacheManager:nil
                       tokenCache:nil
                           config:nil
                       deviceInfo:nil
                          consent:nil
                   networkManager:nil
                    headerBidding:nil
                 feedbackDelegate:nil
                    threadManager:nil];
}

- (instancetype)initWithApiHandler:(CR_ApiHandler *)apiHandler
                      cacheManager:(CR_CacheManager *)cacheManager
                        tokenCache:(CR_TokenCache *)tokenCache
                            config:(CR_Config *)config
                        deviceInfo:(CR_DeviceInfo *)deviceInfo
                           consent:(CR_DataProtectionConsent *)consent
                    networkManager:(CR_NetworkManager *)networkManager
                     headerBidding:(CR_HeaderBidding *)headerBidding
                  feedbackDelegate:(id<CR_FeedbackDelegate>)feedbackDelegate
                     threadManager:(CR_ThreadManager *)threadManager {
  if (self = [super init]) {
    self->apiHandler = apiHandler;
    self->cacheManager = cacheManager;
    self->tokenCache = tokenCache;
    self->config = config;
    self->deviceInfo = deviceInfo;
    self->networkManager = networkManager;
    _cdbTimeToNextCall = 0;
    _consent = consent;
    _feedbackDelegate = feedbackDelegate;
    _threadManager = threadManager;
    _headerBidding = headerBidding;
  }

  return self;
}

- (void)getBidForAdUnit:(CR_CacheAdUnit *)adUnit
     bidResponseHandler:(CR_BidResponseHandler)responseHandler {
  if (config.liveBiddingEnabled) {
    [self fetchLiveBidForAdUnit:adUnit bidResponseHandler:responseHandler];
  } else {
    responseHandler([self getBidThenFetch:adUnit]);
  }
}

- (CR_CdbBid *)getBidThenFetch:(CR_CacheAdUnit *)slot {
  CR_CdbBid *bid = nil;
  @try {
    bid = [self getBid:slot
           bidConsumed:^(CR_CdbBid *bid, BOOL didConsumeBid) {
             [self.threadManager dispatchAsyncOnGlobalQueue:^{
               if (didConsumeBid) {
                 [self.feedbackDelegate onBidConsumed:bid];
               }
               if (bid == nil || bid.isRenewable) {
                 [self prefetchBidForAdUnit:slot];
               }
             }];
           }];
  } @catch (NSException *exception) {
    CLogException(exception);
  }
  return bid;
}

- (CR_CdbBid *)getBid:(CR_CacheAdUnit *)slot
          bidConsumed:(void (^)(CR_CdbBid *bid, BOOL didConsumeBid))bidConsumed {
  CR_CdbBid *bid = [cacheManager getBidForAdUnit:slot];
  CR_CdbBid *result = bid;
  BOOL didConsumeBid = NO;

  if (bid == nil || [bid isEqual:[CR_CdbBid emptyBid]]) {
    result = [CR_CdbBid emptyBid];
  } else if (bid.isExpired) {
    // immediately invalidate current cache entry if bid is expired
    [cacheManager removeBidForAdUnit:slot];
    didConsumeBid = YES;
    result = [CR_CdbBid emptyBid];
  } else if (bid.isInSilenceMode) {
    result = [CR_CdbBid emptyBid];
  } else {
    // remove it from the cache and consume the good bid
    [cacheManager removeBidForAdUnit:slot];
    didConsumeBid = YES;
  }

  bidConsumed(bid, didConsumeBid);
  return result;
}

- (BOOL)isInSilenceMode {
  return [[NSDate date] timeIntervalSinceReferenceDate] < self.cdbTimeToNextCall;
}

- (CR_TokenValue *)tokenValueForBidToken:(CRBidToken *)bidToken
                              adUnitType:(CRAdUnitType)adUnitType {
  return [tokenCache getValueForToken:bidToken adUnitType:adUnitType];
}

- (void)prefetchBidForAdUnit:(CR_CacheAdUnit *)adUnit {
  [self prefetchBidsForAdUnits:@[ adUnit ]];
}

- (void)prefetchBidsForAdUnits:(CR_CacheAdUnitArray *)adUnits {
  [self fetchBidsForAdUnits:adUnits
         cdbResponseHandler:^(CR_CdbResponse *cdbResponse) {
           [self cacheBidsFromResponse:cdbResponse];
         }];
}

- (void)fetchLiveBidForAdUnit:(CR_CacheAdUnit *)adUnit
           bidResponseHandler:(CR_BidResponseHandler)responseHandler {
  [self fetchLiveBidForAdUnit:adUnit
           bidResponseHandler:responseHandler
                   timeBudget:config.liveBiddingTimeBudget];
}

- (void)fetchLiveBidForAdUnit:(CR_CacheAdUnit *)adUnit
           bidResponseHandler:(CR_BidResponseHandler)responseHandler
                   timeBudget:(NSTimeInterval)timeBudget {
  [self.threadManager dispatchAsyncOnGlobalQueueWithTimeout:timeBudget
      operationHandler:^void(void (^completionHandler)(dispatchWithTimeoutHandler)) {
        [self fetchBidsForAdUnits:@[ adUnit ]
               cdbResponseHandler:^(CR_CdbResponse *cdbResponse) {
                 completionHandler(^(BOOL handled) {
                   if (!handled) {
                     NSAssert(cdbResponse.cdbBids.count <= 1,
                              @"During a live request, only one bid will be fetched at a time.");
                     if (cdbResponse.cdbBids.count == 1) {
                       CR_CdbBid *bid = cdbResponse.cdbBids[0];
                       if (bid.isInSilenceMode && !bid.isExpired) {
                         [self cacheBidsFromResponse:cdbResponse];
                         responseHandler(nil);
                       } else if (bid.isValid && !bid.isExpired) {
                         responseHandler(bid);
                       } else {
                         responseHandler(nil);
                       }
                     } else {
                       responseHandler(nil);
                     }
                   } else {
                     [self cacheBidsFromResponse:cdbResponse];
                   }
                 });
               }];
      }
      timeoutHandler:^(BOOL handled) {
        if (!handled) {
          CR_CdbBid *bid = [self getBid:adUnit
                            bidConsumed:^(CR_CdbBid *bid, BOOL didConsumeBid) {
                              // TODO Check CSM logic with live bidding
                              if (didConsumeBid) {
                                [self.feedbackDelegate onBidConsumed:bid];
                              }
                            }];
          responseHandler(bid);
        }
      }];
}

- (void)fetchBidsForAdUnits:(CR_CacheAdUnitArray *)adUnits
         cdbResponseHandler:(CR_CdbResponseHandler)responseHandler {
  if ([self cannotCallCdb]) {
    if (responseHandler) {
      responseHandler(nil);
    }
    return;
  }

  CLogInfo(@"Fetching bids for ad units: %@", adUnits);
  [deviceInfo waitForUserAgent:^{
    [self->apiHandler callCdb:adUnits
        consent:self.consent
        config:self->config
        deviceInfo:self->deviceInfo
        beforeCdbCall:^(CR_CdbRequest *cdbRequest) {
          [self beforeCdbCall:cdbRequest];
        }
        completionHandler:^(CR_CdbRequest *cdbRequest, CR_CdbResponse *cdbResponse,
                            NSError *error) {
          if (error) {
            [self handleError:error cdbRequest:cdbRequest];
            if (responseHandler) {
              responseHandler(nil);
            }
          } else if (cdbResponse) {
            [self handleResponse:cdbResponse cdbRequest:cdbRequest];
            if (responseHandler) {
              responseHandler(cdbResponse);
            }
          }
        }];
  }];

  [self.feedbackDelegate sendFeedbackBatch];
}

- (void)beforeCdbCall:(CR_CdbRequest *)cdbRequest {
  [self.feedbackDelegate onCdbCallStarted:cdbRequest];
}

- (void)handleError:(NSError *)error cdbRequest:(CR_CdbRequest *)cdbRequest {
  [self.feedbackDelegate onCdbCallFailure:error fromRequest:cdbRequest];
}

- (void)handleResponse:(CR_CdbResponse *)cdbResponse cdbRequest:(CR_CdbRequest *)cdbRequest {
  [self updateTimeToNextCallIfProvided:cdbResponse];

  for (CR_CdbBid *bid in cdbResponse.cdbBids) {
    if (bid.isImmediate) {
      [bid setDefaultTtl];
    }
  }

  [self.feedbackDelegate onCdbCallResponse:cdbResponse fromRequest:cdbRequest];
}

- (BOOL)cannotCallCdb {
  if (!config) {
    CLog(@"Cannot call CDB: Config hasn't been fetched.");
    return YES;
  } else if ([config killSwitch]) {
    CLog(@"Cannot call CDB: killSwitch is engaged.");
    return YES;
  } else if (self.isInSilenceMode) {
    CLog(@"Cannot call CDB: User level silent Mode.");
    return YES;
  }
  return NO;
}

- (void)updateTimeToNextCallIfProvided:(CR_CdbResponse *)cdbResponse {
  if (cdbResponse.timeToNextCall) {
    self.cdbTimeToNextCall = [[NSDate dateWithTimeIntervalSinceNow:cdbResponse.timeToNextCall]
        timeIntervalSinceReferenceDate];
  }
}

- (void)addCriteoBidToRequest:(id)adRequest forAdUnit:(CR_CacheAdUnit *)adUnit {
  @try {
    [self unsafeAddCriteoBidToRequest:adRequest forAdUnit:adUnit];
  } @catch (NSException *exception) {
    CLogException(exception);
  }
}

- (void)unsafeAddCriteoBidToRequest:(id)adRequest forAdUnit:(CR_CacheAdUnit *)adUnit {
  if (!config) {
    CLog(@"Config hasn't been fetched. So no bids will be fetched.");
    return;
  } else if ([config killSwitch]) {
    CLog(@"killSwitch is engaged. No bid will be fetched.");
    return;
  }

  CR_CdbBid *fetchedBid = [self getBidThenFetch:adUnit];
  [self.headerBidding enrichRequest:adRequest withBid:fetchedBid adUnit:adUnit];
}

- (CRBidResponse *)bidResponseForCacheAdUnit:(CR_CacheAdUnit *)cacheAdUnit
                                  adUnitType:(CRAdUnitType)adUnitType {
  CR_CdbBid *bid = [self getBidThenFetch:cacheAdUnit];
  if ([bid isEmpty]) {
    return [[CRBidResponse alloc] initWithPrice:0.0 bidSuccess:NO bidToken:nil];
  }
  CRBidToken *bidToken = [tokenCache getTokenForBid:bid adUnitType:adUnitType];
  return [[CRBidResponse alloc] initWithPrice:[bid.cpm doubleValue]
                                   bidSuccess:YES
                                     bidToken:bidToken];
}

- (void)cacheBidsFromResponse:(CR_CdbResponse *)cdbResponse {
  for (CR_CdbBid *bid in cdbResponse.cdbBids) {
    [cacheManager setBid:bid];
  }
}

- (CR_Config *)config {
  return self->config;
}

@end
