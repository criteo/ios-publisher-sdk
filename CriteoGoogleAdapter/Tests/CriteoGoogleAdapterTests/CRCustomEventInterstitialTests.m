//
//  CRCustomEventInterstitialTests.m
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
#import "CRCustomEventInterstitial.h"

@interface CRCustomEventInterstitialTests : XCTestCase

@end

// Private property (duplicates code in CRCustomEventInterstitial.m so that we can use it in
// testing)
@interface CRCustomEventInterstitial ()

@property(nonatomic, strong) CRInterstitial *interstitial;

@end

// Test-only initializer
@interface CRCustomEventInterstitial (Test)

- (instancetype)initWithInterstitial:(CRInterstitial *)interstitial;

@end

@implementation CRCustomEventInterstitial (Test)

- (instancetype)initWithInterstitial:(CRInterstitial *)interstitial {
  if (self = [super init]) {
    self.interstitial = interstitial;
  }
  return self;
}

@end

#define SERVER_PARAMETER @"{\"cpId\":\"testCpId\",\"adUnitId\":\"testAdUnitId\"}"

@implementation CRCustomEventInterstitialTests

- (void)testCustomEventDelegateFailWhenParametersIsNil {
  CRCustomEventInterstitial *customEvent = [CRCustomEventInterstitial new];
  id mockGADInterstitialDelegate =
      OCMStrictProtocolMock(@protocol(GADCustomEventInterstitialDelegate));
  OCMExpect([mockGADInterstitialDelegate
      customEventInterstitial:customEvent
                    didFailAd:[NSError errorWithDomain:GADErrorDomain
                                                  code:GADErrorInvalidArgument
                                              userInfo:nil]]);
  NSString *invalidServerParameter = @"{\"cpIDD\":\"testCpId\"}";
  customEvent.delegate = mockGADInterstitialDelegate;
  [customEvent requestInterstitialAdWithParameter:invalidServerParameter
                                            label:nil
                                          request:[GADCustomEventRequest new]];
  OCMVerifyAllWithDelay(mockGADInterstitialDelegate, 1);
}

- (void)testLoadAndPresentFromRootViewController {
  CRInterstitial *mockCRInterstitial = OCMStrictClassMock([CRInterstitial class]);
  CRInterstitialAdUnit *interstitialAdUnit =
      [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"testAdUnitId"];
  CRCustomEventInterstitial *customEvent =
      [[CRCustomEventInterstitial alloc] initWithInterstitial:mockCRInterstitial];

  OCMStub([mockCRInterstitial loadAd]);
  OCMStub([mockCRInterstitial setDelegate:customEvent]);
  UIViewController *realVC = [UIViewController new];
  OCMStub([mockCRInterstitial presentFromRootViewController:realVC]);

  id mockCriteo = OCMStrictClassMock([Criteo class]);
  OCMStub([mockCriteo sharedCriteo]).andReturn(mockCriteo);
  OCMStub([mockCriteo registerCriteoPublisherId:@"testCpId" withAdUnits:@[ interstitialAdUnit ]]);

  [customEvent requestInterstitialAdWithParameter:SERVER_PARAMETER
                                            label:nil
                                          request:[GADCustomEventRequest new]];
  [customEvent presentFromRootViewController:realVC];

  OCMVerify([mockCRInterstitial loadAd]);
  OCMVerify([mockCRInterstitial setDelegate:customEvent]);
  OCMVerify([mockCRInterstitial presentFromRootViewController:realVC]);
  OCMVerify([mockCriteo registerCriteoPublisherId:@"testCpId" withAdUnits:@[ interstitialAdUnit ]]);
}

#pragma mark CRInterstitial Delegate tests

- (void)testDidFailToReceiveAdDelegate {
  CRCustomEventInterstitial *customEvent = [CRCustomEventInterstitial new];
  id mockGADInterstitialDelegate =
      OCMStrictProtocolMock(@protocol(GADCustomEventInterstitialDelegate));
  NSError *CriteoError =
      [NSError errorWithDomain:@"test domain"
                          code:0
                      userInfo:@{NSLocalizedDescriptionKey : @"test description"}];
  NSError *expectedError =
      [NSError errorWithDomain:GADErrorDomain
                          code:GADErrorNoFill
                      userInfo:@{NSLocalizedDescriptionKey : CriteoError.description}];
  OCMExpect([mockGADInterstitialDelegate customEventInterstitial:customEvent
                                                       didFailAd:expectedError]);

  customEvent.delegate = mockGADInterstitialDelegate;
  [customEvent interstitial:[CRInterstitial new] didFailToReceiveAdWithError:CriteoError];
  OCMVerifyAll(mockGADInterstitialDelegate);
}

- (void)testWillAppearDelegate {
  CRCustomEventInterstitial *customEvent = [CRCustomEventInterstitial new];
  id mockGADInterstitialDelegate =
      OCMStrictProtocolMock(@protocol(GADCustomEventInterstitialDelegate));
  OCMExpect([mockGADInterstitialDelegate customEventInterstitialWillPresent:customEvent]);

  customEvent.delegate = mockGADInterstitialDelegate;
  [customEvent interstitialWillAppear:[CRInterstitial new]];
  OCMVerifyAll(mockGADInterstitialDelegate);
}

- (void)testWillDisappearDelegate {
  CRCustomEventInterstitial *customEvent = [CRCustomEventInterstitial new];
  id mockGADInterstitialDelegate =
      OCMStrictProtocolMock(@protocol(GADCustomEventInterstitialDelegate));
  OCMExpect([mockGADInterstitialDelegate customEventInterstitialWillDismiss:customEvent]);

  customEvent.delegate = mockGADInterstitialDelegate;
  [customEvent interstitialWillDisappear:[CRInterstitial new]];
  OCMVerifyAll(mockGADInterstitialDelegate);
}

- (void)testDidDisappearDelegate {
  CRCustomEventInterstitial *customEvent = [CRCustomEventInterstitial new];
  id mockGADInterstitialDelegate =
      OCMStrictProtocolMock(@protocol(GADCustomEventInterstitialDelegate));
  OCMExpect([mockGADInterstitialDelegate customEventInterstitialDidDismiss:customEvent]);

  customEvent.delegate = mockGADInterstitialDelegate;
  [customEvent interstitialDidDisappear:[CRInterstitial new]];
  OCMVerifyAll(mockGADInterstitialDelegate);
}

- (void)testWillLeaveApplicationDelegate {
  CRCustomEventInterstitial *customEvent = [CRCustomEventInterstitial new];
  id mockGADInterstitialDelegate =
      OCMStrictProtocolMock(@protocol(GADCustomEventInterstitialDelegate));
  OCMExpect([mockGADInterstitialDelegate customEventInterstitialWasClicked:customEvent]);
  OCMExpect([mockGADInterstitialDelegate customEventInterstitialWillLeaveApplication:customEvent]);

  customEvent.delegate = mockGADInterstitialDelegate;
  [customEvent interstitialWillLeaveApplication:[CRInterstitial new]];
  OCMVerifyAll(mockGADInterstitialDelegate);
}

- (void)testInterstitialDidReceiveAdDelegate {
  CRCustomEventInterstitial *customEvent = [CRCustomEventInterstitial new];
  id mockGADInterstitialDelegate =
      OCMStrictProtocolMock(@protocol(GADCustomEventInterstitialDelegate));
  OCMExpect([mockGADInterstitialDelegate customEventInterstitialDidReceiveAd:customEvent]);

  customEvent.delegate = mockGADInterstitialDelegate;
  [customEvent interstitialDidReceiveAd:[CRInterstitial new]];
  OCMVerifyAll(mockGADInterstitialDelegate);
}

- (void)testInterstitialDidFailToReceiveAdContentWithErrorDelegate {
  CRCustomEventInterstitial *customEvent = [CRCustomEventInterstitial new];
  id mockGADInterstitialDelegate =
      OCMStrictProtocolMock(@protocol(GADCustomEventInterstitialDelegate));
  OCMExpect([mockGADInterstitialDelegate customEventInterstitial:customEvent
                                                       didFailAd:[OCMArg any]]);

  customEvent.delegate = mockGADInterstitialDelegate;
  NSError *CriteoError =
      [NSError errorWithDomain:@"test domain"
                          code:0
                      userInfo:@{NSLocalizedDescriptionKey : @"test description"}];
  NSError *expectedError =
      [NSError errorWithDomain:GADErrorDomain
                          code:GADErrorNetworkError
                      userInfo:@{NSLocalizedDescriptionKey : CriteoError.description}];
  [customEvent interstitial:[CRInterstitial new] didFailToReceiveAdWithError:expectedError];
  OCMVerifyAll(mockGADInterstitialDelegate);
}

@end
