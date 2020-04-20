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

/**
 * Default timeout relevant for the unit tests and the integrations tests.
 */
@property (class, assign, nonatomic, readonly) NSTimeInterval defaultTimeout;

/**
 * The performance tests can be longuer than other kind of tests.
 * It requires a timeout greater than the default one.
 */
@property (class, assign, nonatomic, readonly) NSTimeInterval timeoutForPerformanceTests;

- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager;

- (void)waitIdleWithTimeout:(NSTimeInterval)timeout;

@end

NS_ASSUME_NONNULL_END
