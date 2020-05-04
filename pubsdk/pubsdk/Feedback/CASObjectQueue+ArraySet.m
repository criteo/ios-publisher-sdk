//
//  CASObjectQueue+ArraySet.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CASObjectQueue+ArraySet.h"

@implementation CASObjectQueue (ArraySet)

- (void)addFeedbackMessage:(CR_FeedbackMessage *)message {
    NSAssert(![self containsFeedbackMessage:message],
             @"Add to the queue an existing element: %@",
             [self allFeedbackMessages]);
    [self add:message];
}

- (BOOL)containsFeedbackMessage:(CR_FeedbackMessage *)message {
    NSArray *all = [self allFeedbackMessages];
    for (CR_FeedbackMessage *m in all) {
        if ([m.impressionId isEqualToString:message.impressionId]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)allFeedbackMessages {
    return [self peek:NSUIntegerMax];
}

@end
