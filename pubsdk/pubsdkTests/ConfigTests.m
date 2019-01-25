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
#import "../pubsdk/Config.h"
#import "../pubsdk/ApiHandler.h"

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

- (void) testRefreshConfig {
    NSDictionary *configData = [NSDictionary dictionaryWithObjectsAndKeys:@(YES), @"killSwitch", nil];
    ApiHandler *mockApiHandler = OCMStrictClassMock([ApiHandler class]);
    Config *config = [[Config alloc] initWithNetworkId:@(1234)];
    XCTAssertFalse([config killSwitch]);
    
    OCMStub([mockApiHandler getConfig:[OCMArg isKindOfClass:[Config class]]
             ahConfigHandler:([OCMArg invokeBlockWithArgs:configData, nil])]);
    
    [config refreshConfig:mockApiHandler];
    XCTAssertTrue([config killSwitch]);
}

- (void) testRefreshConfig_2 {
    NSDictionary *configData = [NSDictionary dictionaryWithObjectsAndKeys:@(NO), @"killSwitch", nil];
    ApiHandler *mockApiHandler = OCMStrictClassMock([ApiHandler class]);
    Config *config = [[Config alloc] initWithNetworkId:@(1234)];
    config.killSwitch = YES;
    XCTAssertTrue([config killSwitch]);

    OCMStub([mockApiHandler getConfig:[OCMArg isKindOfClass:[Config class]]
                      ahConfigHandler:([OCMArg invokeBlockWithArgs:configData, nil])]);

    [config refreshConfig:mockApiHandler];
    XCTAssertFalse([config killSwitch]);
}

@end
