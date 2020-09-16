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
#import "CR_CdbBid.h"
#import "NSError+Criteo.h"
#import "CR_TokenValue.h"
#import "CRBidToken+Internal.h"
#import "CR_Config.h"
#import "CRInterstitialAdUnit.h"
#import "CRBannerViewDelegateMock.h"
#import "CR_URLOpenerMock.h"
#import "XCTestCase+Criteo.h"
#import "NSURL+Criteo.h"
#import "CR_TokenValue+Testing.h"
#import "CR_DependencyProvider.h"
#import "CR_DependencyProvider+Testing.h"

@interface CRBannerViewDelegateTests : XCTestCase {
  WKNavigationResponse *validNavigationResponse;
}

@property(nonatomic, strong) CR_CacheAdUnit *expectedCacheAdUnit;
@property(nonatomic, strong) CRBannerAdUnit *adUnit;
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
                                insertTime:[NSDate date]
                              nativeAssets:nil
                              impressionId:nil];
}

- (void)testBannerDidReceiveAd {
  WKWebView *realWebView = [WKWebView new];
  OCMStub([self.criteo getBid:[self expectedCacheAdUnit]])
      .andReturn([self bidWithDisplayURL:@"test"]);

  CRBannerView *bannerView = [self bannerViewWithWebView:realWebView];
  bannerView.delegate = self.delegate;
  [bannerView loadAd];

  [self cr_waitShortlyForExpectations:@[ self.delegate.didReceiveAdExpectation ]];
}

// test banner fail when an empty bid is returned
- (void)testBannerAdFetchFail {
  self.delegate.expectedError = [NSError cr_errorWithCode:CRErrorCodeNoFill];

  OCMStub([self.criteo getBid:self.expectedCacheAdUnit]).andReturn([CR_CdbBid emptyBid]);

  CRBannerView *bannerView = [self bannerViewWithWebView:nil];
  bannerView.delegate = self.delegate;
  [bannerView loadAd];

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

  OCMStub([self.criteo getBid:[self expectedCacheAdUnit]]).andReturn([self bidWithDisplayURL:@"-"]);

  CRBannerView *bannerView = [self bannerViewWithWebView:realWebView];
  bannerView.delegate = self.delegate;
  [bannerView loadAd];

  [self cr_waitShortlyForExpectations:@[ self.delegate.didReceiveAdExpectation ]];
}

#pragma mark inhouseSpecificTests

- (void)testBannerLoadFailWhenTokenValueIsNil {
  WKWebView *mockWebView = [WKWebView new];
  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView];
  CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
  OCMStub([self.criteo tokenValueForBidToken:token adUnitType:CRAdUnitTypeBanner]).andReturn(nil);
  id<CRBannerViewDelegate> mockBannerViewDelegate =
      OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
  bannerView.delegate = mockBannerViewDelegate;
  OCMStub([mockBannerViewDelegate banner:bannerView didFailToReceiveAdWithError:[OCMArg any]]);
  [bannerView loadAdWithBidToken:token];

  self.delegate.expectedError = [NSError cr_errorWithCode:CRErrorCodeNoFill];
  bannerView.delegate = self.delegate;

  [bannerView loadAdWithBidToken:token];

  [self cr_waitForExpectations:@[ self.delegate.didFailToReceiveAdWithErrorExpectation ]];
}

- (void)testBannerLoadFailWhenTokenValueDoesntMatchAdUnitId {
  WKWebView *mockWebView = [WKWebView new];

  CRBannerAdUnit *wrongAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"Yo"
                                                                    size:CGSizeMake(200, 200)];

  CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
  CR_TokenValue *expectedTokenValue = [CR_TokenValue tokenValueWithDisplayUrl:@"test"
                                                                       adUnit:wrongAdUnit];

  OCMStub([self.criteo tokenValueForBidToken:token adUnitType:CRAdUnitTypeBanner])
      .andReturn(expectedTokenValue);

  self.delegate.expectedError = [NSError
      cr_errorWithCode:CRErrorCodeInvalidParameter
           description:
               @"Token passed to loadAdWithBidToken doesn't have the same ad unit as the CRBannerView was initialized with"];

  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView];
  bannerView.delegate = self.delegate;
  [bannerView loadAdWithBidToken:token];

  [self cr_waitForExpectations:@[ self.delegate.didFailToReceiveAdWithErrorExpectation ]];
}

- (void)testBannerLoadFailWhenTokenValueDoesntMatchAdUnitType {
  WKWebView *mockWebView = [WKWebView new];

  CRInterstitialAdUnit *wrongAdUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"Yo"];
  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView];
  CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
  CR_TokenValue *expectedTokenValue = [CR_TokenValue tokenValueWithDisplayUrl:@"test"
                                                                       adUnit:wrongAdUnit];
  OCMStub([self.criteo tokenValueForBidToken:token adUnitType:CRAdUnitTypeBanner])
      .andReturn(expectedTokenValue);
  id<CRBannerViewDelegate> mockBannerViewDelegate =
      OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
  bannerView.delegate = mockBannerViewDelegate;
  OCMStub([mockBannerViewDelegate banner:bannerView didFailToReceiveAdWithError:[OCMArg any]]);
  [bannerView loadAdWithBidToken:token];

  self.delegate.expectedError = [NSError
      cr_errorWithCode:CRErrorCodeInvalidParameter
           description:
               @"Token passed to loadAdWithBidToken doesn't have the same ad unit as the CRBannerView was initialized with"];
  bannerView.delegate = self.delegate;

  [bannerView loadAdWithBidToken:token];

  [self cr_waitForExpectations:@[ self.delegate.didFailToReceiveAdWithErrorExpectation ]];
}

- (void)testBannerDidLoadForValidTokenValue {
  WKWebView *mockWebView = [WKWebView new];

  CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
  CR_TokenValue *expectedTokenValue = [CR_TokenValue tokenValueWithDisplayUrl:@"test"
                                                                       adUnit:self.adUnit];

  OCMStub([self.criteo tokenValueForBidToken:token adUnitType:CRAdUnitTypeBanner])
      .andReturn(expectedTokenValue);

  CRBannerView *bannerView = [self bannerViewWithWebView:mockWebView];
  bannerView.delegate = self.delegate;
  [bannerView loadAdWithBidToken:token];

  [self cr_waitForExpectations:@[ self.delegate.didReceiveAdExpectation ]];
}

- (CRBannerView *)bannerViewWithWebView:(WKWebView *)webView {
  return [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                      criteo:self.criteo
                                     webView:webView
                                      adUnit:self.adUnit
                                   urlOpener:self.urlOpener];
}

@end
