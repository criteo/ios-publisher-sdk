//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_FeedbackStorage.h"
#import "CR_CdbBid.h"

@interface CR_FeedbackStorage (MessageUpdating)

- (void)setCdbStartAndImpressionIdForImpressionId:(NSString *)impressionId
                                   requestGroupId:(NSString *)requestGroupId;

- (void)setCdbEndAndCacheBidUsedIdForImpressionId:(NSString *)impressionId;

- (void)setCdbEndAndExpiredForImpressionId:(NSString *)impressionId;

- (void)setElapsedForImpressionId:(NSString *)impressionId;

- (void)setExpiredForImpressionId:(NSString *)impressionId;

- (void)setTimeoutAndExpiredForImpressionId:(NSString *)impressionId;

@end
