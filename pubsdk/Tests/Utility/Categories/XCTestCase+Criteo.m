//
//  XCTestCase+Criteo.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "XCTestCase+Criteo.h"

NSTimeInterval XCTestCaseCriteoTimeout = 10.f;
NSTimeInterval XCTestCaseCriteoShortTimeout = 3.f;

@implementation XCTestCase (Criteo)

- (void)cr_waitForExpectations:(NSArray<XCTestExpectation *> *)expectations {
    [self waitForExpectations:expectations timeout:XCTestCaseCriteoTimeout];
}

- (void)cr_waitShortlyForExpectations:(NSArray<XCTestExpectation *> *)expectations {
    [self waitForExpectations:expectations timeout:XCTestCaseCriteoShortTimeout];
}

@end
