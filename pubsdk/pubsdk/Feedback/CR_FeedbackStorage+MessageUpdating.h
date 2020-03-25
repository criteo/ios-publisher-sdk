//
// Created by Aleksandr Pakhmutov on 03/03/2020.
// Copyright (c) 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_FeedbackStorage.h"
#import "CR_CdbBid.h"

@interface CR_FeedbackStorage (MessageUpdating)

- (void)setCdbStartForImpressionId:(NSString *)impressionId;

- (void)setCdbEndAndImpressionIdForImpressionId:(NSString *)impressionId;

- (void)setCdbEndAndExpiredForImpressionId:(NSString *)impressionId;

- (void)setElapsedForImpressionId:(NSString *)impressionId;

- (void)setExpiredForImpressionId:(NSString *)impressionId;

- (void)setTimeoutedForImpressionId:(NSString *)impressionId;

@end
