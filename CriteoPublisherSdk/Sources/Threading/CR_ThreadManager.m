//
//  CR_ThreadManager.m
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

#include <libkern/OSAtomic.h>
#import "CR_ThreadManager.h"
#import "CR_Logging.h"

@interface CR_ThreadManager ()

@property(atomic, assign) NSInteger blockInProgressCounter;

@property(nonatomic, readonly) dispatch_queue_t timeoutBarrierQueue;

@end

@implementation CR_ThreadManager

- (instancetype)init {
  self = [super init];
  if (self) {
    _timeoutBarrierQueue =
        dispatch_queue_create("com.criteo.timeoutBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
  }
  return self;
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingIsIdle {
  return
      [[NSSet alloc] initWithObjects:NSStringFromSelector(@selector(blockInProgressCounter)), nil];
}

- (BOOL)isIdle {
  return (self.blockInProgressCounter == 0);
}

- (void)runWithCompletionContext:(void (^)(CR_CompletionContext *))block {
  CR_CompletionContext *context = [[CR_CompletionContext alloc] initWithThreadManager:self];
  block(context);
}

- (void)dispatchAsyncOnMainQueue:(dispatch_block_t)block {
  [self dispatchAsyncQueue:dispatch_get_main_queue() block:block];
}
- (void)dispatchAsyncOnGlobalQueue:(dispatch_block_t)block {
  [self dispatchAsyncQueue:self.globalQueue block:block];
}

- (void)dispatchAsyncOnGlobalQueueWithTimeout:(NSTimeInterval)timeout
                             operationHandler:(dispatchWithTimeoutOperationHandler)operationHandler
                               timeoutHandler:(dispatchWithTimeoutHandler)timeoutHandler {
  __block BOOL handled = NO;
  [self dispatchAsyncOnGlobalQueue:^{
    operationHandler(^(void (^completionHandler)(BOOL)) {
      dispatch_barrier_async(self.timeoutBarrierQueue, ^{
        completionHandler(handled);
        handled = YES;
      });
    });
  }];
  [self dispatchOnQueue:self.globalQueue
                  after:timeout
                  block:^{
                    dispatch_barrier_async(self.timeoutBarrierQueue, ^{
                      timeoutHandler(handled);
                      handled = YES;
                    });
                  }];
}

#pragma mark - Shared with CR_AsyncTaskWatcher

- (void)countUp {
  @synchronized(self) {
    self.blockInProgressCounter += 1;
  }
}

- (void)countDown {
  @synchronized(self) {
    self.blockInProgressCounter -= 1;
  }
}

#pragma mark - Private

- (dispatch_queue_global_t)globalQueue {
  return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

- (void)dispatchAsyncQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block {
  if (block == nil) return;

  [self countUp];
  dispatch_async(queue, ^{
    @try {
      block();
    } @catch (NSException *exception) {
      CRLogException(@"Threading", exception, @"Failed dispatching block");
    } @finally {
      [self countDown];
    }
  });
}

- (void)dispatchOnQueue:(dispatch_queue_t)queue
                  after:(NSTimeInterval)when
                  block:(dispatch_block_t)block {
  if (block == nil) return;

  [self countUp];
  dispatch_time_t afterTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(when * NSEC_PER_SEC));
  dispatch_after(afterTime, queue, ^{
    @try {
      block();
    } @catch (NSException *exception) {
      CRLogException(@"Threading", exception, @"Failed dispatching block after delay");
    } @finally {
      [self countDown];
    }
  });
}

@end

typedef NS_ENUM(NSInteger, CR_CompletionContextState) {
  CR_CompletionContextStateReady,
  CR_CompletionContextStateExecuting,
  CR_CompletionContextStateFinished,
};

@interface CR_CompletionContext ()

@property(weak, nonatomic, readonly) CR_ThreadManager *threadManager;
@property(assign, nonatomic) CR_CompletionContextState state;

@end

@implementation CR_CompletionContext

- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager {
  if (self = [super init]) {
    _state = CR_CompletionContextStateReady;
    _threadManager = threadManager;
    [_threadManager countUp];
  }
  return self;
}

- (void)executeBlock:(void (^)(void))block {
  @synchronized(self) {
    NSAssert(
        self.state == CR_CompletionContextStateReady,
        @"Try to execute a block on a context that is already executing something or finished: %zd",
        self.state);
    self.state = CR_CompletionContextStateExecuting;
  }
  @try {
    if (block != nil) {
      block();
    }
  } @catch (NSException *exception) {
    CRLogException(@"Threading", exception, @"Failed executing block");
  } @finally {
    self.state = CR_CompletionContextStateFinished;
    [self.threadManager countDown];
  }
}

@end
