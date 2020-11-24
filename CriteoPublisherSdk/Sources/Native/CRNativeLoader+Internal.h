//
//  CRNativeLoader+Internal.h
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

#import "CRNativeLoader.h"
#import "Criteo.h"

@class UIView;
@class CR_ThreadManager;
@protocol CR_URLOpening;

NS_ASSUME_NONNULL_BEGIN

@interface CRNativeLoader ()

@property(nonatomic, strong, readonly) Criteo *criteo;
@property(nonatomic, strong, readonly, nullable) CRNativeAdUnit *adUnit;
@property(nonatomic, strong, readonly) id<CR_URLOpening> urlOpener;

- (instancetype)initWithAdUnit:(CRNativeAdUnit *_Nullable)adUnit
                        criteo:(Criteo *)criteo
                     urlOpener:(id<CR_URLOpening>)urlOpener;
- (instancetype)initWithAdUnit:(CRNativeAdUnit *_Nullable)adUnit criteo:(Criteo *)criteo;

- (void)handleImpressionOnNativeAd:(CRNativeAd *)nativeAd;
- (void)handleClickOnNativeAd:(CRNativeAd *)nativeAd fromView:(UIView *_Nullable)view;
- (void)handleClickOnAdChoiceOfNativeAd:(CRNativeAd *)nativeAd;

- (void)notifyDidDetectImpression;
- (void)notifyDidDetectClick;

@end

NS_ASSUME_NONNULL_END
