//
//  CR_CustomNativeAdView.h
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

#import "CRNativeAdView.h"

@class CRNativeAd;
@class CRMediaView;

NS_ASSUME_NONNULL_BEGIN

@interface CR_CustomNativeAdView : CRNativeAdView

@property(strong, nonatomic) CRMediaView *productMediaView;
@property(strong, nonatomic) CRMediaView *advertiserLogoMediaView;

@end

NS_ASSUME_NONNULL_END
