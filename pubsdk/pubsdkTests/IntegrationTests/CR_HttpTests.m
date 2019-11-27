//
//  CR_HttpTests.m
//  pubsdkTests
//
//  Created by Aleksandr Pakhmutov on 25/11/2019.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CR_Config.h"
#import "CR_BidManagerBuilder.h"
#import "CR_NetworkCaptor.h"
#import "Criteo+Testing.h"

@interface CR_HttpTests : XCTestCase

@end

@implementation CR_HttpTests

- (void)testThreeMainApiCallsWerePerformed {
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];

    XCTestExpectation *configApiCallExpectation = [self expectationWithDescription:@"configApiCallExpectation"];
    XCTestExpectation *eventApiCallExpectation = [self expectationWithDescription:@"eventApiCallExpectation"];
    XCTestExpectation *cdbApiCallExpectation = [self expectationWithDescription:@"cdbApiCallExpectation"];

    [criteo.testing_networkCaptor setRequestListener:^(NSURL *url, CR_HTTPVerb verb, NSDictionary *body) {

        CR_Config *config = criteo.bidManagerBuilder.config;
        NSString *urlString = url.absoluteString;

        if ([urlString containsString:config.configUrl]) {
            [configApiCallExpectation fulfill];
        }

        if ([urlString containsString:config.appEventsUrl] && [urlString containsString:@"eventType=Launch"]) {
            [eventApiCallExpectation fulfill];
        }

        if ([urlString containsString:config.cdbUrl]) {
            [cdbApiCallExpectation fulfill];
        }
    }];

    [criteo testing_register];
    NSArray *expectations = @[
        configApiCallExpectation,
        eventApiCallExpectation,
        cdbApiCallExpectation,
    ];
    [self waitForExpectations:expectations timeout:3];
}

@end
