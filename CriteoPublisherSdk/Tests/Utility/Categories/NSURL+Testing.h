//
//  NSURL+Testing.h
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

#import <Foundation/Foundation.h>

@class CR_Config;

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (Testing)

- (BOOL)testing_isFeedbackMessageUrlWithConfig:(CR_Config *)config;
- (BOOL)testing_isBidUrlWithConfig:(CR_Config *)config;
- (BOOL)testing_isAppEventUrlWithConfig:(CR_Config *)config;
- (BOOL)testing_isAppLaunchEventUrlWithConfig:(CR_Config *)config;
- (BOOL)testing_isConfigEventUrlWithConfig:(CR_Config *)config;
- (BOOL)testing_isNativeProductImage;
- (BOOL)testing_isNativeAdvertiserLogoImage;
- (BOOL)testing_isNativeAdChoiceImage;
- (BOOL)testing_isNativeAdImpressionPixel;

@end

NS_ASSUME_NONNULL_END
