//
//  CR_ThreadManager+Waiter.h
//  pubsdk
//
//  Created by Romain Lofaso on 1/29/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_ThreadManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface CR_ThreadManager (Waiter)

- (void)waiter_waitIdle;

@end

NS_ASSUME_NONNULL_END
