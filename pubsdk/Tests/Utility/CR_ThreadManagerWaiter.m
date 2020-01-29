//
//  CR_ThreadManagerWaiter.m
//  pubsdk
//
//  Created by Romain Lofaso on 1/29/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_ThreadManager.h"
#import "CR_ThreadManagerWaiter.h"

const NSTimeInterval CR_ThreadManagerWaiterTimeout = 15.f;

@interface CR_ThreadManagerWaiter ()

@property (nonatomic, strong, readonly) CR_ThreadManager *threadManager;
@property (nonatomic, strong) XCTestExpectation *expectation;

@end

@implementation CR_ThreadManagerWaiter

- (instancetype)initWithThreadManager:(CR_ThreadManager *)threadManager {
    if (self = [super init]) {
        _threadManager = threadManager;
    }
    return self;
}

- (void)waitIdle {
    [self waitIdleWithTimeout:CR_ThreadManagerWaiterTimeout];
}

- (void)waitIdleWithTimeout:(NSTimeInterval)timeout {
    NSString *keypath = NSStringFromSelector(@selector(isIdle));
    XCTKVOExpectation *expectation = [[XCTKVOExpectation alloc] initWithKeyPath:keypath
                                                                         object:self.threadManager
                                                                  expectedValue:@YES];
    XCTWaiter *waiter = [[XCTWaiter alloc] init];
    XCTWaiterResult result = [waiter waitForExpectations:@[expectation]
                                                 timeout:timeout];
    NSAssert(result == XCTWaiterResultCompleted, @"Idle mode did not finished (reason = %ld, nbBlockInProgress = %ld)", (long)result, self.threadManager.blockInProgressCounter);
    result = result; // to avoid compilation error
}

@end
