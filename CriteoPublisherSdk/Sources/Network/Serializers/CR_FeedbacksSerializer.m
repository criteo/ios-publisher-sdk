//
//  CR_FeedbacksSerializer.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_FeedbacksSerializer.h"
#import "CR_FeedbackMessage.h"
#import "CR_Config.h"
#import "CR_ApiQueryKeys.h"

@implementation CR_FeedbacksSerializer

- (NSDictionary *)postBodyForCsm:(NSArray<CR_FeedbackMessage *> *)messages
                          config:(CR_Config *)config {
  NSMutableDictionary *postBody = [[NSMutableDictionary alloc] init];
  NSMutableArray *feedbacks = [[NSMutableArray alloc] init];
  for (CR_FeedbackMessage *message in messages) {
    [feedbacks addObject:[self buildFeedbackDictFromMessage:message]];
  }
  postBody[CR_ApiQueryKeys.feedbacks] = feedbacks;
  postBody[CR_ApiQueryKeys.wrapperVersion] = [config sdkVersion];
  postBody[CR_ApiQueryKeys.profile_id] = [config profileId];
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
      [self.class substractionWithNumber1:message.cdbCallEndTimestamp
                                  number2:message.cdbCallStartTimestamp];

  feedbackDict[CR_ApiQueryKeys.feedbackElapsed] =
      [self.class substractionWithNumber1:message.elapsedTimestamp
                                  number2:message.cdbCallStartTimestamp];

  return feedbackDict;
}

- (NSDictionary *)buildSlotDictFromMessage:(CR_FeedbackMessage *)message {
  NSMutableDictionary *slotDict = [[NSMutableDictionary alloc] init];
  slotDict[CR_ApiQueryKeys.bidSlotsImpressionId] = message.impressionId;
  slotDict[CR_ApiQueryKeys.bidSlotsCachedBidUsed] = @(message.cachedBidUsed);
  return slotDict;
}

+ (NSNumber *)substractionWithNumber1:(NSNumber *)number1 number2:(NSNumber *)number2 {
  if (number1 != nil) {
    return @([number1 integerValue] - [number2 integerValue]);
  }
  return nil;
}

@end
