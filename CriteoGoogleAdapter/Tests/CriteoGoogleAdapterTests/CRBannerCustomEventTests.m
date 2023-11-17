//
//  CRBannerCustomEventTests.m
//  CriteoGoogleAdapterTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
//  in compliance with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the License for the specific language governing permissions and
//  limitations under the License.

#import <XCTest/XCTest.h>
#import "CRBannerCustomEvent.h"
#import <OCMock.h>
#import "CRGoogleMediationParameters.h"

@interface CRBannerCustomEventTests : XCTestCase

@end

// Private property
@interface CRBannerCustomEvent ()

@property(nonatomic, strong) CRBannerView *bannerView;

@end

// Test-only
@interface CRBannerCustomEvent (Test)

- (instancetype)initWithBanner:(CRBannerView *)ad;
- (void)loadBannerForAdUnit:(CRBannerAdUnit *)adUnit
            mediationParams:(CRGoogleMediationParameters *)params
     childDirectedTreatment:(NSNumber *)childDirectedTreatment;

@end

@implementation CRBannerCustomEvent (Test)

- (instancetype)initWithBanner:(CRBannerView *)ad {
  if (self = [super init]) {
    self.bannerView = ad;
  }
  return self;
}

@end

#define SERVER_PARAMETER @"{\"cpId\":\"testCpId\",\"adUnitId\":\"testAdUnitId\"}"

@implementation CRBannerCustomEventTests

- (void)testRequestBannerAdSuccess {
  NSNumber *mockChildDirectedTreatment = @YES;
  CRBannerView *mockCRBannerView = OCMStrictClassMock([CRBannerView class]);
  CRBannerAdUnit *bannerAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"testAdUnitId"
                                                                     size:CGSizeMake(320, 50)];
  CRBannerCustomEvent *customEvent = [[CRBannerCustomEvent alloc] initWithBanner:mockCRBannerView];
  CRGoogleMediationParameters *params =
      [CRGoogleMediationParameters parametersFromJSONString:SERVER_PARAMETER error:NULL];

  OCMStub([mockCRBannerView loadAd]);
  OCMStub([mockCRBannerView setDelegate:customEvent]);

  id mockCriteo = OCMClassMock([Criteo class]);
  OCMStub([mockCriteo sharedCriteo]).andReturn(mockCriteo);
OCMStub([mockCriteo registerCriteoPublisherId:@"testCpId" withStoreId: @"testStoreId" withAdUnits:@[ bannerAdUnit ]]);
  OCMStub([mockCriteo setChildDirectedTreatment:mockChildDirectedTreatment]);

  [customEvent loadBannerForAdUnit:bannerAdUnit
                   mediationParams:params
            childDirectedTreatment:mockChildDirectedTreatment];

  OCMVerify([mockCRBannerView loadAd]);
  OCMVerify([mockCRBannerView setDelegate:customEvent]);
  OCMVerify([mockCriteo registerCriteoPublisherId:@"testCpId" withStoreId: @"testStoreId" withAdUnits:@[ bannerAdUnit ]]);
  OCMVerify([mockCriteo setChildDirectedTreatment:mockChildDirectedTreatment]);
}

@end
