//
//  NSString+UrlTests.m
//  pubsdkTests
//
//  Created by Paul Davis on 1/30/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSString+CR_Url.h"

@interface NSString_CR_UrlTests : XCTestCase

@end

@implementation NSString_CR_UrlTests

- (void) testEncodeUrlWithRestrictedChars
{
    NSString *charsToEncode = @"http://www.example.com/someurl?somedata=!*'();:@&=+$,/?%#[]\" ";

    NSString *encodedString = [charsToEncode urlEncode];
    XCTAssertEqualObjects(encodedString,
                          @"http%3A%2F%2Fwww.example.com%2Fsomeurl%3Fsomedata%3D%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%25%23%5B%5D%22%20");
}

- (void) testNoRestrictedCharsDoesNotEncode
{
    NSString *charsToEncode = @"www.example.com";

    NSString *encodedString = [charsToEncode urlEncode];
    XCTAssertEqualObjects(encodedString, charsToEncode);
}

- (void) testEncodeNilDoesNotExplode
{
    NSString *nilString = nil;

    XCTAssertNil([nilString urlEncode]); // Duh, it's a message to nil
}

- (void) testEncodePerformance
{
    NSString *charsToEncode = @"http://www.example.com/someurl?somedata=!*'();:@&=+$,/?%#[]\" ";
    __block NSString *tempStr = [charsToEncode urlEncode];

    [self measureMetrics:XCTestCase.defaultPerformanceMetrics automaticallyStartMeasuring:YES forBlock:^{
        tempStr = [charsToEncode urlEncode];
    }];
}

- (void)testUrlQueryParamsWithoutKey {
    NSString *actual = [NSString urlQueryParamsWithDictionary:@{}];

    XCTAssertEqualObjects(actual, @"");
}

- (void)testUrlQueryParamsWith1Key {
    NSString *expected = @"key1=value1";

    NSString *actual = [NSString urlQueryParamsWithDictionary:@{ @"key1" : @"value1" }];

    XCTAssertEqualObjects(actual, expected);
}

- (void)testUrlQueryParamsWith2Keys {
    NSString *expected = @"key1=value1&key2=value2";
    NSDictionary *dict = @{
        @"key1" : @"value1",
        @"key2" : @"value2",
    };

    NSString *actual = [NSString urlQueryParamsWithDictionary:dict];

    XCTAssertEqualObjects(actual, expected);
}

@end
