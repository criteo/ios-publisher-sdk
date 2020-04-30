//
//  CRNativeAd+Internal.h
//  pubsdk
//
//  Created by Romain Lofaso on 2/13/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CRNativeAd.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Criteo internal interface.

 The public interface doesn't allow to instanciate the NativeAd. Only
 internal classes of the SDK can.
*/
@interface CRNativeAd ()

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
