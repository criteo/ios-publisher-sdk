//
//  CR_ContextualFunctionalTests.m
//  CriteoPublisherSdk
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
#import "Criteo+Testing.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_HttpContent.h"
#import "CR_TestAdUnits.h"
#import "CRBannerView+Internal.h"
#import "CRInterstitial+Internal.h"
#import "CRNativeLoader+Internal.h"
#import "CR_NetworkCaptor.h"
#import "Criteo+Internal.h"

typedef void (^CR_ContextualTestedIntegration)(CRContextData *contextData);

@interface CR_ContextualFunctionalTests : CR_IntegrationsTestBase <CRNativeLoaderDelegate>
@end

@implementation CR_ContextualFunctionalTests

- (void)testPublisherExt_GivenContext_PutItInRequest {
  for (CR_ContextualTestedIntegration testedIntegration in self.testedIntegrations) {
    [self.criteo.testing_networkCaptor clear];
    [self testPublisherExt_GivenContext_PutItInRequest:testedIntegration];
  }
}

- (void)testPublisherExt_GivenContext_PutItInRequest:
    (CR_ContextualTestedIntegration)testedIntegration {
  CRContextData *contextData = [CRContextData contextDataWithDictionary:@{
    CRContextDataContentUrl : @"https://www.criteo.com",
    @"data.foo" : @"bar",
    @"data.baz" : @42
  }];

  NSDictionary *expected = @{
    @"content" : @{@"url" : @"https://www.criteo.com"},
    @"data" : @{@"foo" : @"bar", @"baz" : @42}
  };

  [self initCriteoWithAdUnits:@[ CR_TestAdUnits.randomBanner320x50 ]];

  // bid with context
  testedIntegration(contextData);
  [self waitForIdleState];

  NSDictionary *requestBody = self.criteo.testing_lastBidHttpContent.requestBody;
  XCTAssertEqualObjects(requestBody[@"publisher"][@"ext"], expected);
}

- (NSArray<CR_ContextualTestedIntegration> *)testedIntegrations {
  return @[
    // Load bid: InHouse & AppBidding
    ^(CRContextData *contextData) {
      [self.criteo loadBidForAdUnit:CR_TestAdUnits.preprodBanner320x50
                        withContext:contextData
                    responseHandler:^(CRBid *bid){/* no op */}];
    },
    // Standalone banner
    ^(CRContextData *contextData) {
      CRBannerView *bannerView =
          [[CRBannerView alloc] initWithAdUnit:CR_TestAdUnits.preprodBanner320x50
                                        criteo:self.criteo];
      [bannerView loadAdWithContext:contextData];
    },
    // Standalone interstitial
    ^(CRContextData *contextData) {
      CRInterstitial *interstitial =
          [[CRInterstitial alloc] initWithAdUnit:CR_TestAdUnits.preprodInterstitial
                                          criteo:self.criteo];
      [interstitial loadAdWithContext:contextData];
    },
    // Standalone native
    ^(CRContextData *contextData) {
      CRNativeLoader *nativeLoader =
          [[CRNativeLoader alloc] initWithAdUnit:CR_TestAdUnits.preprodNative criteo:self.criteo];
      nativeLoader.delegate = self;
      [nativeLoader loadAdWithContext:contextData];
    }
  ];
}

- (void)nativeLoader:(CRNativeLoader *)loader didReceiveAd:(CRNativeAd *)ad {
  // no op
}

@end
