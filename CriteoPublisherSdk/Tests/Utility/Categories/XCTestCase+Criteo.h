//
//  XCTestCase+Criteo.h
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
