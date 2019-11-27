//
//  CR_NetworkWaiter.m
//  pubsdkTests
//
//  Created by Romain Lofaso on 11/27/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CR_NetworkWaiter.h"
#import "CR_NetworkCaptor.h"

const NSTimeInterval CR_NetworkWaiterDefaultTimeout = 15.f;

@interface CR_NetworkWaiter ()

@property (nonatomic, weak) CR_NetworkCaptor *networkCaptor;

@end

@implementation CR_NetworkWaiter

- (instancetype)initWithNetworkCaptor:(CR_NetworkCaptor *)networkCaptor {
    if (self = [super init]) {
        _networkCaptor = networkCaptor;
    }
    return self;
}

- (BOOL)waitWithResponseTester:(CR_HTTPResponseTester)tester
{
    return [self waitWithTimeout:CR_NetworkWaiterDefaultTimeout responseTester:tester];
}

- (BOOL)waitWithTimeout:(NSTimeInterval)timeout responseTester:(CR_HTTPResponseTester)tester
{
    NSString *desc = @"The tester block given to CR_NetworkWaiter must return true once";
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:desc];
    XCTWaiter *waiter = [[XCTWaiter alloc] init];
    self.networkCaptor.responseListener = ^(CR_HttpContent * _Nonnull httpContent) {
        if (tester(httpContent)) {
            [expectation fulfill];
        }
    };
    XCTWaiterResult result = [waiter waitForExpectations:@[expectation] timeout:timeout];
    self.networkCaptor.responseListener = nil;
    return (result == XCTWaiterResultCompleted);
}

@end
