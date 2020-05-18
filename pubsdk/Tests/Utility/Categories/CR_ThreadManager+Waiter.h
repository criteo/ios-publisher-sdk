//
//  CR_ThreadManager+Waiter.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_ThreadManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_ThreadManager (Waiter)

- (void)waiter_waitIdle;

@end

NS_ASSUME_NONNULL_END
