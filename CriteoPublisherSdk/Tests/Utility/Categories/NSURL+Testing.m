//
//  NSURL+Testing.m
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

#import "NSURL+Testing.h"

#import "CR_Config.h"
#import "CR_NativeAssets+Testing.h"

@implementation NSURL (Testing)

- (BOOL)testing_isFeedbackMessageUrlWithConfig:(CR_Config *)config {
  return [self.absoluteString containsString:config.cdbUrl] &&
         [self.absoluteString containsString:config.csmPath];
}

- (BOOL)testing_isBidUrlWithConfig:(CR_Config *)config {
  return [self.absoluteString containsString:config.cdbUrl] &&
         [self.absoluteString containsString:config.path];
}

- (BOOL)testing_isAppEventUrlWithConfig:(CR_Config *)config {
  return [self.absoluteString containsString:config.appEventsUrl];
}

- (BOOL)testing_isAppLaunchEventUrlWithConfig:(CR_Config *)config {
  return [self testing_isAppEventUrlWithConfig:config] &&
         [self.absoluteString containsString:@"eventType=Launch"];
}

- (BOOL)testing_isConfigEventUrlWithConfig:(CR_Config *)config {
  return [self.absoluteString containsString:config.configUrl];
}

- (BOOL)testing_isNativeProductImage {
  return [self.absoluteString
      isEqualToString:CR_NativeAssets.nativeAssetsFromCdb.products[0].image.url];
}

- (BOOL)testing_isNativeAdvertiserLogoImage {
  NSString *selfStr = self.absoluteString;
  NSString *defaultLogoUrlStr = CR_NativeAssets.nativeAssetsFromCdb.advertiser.logoImage.url;
  BOOL isEqual = [selfStr isEqualToString:defaultLogoUrlStr];
  return isEqual;
}

- (BOOL)testing_isNativeAdChoiceImage {
  return [self.absoluteString
      isEqualToString:CR_NativeAssets.nativeAssetsFromCdb.privacy.optoutImageUrl];
}

- (BOOL)testing_isNativeAdImpressionPixel {
  NSArray<NSString *> *urlStrings = CR_NativeAssets.nativeAssetsFromCdb.impressionPixels;
  for (NSString *urlStr in urlStrings) {
    if ([self.absoluteString isEqualToString:urlStr]) {
      return YES;
    }
  }
  return NO;
}

@end
