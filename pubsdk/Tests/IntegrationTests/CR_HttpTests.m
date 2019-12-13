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
#import "AdSupport/ASIdentifierManager.h"
#import "CR_ApiQueryKeys.h"
#import "XCTestCase+Criteo.h"

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

    [criteo testing_registerInterstitial];
    NSArray *expectations = @[
        configApiCallExpectation,
        eventApiCallExpectation,
        cdbApiCallExpectation,
    ];
    [self criteo_waitForExpectations:expectations];
}

- (void)testCdbApiCallDuringInitialisation {
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];
    XCTestExpectation *expectation = [self expectationWithDescription:@"cdbApiCallExpectation"];
    CR_Config *config = criteo.bidManagerBuilder.config;
    CR_DeviceInfo *deviceInfo = criteo.bidManagerBuilder.deviceInfo;

    [criteo.testing_networkCaptor setRequestListener:^(NSURL *url, CR_HTTPVerb verb, NSDictionary *postBody) {
        NSDictionary *user = postBody[@"user"];
        if ([url.absoluteString containsString:config.cdbUrl] &&
            postBody[@"sdkVersion"] == config.sdkVersion &&
            user[@"deviceId"] == deviceInfo.deviceId &&
            user[@"deviceOs"] == config.deviceOs &&
            user[@"userAgent"] == deviceInfo.userAgent) {
            [expectation fulfill];
        }
    }];

    [criteo testing_registerInterstitial];

    [self criteo_waitForExpectations:@[expectation]];
}

- (void)testConfigApiCallDuringInitialisation {
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];
    XCTestExpectation *expectation = [self expectationWithDescription:@"configApiCallExpectation"];
    CR_Config *config = criteo.bidManagerBuilder.config;
    NSString *appIdValue = [NSBundle mainBundle].bundleIdentifier;

    [criteo.testing_networkCaptor setRequestListener:^(NSURL *url, CR_HTTPVerb verb, NSDictionary *body) {
        if ([url.absoluteString containsString:config.configUrl] &&
            [self query:url.query hasParamKey:CR_ApiQueryKeys.appId withValue:appIdValue] &&
            [self query:url.query hasParamKey:CR_ApiQueryKeys.sdkVersion withValue:config.sdkVersion]) {
            [expectation fulfill];
        }
    }];

    [criteo testing_registerInterstitial];

    [self criteo_waitForExpectations:@[expectation]];
}

- (void)testEventApiCallDuringInitialization {
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];
    XCTestExpectation *expectation = [self expectationWithDescription:@"eventApiCallExpectation"];

    ASIdentifierManager *idfaManager = [ASIdentifierManager sharedManager];
    NSString *limitedAdTrackingValue = idfaManager.advertisingTrackingEnabled ? @"0" : @"1";
    NSString *idfaValue = [idfaManager.advertisingIdentifier UUIDString];
    NSString *appIdValue = [NSBundle mainBundle].bundleIdentifier;

    [criteo.testing_networkCaptor setRequestListener:^(NSURL *url, CR_HTTPVerb verb, NSDictionary *body) {
        if ([url.absoluteString containsString:criteo.bidManagerBuilder.config.appEventsUrl] &&
            [self query:url.query hasParamKey:CR_ApiQueryKeys.idfa withValue:idfaValue] &&
            [self query:url.query hasParamKey:CR_ApiQueryKeys.limitedAdTracking withValue:limitedAdTrackingValue] &&
            [self query:url.query hasParamKey:CR_ApiQueryKeys.appId withValue:appIdValue] &&
            [self query:url.query hasParamKey:CR_ApiQueryKeys.eventType withValue:@"Launch"]) {
            [expectation fulfill];
        }
    }];

    [criteo testing_registerInterstitial];

    [self criteo_waitForExpectations:@[expectation]];
}

- (void)testInitDoNotMakeNetworkCalls
{
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];
    [NSThread sleepForTimeInterval:1.5f];

    XCTAssertEqualObjects(criteo.testing_networkCaptor.pendingRequests, @[]);
    XCTAssertEqualObjects(criteo.testing_networkCaptor.finishedRequests, @[]);
}


#pragma mark - Private methods

- (BOOL)query:(NSString *)query hasParamKey:(NSString *)key withValue:(NSString *)value {
    return [[query componentsSeparatedByString:@"&"] containsObject:[NSString stringWithFormat:@"%@=%@", key, value]];
}

@end
