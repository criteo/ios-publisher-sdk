//
//  CRInterstitialCustomEventTests.m
//  CriteoGoogleAdapterTests
//
// Copyright © 2018-2020 Criteo. All rights reserved.
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

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CRInterstitialCustomEvent.h"
#import "CRGoogleMediationParameters.h"
@import CriteoPublisherSdk;

@interface CRInterstitialCustomEventTests : XCTestCase

@end

// Private property (duplicates code in CRInterstitialCustomEvent.m so that we can use it in
// testing)
@interface CRInterstitialCustomEvent ()

@property(nonatomic, strong) CRInterstitial *interstitial;

@end

// Test-only initializer
@interface CRInterstitialCustomEvent (Test)

- (instancetype)initWithInterstitial:(CRInterstitial *)interstitial;
- (void)presentFromViewController:(nonnull UIViewController *)viewController;
- (void)loadInterstitialForAdUnit:(CRInterstitialAdUnit *)adUnit
                  adConfiguration:(CRGoogleMediationParameters *)params
           childDirectedTreatment:(NSNumber *)childDirectedTreatment;

@end

@implementation CRInterstitialCustomEvent (Test)

- (instancetype)initWithInterstitial:(CRInterstitial *)interstitial {
  if (self = [super init]) {
    self.interstitial = interstitial;
  }
  return self;
}

@end

#define SERVER_PARAMETER @"{\"cpId\":\"testCpId\",\"adUnitId\":\"testAdUnitId\"}"

@implementation CRInterstitialCustomEventTests

- (void)testLoadAndPresentFromRootViewController {
  NSNumber *mockChildDirectedTreatment = @YES;
  CRInterstitial *mockCRInterstitial = OCMStrictClassMock([CRInterstitial class]);
  CRInterstitialAdUnit *interstitialAdUnit =
      [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"testAdUnitId"];
  CRInterstitialCustomEvent *customEvent =
      [[CRInterstitialCustomEvent alloc] initWithInterstitial:mockCRInterstitial];
  CRGoogleMediationParameters *params = [CRGoogleMediationParameters parametersFromJSONString:SERVER_PARAMETER
                                                                                        error:NULL];
  OCMStub([mockCRInterstitial loadAd]);
  OCMStub([mockCRInterstitial setDelegate:customEvent]);
  UIViewController *realVC = [UIViewController new];
  OCMStub([mockCRInterstitial presentFromRootViewController:realVC]);
  OCMStub([mockCRInterstitial isAdLoaded]).andReturn(YES);

  id mockCriteo = OCMStrictClassMock([Criteo class]);
  OCMStub([mockCriteo sharedCriteo]).andReturn(mockCriteo);
  OCMStub([mockCriteo registerCriteoPublisherId:@"testCpId" withAdUnits:@[ interstitialAdUnit ]]);
  OCMStub([mockCriteo setChildDirectedTreatment:mockChildDirectedTreatment]);

  [customEvent loadInterstitialForAdUnit:interstitialAdUnit
                         adConfiguration:params
                  childDirectedTreatment:mockChildDirectedTreatment];
  [customEvent presentFromViewController:realVC];

  OCMVerify([mockCRInterstitial loadAd]);
  OCMVerify([mockCRInterstitial setDelegate:customEvent]);
  OCMVerify([mockCRInterstitial presentFromRootViewController:realVC]);
  OCMVerify([mockCriteo registerCriteoPublisherId:@"testCpId" withAdUnits:@[ interstitialAdUnit ]]);
  OCMVerify([mockCriteo setChildDirectedTreatment:mockChildDirectedTreatment]);
}

@end
