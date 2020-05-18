//
//  CR_AppEventsIntegrationTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "XCTestCase+Criteo.h"
#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_AppEvents+Internal.h"
#import "CR_BidManagerBuilder+Testing.h"
#import "CR_NetworkCaptor.h"
#import "CR_ThreadManager+Waiter.h"

@interface CR_AppEventsIntegrationTests : XCTestCase

@property (strong, nonatomic) CR_NetworkCaptor *networkCaptor;
@property (strong, nonatomic) NSNotificationCenter *notificationCenter;
@property (strong, nonatomic) Criteo *criteo;

@end

@implementation CR_AppEventsIntegrationTests

- (void)setUp {
    self.criteo = [Criteo testing_criteoWithNetworkCaptor];
    self.networkCaptor = self.criteo.testing_networkCaptor;
    self.notificationCenter = self.criteo.bidManagerBuilder.notificationCenter;

    [self.criteo.bidManagerBuilder.appEvents disableThrottling];
}

- (void)tearDown {
    [self.criteo.bidManagerBuilder.threadManager waiter_waitIdle];
    [super tearDown];
}

- (void)testActiveEventNotSentIfCriteoNotRegister {
    XCTestExpectation *exp = [self expectationForAppEventCall];
    exp.inverted = YES;

    [self sendAppGoesForegroundNotification];

    [self waitForExpectations:@[exp] timeout:1.];
}

- (void)testInactiveEventNotSentIfCriteoNotRegister {
    XCTestExpectation *exp = [self expectationForAppEventCall];
    exp.inverted = YES;

    [self sendAppGoesBackgroundNotification];

    [self waitForExpectations:@[exp] timeout:1.];
}


- (void)testActiveEventSentIfCriteoRegister {
    [self.criteo testing_registerBannerAndWaitForHTTPResponses];
    XCTestExpectation *exp = [self expectationForAppEventCall];

    [self sendAppGoesForegroundNotification];

    [self criteo_waitForExpectations:@[exp]];
}

- (void)testInactiveEventSentIfCriteoRegister {
    [self.criteo testing_registerBannerAndWaitForHTTPResponses];
    XCTestExpectation *exp = [self expectationForAppEventCall];

    [self sendAppGoesBackgroundNotification];

    [self criteo_waitForExpectations:@[exp]];
}

#pragma mark - Private

- (void)sendAppGoesForegroundNotification {
    [self.notificationCenter postNotificationName:UIApplicationDidBecomeActiveNotification
                                           object:nil];
}

- (void)sendAppGoesBackgroundNotification {
    [self.notificationCenter postNotificationName:UIApplicationWillResignActiveNotification
                                           object:nil];
}

- (XCTestExpectation *)expectationForAppEventCall {
    __weak typeof(self) weakSelf = self;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Expecting that AppEvent was sent"];
    self.networkCaptor.requestListener = ^(NSURL * _Nonnull url, CR_HTTPVerb verb, NSDictionary * _Nullable body) {
        if ([url.absoluteString containsString:weakSelf.criteo.config.appEventsUrl]) {
            [expectation fulfill];
        }
    };
    return expectation;
}

@end
