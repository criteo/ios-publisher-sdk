//
//  CRBannerView.m
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

#import "CRBannerView+Internal.h"
#import "Criteo+Internal.h"
#import "CR_BidManager.h"
#import "CR_URLOpener.h"
#import "CR_IntegrationRegistry.h"
#import "CR_DependencyProvider.h"
#import "CR_Logging.h"
#import "NSError+Criteo.h"

@interface CRBannerView () <WKNavigationDelegate, WKUIDelegate>
@property(nonatomic) BOOL isResponseValid;
@property(nonatomic, strong) Criteo *criteo;
@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, readonly) CRBannerAdUnit *adUnit;
@property(nonatomic, readonly) id<CR_URLOpening> urlOpener;
@property(nonatomic, strong) CR_SKAdNetworkParameters *skAdNetworkParameters;

@end

@implementation CRBannerView

- (instancetype)initWithAdUnit:(CRBannerAdUnit *)adUnit {
  return [self initWithAdUnit:adUnit criteo:[Criteo sharedCriteo]];
}

- (instancetype)initWithAdUnit:(CRBannerAdUnit *)adUnit criteo:(Criteo *)criteo {
  WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
  webViewConfiguration.allowsInlineMediaPlayback = YES;
  CGRect webViewRect = CGRectMake(.0, .0, adUnit.size.width, adUnit.size.height);

  return [self initWithFrame:CGRectMake(.0, .0, adUnit.size.width, adUnit.size.height)
                      criteo:criteo
                     webView:[[WKWebView alloc] initWithFrame:webViewRect
                                                configuration:webViewConfiguration]
                      adUnit:adUnit
                   urlOpener:[[CR_URLOpener alloc] init]];
}

- (instancetype)initWithFrame:(CGRect)rect
                       criteo:(Criteo *)criteo
                      webView:(WKWebView *)webView
                       adUnit:(CRBannerAdUnit *)adUnit
                    urlOpener:(id<CR_URLOpening>)opener {
  return [self initWithFrame:rect
                      criteo:criteo
                     webView:webView
                  addWebView:YES
                      adUnit:adUnit
                   urlOpener:opener];
}

- (instancetype)initWithFrame:(CGRect)rect
                       criteo:(Criteo *)criteo
                      webView:(WKWebView *)webView
                   addWebView:(BOOL)addWebView
                       adUnit:(CRBannerAdUnit *)adUnit
                    urlOpener:(id<CR_URLOpening>)opener {
  CRLogInfo(@"BannerView", @"Initializing with Ad Unit:%@", adUnit);
  if (self = [super initWithFrame:rect]) {
    _criteo = criteo;
    _webView = webView;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.scrollView.scrollEnabled = false;
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    if (addWebView) {
      [self addSubview:webView];
    }
    _adUnit = adUnit;
    _urlOpener = opener;
  }
  return self;
}

- (void)safelyLoadWebViewWithDisplayUrl:(NSString *)displayUrl {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self loadWebViewWithDisplayUrl:displayUrl];
  });
}

- (void)loadWebViewWithDisplayUrl:(NSString *)displayUrl {
  // Will crash the app if nil is passed to stringByReplacingOccurrencesOfString
  CR_Config *config = _criteo.config;

  NSString *viewportWidth = [NSString stringWithFormat:@"%ld", (long)self.frame.size.width];

  NSString *htmlString =
      [[config.adTagUrlMode stringByReplacingOccurrencesOfString:config.viewportWidthMacro
                                                      withString:viewportWidth]
          stringByReplacingOccurrencesOfString:config.displayURLMacro
                                    withString:displayUrl];

  [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"https://criteo.com"]];
}

- (void)dispatchDidReceiveAdDelegate {
  CRLogInfo(@"BannerView", @"Received ad for Ad Unit:%@", self.adUnit);
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self.delegate respondsToSelector:@selector(bannerDidReceiveAd:)]) {
      [self.delegate bannerDidReceiveAd:self];
    }
  });
}

- (void)loadAd {
  [self loadAdWithContext:CRContextData.new];
}

- (void)loadAdWithContext:(CRContextData *)contextData {
  CRLogInfo(@"BannerView", @"Loading ad for Ad Unit:%@", self.adUnit);
  [self.integrationRegistry declare:CR_IntegrationStandalone];

  self.isResponseValid = NO;

  if (!self.adUnit) {
    [self safelyNotifyAdLoadFail:CRErrorCodeInvalidParameter
                     description:@"Missing adUnit, make sure to use initWithAdUnit:"];
    return;
  }
  CR_CacheAdUnit *cacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:self.adUnit.adUnitId
                                                                    size:self.frame.size
                                                              adUnitType:CRAdUnitTypeBanner];
  [self.criteo loadCdbBidForAdUnit:cacheAdUnit
                       withContext:contextData
                   responseHandler:^(CR_CdbBid *bid) {
                     if (!bid || bid.isEmpty) {
                       [self safelyNotifyAdLoadFail:CRErrorCodeNoFill];
                     } else {
                       [self loadAdWithCdbBid:bid];
                     }
                   }];
}

- (void)loadAdWithBid:(CRBid *)bid {
  [self.integrationRegistry declare:CR_IntegrationInHouse];
  self.isResponseValid = NO;

  if (!bid) {
    [self safelyNotifyAdLoadFail:CRErrorCodeNoFill];
    return;
  }

  CR_CdbBid *cdbBid = bid.consume;
  if (!cdbBid) {
    [self safelyNotifyAdLoadFail:CRErrorCodeNoFill];
    return;
  }

  [self loadAdWithCdbBid:cdbBid];
}

- (void)loadAdWithCdbBid:(CR_CdbBid *)bid {
  self.skAdNetworkParameters = bid.skAdNetworkParameters;
  [self loadAdWithDisplayData:bid.displayUrl];
}

- (void)loadAdWithDisplayData:(NSString *)displayData {
  if (!displayData || displayData.length == 0) {
    return [self safelyNotifyAdLoadFail:CRErrorCodeInternalError description:@"No display URL"];
  }

  [self dispatchDidReceiveAdDelegate];
  [self safelyLoadWebViewWithDisplayUrl:displayData];
}

// When the creative uses window.open(url) to open the URL, this method will be called
- (WKWebView *)webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
               forNavigationAction:(WKNavigationAction *)navigationAction
                    windowFeatures:(WKWindowFeatures *)windowFeatures {
  [self handlePotentialClickForNavigationAction:navigationAction
                                decisionHandler:nil
                          allowedNavigationType:WKNavigationTypeOther];
  return nil;
}

// When the creative uses <a href="url"> to open the URL, this method will be called
- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  [self handlePotentialClickForNavigationAction:navigationAction
                                decisionHandler:decisionHandler
                          allowedNavigationType:WKNavigationTypeLinkActivated];
}

- (void)handlePotentialClickForNavigationAction:(WKNavigationAction *)navigationAction
                                decisionHandler:
                                    (nullable void (^)(WKNavigationActionPolicy))decisionHandler
                          allowedNavigationType:(WKNavigationType)allowedNavigationType {
  if (navigationAction.navigationType == allowedNavigationType &&
      navigationAction.request.URL != nil) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if ([self.delegate respondsToSelector:@selector(bannerWasClicked:)]) {
        [self.delegate bannerWasClicked:self];
      }
      [self.urlOpener openExternalURL:navigationAction.request.URL
            withSKAdNetworkParameters:self.skAdNetworkParameters
                             fromView:self
                           completion:^(BOOL success) {
                             if (success && [self.delegate respondsToSelector:@selector
                                                           (bannerWillLeaveApplication:)]) {
                               [self.delegate bannerWillLeaveApplication:self];
                             }
                           }];
    });
    if (decisionHandler) {
      decisionHandler(WKNavigationActionPolicyCancel);
    }
    return;
  }
  if (decisionHandler) {
    decisionHandler(WKNavigationActionPolicyAllow);
  }
}

// Delegate errors that occur during web view navigation
- (void)webView:(WKWebView *)webView
    didFailNavigation:(WKNavigation *)navigation
            withError:(NSError *)error {
}

// Delegate errors that occur while the web view is loading content.
- (void)webView:(WKWebView *)webView
    didFailProvisionalNavigation:(WKNavigation *)navigation
                       withError:(NSError *)error {
}

// Potential place for invoking didReceiveAd:
- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
                      decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
  if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)navigationResponse.response;
    if (httpResponse.statusCode >= 400) {
      self.isResponseValid = NO;
    } else {
      self.isResponseValid = YES;
    }
  }
  decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)safelyNotifyAdLoadFail:(CRErrorCode)errorCode {
  return [self safelyNotifyAdLoadFail:errorCode description:nil];
}

- (void)safelyNotifyAdLoadFail:(CRErrorCode)errorCode description:(NSString *)description {
  NSError *error = description ? [NSError cr_errorWithCode:errorCode description:description]
                               : [NSError cr_errorWithCode:errorCode];
  CRLogInfo(@"BannerView", @"Failed loading ad for Ad Unit: %@, error: %@", self.adUnit, error);
  if ([self.delegate respondsToSelector:@selector(banner:didFailToReceiveAdWithError:)]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.delegate banner:self didFailToReceiveAdWithError:error];
    });
  }
}

- (CR_IntegrationRegistry *)integrationRegistry {
  return self.criteo.dependencyProvider.integrationRegistry;
}

@end
