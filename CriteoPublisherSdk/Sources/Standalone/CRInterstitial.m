//
//  CRInterstitial.m
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

#import "Criteo+Internal.h"
#import "CRBid+Internal.h"
#import "CRInterstitial.h"
#import "CRInterstitial+Internal.h"
#import "CR_Config.h"
#import "CR_CdbBid.h"
#import "NSError+Criteo.h"
#import "CR_InterstitialViewController.h"
#import "CR_DeviceInfo.h"
#import "CR_URLOpener.h"
#import "CR_DependencyProvider.h"
#import "CR_DisplaySizeInjector.h"
#import "CR_IntegrationRegistry.h"
#import "CR_Logging.h"

@interface CRInterstitial () <WKNavigationDelegate, WKUIDelegate>

@property(strong, nonatomic) id<CR_URLOpening> urlOpener;
@property(nonatomic, strong) CR_SKAdNetworkParameters *skAdNetworkParameters;

@end

@implementation CRInterstitial

- (instancetype)initWithCriteo:(Criteo *)criteo
                viewController:(CR_InterstitialViewController *)viewController
                    isAdLoaded:(BOOL)isAdLoaded
                        adUnit:(CRInterstitialAdUnit *)adUnit
                     urlOpener:(id<CR_URLOpening>)urlOpener {
  CRLogInfo(@"Interstitial", @"Initializing with Ad Unit:%@", adUnit);
  if (self = [super init]) {
    _criteo = criteo;
    viewController.webView.navigationDelegate = self;
    viewController.webView.UIDelegate = self;
    _viewController = viewController;
    _isAdLoaded = isAdLoaded;
    _adUnit = adUnit;
    _urlOpener = urlOpener;
  }
  return self;
}

- (instancetype)initWithAdUnit:(CRInterstitialAdUnit *)adUnit {
  return [self initWithAdUnit:adUnit criteo:[Criteo sharedCriteo]];
}

- (instancetype)initWithAdUnit:(CRInterstitialAdUnit *)adUnit criteo:(Criteo *)criteo {
  WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
  webViewConfiguration.allowsInlineMediaPlayback = YES;
  WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero
                                          configuration:webViewConfiguration];
  CR_URLOpener *urlOpener = [[CR_URLOpener alloc] init];
  return [self initWithCriteo:criteo
               viewController:[[CR_InterstitialViewController alloc] initWithWebView:webView
                                                                                view:nil
                                                                        interstitial:self]
                   isAdLoaded:NO
                       adUnit:adUnit
                    urlOpener:urlOpener];
}

- (BOOL)checkSafeToLoad {
  if (self.isAdLoading) {
    // Already loading
    [self safelyNotifyAdLoadFail:CRErrorCodeInvalidRequest
                     description:@"An Ad is already being loaded."];
    return NO;
  }
  if (self.viewController.presentingViewController) {
    // Already presenting
    [self safelyNotifyAdLoadFail:CRErrorCodeInvalidRequest
                     description:@"Ad cannot load as another is already being presented."];
    return NO;
  }

  self.isAdLoading = YES;
  self.isAdLoaded = NO;
  self.isResponseValid = NO;
  return YES;
}

- (void)loadAd {
  [self loadAdWithContext:CRContextData.new];
}

- (void)loadAdWithContext:(CRContextData *)contextData {
  CRLogInfo(@"Interstitial", @"Loading ad for Ad Unit:%@", self.adUnit);
  [self.integrationRegistry declare:CR_IntegrationStandalone];

  if (![self checkSafeToLoad]) {
    return;
  }

  if (!self.adUnit) {
    [self safelyNotifyAdLoadFail:CRErrorCodeInvalidParameter
                     description:@"Missing adUnit, make sure to use initWithAdUnit:"];
    return;
  }
  CR_CacheAdUnit *cacheAdUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:self.adUnit.adUnitId
                                                                    size:self.deviceInfo.screenSize
                                                              adUnitType:CRAdUnitTypeInterstitial];
  [self.criteo loadCdbBidForAdUnit:cacheAdUnit
                       withContext:contextData
                   responseHandler:^(CR_CdbBid *bid) {
                     if (!bid || bid.isEmpty) {
                       self.isAdLoading = NO;
                       [self safelyNotifyAdLoadFail:CRErrorCodeNoFill];
                     } else {
                       [self loadAdWithCdbBid:bid];
                     }
                   }];
}

- (void)safelyLoadWebViewWithDisplayURL:(NSString *)displayURL {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self loadWebViewWithDisplayURL:displayURL];
  });
}

- (void)loadWebViewWithDisplayURL:(NSString *)displayURL {
  CR_Config *config = _criteo.config;

  NSString *viewportWidth =
      [NSString stringWithFormat:@"%ld", (long)[UIScreen mainScreen].bounds.size.width];

  // Standalone and In-House use the safe area for rendering the interstitial
  displayURL = [self.displaySizeInjector injectSafeScreenSizeInDisplayUrl:displayURL];

  NSString *htmlString =
      [[config.adTagUrlMode stringByReplacingOccurrencesOfString:config.viewportWidthMacro
                                                      withString:viewportWidth]
          stringByReplacingOccurrencesOfString:config.displayURLMacro
                                    withString:displayURL];

  [self.viewController.webView loadHTMLString:htmlString
                                      baseURL:[NSURL URLWithString:@"https://criteo.com"]];
}

- (void)dispatchDidReceiveAdDelegate {
  CRLogInfo(@"Interstitial", @"Received ad for Ad Unit:%@", self.adUnit);
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self.delegate respondsToSelector:@selector(interstitialDidReceiveAd:)]) {
      [self.delegate interstitialDidReceiveAd:self];
    }
  });
}

- (void)loadAdWithBid:(CRBid *)bid {
  [self.integrationRegistry declare:CR_IntegrationInHouse];

  if (![self checkSafeToLoad]) {
    return;
  }

  if (!bid) {
    [self safelyNotifyAdLoadFail:CRErrorCodeNoFill];
    self.isAdLoading = NO;
    return;
  }

  CR_CdbBid *cdbBid = bid.consume;
  if (!cdbBid) {
    [self safelyNotifyAdLoadFail:CRErrorCodeNoFill];
    self.isAdLoading = NO;
    return;
  }

  [self loadAdWithCdbBid:cdbBid];
}

- (void)loadAdWithCdbBid:(CR_CdbBid *)bid {
  self.skAdNetworkParameters = bid.skAdNetworkParameters;
  [self loadAdWithDisplayData:bid.displayUrl];
}

- (void)loadAdWithDisplayData:(NSString *)displayData {
  if (!displayData || displayData.length == 0)
    return [self safelyNotifyAdLoadFail:CRErrorCodeInternalError description:@"No display URL"];

  [self.viewController initWebViewIfNeeded];
  [self safelyLoadWebViewWithDisplayURL:displayData];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  self.isAdLoading = NO;
  if (self.isResponseValid) {
    self.isAdLoaded = YES;
    [self dispatchDidReceiveAdDelegate];
  } else {
    [self safelyNotifyAdLoadFail:CRErrorCodeNetworkError];
  }
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
  if (self.viewController.presentingViewController)
    return [self safelyNotifyAdLoadFail:CRErrorCodeInvalidRequest
                            description:@"An Ad is already being presented."];

  if (!rootViewController)
    return [self safelyNotifyAdLoadFail:CRErrorCodeInvalidParameter
                            description:@"rootViewController parameter must not be nil."];

  if (!self.isAdLoaded)
    return [self safelyNotifyAdLoadFail:CRErrorCodeInvalidRequest
                            description:@"Interstitial Ad is not loaded."];

  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self.delegate respondsToSelector:@selector(interstitialWillAppear:)]) {
      [self.delegate interstitialWillAppear:self];
    }
  });

  self.rootViewController = rootViewController;
  self.viewController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.rootViewController
      presentViewController:self.viewController
                   animated:YES
                 completion:^{
                   dispatch_async(dispatch_get_main_queue(), ^{
                     if ([self.delegate respondsToSelector:@selector(interstitialDidAppear:)]) {
                       [self.delegate interstitialDidAppear:self];
                     }
                   });
                 }];
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
      if ([self.delegate respondsToSelector:@selector(interstitialWasClicked:)]) {
        [self.delegate interstitialWasClicked:self];
      }
      [self.urlOpener openExternalURL:navigationAction.request.URL
            withSKAdNetworkParameters:self.skAdNetworkParameters
                   fromViewController:self.rootViewController
                           completion:^(BOOL success) {
                             if (success && [self.delegate respondsToSelector:@selector
                                                           (interstitialWillLeaveApplication:)]) {
                               [self.delegate interstitialWillLeaveApplication:self];
                             }
                           }];
      [self.viewController dismissViewController];
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
  self.isAdLoading = NO;
  [self safelyNotifyAdLoadFail:CRErrorCodeNetworkError];
}

// Delegate errors that occur while the web view is loading content.
- (void)webView:(WKWebView *)webView
    didFailProvisionalNavigation:(WKNavigation *)navigation
                       withError:(NSError *)error {
  self.isAdLoading = NO;
  [self safelyNotifyAdLoadFail:CRErrorCodeNetworkError];
}

// Delegate HTTP errors
- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
                      decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
  if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)navigationResponse.response;
    if (httpResponse.statusCode >= 400) {
      self.isResponseValid = NO;
      self.isAdLoading = NO;
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
  CRLogInfo(@"Interstitial", @"Failed loading ad for Ad Unit: %@, error: %@", self.adUnit, error);
  if ([self.delegate respondsToSelector:@selector(interstitial:didFailToReceiveAdWithError:)]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.delegate interstitial:self didFailToReceiveAdWithError:error];
    });
  }
}

- (CR_DeviceInfo *)deviceInfo {
  return _criteo.dependencyProvider.deviceInfo;
}

- (CR_DisplaySizeInjector *)displaySizeInjector {
  return _criteo.dependencyProvider.displaySizeInjector;
}

- (CR_IntegrationRegistry *)integrationRegistry {
  return _criteo.dependencyProvider.integrationRegistry;
}

@end
