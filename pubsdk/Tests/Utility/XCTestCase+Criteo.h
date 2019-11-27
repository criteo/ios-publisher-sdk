//
//  XCTestCase+Criteo.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/2/19.
//  Copyright © 2019 Criteo. All rights reserved.
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
