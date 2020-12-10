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
#import <OCMock/OCMock.h>
#import "Criteo+Testing.h"
#import "CR_IntegrationsTestBase.h"
#import "CR_HttpContent.h"
#import "CR_TestAdUnits.h"
#import "CRBannerView+Internal.h"
#import "CRInterstitial+Internal.h"
#import "CRNativeLoader+Internal.h"
#import "CR_NetworkCaptor.h"
#import "Criteo+Internal.h"
#import "Criteo+Testing.h"
#import "CR_DependencyProvider.h"
#import "CR_InternalContextProvider.h"

typedef void (^CR_ContextualTestedIntegration)(CRContextData *contextData);

@interface CR_ContextualFunctionalTests : CR_IntegrationsTestBase <CRNativeLoaderDelegate>

@property(nonatomic, strong) CR_InternalContextProvider *internalContextProvider;

@end

@implementation CR_ContextualFunctionalTests

- (void)setUp {
  [self initCriteoWithAdUnits:@[ CR_TestAdUnits.randomBanner320x50 ]];
  self.internalContextProvider =
      OCMPartialMock(self.criteo.dependencyProvider.internalContextProvider);
  self.criteo.dependencyProvider.internalContextProvider = self.internalContextProvider;
}

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

  // bid with context
  testedIntegration(contextData);
  [self waitForIdleState];

  NSDictionary *requestBody = self.criteo.testing_lastBidHttpContent.requestBody;
  XCTAssertEqualObjects(requestBody[@"publisher"][@"ext"], expected);
}

- (void)testUserExt_GivenContextAndInternalContext_PutItInRequest {
  for (CR_ContextualTestedIntegration testedIntegration in self.testedIntegrations) {
    [self.criteo.testing_networkCaptor clear];
    [self testUserExt_GivenContextAndInternalContext_PutItInRequest:testedIntegration];
  }
}

- (void)testUserExt_GivenContextAndInternalContext_PutItInRequest:
    (CR_ContextualTestedIntegration)testedIntegration {
  CRUserData *userData = [CRUserData userDataWithDictionary:@{
    CRUserDataHashedEmail : [CREmailHasher hash:@"john.doe@gmail.com"],
    CRUserDataDevUserId : @"abc123",
    @"data.foo" : @[ @"bar", @"baz" ],
    @"device.make" : @"ignored"
  }];

  OCMStub([self.internalContextProvider fetchDeviceMake]).andReturn(@"Apple");
  OCMStub([self.internalContextProvider fetchDeviceModel]).andReturn(@"iPhone X");
  OCMStub([self.internalContextProvider fetchDeviceOrientation]).andReturn(@"Portrait");
  OCMStub([self.internalContextProvider fetchDeviceWidth]).andReturn(@2048);
  OCMStub([self.internalContextProvider fetchDeviceHeight]).andReturn(@2732);
  OCMStub([self.internalContextProvider fetchDevicePixelRatio]).andReturn(@42.42);
  OCMStub([self.internalContextProvider fetchDeviceConnectionType])
      .andReturn(CR_DeviceConnectionTypeCellular3G);
  OCMStub([self.internalContextProvider fetchUserCountry]).andReturn(@"FR");
  OCMStub([self.internalContextProvider fetchUserLanguages]).andReturn((@[ @"en", @"he" ]));
  OCMStub([self.internalContextProvider fetchSessionDuration]).andReturn(@45);

  NSDictionary *expected = @{
    @"device" : @{
      @"make" : @"Apple",
      @"model" : @"iPhone X",
      @"contype" : @5,
      @"w" : @2048,
      @"h" : @2732,
      @"pxratio" : @42.42
    },
    @"data" : @{
      @"orientation" : @"Portrait",
      @"inputLanguage" : @[ @"en", @"he" ],
      @"sessionDuration" : @45L,
      @"hashedEmail" : @"000e3171a5110c35c69d060112bd0ba55d9631c7c2ec93f1840e4570095b263a",
      @"devUserId" : @"abc123",
      @"foo" : @[ @"bar", @"baz" ]
    },
    @"user" : @{@"geo" : @{@"country" : @"FR"}}
  };

  [self.criteo setUserData:userData];

  // bid with context
  testedIntegration(CRContextData.new);
  [self waitForIdleState];

  NSDictionary *requestBody = self.criteo.testing_lastBidHttpContent.requestBody;
  XCTAssertEqualObjects(requestBody[@"user"][@"ext"], expected);
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
