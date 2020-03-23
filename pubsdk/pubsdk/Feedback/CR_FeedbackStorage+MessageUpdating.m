//
// Created by Aleksandr Pakhmutov on 03/03/2020.
// Copyright (c) 2020 Criteo. All rights reserved.
//

#import "CR_FeedbackStorage+MessageUpdating.h"


@implementation CR_FeedbackStorage (MessageUpdating)

- (void)setCdbStartForImpressionId:(NSString *)impressionId {
    [self updateMessageWithImpressionId:impressionId by:^(CR_FeedbackMessage *message) {
        message.cdbCallStartTimestamp = [self dateTimeNowInMilliseconds];
    }];
}

- (void)setCdbEndForImpressionId:(NSString *)impressionId {
    [self updateMessageWithImpressionId:impressionId by:^(CR_FeedbackMessage *message) {
        message.cdbCallEndTimestamp = [self dateTimeNowInMilliseconds];
        message.impressionId = impressionId;
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

- (void)setTimeoutedForImpressionId:(NSString *)impressionId {
    [self updateMessageWithImpressionId:impressionId by:^(CR_FeedbackMessage *message) {
        message.timeouted = YES;
    }];
}

#pragma mark - Private methods

- (NSNumber *)dateTimeNowInMilliseconds {
    NSTimeInterval nowInMilliseconds = [[NSDate date] timeIntervalSince1970] * 1000.0;
    return [[NSNumber alloc] initWithDouble:nowInMilliseconds];
}

@end
