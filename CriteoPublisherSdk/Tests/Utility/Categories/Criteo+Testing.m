//
//  Criteo+Testing.m
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

#import <objc/runtime.h>
#import <OCMock/OCMock.h>

#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_NetworkCaptor.h"
#import "CRInterstitialAdUnit.h"
#import "CRBannerAdUnit.h"
#import "CR_NetworkWaiter.h"
#import "CR_NetworkWaiterBuilder.h"
#import "CR_TestAdUnits.h"
#import "CR_Config.h"

// This publisherId B-056946 exists in production.
NSString *const CriteoTestingPublisherId = @"B-000001";

NSString *const DemoBannerAdUnitId = @"30s6zt3ayypfyemwjvmp";
NSString *const DemoInterstitialAdUnitId = @"6yws53jyfjgoq1ghnuqb";

NSString *const PreprodBannerAdUnitId = @"test-PubSdk-Base";
NSString *const PreprodInterstitialAdUnitId = @"test-PubSdk-Interstitial";
NSString *const PreprodNativeAdUnitId = @"test-PubSdk-Native";

NSString *const VideoInterstitialAdUnitId = @"test-PubSdk-Video";

@implementation Criteo (Testing)

- (CR_NetworkCaptor *)testing_networkCaptor {
  NSAssert([self.dependencyProvider.networkManager isKindOfClass:[CR_NetworkCaptor class]],
           @"Checking that the networkManager is the CR_NetworkCaptor");
  return (CR_NetworkCaptor *)self.dependencyProvider.networkManager;
}

- (id)testing_networkManagerMock {
  // Note that [captor.networkManager isKindOfClass:[OCMockObject class]] doesn't work.
  // Indeed, OCMockObject is a subclass of NSProxy, not of NSObject. So to know if we
  // use an OCMock, we verify that is it an NSProxy with object.isProxy.
  if ([self.dependencyProvider.networkManager isKindOfClass:[CR_NetworkCaptor class]]) {
    NSAssert(self.testing_networkCaptor.networkManager.isProxy,
             @"OCMockObject class not found on the networkCaptor");
    return self.testing_networkCaptor.networkManager;
  } else {
    NSAssert(self.dependencyProvider.networkManager.isProxy,
             @"OCMockObject class not found on the networkCaptor");
    return self.dependencyProvider.networkManager;
  }
}

- (CR_HttpContent *)testing_lastBidHttpContent {
  for (CR_HttpContent *content in
       [self.testing_networkCaptor.finishedRequests reverseObjectEnumerator]) {
    if ([content.url.absoluteString containsString:self.config.cdbUrl]) {
      return content;
    }
  }
  return nil;
}

- (CR_HttpContent *)testing_lastAppEventHttpContent {
  for (CR_HttpContent *content in
       [self.testing_networkCaptor.finishedRequests reverseObjectEnumerator]) {
    if ([content.url.absoluteString containsString:self.config.appEventsUrl]) {
      return content;
    }
  }
  return nil;
}

+ (Criteo *)testing_criteoWithNetworkCaptor {
  CR_DependencyProvider *dependencyProvider = [CR_DependencyProvider testing_dependencyProvider];
  Criteo *criteo = [[Criteo alloc] initWithDependencyProvider:dependencyProvider];
  return criteo;
}

#pragma mark - Register

- (void)testing_registerInterstitial {
  [self testing_registerWithAdUnits:@[ [CR_TestAdUnits randomInterstitial] ]];
}

- (void)testing_registerBanner {
  [self testing_registerWithAdUnits:@[ [CR_TestAdUnits randomBanner320x50] ]];
}

- (void)testing_registerWithAdUnits:(NSArray<CRAdUnit *> *)adUnits {
  [self registerCriteoPublisherId:CriteoTestingPublisherId withAdUnits:adUnits];
}

#pragma mark - Wait

- (BOOL)testing_waitForRegisterHTTPResponses {
  CR_NetworkWaiterBuilder *builder =
      [[CR_NetworkWaiterBuilder alloc] initWithConfig:self.config
                                        networkCaptor:self.testing_networkCaptor];
  CR_NetworkWaiter *waiter =
      builder.withBid.withConfig.withLaunchAppEvent.withFinishedRequestsIncluded.build;
  return [waiter wait];
}

#pragma mark - Register & Wait

- (void)testing_registerInterstitialAndWaitForHTTPResponses {
  [self testing_registerAndWaitForHTTPResponseWithAdUnits:@[ [CR_TestAdUnits randomInterstitial] ]];
}

- (void)testing_registerBannerAndWaitForHTTPResponses {
  [self testing_registerAndWaitForHTTPResponseWithAdUnits:@[ [CR_TestAdUnits randomBanner320x50] ]];
}

- (void)testing_registerAndWaitForHTTPResponseWithAdUnits:(NSArray<CRAdUnit *> *)adUnits {
  [self testing_registerWithAdUnits:adUnits];
  BOOL finished = [self testing_waitForRegisterHTTPResponses];
  NSAssert(finished, @"Failed to received all the requests for the register: %@",
           self.testing_networkCaptor);
}

@end
