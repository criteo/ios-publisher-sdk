//
// Created by Aleksandr Pakhmutov on 03/03/2020.
// Copyright (c) 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_FeedbackStorage.h"
#import "CR_CdbBid.h"

@interface CR_FeedbackStorage (MessageUpdating)

- (void)setCdbStartForAdUnit:(CR_CacheAdUnit *)cacheAdUnit;

- (void)setCdbEndAndImpressionId:(NSString *)impressionId forAdUnit:(CR_CacheAdUnit *)cacheAdUnit;

- (void)setCdbEndAndExpiredForAdUnit:(CR_CacheAdUnit *)cacheAdUnit;

- (void)setElapsedForAdUnit:(CR_CacheAdUnit *)cacheAdUnit;

- (void)setExpiredForAdUnit:(CR_CacheAdUnit *)cacheAdUnit;

- (void)setTimeoutedForAdUnit:(CR_CacheAdUnit *)cacheAdUnit;

@end