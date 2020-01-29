//
//  CR_ThreadManagerWaiter.h
//  pubsdk
//
//  Created by Romain Lofaso on 1/29/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CR_ThreadManager;

NS_ASSUME_NONNULL_BEGIN

@interface CR_ThreadManagerWaiter : NSObject

- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager;

- (void)waitIdle;
- (void)waitIdleWithTimeout:(NSTimeInterval)timeout;

@end

NS_ASSUME_NONNULL_END
