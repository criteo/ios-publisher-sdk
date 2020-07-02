//
//  CR_AppEventsIntegrationTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "XCTestCase+Criteo.h"
#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_AppEvents+Internal.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_NetworkCaptor.h"
#import "CR_ThreadManager+Waiter.h"

@interface CR_AppEventsIntegrationTests : XCTestCase

@property(strong, nonatomic) CR_NetworkCaptor *networkCaptor;
@property(strong, nonatomic) NSNotificationCenter *notificationCenter;
@property(strong, nonatomic) Criteo *criteo;

@end

@implementation CR_AppEventsIntegrationTests

- (void)setUp {
  self.criteo = [Criteo testing_criteoWithNetworkCaptor];
  self.networkCaptor = self.criteo.testing_networkCaptor;
  self.notificationCenter = self.criteo.dependencyProvider.notificationCenter;

  [self.criteo.dependencyProvider.appEvents disableThrottling];
}

- (void)tearDown {
  [self.criteo.dependencyProvider.threadManager waiter_waitIdle];
  [super tearDown];
}

- (void)testActiveEventNotSentIfCriteoNotRegister {
  XCTestExpectation *exp = [self expectationForAppEventCall];
  exp.inverted = YES;

  [self sendAppGoesForegroundNotification];
  [self cr_waitShortlyForExpectations:@[ exp ]];
}

- (void)testInactiveEventNotSentIfCriteoNotRegister {
  XCTestExpectation *exp = [self expectationForAppEventCall];
  exp.inverted = YES;

  [self sendAppGoesBackgroundNotification];
  [self cr_waitShortlyForExpectations:@[ exp ]];
}

- (void)testActiveEventSentIfCriteoRegister {
  [self.criteo testing_registerBannerAndWaitForHTTPResponses];
  XCTestExpectation *exp = [self expectationForAppEventCall];

  [self sendAppGoesForegroundNotification];
  [self cr_waitForExpectations:@[ exp ]];
}

- (void)testInactiveEventSentIfCriteoRegister {
  [self.criteo testing_registerBannerAndWaitForHTTPResponses];
  XCTestExpectation *exp = [self expectationForAppEventCall];

  [self sendAppGoesBackgroundNotification];

  [self cr_waitForExpectations:@[ exp ]];
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
  XCTestExpectation *expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Expecting that AppEvent was sent"];
  self.networkCaptor.requestListener =
      ^(NSURL *_Nonnull url, CR_HTTPVerb verb, NSDictionary *_Nullable body) {
        if ([url.absoluteString containsString:weakSelf.criteo.config.appEventsUrl]) {
          [expectation fulfill];
        }
      };
  return expectation;
}

@end
