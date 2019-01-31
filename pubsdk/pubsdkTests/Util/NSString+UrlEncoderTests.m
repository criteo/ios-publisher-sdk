//
//  NSString+UrlEncoderTests.m
//  pubsdkTests
//
//  Created by Paul Davis on 1/30/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSString+UrlEncoder.h"

@interface NSString_UrlEncoderTests : XCTestCase

@end

@implementation NSString_UrlEncoderTests

- (void)setUp {
}

- (void)tearDown {
}

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

@end
