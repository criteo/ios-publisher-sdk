//
//  CR_ThreadManager.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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

@property(atomic, assign, readonly) BOOL isIdle;
@property(atomic, assign, readonly) NSInteger blockInProgressCounter;

- (void)dispatchAsyncOnMainQueue:(dispatch_block_t)block;
- (void)dispatchAsyncOnGlobalQueue:(dispatch_block_t)block;

/** Runs with a context interacting with the CR_ThreadManager instance. */
- (void)runWithCompletionContext:(void (^)(CR_CompletionContext *))block;

typedef void (^dispatchWithTimeoutHandler)(BOOL handled);
typedef void (^dispatchWithTimeoutOperationHandler)(
    void (^completionCallback)(dispatchWithTimeoutHandler));

/**
 * Dispatch asynchronously an operation block and a timeout block concurrently.
 *
 * Whatever the outcome of the operation is, both handlers will be called with a flag indicating if
 * the operation has already been handled.
 * - When the Operation block completes, it must call the provided block with a callback argument
 *   that will be called providing the `handled` flag
 * - When the timeout is reached, the `timeoutHandler` will be called with the `handled` flag.
 *
 * Example use:
 * [self.manager dispatchAsyncOnGlobalQueueWithTimeout:5 operationHandler:
 * ^void(void (^completionHandler)(dispatchWithTimeoutHandler)) {
 *   // Long running task that is subject to timeout, can be asynchronous
 *   // On completion you MUST call the handler that will call back with the handled status:
 *   completionHandler(^(BOOL handled) {
 *       if (handled) {
 *         // means timeout reached before completion
 *       }
 *   });
 * }
 * timeoutHandler:^(BOOL handled) {
 *   if (!handled) {
 *     // means timeout reached before completion
 *   }
 * }];
 *
 * @param timeout Timeout value in seconds
 * @param operationHandler Block to run on Global Queue, with a block callback argument to retrieve
 * the handled status
 * @param timeoutHandler Block to be run on timeout, with the handled flag as argument
 */
- (void)dispatchAsyncOnGlobalQueueWithTimeout:(NSTimeInterval)timeout
                             operationHandler:(dispatchWithTimeoutOperationHandler)operationHandler
                               timeoutHandler:(dispatchWithTimeoutHandler)timeoutHandler;

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
- (void)executeBlock:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
