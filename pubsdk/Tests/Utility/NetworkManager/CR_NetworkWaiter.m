//
//  CR_NetworkWaiter.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CR_NetworkWaiter.h"
#import "CR_NetworkCaptor.h"

const NSTimeInterval CR_NetworkWaiterDefaultTimeout = 15.f;

@interface CR_NetworkWaiter ()

@property (nonatomic, weak) CR_NetworkCaptor *networkCaptor;

@end

@implementation CR_NetworkWaiter

- (instancetype)initWithNetworkCaptor:(CR_NetworkCaptor *)networkCaptor
                              testers:(NSArray<CR_HTTPResponseTester> *)testers {
    if (self = [super init]) {
        _networkCaptor = networkCaptor;
        _testers = testers;
    }
    return self;
}

- (BOOL)wait {
    return [self waitWithTimeout:CR_NetworkWaiterDefaultTimeout];
}

- (BOOL)waitWithTimeout:(NSTimeInterval)timeout {
    NSMutableArray *expectations = [[NSMutableArray alloc] initWithCapacity:self.testers.count];
    for (NSUInteger i = 0; i < self.testers.count; i++) {
        NSString *desc = [[NSString alloc] initWithFormat:@"Tester #%lu", (unsigned long)i];
        XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:desc];
        [expectations addObject:expectation];
    }

    if (self.finishedRequestsIncluded) {
        for (CR_HttpContent *content in self.networkCaptor.finishedRequests) {
            [self _testWithHttpContent:content expectations:expectations];
        }
    }

    XCTWaiter *waiter = [[XCTWaiter alloc] init];
    self.networkCaptor.responseListener = ^(CR_HttpContent * _Nonnull httpContent) {
        [self _testWithHttpContent:httpContent expectations:expectations];
    };

    XCTWaiterResult result = [waiter waitForExpectations:expectations timeout:timeout];
    self.networkCaptor.responseListener = nil;
    return (result == XCTWaiterResultCompleted);
}

- (void)_testWithHttpContent:(CR_HttpContent *)content
                expectations:(NSArray<XCTestExpectation *> *)expectations {
    for (NSUInteger i = 0; i < self.testers.count; i++) {
        CR_HTTPResponseTester tester = self.testers[i];
        XCTestExpectation *expectation = expectations[i];
        if (tester(content)) {
            [expectation fulfill];
            break;
        }
    }
}

@end
