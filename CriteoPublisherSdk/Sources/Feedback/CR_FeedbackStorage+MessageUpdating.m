//
//  CR_FeedbackStorage+MessageUpdating.m
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

#import "CR_FeedbackStorage+MessageUpdating.h"

@implementation CR_FeedbackStorage (MessageUpdating)

- (void)setCdbStartForImpressionId:(NSString *)impressionId
                         profileId:(NSNumber *)profileId
                    requestGroupId:(NSString *)requestGroupId {
  [self updateMessageWithImpressionId:impressionId
                                   by:^(CR_FeedbackMessage *message) {
                                     message.cdbCallStartTimestamp =
                                         [self dateTimeNowInMilliseconds];
                                     message.impressionId = impressionId;
                                     message.profileId = profileId;
                                     message.requestGroupId = requestGroupId;
                                   }];
}

- (void)setCdbEndForImpressionId:(NSString *)impressionId zoneId:(NSNumber *)zoneId {
  [self updateMessageWithImpressionId:impressionId
                                   by:^(CR_FeedbackMessage *message) {
                                     message.cdbCallEndTimestamp = [self dateTimeNowInMilliseconds];
                                     message.zoneId = zoneId;
                                   }];
}

- (void)setCacheBidUsedForImpressionId:(NSString *)impressionId {
  [self updateMessageWithImpressionId:impressionId
                                   by:^(CR_FeedbackMessage *message) {
                                     message.cachedBidUsed = YES;
                                   }];
}

- (void)setCdbEndAndExpiredForImpressionId:(NSString *)impressionId {
  [self updateMessageWithImpressionId:impressionId
                                   by:^(CR_FeedbackMessage *message) {
                                     message.cdbCallEndTimestamp = [self dateTimeNowInMilliseconds];
                                     message.expired = YES;
                                   }];
}

- (void)setElapsedForImpressionId:(NSString *)impressionId {
  [self updateMessageWithImpressionId:impressionId
                                   by:^(CR_FeedbackMessage *message) {
                                     message.elapsedTimestamp = [self dateTimeNowInMilliseconds];
                                   }];
}

- (void)setExpiredForImpressionId:(NSString *)impressionId {
  [self updateMessageWithImpressionId:impressionId
                                   by:^(CR_FeedbackMessage *message) {
                                     message.expired = YES;
                                   }];
}

- (void)setTimeoutAndExpiredForImpressionId:(NSString *)impressionId {
  [self updateMessageWithImpressionId:impressionId
                                   by:^(CR_FeedbackMessage *message) {
                                     message.timeout = YES;
                                     message.expired = YES;
                                   }];
}

#pragma mark - Private methods

- (NSNumber *)dateTimeNowInMilliseconds {
  NSTimeInterval nowInMilliseconds = [[NSDate date] timeIntervalSince1970] * 1000.0;
  return [[NSNumber alloc] initWithDouble:nowInMilliseconds];
}

@end
