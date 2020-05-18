//
//  XCTestCase+Criteo.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

/**
 By experience, the initialization of the Criteo SDK takes up to 7 seconds
 with all the network calls.
 */
FOUNDATION_EXPORT NSTimeInterval XCTestCaseCriteoTimeout;

@interface XCTestCase (Criteo)

/**
 Wait for expectation with  XCTestCaseCriteoTimeout.
 */
- (void)criteo_waitForExpectations:(NSArray<XCTestExpectation *> *)expectations;

@end

NS_ASSUME_NONNULL_END
