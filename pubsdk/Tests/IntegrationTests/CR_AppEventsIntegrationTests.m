//
//  CR_AppEventsIntegrationTests.m
//  pubsdkTests
//
//  Created by Romain Lofaso on 1/6/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "XCTestCase+Criteo.h"
#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_NetworkCaptor.h"
#import "CR_Config.h"
#import "CR_AppEvents+Internal.h"
#import "CR_BidManagerBuilder.h"

@interface CR_AppEventsIntegrationTests : XCTestCase

@property (nonatomic, strong) NSNotificationCenter *notificationCenter;
@property (nonatomic, strong) Criteo *criteo;

@end

@implementation CR_AppEventsIntegrationTests

- (void)setUp {
    self.notificationCenter = [NSNotificationCenter defaultCenter];
    self.criteo = [Criteo testing_criteoWithNetworkCaptor];
    [self.criteo.bidManagerBuilder.appEvents disableThrottling];
}

- (void)testActiveEventNotSentIfCriteoNotRegister {
    XCTestExpectation *exp = [self _expectationForAppEventCall];
    exp.inverted = YES;

    [self _sendAppGoesForegroundNotification];

    [self criteo_waitForExpectations:@[exp]];
}

- (void)testInactiveEventNotSentIfCriteoNotRegister {
    XCTestExpectation *exp = [self _expectationForAppEventCall];
    exp.inverted = YES;

    [self _sendAppGoesBackgroundNotification];

    [self criteo_waitForExpectations:@[exp]];
}


- (void)testActiveEventSentIfCriteoRegister {
    [self.criteo testing_registerBannerAndWaitForHTTPResponses];
    XCTestExpectation *exp = [self _expectationForAppEventCall];

    [self _sendAppGoesForegroundNotification];

    [self criteo_waitForExpectations:@[exp]];
}

- (void)testInactiveEventSentIfCriteoRegister {
    [self.criteo testing_registerBannerAndWaitForHTTPResponses];
    XCTestExpectation *exp = [self _expectationForAppEventCall];

    [self _sendAppGoesBackgroundNotification];

    [self criteo_waitForExpectations:@[exp]];
}

#pragma mark - Private

- (void)_sendAppGoesForegroundNotification {
    [self.notificationCenter postNotificationName:UIApplicationDidBecomeActiveNotification
                                           object:nil];
}

- (void)_sendAppGoesBackgroundNotification {
    [self.notificationCenter postNotificationName:UIApplicationWillResignActiveNotification
                                           object:nil];
}

- (XCTestExpectation *)_expectationForAppEventCall {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Expecting that AppEvent was sent"];
    self.criteo.testing_networkCaptor.requestListener = ^(NSURL * _Nonnull url, CR_HTTPVerb verb, NSDictionary * _Nullable body) {
        if ([url.absoluteString containsString:self.criteo.config.appEventsUrl]) {
            [expectation fulfill];
        }
    };
    return expectation;
}

@end
