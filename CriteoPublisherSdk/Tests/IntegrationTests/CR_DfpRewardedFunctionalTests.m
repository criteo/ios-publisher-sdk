//
//  CR_DfpRewardedFunctionalTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2021 Criteo. All rights reserved.
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
#import "Criteo+Testing.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_DependencyProvider.h"
#import "CR_TestAdUnits.h"
#import "CR_AdUnitHelper.h"
#import "CR_TargetingKeys.h"
#import "NSString+CriteoUrl.h"
#import "CR_DfpCreativeViewChecker.h"
#import "CR_NativeAssets+Testing.h"
#import "CR_IntegrationRegistry.h"
#import "CR_CacheManager.h"
@import GoogleMobileAds;

@interface CR_DfpRewardedFunctionalTests : CR_IntegrationsTestBase

// to be able to restore
@property(strong, nonatomic) CR_IntegrationRegistry *oldIntegrationRegistry;

@end

@implementation CR_DfpRewardedFunctionalTests

#pragma mark - rewarded

- (void)setUp {
  // WARNING AdUnitHelper does use singleton object (no DI in here) should be changed with DPP-3734
  self.oldIntegrationRegistry = Criteo.sharedCriteo.dependencyProvider.integrationRegistry;
}

- (void)tearDown {
  Criteo.sharedCriteo.dependencyProvider.integrationRegistry = self.oldIntegrationRegistry;
}

- (void)test_givenRewarded_noIntegrationDeclared_whenLoadThreeTimes_adLoaded {
  CRRewardedAdUnit *adUnit = [CR_TestAdUnits rewarded];

  [self setupCriteo_andReplaceIntegrationRegistry];

  // register here fails as integration is not yet detected
  [self.criteo testing_registerWithAdUnits:@[ adUnit ]];

  GAMRequest *request = [[GAMRequest alloc] init];

  // this one make the detection logic discover GAM integration
  [self enrichAdObject:request forAdUnit:adUnit];

  [self warmCacheThenEnrich:adUnit request:request];

  CR_DependencyProvider *dependencyProvider = self.criteo.dependencyProvider;
  CR_CdbBid *bid = [dependencyProvider.cacheManager
      getBidForAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit]];
  NSDictionary *targeting = request.customTargeting;

  XCTAssertEqualObjects(targeting[CR_TargetingKey_crtCpm], @"1.12");
  XCTAssertEqual(targeting[CR_TargetingKey_crtFormat], @"video");
  XCTAssertEqualObjects(targeting[CR_TargetingKey_crtSize], @"320x480");

  // as this is a "video" url is not base64ed
  NSString *encodedUrl = targeting[CR_TargetingKey_crtDfpDisplayUrl];
  NSString *decodedUrl =
      [[encodedUrl stringByRemovingPercentEncoding] stringByRemovingPercentEncoding];

  XCTAssertEqualObjects(bid.displayUrl, decodedUrl);
  BOOL finished = [self.criteo testing_waitForRegisterHTTPResponses];
  XCTAssert(finished, "Failed to receive all prefetch requests");
}

- (void)test_givenRewarded_GAMIntegrationDeclared_whenLoadTwoTimes_adLoaded {
  CRRewardedAdUnit *adUnit = [CR_TestAdUnits rewarded];

  CR_IntegrationRegistry *integrationRegistry = [self setupCriteo_andReplaceIntegrationRegistry];
  [integrationRegistry declare:CR_IntegrationGamAppBidding];

  // GAM is declared so adUnit can be properly built
  [self.criteo testing_registerWithAdUnits:@[ adUnit ]];

  GAMRequest *request = [[GAMRequest alloc] init];

  [self warmCacheThenEnrich:adUnit request:request];
  CR_DependencyProvider *dependencyProvider = self.criteo.dependencyProvider;
  CR_CdbBid *bid = [dependencyProvider.cacheManager
      getBidForAdUnit:[CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit]];
  NSDictionary *targeting = request.customTargeting;

  XCTAssertEqualObjects(targeting[CR_TargetingKey_crtCpm], @"1.12");
  XCTAssertEqual(targeting[CR_TargetingKey_crtFormat], @"video");
  XCTAssertEqualObjects(targeting[CR_TargetingKey_crtSize], @"320x480");

  // as this is a "video" url is not base64ed
  NSString *encodedUrl = targeting[CR_TargetingKey_crtDfpDisplayUrl];
  NSString *decodedUrl =
      [[encodedUrl stringByRemovingPercentEncoding] stringByRemovingPercentEncoding];

  XCTAssertEqualObjects(bid.displayUrl, decodedUrl);
  BOOL finished = [self.criteo testing_waitForRegisterHTTPResponses];
  XCTAssert(finished, "Failed to receive all prefetch requests");
}

- (CR_IntegrationRegistry *)setupCriteo_andReplaceIntegrationRegistry {
  self.criteo = [Criteo testing_criteoWithNetworkCaptor];
  // use same integrationRegistry in test criteo object and global instance (see DPP-3734)
  CR_IntegrationRegistry *integrationRegistry = [[CR_IntegrationRegistry alloc] init];
  self.criteo.dependencyProvider.integrationRegistry = integrationRegistry;
  Criteo.sharedCriteo.dependencyProvider.integrationRegistry = integrationRegistry;
  return integrationRegistry;
}

- (void)warmCacheThenEnrich:(CRRewardedAdUnit *)adUnit request:(GAMRequest *)request {
  // this one warms up the cache
  [self enrichAdObject:request forAdUnit:adUnit];

  // this one passes properly
  [self enrichAdObject:request forAdUnit:adUnit];
}

@end
