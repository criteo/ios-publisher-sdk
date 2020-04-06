//
// Created by Aleksandr Pakhmutov on 03/03/2020.
// Copyright (c) 2020 Criteo. All rights reserved.
//

#import "CR_FeedbackStorage+MessageUpdating.h"


@implementation CR_FeedbackStorage (MessageUpdating)

- (void)setCdbStartAndImpressionIdForImpressionId:(NSString *)impressionId requestGroupId:(NSString *)requestGroupId {
    [self updateMessageWithImpressionId:impressionId by:^(CR_FeedbackMessage *message) {
        message.cdbCallStartTimestamp = [self dateTimeNowInMilliseconds];
        message.impressionId = impressionId;
        message.requestGroupId = requestGroupId;
    }];
}

- (void)setCdbEndAndCacheBidUsedIdForImpressionId:(NSString *)impressionId {
    [self updateMessageWithImpressionId:impressionId by:^(CR_FeedbackMessage *message) {
        message.cdbCallEndTimestamp = [self dateTimeNowInMilliseconds];
        // All bids are consumed from the cache, for current SDK implementation, the value for this
        // field will be true if the bid is ready to be consumed
        message.cachedBidUsed = YES;
    }];
}

- (void)setCdbEndAndExpiredForImpressionId:(NSString *)impressionId {
    [self updateMessageWithImpressionId:impressionId by:^(CR_FeedbackMessage *message) {
        message.cdbCallEndTimestamp = [self dateTimeNowInMilliseconds];
        message.expired = YES;
    }];
}

- (void)setElapsedForImpressionId:(NSString *)impressionId {
    [self updateMessageWithImpressionId:impressionId by:^(CR_FeedbackMessage *message) {
        message.elapsedTimestamp = [self dateTimeNowInMilliseconds];
    }];
}

- (void)setExpiredForImpressionId:(NSString *)impressionId {
    [self updateMessageWithImpressionId:impressionId by:^(CR_FeedbackMessage *message) {
        message.expired = YES;
    }];
}

- (void)setTimeoutForImpressionId:(NSString *)impressionId {
    [self updateMessageWithImpressionId:impressionId by:^(CR_FeedbackMessage *message) {
        message.timeout = YES;
    }];
}

#pragma mark - Private methods

- (NSNumber *)dateTimeNowInMilliseconds {
    NSTimeInterval nowInMilliseconds = [[NSDate date] timeIntervalSince1970] * 1000.0;
    return [[NSNumber alloc] initWithDouble:nowInMilliseconds];
}

@end
