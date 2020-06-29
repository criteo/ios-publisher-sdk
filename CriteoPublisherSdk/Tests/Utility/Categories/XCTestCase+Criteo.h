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
FOUNDATION_EXPORT NSTimeInterval XCTestCaseCriteoShortTimeout;

@interface XCTestCase (Criteo)

/**
 * Wait for expectation with  XCTestCaseCriteoTimeout.
 */
- (void)cr_waitForExpectations:(NSArray<XCTestExpectation *> *)expectations;

/**
 * Wait for expectation with  XCTestCaseCriteoShortTimeout.
 */
- (void)cr_waitShortlyForExpectations:(NSArray<XCTestExpectation *> *)expectations;

@end

NS_ASSUME_NONNULL_END
