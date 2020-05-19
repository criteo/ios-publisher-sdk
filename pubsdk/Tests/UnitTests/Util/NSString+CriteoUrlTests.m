//
//  NSString+CriteoUrlTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSString+CriteoUrl.h"

@interface NSString_CriteoUrlTests : XCTestCase

@end

@implementation NSString_CriteoUrlTests

- (void)testEncodeUrlWithRestrictedChars {
    NSString *charsToEncode = @"http://www.example.com/someurl?somedata=!*'();:@&=+$,/?%#[]\" ";

    NSString *encodedString = [charsToEncode cr_urlEncode];
    XCTAssertEqualObjects(encodedString,
        @"http%3A%2F%2Fwww.example.com%2Fsomeurl%3Fsomedata%3D%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%25%23%5B%5D%22%20");
}

- (void)testNoRestrictedCharsDoesNotEncode {
    NSString *charsToEncode = @"www.example.com";

    NSString *encodedString = [charsToEncode cr_urlEncode];
    XCTAssertEqualObjects(encodedString, charsToEncode);
}

- (void)testEncodeNilDoesNotExplode {
    NSString *nilString = nil;

    XCTAssertNil([nilString cr_urlEncode]); // Duh, it's a message to nil
}

- (void)testEncodePerformance {
    NSString *charsToEncode = @"http://www.example.com/someurl?somedata=!*'();:@&=+$,/?%#[]\" ";
    __block NSString *tempStr = [charsToEncode cr_urlEncode];

    [self measureMetrics:XCTestCase.defaultPerformanceMetrics automaticallyStartMeasuring:YES forBlock:^{
        tempStr = [charsToEncode cr_urlEncode];
    }];
}

- (void)testUrlQueryParamsWithoutKey {
    NSString *actual = [NSString cr_urlQueryParamsWithDictionary:@{}];

    XCTAssertEqualObjects(actual, @"");
}

- (void)testUrlQueryParamsWith1Key {
    NSString *expected = @"key1=value1";

    NSString *actual = [NSString cr_urlQueryParamsWithDictionary:@{@"key1": @"value1"}];

    XCTAssertEqualObjects(actual, expected);
}

- (void)testUrlQueryParamsWith2Keys {
    NSString *expected = @"key1=value1&key2=value2";
    NSDictionary *dict = @{
        @"key1": @"value1",
        @"key2": @"value2",
    };

    NSString *actual = [NSString cr_urlQueryParamsWithDictionary:dict];

    XCTAssertEqualObjects(actual, expected);
}

- (void)testUrlQueryParamsDictionaryMalformed {
    XCTAssertNil([@"" cr_urlQueryParamsDictionary]);
    XCTAssertNil([@"key" cr_urlQueryParamsDictionary]);
    XCTAssertNil([@"key=" cr_urlQueryParamsDictionary]);
    XCTAssertNil([@"=value" cr_urlQueryParamsDictionary]);
    XCTAssertNil([@"&&" cr_urlQueryParamsDictionary]);
    XCTAssertNil([@"&key" cr_urlQueryParamsDictionary]);
    XCTAssertNil([@"key&" cr_urlQueryParamsDictionary]);
    XCTAssertNil([@"key=value&" cr_urlQueryParamsDictionary]);
    XCTAssertNil([@"&key=value" cr_urlQueryParamsDictionary]);
}

- (void)testUrlQueryParamsDictionary {
    NSDictionary *params1 = @{@"key": @"value"};
    XCTAssertEqualObjects([@"key=value" cr_urlQueryParamsDictionary], params1);
    XCTAssertEqualObjects([@"http://hello.com?key=value" cr_urlQueryParamsDictionary], params1);

    NSDictionary *keyValue2 = @{@"key1": @"value1", @"key2": @"value2"};
    XCTAssertEqualObjects([@"key1=value1&key2=value2" cr_urlQueryParamsDictionary], keyValue2);
    XCTAssertEqualObjects([@"http://hello.com?key1=value1&key2=value2" cr_urlQueryParamsDictionary], keyValue2);
}

@end
