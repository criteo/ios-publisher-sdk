//
//  CRNativeAd+Internal.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRNativeAd.h"

@class CRNativeLoader;
@class CR_NativeAssets;
@class CR_NativeProduct;

NS_ASSUME_NONNULL_BEGIN

@interface CRNativeAd ()

@property (weak, nonatomic, readonly) CRNativeLoader *loader;
@property (strong, nonatomic, readonly) CR_NativeAssets *assets;
@property (strong, nonatomic, readonly) CR_NativeProduct *product;
@property (assign, nonatomic, readonly) BOOL isImpressed;

- (instancetype)initWithLoader:(CRNativeLoader *)loader
                        assets:(CR_NativeAssets *)assets;

- (instancetype)initWithNativeAssets:(CR_NativeAssets *)assets;

- (instancetype)initWithTitle:(NSString * _Nullable)title
                         body:(NSString * _Nullable)body
                        price:(NSString * _Nullable)price
                 callToAction:(NSString * _Nullable)callToAction
        advertiserDescription:(NSString * _Nullable)advertiserDescription
             advertiserDomain:(NSString * _Nullable)advertiserDomain NS_DESIGNATED_INITIALIZER;

- (void)markAsImpressed;

@end

NS_ASSUME_NONNULL_END
