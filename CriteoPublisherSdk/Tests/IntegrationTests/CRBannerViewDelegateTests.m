//
//  CRBannerViewDelegateTests.m
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
#import <OCMock.h>
#import "CRBannerView.h"
#import "Criteo.h"
#import "CRBannerView+Internal.h"
#import "Criteo+Internal.h"
#import "CRBid+Internal.h"
#import "CR_CdbBid.h"
#import "NSError+Criteo.h"
#import "CRInterstitialAdUnit.h"
#import "CRBannerViewDelegateMock.h"
#import "CR_URLOpenerMock.h"
#import "XCTestCase+Criteo.h"
#import "CR_DependencyProvider.h"
#import "CR_DependencyProvider+Testing.h"
#import "CRContextData.h"

@interface CRBannerViewDelegateTests : XCTestCase {
  WKNavigationResponse *validNavigationResponse;
}

@property(nonatomic, strong) CR_CacheAdUnit *expectedCacheAdUnit;
@property(nonatomic, strong) CRBannerAdUnit *adUnit;
@property(nonatomic, strong) CRContextData *contextData;
@property(strong, nonatomic) CR_URLOpenerMock *urlOpener;
@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) CRBannerViewDelegateMock *delegate;

@end

@implementation CRBannerViewDelegateTests

- (void)setUp {
  self.expectedCacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                                 size:CGSizeMake(47.0f, 57.0f)
                                                           adUnitType:CRAdUnitTypeBanner];
  self.adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"123" size:CGSizeMake(47.0f, 57.0f)];
  self.contextData = CRContextData.new;

  self.urlOpener = [[CR_URLOpenerMock alloc] init];

  CR_DependencyProvider *dependencyProvider = CR_DependencyProvider.testing_dependencyProvider;
  self.criteo = OCMPartialMock([Criteo.alloc initWithDependencyProvider:dependencyProvider]);

  self.delegate = [[CRBannerViewDelegateMock alloc] init];
}

- (WKNavigationResponse *)validNavigationResponse {
  if (!validNavigationResponse) {
    validNavigationResponse = OCMStrictClassMock([WKNavigationResponse class]);
    NSHTTPURLResponse *response = OCMStrictClassMock([NSHTTPURLResponse class]);
    OCMStub(response.statusCode).andReturn(200);
    OCMStub(validNavigationResponse.response).andReturn(response);
  }
  return validNavigationResponse;
}

- (CR_CdbBid *)bidWithDisplayURL:(NSString *)displayURL {
  return [[CR_CdbBid alloc] initWithZoneId:@123
                               placementId:@"placementId"
                                       cpm:@"4.2"
                                  currency:@"₹😀"
                                     width:@47.0f
                                    height:@57.0f
                                       ttl:26
                                  creative:@"THIS IS USELESS LEGACY"
                                displayUrl:displayURL
                                   isVideo:NO
                                insertTime:[NSDate date]
                              nativeAssets:nil
                              impressionId:nil
                     skAdNetworkParameters:nil];
}

- (void)testBannerDidReceiveAd {
  WKWebView *realWebView = [WKWebView new];
  [self mockCriteoWithAdUnit:self.expectedCacheAdUnit respondBid:[self bidWithDisplayURL:@"test"]];

  CRBannerView *bannerView = [self bannerViewWithWebView:realWebView];
  bannerView.delegate = self.delegate;
  [bannerView loadAdWithContext:self.contextData];

  [self cr_waitShortlyForExpectations:@[ self.delegate.didReceiveAdExpectation ]];
}

// test banner fail when an empty bid is returned
- (void)testBannerAdFetchFail {
  self.delegate.expectedError = [NSError cr_errorWithCode:CRErrorCodeNoFill];

  [self mockCriteoWithAdUnit:self.expectedCacheAdUnit respondBid:nil];
  CRBannerView *bannerView = [self bannerViewWithWebView:nil];
  bannerView.delegate = self.delegate;
  [bannerView loadAdWithContext:self.contextData];

  [self cr_waitShortlyForExpectations:@[ self.delegate.didFailToReceiveAdWithErrorExpectation ]];
}

- (void)testBannerWillLeaveApplicationAndWasClicked {
  WKNavigationAction *mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);
  OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeLinkActivated);
  WKFrameInfo *mockFrame = OCMStrictClassMock([WKFrameInfo class]);
  OCMStub(mockNavigationAction.sourceFrame).andReturn(mockFrame);
  OCMStub([mockFrame isMainFrame]).andReturn(YES);
  NSURL *url = [[NSURL alloc] initWithString:@"123"];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
  OCMStub(mockNavigationAction.request).andReturn(request);

  CRBannerView *bannerView = [self bannerViewWithWebView:nil];
  bannerView.delegate = self.delegate;
  [bannerView webView:nil
      decidePolicyForNavigationAction:mockNavigationAction
                      decisionHandler:^(WKNavigationActionPolicy decisionHandler){
                      }];

  [self cr_waitShortlyForExpectations:@[
    self.delegate.wasClickedExpectation, self.delegate.willLeaveApplicationExpectation
  ]];
}

// test no delegate method called when webView navigation fails
- (void)testNoDelegateWhenWebViewFailsToNavigate {
  [self.delegate invertAllExpectations];

  CRBannerView *bannerView = [self bannerViewWithWebView:nil];
  bannerView.delegate = self.delegate;
  [bannerView webView:nil didFailNavigation:nil withError:nil];

  [self cr_waitShortlyForExpectations:self.delegate.allExpectations];
}

// test no delegate method called when webView load fails
- (void)testNoDelegateWhenWebViewFailsToLoad {
  [self.delegate invertAllExpectations];

  CRBannerView *bannerView = [self bannerViewWithWebView:nil];
  bannerView.delegate = self.delegate;
  [bannerView webView:nil didFailProvisionalNavigation:nil withError:nil];

  [self cr_waitShortlyForExpectations:self.delegate.allExpectations];
}

// test no delegate method called when HTTP error
- (void)testNoDelegateWhenHTTPError {
  [self.delegate invertAllExpectations];

  WKNavigationResponse *navigationResponse = OCMStrictClassMock([WKNavigationResponse class]);
  NSHTTPURLResponse *response = OCMStrictClassMock([NSHTTPURLResponse class]);
  OCMStub(response.statusCode).andReturn(404);
  OCMStub(navigationResponse.response).andReturn(response);

  CRBannerView *bannerView = [self bannerViewWithWebView:nil];
  bannerView.delegate = self.delegate;
  [bannerView webView:nil
      decidePolicyForNavigationResponse:navigationResponse
                        decisionHandler:^(WKNavigationResponsePolicy decisionHandler){
                        }];

  [self cr_waitShortlyForExpectations:self.delegate.allExpectations];
}

- (void)testNoDelegateWhenNoHttpResponse {
  WKWebView *realWebView = [WKWebView new];

  [self mockCriteoWithAdUnit:self.expectedCacheAdUnit respondBid:[self bidWithDisplayURL:@"-"]];
  CRBannerView *bannerView = [self bannerViewWithWebView:realWebView];
  bannerView.delegate = self.delegate;
  [bannerView loadAdWithContext:self.contextData];

  [self cr_waitShortlyForExpectations:@[ self.delegate.didReceiveAdExpectation ]];
}

- (void)testInterstitialFailWithMissingAdUnit {
  CRBannerView *bannerView = [[CRBannerView alloc] initWithAdUnit:nil criteo:nil];
  id<CRBannerViewDelegate> delegate = OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
  bannerView.delegate = delegate;
  OCMExpect([delegate banner:bannerView
      didFailToReceiveAdWithError:[OCMArg checkWithBlock:^BOOL(NSError *error) {
        return error.code == CRErrorCodeInvalidParameter;
      }]]);
  [bannerView loadAdWithContext:self.contextData];
  OCMVerifyAllWithDelay(delegate, 1);
}

#pragma mark inhouseSpecificTests

- (void)testBannerLoadFailWhenBidIsNil {
  WKWebView *mockWebView = [WKWebView new];
  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView];
  CRBid *bid = nil;
  id<CRBannerViewDelegate> mockBannerViewDelegate =
      OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
  bannerView.delegate = mockBannerViewDelegate;
  OCMStub([mockBannerViewDelegate banner:bannerView didFailToReceiveAdWithError:[OCMArg any]]);
  [bannerView loadAdWithBid:bid];

  self.delegate.expectedError = [NSError cr_errorWithCode:CRErrorCodeNoFill];
  bannerView.delegate = self.delegate;

  [bannerView loadAdWithBid:bid];

  [self cr_waitForExpectations:@[ self.delegate.didFailToReceiveAdWithErrorExpectation ]];
}

- (void)testBannerDidLoadForValidBid {
  WKWebView *mockWebView = [WKWebView new];
  CR_CdbBid *cdbBid = [self bidWithDisplayURL:@"test"];
  CRBid *bid = [[CRBid alloc] initWithCdbBid:cdbBid adUnit:self.adUnit];

  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView];
  bannerView.delegate = self.delegate;
  [bannerView loadAdWithBid:bid];

  [self cr_waitForExpectations:@[ self.delegate.didReceiveAdExpectation ]];
}

#pragma mark - Private

- (CRBannerView *)bannerViewWithWebView:(WKWebView *)webView {
  return [[CRBannerView alloc]
              initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                     criteo:self.criteo
                    webView:webView
                 addWebView:NO
                     adUnit:self.adUnit
                  urlOpener:self.urlOpener
      delegateDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
}

- (void)mockCriteoWithAdUnit:(CR_CacheAdUnit *)adUnit respondBid:(CR_CdbBid *)bid {
  OCMStub([self.criteo loadCdbBidForAdUnit:adUnit
                               withContext:self.contextData
                           responseHandler:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        CR_CdbBidResponseHandler handler;
        [invocation getArgument:&handler atIndex:4];
        handler(bid);
      });
}

@end
