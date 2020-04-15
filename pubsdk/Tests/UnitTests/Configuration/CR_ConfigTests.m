//
//  CR_ConfigTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/25/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "CR_Config.h"

@interface CR_ConfigTests: XCTestCase

@end

@implementation CR_ConfigTests

- (void)testGetConfigValuesFromData {
    // Json response from config endpoint
    NSString *rawJsonCdbResponse = @"{\"killSwitch\":true}";
    NSData *configResponse = [rawJsonCdbResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *configData = [CR_Config getConfigValuesFromData:configResponse];
    XCTAssertEqual(YES, ((NSNumber *)[configData objectForKey:@"killSwitch"]).boolValue);
}

- (void)testInit_GivenAnyParameter_CsmFeatureIsEnabledByDefault {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    CR_Config *config = [[CR_Config alloc] initWithUserDefaults:userDefaults];

    XCTAssertTrue(config.isCsmEnabled);
}

@end
