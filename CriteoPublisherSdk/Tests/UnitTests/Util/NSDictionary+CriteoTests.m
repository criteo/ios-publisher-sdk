//
//  NSDictionary+CriteoTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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
