//
//  CRNativeAd+Internal.h
//  pubsdk
//
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CRNativeAd.h"

@class CR_NativeAssets;

NS_ASSUME_NONNULL_BEGIN

/**
 Criteo internal interface.

 The public interface doesn't allow to instanciate the NativeAd. Only
 internal classes of the SDK can.
*/
@interface CRNativeAd ()

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
