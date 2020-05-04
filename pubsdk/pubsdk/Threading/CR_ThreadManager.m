//
//  CR_ThreadManager.m
//  pubsdk
//
//  Copyright © 2020 Criteo. All rights reserved.
//

#include <libkern/OSAtomic.h>
#import "CR_ThreadManager.h"
#import "Logging.h"

@interface CR_ThreadManager ()

@property (atomic, assign) NSInteger blockInProgressCounter;

@end

@implementation CR_ThreadManager

+ (NSSet<NSString *> *)keyPathsForValuesAffectingIsIdle {
    return [[NSSet alloc] initWithObjects:NSStringFromSelector(@selector(blockInProgressCounter)), nil];
}

- (BOOL)isIdle {
    return (self.blockInProgressCounter == 0);
}

- (void)runWithCompletionContext:(void(^)(CR_CompletionContext *)) block {
    CR_CompletionContext *context = [[CR_CompletionContext alloc] initWithThreadManager:self];
    block(context);
}

- (void)dispatchAsyncOnMainQueue:(dispatch_block_t)block {
    [self dispatchAsyncQueue:dispatch_get_main_queue()
                       block:block];
}
- (void)dispatchAsyncOnGlobalQueue:(dispatch_block_t)block {
    [self dispatchAsyncQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                       block:block];
}

#pragma mark - Shared with CR_AsyncTaskWatcher

- (void)countUp {
    @synchronized (self) {
        self.blockInProgressCounter += 1;
    }
}

- (void)countDown {
    @synchronized (self) {
        self.blockInProgressCounter -= 1;
    }
}

#pragma mark - Private

- (void)dispatchAsyncQueue:(dispatch_queue_t)queue
                     block:(dispatch_block_t)block {
    if (block == nil) return;

    [self countUp];
    dispatch_async(queue, ^{
        @try {
            block();
        }
        @catch (NSException *exception) {
            CLogException(exception);
        }
        @finally {
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

@property (weak, nonatomic, readonly) CR_ThreadManager *threadManager;
@property (assign, nonatomic) CR_CompletionContextState state;

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

- (void)executeBlock:(void(^)(void))block {
    @synchronized (self) {
        NSAssert(self.state == CR_CompletionContextStateReady,
                 @"Try to execute a block on a context that is already executing something or finished: %zd",
                 self.state);
        self.state = CR_CompletionContextStateExecuting;
    }
    @try {
        if (block != nil) {
            block();
        }
    }
    @catch (NSException *exception) {
        CLogException(exception);
    }
    @finally {
        self.state = CR_CompletionContextStateFinished;
        [self.threadManager countDown];
    }
}

@end
