//
//  NSDictionary+CriteoTests.m
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
#import "NSDictionary+Criteo.h"

@interface NSDictionary_CriteoTests : XCTestCase

@end

@implementation NSDictionary_CriteoTests

- (void)testDictionaryWithNewValueForKey {
  NSDictionary *dict = @{@"a" : @(1), @"b" : @(2)};
  NSDictionary *modDict = [dict cr_dictionaryWithNewValue:@(3) forKey:@"a"];
  XCTAssertEqualObjects(modDict[@"a"], @(3));
  XCTAssertEqualObjects(modDict[@"b"], @(2));
}

- (void)testDictionaryWithNewValueForKeys {
  NSDictionary *dict = @{@"a" : @(1), @"b" : @{@"c" : @{@"x" : @(14)}, @"y" : @(42)}};
  NSDictionary *modDict = [dict cr_dictionaryWithNewValue:@(3) forKeys:@[ @"b", @"c", @"x" ]];
  XCTAssertEqualObjects(modDict[@"a"], @(1));
  XCTAssertEqualObjects(modDict[@"b"][@"c"], @{@"x" : @(3)});
  XCTAssertEqualObjects(modDict[@"b"][@"c"][@"x"], @(3));

  modDict = [dict cr_dictionaryWithNewValue:nil forKeys:@[ @"b", @"c", @"x" ]];
  XCTAssertNil(modDict[@"b"][@"c"][@"x"]);

  modDict = [dict cr_dictionaryWithNewValue:@(3) forKeys:@[ @"d", @"c" ]];
  XCTAssertNil(modDict);

  modDict = [dict cr_dictionaryWithNewValue:@(3) forKeys:@[ @"a", @"c", @"x", @"q" ]];
  XCTAssertNil(modDict);
}

@end
