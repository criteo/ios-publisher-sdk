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

@interface CRBannerViewDelegateTests : XCTestCase {
  CR_CacheAdUnit *cacheAdUnit;
  CRBannerAdUnit *adUnit;
  CR_CdbBid *bid;
  WKNavigationResponse *validNavigationResponse;
}

@property(strong, nonatomic) CR_URLOpenerMock *urlOpener;

@end

@implementation CRBannerViewDelegateTests

- (void)setUp {
  bid = nil;
  cacheAdUnit = nil;
  adUnit = nil;
  self.urlOpener = [[CR_URLOpenerMock alloc] init];
}

- (CR_CacheAdUnit *)expectedAdUnit {
  if (!cacheAdUnit) {
    cacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                      size:CGSizeMake(47.0f, 57.0f)
                                                adUnitType:CRAdUnitTypeBanner];
  }
  return cacheAdUnit;
}

- (CRBannerAdUnit *)adUnit {
  if (!adUnit) {
    adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"123" size:CGSizeMake(47.0f, 57.0f)];
  }
  return adUnit;
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
  if (!bid) {
    bid = [[CR_CdbBid alloc] initWithZoneId:@123
                                placementId:@"placementId"
                                        cpm:@"4.2"
                                   currency:@"₹😀"
                                      width:@47.0f
                                     height:[NSNumber numberWithFloat:57.0f]
                                        ttl:26
                                   creative:@"THIS IS USELESS LEGACY"
                                 displayUrl:displayURL
                                 insertTime:[NSDate date]
                               nativeAssets:nil
                               impressionId:nil];
  }
  return bid;
}

- (void)testBannerDidReceiveAd {
  WKWebView *realWebView = [WKWebView new];
  Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
  OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
  OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn([self bidWithDisplayURL:@"test"]);
  CRBannerView *bannerView =
      [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                   criteo:mockCriteo
                                  webView:realWebView
                                   adUnit:self.adUnit
                                urlOpener:self.urlOpener];

  CRBannerViewDelegateMock *delegate = [[CRBannerViewDelegateMock alloc] init];
  bannerView.delegate = delegate;

  [bannerView loadAd];

  [self cr_waitShortlyForExpectations:@[ delegate.didReceiveAdExpectation ]];
}

// test banner fail when an empty bid is returned
- (void)testBannerAdFetchFail {
  Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
  CRBannerView *bannerView =
      [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                   criteo:mockCriteo
                                  webView:nil
                                   adUnit:self.adUnit
                                urlOpener:self.urlOpener];

  CRBannerViewDelegateMock *delegate = [[CRBannerViewDelegateMock alloc] init];
  delegate.expectedError = [NSError cr_errorWithCode:CRErrorCodeNoFill];
  bannerView.delegate = delegate;
  CR_CacheAdUnit *expectedAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                                       size:CGSizeMake(47.0f, 57.0f)
                                                                 adUnitType:CRAdUnitTypeBanner];
  OCMStub([mockCriteo getBid:expectedAdUnit]).andReturn([CR_CdbBid emptyBid]);

  [bannerView loadAd];

  [self cr_waitShortlyForExpectations:@[ delegate.didFailToReceiveAdWithErrorExpectation ]];
}

- (void)testBannerWillLeaveApplicationAndWasClicked {
  CRBannerView *bannerView =
      [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                   criteo:nil
                                  webView:nil
                                   adUnit:self.adUnit
                                urlOpener:self.urlOpener];
  CRBannerViewDelegateMock *delegate = [[CRBannerViewDelegateMock alloc] init];
  bannerView.delegate = delegate;

  WKNavigationAction *mockNavigationAction = OCMStrictClassMock([WKNavigationAction class]);
  OCMStub(mockNavigationAction.navigationType).andReturn(WKNavigationTypeLinkActivated);
  WKFrameInfo *mockFrame = OCMStrictClassMock([WKFrameInfo class]);
  OCMStub(mockNavigationAction.sourceFrame).andReturn(mockFrame);
  OCMStub([mockFrame isMainFrame]).andReturn(YES);
  NSURL *url = [[NSURL alloc] initWithString:@"123"];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
  OCMStub(mockNavigationAction.request).andReturn(request);

  [bannerView webView:nil
      decidePolicyForNavigationAction:mockNavigationAction
                      decisionHandler:^(WKNavigationActionPolicy decisionHandler){
                      }];

  [self cr_waitShortlyForExpectations:@[
    delegate.wasClickedExpectation, delegate.willLeaveApplicationExpectation
  ]];
}

// test no delegate method called when webView navigation fails
- (void)testNoDelegateWhenWebViewFailsToNavigate {
  CRBannerView *bannerView =
      [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                   criteo:nil
                                  webView:nil
                                   adUnit:self.adUnit
                                urlOpener:self.urlOpener];
  CRBannerViewDelegateMock *delegate = [[CRBannerViewDelegateMock alloc] init];
  [delegate invertAllExpectations];
  bannerView.delegate = delegate;

  [bannerView webView:nil didFailNavigation:nil withError:nil];

  [self cr_waitShortlyForExpectations:delegate.allExpectations];
}

// test no delegate method called when webView load fails
- (void)testNoDelegateWhenWebViewFailsToLoad {
  CRBannerView *bannerView =
      [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                   criteo:nil
                                  webView:nil
                                   adUnit:self.adUnit
                                urlOpener:self.urlOpener];

  CRBannerViewDelegateMock *delegate = [[CRBannerViewDelegateMock alloc] init];
  [delegate invertAllExpectations];
  bannerView.delegate = delegate;

  [bannerView webView:nil didFailProvisionalNavigation:nil withError:nil];

  [self cr_waitShortlyForExpectations:delegate.allExpectations];
}

// test no delegate method called when HTTP error
- (void)testNoDelegateWhenHTTPError {
  CRBannerView *bannerView =
      [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                   criteo:nil
                                  webView:nil
                                   adUnit:self.adUnit
                                urlOpener:self.urlOpener];

  CRBannerViewDelegateMock *delegate = [[CRBannerViewDelegateMock alloc] init];
  [delegate invertAllExpectations];
  bannerView.delegate = delegate;

  WKNavigationResponse *navigationResponse = OCMStrictClassMock([WKNavigationResponse class]);
  NSHTTPURLResponse *response = OCMStrictClassMock([NSHTTPURLResponse class]);
  OCMStub(response.statusCode).andReturn(404);
  OCMStub(navigationResponse.response).andReturn(response);
  [bannerView webView:nil
      decidePolicyForNavigationResponse:navigationResponse
                        decisionHandler:^(WKNavigationResponsePolicy decisionHandler){
                        }];

  [self cr_waitShortlyForExpectations:delegate.allExpectations];
}

- (void)testNoDelegateWhenNoHttpResponse {
  WKWebView *realWebView = [WKWebView new];
  Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
  OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
  CRBannerView *bannerView =
      [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                   criteo:mockCriteo
                                  webView:realWebView
                                   adUnit:self.adUnit
                                urlOpener:self.urlOpener];

  CRBannerViewDelegateMock *delegate = [[CRBannerViewDelegateMock alloc] init];
  bannerView.delegate = delegate;

  OCMStub([mockCriteo getBid:[self expectedAdUnit]]).andReturn([self bidWithDisplayURL:@""]);
  [bannerView loadAd];
  [self cr_waitShortlyForExpectations:@[ delegate.didReceiveAdExpectation ]];
}

#pragma mark inhouseSpecificTests

- (void)testBannerLoadFailWhenTokenValueIsNil {
  Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
  WKWebView *mockWebView = [WKWebView new];
  CRBannerAdUnit *adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"Yup"
                                                               size:CGSizeMake(200, 200)];
  CRBannerView *bannerView =
      [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                   criteo:mockCriteo
                                  webView:mockWebView
                                   adUnit:adUnit
                                urlOpener:self.urlOpener];
  CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
  OCMStub([mockCriteo tokenValueForBidToken:token adUnitType:CRAdUnitTypeBanner]).andReturn(nil);
  id<CRBannerViewDelegate> mockBannerViewDelegate =
      OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
  bannerView.delegate = mockBannerViewDelegate;
  OCMStub([mockBannerViewDelegate banner:bannerView didFailToReceiveAdWithError:[OCMArg any]]);
  [bannerView loadAdWithBidToken:token];

  CRBannerViewDelegateMock *delegate = [[CRBannerViewDelegateMock alloc] init];
  delegate.expectedError = [NSError cr_errorWithCode:CRErrorCodeNoFill];
  bannerView.delegate = delegate;

  [bannerView loadAdWithBidToken:token];

  [self cr_waitForExpectations:@[ delegate.didFailToReceiveAdWithErrorExpectation ]];
}

- (void)testBannerLoadFailWhenTokenValueDoesntMatchAdUnitId {
  Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
  WKWebView *mockWebView = [WKWebView new];
  CRBannerAdUnit *adUnit1 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"Yup"
                                                                size:CGSizeMake(200, 200)];
  CRBannerAdUnit *adUnit2 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"Yo"
                                                                size:CGSizeMake(200, 200)];
  CRBannerView *bannerView =
      [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                   criteo:mockCriteo
                                  webView:mockWebView
                                   adUnit:adUnit1
                                urlOpener:self.urlOpener];
  CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
  CR_TokenValue *expectedTokenValue = [CR_TokenValue tokenValueWithDisplayUrl:@"test"
                                                                       adUnit:adUnit2];
  ;
  OCMStub([mockCriteo tokenValueForBidToken:token adUnitType:CRAdUnitTypeBanner])
      .andReturn(expectedTokenValue);

  CRBannerViewDelegateMock *delegate = [[CRBannerViewDelegateMock alloc] init];
  delegate.expectedError = [NSError
      cr_errorWithCode:CRErrorCodeInvalidParameter
           description:
               @"Token passed to loadAdWithBidToken doesn't have the same ad unit as the CRBannerView was initialized with"];
  bannerView.delegate = delegate;

  [bannerView loadAdWithBidToken:token];

  [self cr_waitForExpectations:@[ delegate.didFailToReceiveAdWithErrorExpectation ]];
}

- (void)testBannerLoadFailWhenTokenValueDoesntMatchAdUnitType {
  Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
  WKWebView *mockWebView = [WKWebView new];
  CRBannerAdUnit *adUnit1 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"Yup"
                                                                size:CGSizeMake(200, 200)];
  CRInterstitialAdUnit *adUnit2 = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"Yo"];
  CRBannerView *bannerView =
      [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                   criteo:mockCriteo
                                  webView:mockWebView
                                   adUnit:adUnit1
                                urlOpener:self.urlOpener];
  CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
  CR_TokenValue *expectedTokenValue = [CR_TokenValue tokenValueWithDisplayUrl:@"test"
                                                                       adUnit:adUnit2];
  OCMStub([mockCriteo tokenValueForBidToken:token adUnitType:CRAdUnitTypeBanner])
      .andReturn(expectedTokenValue);
  id<CRBannerViewDelegate> mockBannerViewDelegate =
      OCMStrictProtocolMock(@protocol(CRBannerViewDelegate));
  bannerView.delegate = mockBannerViewDelegate;
  OCMStub([mockBannerViewDelegate banner:bannerView didFailToReceiveAdWithError:[OCMArg any]]);
  [bannerView loadAdWithBidToken:token];

  CRBannerViewDelegateMock *delegate = [[CRBannerViewDelegateMock alloc] init];
  delegate.expectedError = [NSError
      cr_errorWithCode:CRErrorCodeInvalidParameter
           description:
               @"Token passed to loadAdWithBidToken doesn't have the same ad unit as the CRBannerView was initialized with"];
  bannerView.delegate = delegate;

  [bannerView loadAdWithBidToken:token];

  [self cr_waitForExpectations:@[ delegate.didFailToReceiveAdWithErrorExpectation ]];
}

- (void)testBannerDidLoadForValidTokenValue {
  Criteo *mockCriteo = OCMStrictClassMock([Criteo class]);
  OCMStub(mockCriteo.config).andReturn([[CR_Config alloc] initWithCriteoPublisherId:@"123"]);
  WKWebView *mockWebView = [WKWebView new];
  CRBannerAdUnit *adUnit1 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"Yo"
                                                                size:CGSizeMake(200, 200)];
  CRBannerAdUnit *adUnit2 = [[CRBannerAdUnit alloc] initWithAdUnitId:@"Yo"
                                                                size:CGSizeMake(200, 200)];
  CRBannerView *bannerView =
      [[CRBannerView alloc] initWithFrame:CGRectMake(13.0f, 17.0f, 47.0f, 57.0f)
                                   criteo:mockCriteo
                                  webView:mockWebView
                                   adUnit:adUnit1
                                urlOpener:self.urlOpener];
  CRBidToken *token = [[CRBidToken alloc] initWithUUID:[NSUUID UUID]];
  CR_TokenValue *expectedTokenValue = [CR_TokenValue tokenValueWithDisplayUrl:@"test"
                                                                       adUnit:adUnit2];
  ;
  OCMStub([mockCriteo tokenValueForBidToken:token adUnitType:CRAdUnitTypeBanner])
      .andReturn(expectedTokenValue);

  CRBannerViewDelegateMock *delegate = [[CRBannerViewDelegateMock alloc] init];
  bannerView.delegate = delegate;

  [bannerView loadAdWithBidToken:token];

  [self cr_waitForExpectations:@[ delegate.didReceiveAdExpectation ]];
}

@end
