//
//  CR_ThreadManagerWaiter.m
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
#import "CR_ThreadManager.h"
#import "CR_ThreadManagerWaiter.h"

@interface CR_ThreadManagerWaiter ()

@property(class, assign, nonatomic, readonly) NSTimeInterval defaultTimeout;
@property(class, assign, nonatomic, readonly) NSTimeInterval timeoutForPerformanceTests;

@property(nonatomic, strong, readonly) CR_ThreadManager *threadManager;
@property(nonatomic, strong) XCTestExpectation *expectation;

@end

@implementation CR_ThreadManagerWaiter

#pragma mark - Class methods

+ (NSTimeInterval)defaultTimeout {
  return 15.;
}

+ (NSTimeInterval)timeoutForPerformanceTests {
  return 30.;
}

#pragma mark - Life Cycle

- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager {
  if (self = [super init]) {
    _threadManager = threadManager;
  }
  return self;
}

#pragma mark - Public

- (void)waitIdle {
  [self waitIdleWithTimeout:self.class.defaultTimeout];
}

- (void)waitIdleForPerformanceTests {
  [self waitIdleWithTimeout:self.class.timeoutForPerformanceTests];
}

- (void)waitIdleWithTimeout:(NSTimeInterval)timeout {
  NSString *keypath = NSStringFromSelector(@selector(isIdle));
  XCTKVOExpectation *expectation = [[XCTKVOExpectation alloc] initWithKeyPath:keypath
                                                                       object:self.threadManager
                                                                expectedValue:@YES];
  XCTWaiter *waiter = [[XCTWaiter alloc] init];
  XCTWaiterResult result = [waiter waitForExpectations:@[ expectation ] timeout:timeout];
  NSAssert(result == XCTWaiterResultCompleted,
           @"Idle mode did not finished (reason = %ld, nbBlockInProgress = %ld)", (long)result,
           (long)self.threadManager.blockInProgressCounter);
  result = result;  // to avoid compilation error
}

@end
