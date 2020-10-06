//
//  CRNativeLoader.m
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
#import "CRNativeLoader+Internal.h"
#import "CRNativeAdUnit.h"
#import "CRNativeAd+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CR_CdbBid.h"
#import "CR_NativeAssets.h"
#import "NSError+Criteo.h"
#import "NSURL+Criteo.h"
#import "Logging.h"
#import "CR_DefaultMediaDownloader.h"
#import "CR_SafeMediaDownloader.h"
#import "CR_ThreadManager.h"
#import "CRMediaContent+Internal.h"
#import "CR_URLOpening.h"
#import "CR_DependencyProvider.h"
#import "CR_NetworkManager.h"
#import "CR_IntegrationRegistry.h"
#import "CRBid+Internal.h"

@implementation CRNativeLoader

#pragma mark - Life cycle

- (instancetype)initWithAdUnit:(CRNativeAdUnit *)adUnit {
  return [self initWithAdUnit:adUnit criteo:[Criteo sharedCriteo]];
}

- (instancetype)initWithAdUnit:(CRNativeAdUnit *)adUnit criteo:(Criteo *)criteo {
  return [self initWithAdUnit:adUnit criteo:criteo urlOpener:[[CR_URLOpener alloc] init]];
}

- (instancetype)initWithAdUnit:(CRNativeAdUnit *)adUnit
                        criteo:(Criteo *)criteo
                     urlOpener:(id<CR_URLOpening>)urlOpener {
  if (self = [super init]) {
    _adUnit = adUnit;
    _criteo = criteo;
    self.mediaDownloader = self.criteo.dependencyProvider.mediaDownloader;
    _urlOpener = urlOpener;
  }
  return self;
}

#pragma mark - Public

- (void)loadAd {
  @try {
    [self unsafeLoadAd];
  } @catch (NSException *exception) {
    CLogException(exception);
  }
}

- (void)loadAdWithBid:(CRBid *)bid {
  @try {
    [self unsafeLoadAdWithBid:bid];
  } @catch (NSException *exception) {
    CLogException(exception);
  }
}

#pragma mark - Internal

- (void)handleImpressionOnNativeAd:(CRNativeAd *)nativeAd {
  if (nativeAd.isImpressed) {
    return;
  }
  [nativeAd markAsImpressed];
  [self sendImpressionPixelForNativeAd:nativeAd];
  [self notifyDidDetectImpression];
}

- (void)handleClickOnNativeAd:(CRNativeAd *)nativeAd {
  [self notifyDidDetectClick];

  NSURL *url = [NSURL cr_URLWithStringOrNil:nativeAd.product.clickUrl];
  [self.urlOpener openExternalURL:url
                   withCompletion:^(BOOL success) {
                     if (success) {
                       [self notifyWillLeaveApplicationForNativeAd];
                     }
                   }];
}

- (void)handleClickOnAdChoiceOfNativeAd:(CRNativeAd *)nativeAd {
  NSURL *url = [NSURL cr_URLWithStringOrNil:nativeAd.assets.privacy.optoutClickUrl];
  [self.urlOpener openExternalURL:url
                   withCompletion:^(BOOL success) {
                     if (success) {
                       [self notifyWillLeaveApplicationForNativeAd];
                     }
                   }];
}

#pragma mark - Private

- (void)sendImpressionPixelForNativeAd:(CRNativeAd *)nativeAd {
  for (NSString *urlStr in nativeAd.assets.impressionPixels) {
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    [self.criteo.dependencyProvider.networkManager getFromUrl:url responseHandler:nil];
  }
}

- (void)setMediaDownloader:(id)mediaDownloader {
  _mediaDownloader =
      [[CR_SafeMediaDownloader alloc] initWithUnsafeDownloader:mediaDownloader
                                                 threadManager:self.criteo.threadManager];
}

- (BOOL)canConsumeBid {
  return self.canNotifyDidReceiveAd;
}

- (void)unsafeLoadAd {
  [self.integrationRegistry declare:CR_IntegrationStandalone];

  if (!self.canConsumeBid) {
    return;
  }

  CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:self.adUnit];
  [self.criteo getBid:cacheAdUnit
      responseHandler:^(CR_CdbBid *bid) {
        [self handleNativeAssets:bid.nativeAssets];
      }];
}

- (void)unsafeLoadAdWithBid:(CRBid *)bid {
  if (!self.canConsumeBid) {
    return;
  }

  [self handleNativeAssets:bid.consume.nativeAssets];
}

- (void)handleNativeAssets:(CR_NativeAssets *)nativeAssets {
  if (!nativeAssets) {
    NSError *error = [NSError cr_errorWithCode:CRErrorCodeNoFill];
    [self notifyFailToReceiveAdWithError:error];
  } else {
    CRNativeAd *ad = [[CRNativeAd alloc] initWithLoader:self assets:nativeAssets];
    [self preloadImageUrl:ad.productMedia.url];
    [self preloadImageUrl:ad.advertiserLogoMedia.url];
    [self preloadImageUrl:[NSURL cr_URLWithStringOrNil:nativeAssets.privacy.optoutImageUrl]];
    [self notifyDidReceiveAd:ad];
  }
}

- (void)preloadImageUrl:(NSURL *)imageUrl {
  [self.mediaDownloader downloadImage:imageUrl
                    completionHandler:^(UIImage *ignored1, NSError *ignored2){
                    }];
}

- (CR_ThreadManager *)threadManager {
  return self.criteo.dependencyProvider.threadManager;
}

- (CR_IntegrationRegistry *)integrationRegistry {
  return self.criteo.dependencyProvider.integrationRegistry;
}

#pragma mark - Delegate call

- (void)notifyFailToReceiveAdWithError:(NSError *)error {
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self.delegate respondsToSelector:@selector(nativeLoader:didFailToReceiveAdWithError:)]) {
      [self.delegate nativeLoader:self didFailToReceiveAdWithError:error];
    }
  });
}

- (BOOL)canNotifyDidReceiveAd {
  // We don't use the @required intentionaly on nativeLoader:didReceiveAd:
  // for keeping the API flexible and avoiding breaking changes in the futur.
  return [self.delegate respondsToSelector:@selector(nativeLoader:didReceiveAd:)];
}

- (void)notifyDidReceiveAd:(CRNativeAd *)ad {
  [self.threadManager dispatchAsyncOnMainQueue:^{
    if (self.canNotifyDidReceiveAd) {
      [self.delegate nativeLoader:self didReceiveAd:ad];
    }
  }];
}

- (void)notifyDidDetectImpression {
  [self.threadManager dispatchAsyncOnMainQueue:^{
    if ([self.delegate respondsToSelector:@selector(nativeLoaderDidDetectImpression:)]) {
      [self.delegate nativeLoaderDidDetectImpression:self];
    }
  }];
}

- (void)notifyDidDetectClick {
  [self.threadManager dispatchAsyncOnMainQueue:^{
    if ([self.delegate respondsToSelector:@selector(nativeLoaderDidDetectClick:)]) {
      [self.delegate nativeLoaderDidDetectClick:self];
    }
  }];
}

- (void)notifyWillLeaveApplicationForNativeAd {
  [self.threadManager dispatchAsyncOnMainQueue:^{
    if ([self.delegate respondsToSelector:@selector(nativeLoaderWillLeaveApplication:)]) {
      [self.delegate nativeLoaderWillLeaveApplication:self];
    }
  }];
}

@end
