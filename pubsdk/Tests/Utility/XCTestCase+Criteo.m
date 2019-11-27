//
//  XCTestCase+Criteo.m
//  pubsdk
//
//  Created by Romain Lofaso on 12/2/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "XCTestCase+Criteo.h"

NSTimeInterval XCTestCaseCriteoTimeout = 10.f;

@implementation XCTestCase (Criteo)

- (void)criteo_waitForExpectations:(NSArray<XCTestExpectation *> *)expectations
{
    [self waitForExpectations:expectations timeout:XCTestCaseCriteoTimeout];
}

@end
