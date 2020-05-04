//
//  CR_ThreadManagerTests.m
//  pubsdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_ThreadManager.h"
#import "CR_ThreadManager+Waiter.h"

#define CR_ThreadManagerTestsDebug 0

#if CR_ThreadManagerTestsDebug == 1

#define CR_ThreadManagerTestsDebugLog(args...) \
do { \
CRInternaLog(args); \
} while(0);

dispatch_queue_t CRInternalLogQueue() {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.test.CR_ThreadManagerTests.log", NULL);
    });
    return queue;
}

void CRInternaLog(NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSString *content = [[NSString alloc] initWithFormat:format
                                               arguments:arguments];
    va_end(arguments);
    dispatch_async(CRInternalLogQueue(), ^{
        NSLog(@"[CR_ThreadManagerTests][DEBUG] %@", content);
    });
}

#else

#define CR_ThreadManagerTestsDebugLog(args...) ((void)0)

#endif


@interface CR_ThreadManagerTests : XCTestCase

@property (nonatomic, strong) CR_ThreadManager *manager;
@property (atomic, assign) NSUInteger counter;

@end

@implementation CR_ThreadManagerTests

- (void)setUp {
    self.manager = [[CR_ThreadManager alloc] init];
    self.counter = 0;
}

- (void)testManyDispatchAsyncInGlobalQueue {
    for (NSUInteger i = 0; i < 10; i++) {
        CR_ThreadManagerTestsDebugLog(@"***** testManyDispatchAsyncInGlobalQueue #%ld *******", i);
        self.counter = 0;

        [self _recDispatchAsyncOnGlobalQueueWithNumberOfDispatches:2
                                                      currentLevel:3
                                                          nodeName:@"1"];

        [self.manager waiter_waitIdle];

        XCTAssertEqual(self.counter, 14);
    }
}

- (void)_recDispatchAsyncOnGlobalQueueWithNumberOfDispatches:(NSUInteger)numberOfDispatches
                                                currentLevel:(NSUInteger)currentLevel
                                                    nodeName:(NSString *)nodeName {
    if (currentLevel == 0) return;

    for (NSUInteger i = 1; i <= numberOfDispatches; i++) {
        NSString *newNodeName = [[NSString alloc] initWithFormat:@"%@.%lu", nodeName, (unsigned long)i];
        CR_ThreadManagerTestsDebugLog(@"Before dispatch %@", newNodeName);
        [self.manager dispatchAsyncOnGlobalQueue:^{
            CR_ThreadManagerTestsDebugLog(@"Begin dispatch %@", newNodeName);
            @synchronized (self) {
                self.counter += 1;
            }
            [self _recDispatchAsyncOnGlobalQueueWithNumberOfDispatches:numberOfDispatches
                                                          currentLevel:currentLevel - 1
                                                              nodeName:newNodeName];
        }];
    }
}

@end
