//
//  CRNativeAd+Internal.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRNativeAd.h"

@class CRNativeLoader;
@class CR_NativeAssets;

NS_ASSUME_NONNULL_BEGIN

@interface CRNativeAd ()

@property (weak, nonatomic, readonly) CRNativeLoader *loader;
@property (strong, nonatomic, readonly) CR_NativeAssets *assets;

- (instancetype)initWithLoader:(CRNativeLoader *)loader
                        assets:(CR_NativeAssets *)assets;

- (instancetype)initWithNativeAssets:(CR_NativeAssets *)assets;

- (instancetype)initWithTitle:(NSString * _Nullable)title
                         body:(NSString * _Nullable)body
                        price:(NSString * _Nullable)price
                 callToAction:(NSString * _Nullable)callToAction
              productImageUrl:(NSString * _Nullable)productImageUrl
        advertiserDescription:(NSString * _Nullable)advertiserDescription
             advertiserDomain:(NSString * _Nullable)advertiserDomain
       advertiserLogoImageUrl:(NSString * _Nullable)advertiserLogoImageUrl NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
