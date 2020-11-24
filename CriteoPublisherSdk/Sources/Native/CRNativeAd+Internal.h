//
//  CRNativeAd+Internal.h
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

#import "CRNativeAd.h"

@class CRNativeLoader;
@class CR_NativeAssets;
@class CR_NativeProduct;
@class CR_SKAdNetworkParameters;

NS_ASSUME_NONNULL_BEGIN

@interface CRNativeAd ()

@property(strong, nonatomic, readonly) CRNativeLoader *loader;
@property(strong, nonatomic, readonly) CR_NativeAssets *assets;
@property(strong, nonatomic, readonly) CR_NativeProduct *product;
@property(strong, nonatomic, readonly) CR_SKAdNetworkParameters *skAdNetworkParameters;

/**
 * True when the SDK has detect that the Advanced Native has been well displayed.
 */
@property(assign, nonatomic, readonly) BOOL isImpressed;

- (instancetype)initWithLoader:(CRNativeLoader *)loader
                        assets:(CR_NativeAssets *)assets
         skAdNetworkParameters:(CR_SKAdNetworkParameters *)skAdNetworkParameters;

- (instancetype)initWithNativeAssets:(CR_NativeAssets *)assets;

- (instancetype)initWithTitle:(NSString *_Nullable)title
                         body:(NSString *_Nullable)body
                        price:(NSString *_Nullable)price
                 callToAction:(NSString *_Nullable)callToAction
        advertiserDescription:(NSString *_Nullable)advertiserDescription
             advertiserDomain:(NSString *_Nullable)advertiserDomain
                    legalText:(NSString *_Nullable)legalText NS_DESIGNATED_INITIALIZER;

- (void)markAsImpressed;

@end

NS_ASSUME_NONNULL_END
