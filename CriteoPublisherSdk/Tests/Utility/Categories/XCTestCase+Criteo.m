//
//  XCTestCase+Criteo.m
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

- (void)cr_waitShortlyForExpectationsWithOrder:(NSArray<XCTestExpectation *> *)expectations {
  [self waitForExpectations:expectations timeout:XCTestCaseCriteoShortTimeout enforceOrder:YES];
}

- (void)cr_recordFailureWithDescription:(NSString *)description
                                 inFile:(NSString *)filePath
                                 atLine:(NSUInteger)lineNumber
                               expected:(BOOL)expected {
  XCTSourceCodeLocation *location = [[XCTSourceCodeLocation alloc] initWithFilePath:filePath
                                                                         lineNumber:lineNumber];
  XCTSourceCodeContext *context = [[XCTSourceCodeContext alloc] initWithLocation:location];
  [self recordIssue:[[XCTIssue alloc] initWithType:XCTIssueTypeAssertionFailure
                                compactDescription:description
                               detailedDescription:nil
                                 sourceCodeContext:context
                                   associatedError:nil
                                       attachments:@[]]];
}

@end
