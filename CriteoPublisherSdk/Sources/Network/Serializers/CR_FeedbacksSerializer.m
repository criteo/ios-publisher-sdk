//
//  CR_FeedbacksSerializer.m
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

#import "CR_FeedbacksSerializer.h"
#import "CR_FeedbackMessage.h"
#import "CR_Config.h"
#import "CR_ApiQueryKeys.h"

@implementation CR_FeedbacksSerializer

- (NSDictionary *)postBodyForCsm:(NSArray<CR_FeedbackMessage *> *)messages
                          config:(CR_Config *)config
                       profileId:(NSNumber *)profileId {
  NSMutableDictionary *postBody = [[NSMutableDictionary alloc] init];
  NSMutableArray *feedbacks = [[NSMutableArray alloc] init];
  for (CR_FeedbackMessage *message in messages) {
    [feedbacks addObject:[self buildFeedbackDictFromMessage:message]];
  }
  postBody[CR_ApiQueryKeys.feedbacks] = feedbacks;
  postBody[CR_ApiQueryKeys.wrapperVersion] = [config sdkVersion];
  postBody[CR_ApiQueryKeys.profile_id] = profileId;
  return postBody;
}

#pragma mark - Private methods

- (NSDictionary *)buildFeedbackDictFromMessage:(CR_FeedbackMessage *)message {
  NSMutableDictionary *feedbackDict = [[NSMutableDictionary alloc] init];
  feedbackDict[CR_ApiQueryKeys.bidSlots] = @[ [self buildSlotDictFromMessage:message] ];
  feedbackDict[CR_ApiQueryKeys.isTimeout] = @(message.isTimeout);
  feedbackDict[CR_ApiQueryKeys.cdbCallStartElapsed] = @(0);
  feedbackDict[CR_ApiQueryKeys.requestGroupId] = message.requestGroupId;

  feedbackDict[CR_ApiQueryKeys.cdbCallEndElapsed] =
      [self.class subtractionWithNumber1:message.cdbCallEndTimestamp
                                 number2:message.cdbCallStartTimestamp];

  feedbackDict[CR_ApiQueryKeys.feedbackElapsed] =
      [self.class subtractionWithNumber1:message.elapsedTimestamp
                                 number2:message.cdbCallStartTimestamp];

  return feedbackDict;
}

- (NSDictionary *)buildSlotDictFromMessage:(CR_FeedbackMessage *)message {
  NSMutableDictionary *slotDict = [[NSMutableDictionary alloc] init];
  slotDict[CR_ApiQueryKeys.bidSlotsImpressionId] = message.impressionId;
  slotDict[CR_ApiQueryKeys.bidSlotsCachedBidUsed] = @(message.cachedBidUsed);
  slotDict[CR_ApiQueryKeys.zoneId] = message.zoneId;
  return slotDict;
}

+ (NSNumber *)subtractionWithNumber1:(NSNumber *)number1 number2:(NSNumber *)number2 {
  if (number1 != nil) {
    return @([number1 integerValue] - [number2 integerValue]);
  }
  return nil;
}

@end
