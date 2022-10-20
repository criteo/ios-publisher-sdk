//
//  CRCustomEventBannerTests.m
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
#import "CRCustomEventBanner.h"
#import <OCMock.h>

@interface CRCustomEventBannerTests : XCTestCase

@end

// Private property
@interface CRCustomEventBanner ()

@property(nonatomic, strong) CRBannerView *bannerView;

@end

// Test-only initializer
@interface CRCustomEventBanner (Test)

- (instancetype)initWithBannerView:(CRBannerView *)bannerView;

@end

@implementation CRCustomEventBanner (Test)

- (instancetype)initWithBannerView:(CRBannerView *)bannerView {
  if (self = [super init]) {
    self.bannerView = bannerView;
  }
  return self;
}

@end

@protocol GADCustomEventBannerDelegateDeprecated <NSObject>
- (void)customEventBanner:(id<GADCustomEventBanner>)customEvent didReceiveAd:(UIView *)view;
- (void)customEventBanner:(id<GADCustomEventBanner>)customEvent didFailAd:(nullable NSError *)error;
@property(nonatomic, readonly) UIViewController *viewControllerForPresentingModalView;
- (void)customEventBannerWillPresentModal:(id<GADCustomEventBanner>)customEvent;
- (void)customEventBannerWillDismissModal:(id<GADCustomEventBanner>)customEvent;
- (void)customEventBannerDidDismissModal:(id<GADCustomEventBanner>)customEvent;
- (void)customEventBannerWillLeaveApplication:(id<GADCustomEventBanner>)customEvent;
- (void)customEventBanner:(id<GADCustomEventBanner>)customEvent
        clickDidOccurInAd:(UIView *)view
    GAD_DEPRECATED_MSG_ATTRIBUTE("Use customEventBannerWasClicked:.");
@end

#define SERVER_PARAMETER @"{\"cpId\":\"testCpId\",\"adUnitId\":\"testAdUnitId\"}"

@implementation CRCustomEventBannerTests

- (void)testRequestBannerAdSuccess {
  CRBannerView *mockCRBannerView = OCMStrictClassMock([CRBannerView class]);
  CRBannerAdUnit *bannerAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"testAdUnitId"
                                                                     size:CGSizeMake(320, 50)];
  CRCustomEventBanner *customEvent =
      [[CRCustomEventBanner alloc] initWithBannerView:mockCRBannerView];

  OCMStub([mockCRBannerView loadAd]);
  OCMStub([mockCRBannerView setDelegate:customEvent]);

  id mockCriteo = OCMClassMock([Criteo class]);
  OCMStub([mockCriteo sharedCriteo]).andReturn(mockCriteo);
  OCMStub([mockCriteo registerCriteoPublisherId:@"testCpId" withAdUnits:@[ bannerAdUnit ]]);

  [customEvent requestBannerAd:GADAdSizeBanner
                     parameter:SERVER_PARAMETER
                         label:nil
                       request:[GADCustomEventRequest new]];

  OCMVerify([mockCRBannerView loadAd]);
  OCMVerify([mockCRBannerView setDelegate:customEvent]);
  OCMVerify([mockCriteo registerCriteoPublisherId:@"testCpId" withAdUnits:@[ bannerAdUnit ]]);
}

- (void)testRequestBannerAdFail {
  CRCustomEventBanner *customEvent = [CRCustomEventBanner new];
  id mockGADBannerDelegate = OCMStrictProtocolMock(@protocol(GADCustomEventBannerDelegate));
  OCMExpect([mockGADBannerDelegate
      customEventBanner:customEvent
              didFailAd:[NSError errorWithDomain:GADErrorDomain
                                            code:GADErrorInvalidArgument
                                        userInfo:nil]]);
  NSString *invalid = @"{\"cpIDD\":\"testCpId\"}";
  customEvent.delegate = mockGADBannerDelegate;
  GADCustomEventRequest *request = [GADCustomEventRequest new];
  [customEvent requestBannerAd:GADAdSizeLargeBanner parameter:invalid label:nil request:request];
  OCMVerifyAllWithDelay(mockGADBannerDelegate, 1);
}

#pragma mark CRBannerViewDelegate tests

- (void)testDidReceiveAdDelegate {
  CRCustomEventBanner *customEvent = [CRCustomEventBanner new];
  CRBannerView *bannerView = [CRBannerView new];
  id mockGADBannerDelegate = OCMStrictProtocolMock(@protocol(GADCustomEventBannerDelegate));
  OCMExpect([mockGADBannerDelegate customEventBanner:customEvent didReceiveAd:bannerView]);
  customEvent.delegate = mockGADBannerDelegate;
  [customEvent bannerDidReceiveAd:bannerView];
  OCMVerifyAll(mockGADBannerDelegate);
}

- (void)testDidFailToReceiveAdDelegate {
  CRCustomEventBanner *customEvent = [CRCustomEventBanner new];
  id mockGADBannerDelegate = OCMStrictProtocolMock(@protocol(GADCustomEventBannerDelegate));
  NSError *criteoError =
      [NSError errorWithDomain:@"test domain"
                          code:0
                      userInfo:[NSDictionary dictionaryWithObject:@"test description"
                                                           forKey:NSLocalizedDescriptionKey]];
  NSError *expectedError =
      [NSError errorWithDomain:GADErrorDomain
                          code:GADErrorNoFill
                      userInfo:[NSDictionary dictionaryWithObject:criteoError.description
                                                           forKey:NSLocalizedDescriptionKey]];
  OCMExpect([mockGADBannerDelegate customEventBanner:customEvent didFailAd:expectedError]);
  customEvent.delegate = mockGADBannerDelegate;
  [customEvent banner:[CRBannerView new] didFailToReceiveAdWithError:criteoError];
  OCMVerifyAll(mockGADBannerDelegate);
}

- (void)testWillLeaveApplicationDelegate {
  CRCustomEventBanner *customEvent = [CRCustomEventBanner new];
  id mockGADBannerDelegate = OCMStrictProtocolMock(@protocol(GADCustomEventBannerDelegate));
  OCMExpect([mockGADBannerDelegate customEventBannerWasClicked:customEvent]);
  OCMExpect([mockGADBannerDelegate customEventBannerWillLeaveApplication:customEvent]);
  customEvent.delegate = mockGADBannerDelegate;
  [customEvent bannerWillLeaveApplication:[CRBannerView new]];
  OCMVerifyAll(mockGADBannerDelegate);
}

- (void)testWillLeaveApplicationDelegateDeprecated {
  CRCustomEventBanner *customEvent = [CRCustomEventBanner new];
  id mockGADBannerDelegate =
      OCMStrictProtocolMock(@protocol(GADCustomEventBannerDelegateDeprecated));
  CRBannerView *bannerView = [CRBannerView new];
  OCMExpect([mockGADBannerDelegate customEventBanner:customEvent clickDidOccurInAd:bannerView]);
  OCMExpect([mockGADBannerDelegate customEventBannerWillLeaveApplication:customEvent]);
  customEvent.delegate = mockGADBannerDelegate;
  [customEvent bannerWillLeaveApplication:bannerView];
  OCMVerifyAll(mockGADBannerDelegate);
}

@end
