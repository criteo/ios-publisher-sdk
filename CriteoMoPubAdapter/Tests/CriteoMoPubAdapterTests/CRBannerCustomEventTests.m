//
//  CRBannerCustomEventTests.m
//  CriteoMoPubAdapterTests
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

#import <XCTest/XCTest.h>
#import "CRBannerCustomEvent.h"
#import <OCMock.h>
#import <CriteoPublisherSdk/CriteoPublisherSdk.h>

@interface CRBannerCustomEvent ()

@property(nonatomic, strong) CRBannerView *bannerView;

@end

@interface CRBannerCustomEvent (Test)

- (instancetype)initWithBannerView:(CRBannerView *)bannerView;

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info;

@property(nonatomic, weak) id<MPInlineAdAdapterDelegate> delegate;

@end

@implementation CRBannerCustomEvent (Test)

- (instancetype)initWithBannerView:(CRBannerView *)bannerView {
  if (self = [super init]) {
    self.bannerView = bannerView;
  }
  return self;
}

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info {
  [self requestAdWithSize:size adapterInfo:info adMarkup:nil];
}

@dynamic delegate;
static void *DelegateAssociationKey;

- (id)delegate {
  return objc_getAssociatedObject(self, DelegateAssociationKey);
}

- (void)setDelegate:(id)delegate {
  objc_setAssociatedObject(self, DelegateAssociationKey, delegate, OBJC_ASSOCIATION_ASSIGN);
}

@end

@interface CRBannerCustomEventTests : XCTestCase {
  NSString *bannerAdUnitId;
  CGSize adUnitSize;
  NSDictionary *info;
}

@end

@implementation CRBannerCustomEventTests

- (void)setUp {
  bannerAdUnitId = @"banner adunit id";
  adUnitSize = CGSizeMake(320.0, 50.0);
  info = @{@"cpId" : @"criteo publisher id", @"adUnitId" : bannerAdUnitId};
}

- (void)tearDown {
  bannerAdUnitId = nil;
  adUnitSize = CGSizeZero;
  info = nil;
}

- (void)testRequestWithInvalidInfo {
  NSDictionary *invalidInfo = @{@"invalidKey" : @"value"};
  CRBannerCustomEvent *bannerCustomEvent = [[CRBannerCustomEvent alloc] init];
  id mockBannerCustomEventDelegate = OCMStrictProtocolMock(@protocol(MPInlineAdAdapterDelegate));
  bannerCustomEvent.delegate = mockBannerCustomEventDelegate;
  NSString *expectedErrorDescription =
      @"Criteo Banner ad request failed due to invalid server parameters.";
  NSError *error = [NSError errorWithCode:MOPUBErrorServerError
                     localizedDescription:expectedErrorDescription];
  OCMExpect([mockBannerCustomEventDelegate inlineAdAdapter:bannerCustomEvent
                                  didFailToLoadAdWithError:error]);
  [bannerCustomEvent requestAdWithSize:CGSizeMake(320.0, 50.0) adapterInfo:invalidInfo];
  OCMVerifyAllWithDelay(mockBannerCustomEventDelegate, 2);
}

- (void)testCriteoIsRegistered {
  id mockCriteo = [OCMockObject partialMockForObject:[Criteo sharedCriteo]];
  CRBannerAdUnit *bannerAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:bannerAdUnitId
                                                                     size:adUnitSize];
  id mockBannerView = OCMClassMock([CRBannerView class]);
  CRBannerCustomEvent *bannerCustomEvent =
      [[CRBannerCustomEvent alloc] initWithBannerView:mockBannerView];
  OCMExpect([mockCriteo registerCriteoPublisherId:info[@"cpId"] withAdUnits:@[ bannerAdUnit ]]);
  [bannerCustomEvent requestAdWithSize:adUnitSize adapterInfo:info];
  OCMVerifyAll(mockCriteo);
}

- (void)testBannerViewCorrect {
  CRBannerCustomEvent *bannerCustomEvent = [[CRBannerCustomEvent alloc] init];
  [bannerCustomEvent requestAdWithSize:adUnitSize adapterInfo:info];
  XCTAssertEqual(bannerCustomEvent.bannerView.frame.size.width, adUnitSize.width);
  XCTAssertEqual(bannerCustomEvent.bannerView.frame.size.height, adUnitSize.height);
}

- (void)testBannerViewLoadedAndDelegateIsSet {
  id mockBannerView = OCMStrictClassMock([CRBannerView class]);
  CRBannerCustomEvent *bannerCustomEvent =
      [[CRBannerCustomEvent alloc] initWithBannerView:mockBannerView];
  OCMExpect([mockBannerView setDelegate:bannerCustomEvent]);
  OCMExpect([mockBannerView loadAd]);
  [bannerCustomEvent requestAdWithSize:adUnitSize adapterInfo:info];
  OCMVerifyAll(mockBannerView);
}

- (void)testBannerViewSetMopubConsent {
  id mockCriteo = [OCMockObject partialMockForObject:[Criteo sharedCriteo]];
  id mockMopub = [OCMockObject partialMockForObject:[MoPub sharedInstance]];
  CRBannerCustomEvent *bannerCustomEvent = [[CRBannerCustomEvent alloc] init];
  OCMStub([mockMopub currentConsentStatus]).andReturn(MPConsentStatusDenied);

  [mockCriteo setExpectationOrderMatters:YES];
  OCMExpect([mockCriteo setMopubConsent:@"explicit_no"]);
  OCMExpect([mockCriteo registerCriteoPublisherId:[OCMArg any] withAdUnits:[OCMArg any]]);

  [bannerCustomEvent requestAdWithSize:adUnitSize adapterInfo:info];

  OCMVerifyAll(mockCriteo);
}

#pragma mark - Delegate tests

- (void)testDelegateSuccessfulAdRequest {
  id mockBannerView = OCMClassMock([CRBannerView class]);
  CRBannerCustomEvent *bannerCustomEvent =
      [[CRBannerCustomEvent alloc] initWithBannerView:mockBannerView];

  id mockBannerCustomEventDelegate = OCMStrictProtocolMock(@protocol(MPInlineAdAdapterDelegate));
  bannerCustomEvent.delegate = mockBannerCustomEventDelegate;
  OCMStub([mockBannerView loadAd]).andDo(^(NSInvocation *invocation) {
    [bannerCustomEvent bannerDidReceiveAd:mockBannerView];
  });

  OCMExpect([mockBannerCustomEventDelegate inlineAdAdapter:bannerCustomEvent
                                       didLoadAdWithAdView:mockBannerView]);
  [bannerCustomEvent requestAdWithSize:adUnitSize adapterInfo:info];
  OCMVerifyAll(mockBannerCustomEventDelegate);
}

- (void)testDelegateFailedAdRequest {
  id mockBannerView = OCMClassMock([CRBannerView class]);
  CRBannerCustomEvent *bannerCustomEvent =
      [[CRBannerCustomEvent alloc] initWithBannerView:mockBannerView];
  NSError *expectedCriteoError = [NSError errorWithCode:MOPUBErrorUnknown];
  NSString *errorDescription =
      [NSString stringWithFormat:@"Criteo Banner failed to load with error: %@",
                                 expectedCriteoError.localizedDescription];
  NSError *expectedMopubError = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd
                                  localizedDescription:errorDescription];

  id mockBannerCustomEventDelegate = OCMStrictProtocolMock(@protocol(MPInlineAdAdapterDelegate));
  bannerCustomEvent.delegate = mockBannerCustomEventDelegate;
  OCMStub([mockBannerView loadAd]).andDo(^(NSInvocation *invocation) {
    [bannerCustomEvent banner:mockBannerView didFailToReceiveAdWithError:expectedCriteoError];
  });

  OCMExpect([mockBannerCustomEventDelegate inlineAdAdapter:bannerCustomEvent
                                  didFailToLoadAdWithError:expectedMopubError]);
  [bannerCustomEvent requestAdWithSize:adUnitSize adapterInfo:info];
  OCMVerifyAll(mockBannerCustomEventDelegate);
}

- (void)testDelegateBannerLeaveApplication {
  id mockBannerView = OCMClassMock([CRBannerView class]);
  CRBannerCustomEvent *bannerCustomEvent =
      [[CRBannerCustomEvent alloc] initWithBannerView:mockBannerView];

  id mockBannerCustomEventDelegate = OCMStrictProtocolMock(@protocol(MPInlineAdAdapterDelegate));
  bannerCustomEvent.delegate = mockBannerCustomEventDelegate;
  OCMStub([mockBannerView loadAd]).andDo(^(NSInvocation *invocation) {
    [bannerCustomEvent bannerWillLeaveApplication:mockBannerView];
  });

  OCMExpect([mockBannerCustomEventDelegate inlineAdAdapterWillLeaveApplication:bannerCustomEvent]);
  [bannerCustomEvent requestAdWithSize:adUnitSize adapterInfo:info];
  OCMVerifyAll(mockBannerCustomEventDelegate);
}

@end
