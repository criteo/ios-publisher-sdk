//
//  CR_FeedbackController.m
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

#import "CR_FeedbackController.h"
#import "CR_FeedbackStorage+MessageUpdating.h"
#import "CR_CdbRequest.h"
#import "CR_CdbResponse.h"
#import "CR_ApiHandler.h"
#import "Logging.h"
#import "CR_FeedbackConsentGuard.h"
#import "CR_FeedbackFeatureGuard.h"
#import "CR_IntegrationRegistry.h"

@interface CR_FeedbackController ()

@property(nonatomic, strong, readonly) CR_FeedbackStorage *feedbackStorage;
@property(nonatomic, strong, readonly) CR_ApiHandler *apiHandler;
@property(nonatomic, strong, readonly) CR_Config *config;

@end

@implementation CR_FeedbackController

- (instancetype)init {
  NSAssert(false, @"Do not use this initializer");
  return nil;
}

- (instancetype)initWithFeedbackStorage:(CR_FeedbackStorage *)feedbackStorage
                             apiHandler:(CR_ApiHandler *)apiHandler
                                 config:(CR_Config *)config
                                consent:(CR_DataProtectionConsent *)consent {
  if (self = [super init]) {
    _feedbackStorage = feedbackStorage;
    _apiHandler = apiHandler;
    _config = config;
  }
  return self;
}

+ (id<CR_FeedbackDelegate>)controllerWithFeedbackStorage:(CR_FeedbackStorage *)feedbackStorage
                                              apiHandler:(CR_ApiHandler *)apiHandler
                                                  config:(CR_Config *)config
                                                 consent:(CR_DataProtectionConsent *)consent {
  CR_FeedbackController *controller =
      [[CR_FeedbackController alloc] initWithFeedbackStorage:feedbackStorage
                                                  apiHandler:apiHandler
                                                      config:config
                                                     consent:consent];

  CR_FeedbackConsentGuard *consentGuard =
      [[CR_FeedbackConsentGuard alloc] initWithController:controller consent:consent];
  CR_FeedbackFeatureGuard *featureGuard =
      [[CR_FeedbackFeatureGuard alloc] initWithController:consentGuard config:config];

  return featureGuard;
}

- (void)onCdbCallStarted:(CR_CdbRequest *)request {
  for (NSString *impressionId in request.impressionIds) {
    [self.feedbackStorage setCdbStartForImpressionId:impressionId
                                           profileId:request.profileId
                                      requestGroupId:request.requestGroupId];
  }
}

- (void)onCdbCallResponse:(CR_CdbResponse *)response fromRequest:(CR_CdbRequest *)request {
  NSArray<NSString *> *impressionIdsWithNoBid =
      [request impressionIdsMissingInCdbResponse:response];
  for (NSString *impressionId in impressionIdsWithNoBid) {
    [self.feedbackStorage setCdbEndAndExpiredForImpressionId:impressionId];
  }

  for (CR_CdbBid *bid in response.cdbBids) {
    if (bid.impressionId) {
      if (bid.isValid) {
        [self.feedbackStorage setCdbEndAndCacheBidUsedIdForImpressionId:bid.impressionId
                                                                 zoneId:bid.zoneId];
      } else {
        [self.feedbackStorage setExpiredForImpressionId:bid.impressionId];
      }
    }
  }
}

- (void)onCdbCallFailure:(NSError *)failure fromRequest:(CR_CdbRequest *)request {
  for (NSString *impressionId in request.impressionIds) {
    if (failure.code == NSURLErrorTimedOut) {
      [self.feedbackStorage setTimeoutAndExpiredForImpressionId:impressionId];
    } else {
      [self.feedbackStorage setExpiredForImpressionId:impressionId];
    }
  }
}

- (void)onBidConsumed:(CR_CdbBid *)consumedBid {
  if (consumedBid.isExpired) {
    [self.feedbackStorage setExpiredForImpressionId:consumedBid.impressionId];
  } else {
    [self.feedbackStorage setElapsedForImpressionId:consumedBid.impressionId];
  }
}

- (void)sendFeedbackBatch {
  NSArray<CR_FeedbackMessage *> *messages = [self.feedbackStorage popMessagesToSend];
  NSDictionary<NSNumber *, NSArray<CR_FeedbackMessage *> *> *messagesByProfileId =
      [messages cr_groupByKey:^NSNumber *(CR_FeedbackMessage *message) {
        return message.profileId ?: @(CR_IntegrationFallback);
      }];
  [messagesByProfileId
      enumerateKeysAndObjectsUsingBlock:^(NSNumber *profileId,
                                          NSArray<CR_FeedbackMessage *> *messages_, BOOL *stop) {
        [self sendFeedbacks:messages_ profileId:profileId];
      }];
}

- (void)sendFeedbacks:(NSArray<CR_FeedbackMessage *> *)messages profileId:(NSNumber *)profileId {
  NSArray<CR_FeedbackMessage *> *messagesToRollback = messages;
  [self.apiHandler
      sendFeedbackMessages:messagesToRollback
                    config:self.config
                 profileId:profileId
         completionHandler:^(NSError *error) {
           if (error) {
             CLog(@"CSM sending was failed with error: %@", error.localizedDescription);
             [self.feedbackStorage pushMessagesToSend:messagesToRollback];
           }
         }];
}

@end
