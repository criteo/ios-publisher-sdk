//
//  Criteo+Internal.h
//  CriteoAdViewer
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

#ifndef Criteo_Internal_h
#define Criteo_Internal_h

#import "NetworkManagerDelegate.h"
#import <CriteoPublisherSdk/CriteoPublisherSdk.h>

@class Criteo;

@interface Criteo ()

@property(nonatomic) id<NetworkManagerDelegate> networkManagerDelegate;

+ (instancetype)criteo;

@end

@interface CRInterstitial ()
- (instancetype)initWithAdUnit:(CRInterstitialAdUnit *)adUnit criteo:(Criteo *)criteo;
@end

@interface CRBannerView ()
- (instancetype)initWithAdUnit:(CRBannerAdUnit *)adUnit criteo:(Criteo *)criteo;
@end

@interface CRNativeLoader ()
- (instancetype)initWithAdUnit:(CRNativeAdUnit *)adUnit criteo:(Criteo *)criteo;
@end

#endif /* Criteo_Internal_h */
