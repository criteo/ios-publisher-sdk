//
//  CR_ThreadManager.h
//  pubsdk
//
//  Created by Romain Lofaso on 1/29/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CR_CompletionContext;

/**
 * Abstraction over GCD for executing tasks.
 *
 * Usefull to implement a CountDownLatch in the tests.
 */
@interface CR_ThreadManager : NSObject

@property (atomic, assign, readonly) BOOL isIdle;
@property (atomic, assign, readonly) NSInteger blockInProgressCounter;

- (void)dispatchAsyncOnMainQueue:(dispatch_block_t)block;
- (void)dispatchAsyncOnGlobalQueue:(dispatch_block_t)block;

/** Runs with a context interacting with the CR_ThreadManager instance. */
- (void)runWithCompletionContext:(void(^)(CR_CompletionContext *)) block;

@end

/**
 * Run completion code that cannot be handled directly by
 * the CR_ThreadManager API.
 *
 * It increment the blockInProgressCounter of CR_ThreadManager
 * as soon as it is initialized.
 */
@interface CR_CompletionContext : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager NS_DESIGNATED_INITIALIZER;

/** Execute the block. Can be called only once per instance. */
- (void)executeBlock:(void(^)(void))block;

@end

NS_ASSUME_NONNULL_END
