//
//  CR_ThreadManagerTests.m
//  CriteoPublisherSdkTests
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

#import <XCTest/XCTest.h>

#import "XCTestCase+Criteo.h"
#import "CR_ThreadManager.h"
#import "CR_ThreadManager+Waiter.h"

#define CR_ThreadManagerTestsDebug 0

#if CR_ThreadManagerTestsDebug == 1

#define CR_ThreadManagerTestsDebugLog(args...) \
  do {                                         \
    CRInternaLog(args);                        \
  } while (0);

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
  NSString *content = [[NSString alloc] initWithFormat:format arguments:arguments];
  va_end(arguments);
  dispatch_async(CRInternalLogQueue(), ^{
    NSLog(@"[CR_ThreadManagerTests][DEBUG] %@", content);
  });
}

#else

#define CR_ThreadManagerTestsDebugLog(args...) ((void)0)

#endif

@interface CR_ThreadManagerTests : XCTestCase

@property(nonatomic, strong) CR_ThreadManager *manager;
@property(atomic, assign) NSUInteger counter;

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

    [self _recDispatchAsyncOnGlobalQueueWithNumberOfDispatches:2 currentLevel:3 nodeName:@"1"];

    [self.manager waiter_waitIdle];

    XCTAssertEqual(self.counter, 14);
  }
}

#pragma mark - dispatchAsyncOnQueueWithTimeout

- (void)testDispatchAsyncOnQueueWithTimeout_whenInTimeBudget_handledOnOperationHandler {
  XCTestExpectation *handledOnOperationHandler =
      [[XCTestExpectation alloc] initWithDescription:@"Operation Handled"];
  XCTestExpectation *notHandledOnTimeoutHandler =
      [[XCTestExpectation alloc] initWithDescription:@"Not timeout handled"];
  [self.manager dispatchAsyncOnGlobalQueueWithTimeout:0.1
      operationHandler:^void(void (^completionHandler)(dispatchWithTimeoutHandler)) {
        // do nothing and return immediately
        completionHandler(^(BOOL handled) {
          XCTAssertFalse(handled, @"Operation to be handled by operation handler");
          if (!handled) {
            [handledOnOperationHandler fulfill];
          }
        });
      }
      timeoutHandler:^(BOOL handled) {
        XCTAssertTrue(handled, @"Operation already handled by operation handler");
        if (handled) {
          [notHandledOnTimeoutHandler fulfill];
        }
      }];
  [self waitForExpectations:@[ handledOnOperationHandler, notHandledOnTimeoutHandler ]
                    timeout:2
               enforceOrder:YES];
}

- (void)testDispatchAsyncOnQueueWithTimeout_whenTimeout_handledOnTimeoutHandler {
  XCTestExpectation *notHandledOnOperationHandler =
      [[XCTestExpectation alloc] initWithDescription:@"Not Operation Handled"];
  XCTestExpectation *handledOnTimeoutHandler =
      [[XCTestExpectation alloc] initWithDescription:@"Timeout handled"];
  [self.manager dispatchAsyncOnGlobalQueueWithTimeout:0.1
      operationHandler:^void(void (^completionHandler)(dispatchWithTimeoutHandler)) {
        // Wait longer than timeout
        [NSThread sleepForTimeInterval:1];
        completionHandler(^(BOOL handled) {
          XCTAssertTrue(handled, @"Operation already handled by timeout handler");
          if (handled) {
            [notHandledOnOperationHandler fulfill];
          }
        });
      }
      timeoutHandler:^(BOOL handled) {
        XCTAssertFalse(handled, @"Operation to be handled by timeout handler");
        if (!handled) {
          [handledOnTimeoutHandler fulfill];
        }
      }];
  [self waitForExpectations:@[ handledOnTimeoutHandler, notHandledOnOperationHandler ]
                    timeout:2
               enforceOrder:YES];
}

#pragma mark - Private

- (void)_recDispatchAsyncOnGlobalQueueWithNumberOfDispatches:(NSUInteger)numberOfDispatches
                                                currentLevel:(NSUInteger)currentLevel
                                                    nodeName:(NSString *)nodeName {
  if (currentLevel == 0) return;

  for (NSUInteger i = 1; i <= numberOfDispatches; i++) {
    NSString *newNodeName = [[NSString alloc] initWithFormat:@"%@.%lu", nodeName, (unsigned long)i];
    CR_ThreadManagerTestsDebugLog(@"Before dispatch %@", newNodeName);
    [self.manager dispatchAsyncOnGlobalQueue:^{
      CR_ThreadManagerTestsDebugLog(@"Begin dispatch %@", newNodeName);
      @synchronized(self) {
        self.counter += 1;
      }
      [self _recDispatchAsyncOnGlobalQueueWithNumberOfDispatches:numberOfDispatches
                                                    currentLevel:currentLevel - 1
                                                        nodeName:newNodeName];
    }];
  }
}

@end
