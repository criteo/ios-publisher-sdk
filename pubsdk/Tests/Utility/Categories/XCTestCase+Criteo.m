//
//  XCTestCase+Criteo.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "XCTestCase+Criteo.h"

NSTimeInterval XCTestCaseCriteoTimeout = 10.f;

@implementation XCTestCase (Criteo)

- (void)cr_waitForExpectations:(NSArray<XCTestExpectation *> *)expectations {
    [self waitForExpectations:expectations timeout:XCTestCaseCriteoTimeout];
}

@end
