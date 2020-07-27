//
//  CR_HttpTests.m
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

#import <XCTest/XCTest.h>
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CR_Config.h"
#import "CR_DependencyProvider.h"
#import "CR_NetworkCaptor.h"
#import "Criteo+Testing.h"
#import "AdSupport/ASIdentifierManager.h"
#import "CR_ApiQueryKeys.h"
#import "CR_ThreadManager+Waiter.h"
#import "XCTestCase+Criteo.h"

@interface CR_HttpTests : XCTestCase

@property(strong, nonatomic) Criteo *criteo;

@end

@implementation CR_HttpTests

- (void)setUp {
  [super setUp];
  self.criteo = [Criteo testing_criteoWithNetworkCaptor];
}

- (void)tearDown {
  [self.criteo.dependencyProvider.threadManager waiter_waitIdle];
  [super tearDown];
}

- (void)testThreeMainApiCallsWerePerformed {
  XCTestExpectation *configApiCallExpectation =
      [self expectationWithDescription:@"configApiCallExpectation"];
  XCTestExpectation *eventApiCallExpectation =
      [self expectationWithDescription:@"eventApiCallExpectation"];
  XCTestExpectation *cdbApiCallExpectation =
      [self expectationWithDescription:@"cdbApiCallExpectation"];

  __weak typeof(self) weakSelf = self;
  [self.criteo.testing_networkCaptor
      setRequestListener:^(NSURL *url, CR_HTTPVerb verb, NSDictionary *body) {
        CR_Config *config = weakSelf.criteo.dependencyProvider.config;
        NSString *urlString = url.absoluteString;

        if ([urlString containsString:config.configUrl]) {
          [configApiCallExpectation fulfill];
        }

        if ([urlString containsString:config.appEventsUrl] &&
            [urlString containsString:@"eventType=Launch"]) {
          [eventApiCallExpectation fulfill];
        }

        if ([urlString containsString:config.cdbUrl]) {
          [cdbApiCallExpectation fulfill];
        }
      }];

  [self.criteo testing_registerInterstitial];
  NSArray *expectations = @[
    configApiCallExpectation,
    eventApiCallExpectation,
    cdbApiCallExpectation,
  ];
  [self cr_waitForExpectations:expectations];
}

- (void)testCdbApiCallDuringInitialisation {
  XCTestExpectation *expectation = [self expectationWithDescription:@"cdbApiCallExpectation"];
  CR_Config *config = self.criteo.dependencyProvider.config;
  CR_DeviceInfo *deviceInfo = self.criteo.dependencyProvider.deviceInfo;

  [self.criteo.testing_networkCaptor setRequestListener:^(NSURL *url, CR_HTTPVerb verb,
                                                          NSDictionary *postBody) {
    NSDictionary *user = postBody[@"user"];
    if ([url.absoluteString containsString:config.cdbUrl] &&
        postBody[@"sdkVersion"] == config.sdkVersion && user[@"deviceId"] == deviceInfo.deviceId &&
        user[@"deviceOs"] == config.deviceOs && user[@"userAgent"] == deviceInfo.userAgent) {
      [expectation fulfill];
    }
  }];

  [self.criteo testing_registerInterstitial];

  [self cr_waitForExpectations:@[ expectation ]];
}

- (void)testConfigApiCallDuringInitialisation {
  XCTestExpectation *expectation = [self expectationWithDescription:@"configApiCallExpectation"];
  CR_Config *config = self.criteo.dependencyProvider.config;
  NSString *appIdValue = [NSBundle mainBundle].bundleIdentifier;

  [self.criteo.testing_networkCaptor setRequestListener:^(NSURL *url, CR_HTTPVerb verb,
                                                          NSDictionary *body) {
    if ([url.absoluteString containsString:config.configUrl] &&
        [body[@"bundleId"] isEqual:appIdValue] && [body[@"sdkVersion"] isEqual:config.sdkVersion]) {
      [expectation fulfill];
    }
  }];

  [self.criteo testing_registerInterstitial];

  [self cr_waitForExpectations:@[ expectation ]];
}

- (void)testEventApiCallDuringInitialization {
  XCTestExpectation *expectation = [self expectationWithDescription:@"eventApiCallExpectation"];

  ASIdentifierManager *idfaManager = [ASIdentifierManager sharedManager];
  NSString *limitedAdTrackingValue = idfaManager.advertisingTrackingEnabled ? @"0" : @"1";
#if TARGET_OS_SIMULATOR
  NSString *idfaValue = CR_SIMULATOR_IDFA;
#else
  NSString *idfaValue = [idfaManager.advertisingIdentifier UUIDString];
#endif
  NSString *appIdValue = [NSBundle mainBundle].bundleIdentifier;

  __weak typeof(self) weakSelf = self;
  [self.criteo.testing_networkCaptor
      setRequestListener:^(NSURL *url, CR_HTTPVerb verb, NSDictionary *body) {
        if ([url.absoluteString
                containsString:weakSelf.criteo.dependencyProvider.config.appEventsUrl] &&
            [self query:url.query hasParamKey:CR_ApiQueryKeys.idfa withValue:idfaValue] &&
            [self query:url.query
                hasParamKey:CR_ApiQueryKeys.limitedAdTracking
                  withValue:limitedAdTrackingValue] &&
            [self query:url.query hasParamKey:CR_ApiQueryKeys.appId withValue:appIdValue] &&
            [self query:url.query hasParamKey:CR_ApiQueryKeys.eventType withValue:@"Launch"]) {
          [expectation fulfill];
        }
      }];

  [self.criteo testing_registerInterstitial];

  [self cr_waitForExpectations:@[ expectation ]];
}

- (void)testInitDoNotMakeNetworkCalls {
  [self.criteo.dependencyProvider.threadManager waiter_waitIdle];

  XCTAssertEqualObjects(self.criteo.testing_networkCaptor.pendingRequests, @[]);
  XCTAssertEqualObjects(self.criteo.testing_networkCaptor.finishedRequests, @[]);
}

#pragma mark - Private methods

- (BOOL)query:(NSString *)query hasParamKey:(NSString *)key withValue:(NSString *)value {
  return [[query componentsSeparatedByString:@"&"]
      containsObject:[NSString stringWithFormat:@"%@=%@", key, value]];
}

@end
