//
//  ConfigTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/25/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import <OCMock.h>

#import "Config.h"
#import "ApiHandler.h"

@interface ConfigTests: XCTestCase

@end

@implementation ConfigTests

- (void) testGetConfigValuesFromData {
    // Json response from config endpoint
    NSString *rawJsonCdbResponse = @"{\"killSwitch\":true}";
    NSData *configResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *configData = [Config getConfigValuesFromData:configResponse];
    XCTAssertEqual(YES, ((NSNumber *)[configData objectForKey:@"killSwitch"]).boolValue);
}

@end
