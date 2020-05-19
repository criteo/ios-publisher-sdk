//
//  CRNativeAd.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRNativeAd+Internal.h"
#import "CR_NativeAssets.h"
#import "CRNativeLoader.h"
#import "CRMediaContent.h"
#import "CRMediaContent+Internal.h"
#import "NSURL+Criteo.h"

@implementation CRNativeAd

- (instancetype)initWithLoader:(CRNativeLoader *)loader
                        assets:(CR_NativeAssets *)assets {
    if (self = [self initWithNativeAssets:assets]) {
        _loader = loader;
    }
    return self;
}

- (instancetype)initWithNativeAssets:(CR_NativeAssets *)assets {
    CR_NativeProduct *product = assets.products[0];
    if (self = [self initWithTitle:product.title
                              body:product.description
                             price:product.price
                      callToAction:product.callToAction
                   productImageUrl:product.image.url
             advertiserDescription:assets.advertiser.description
                  advertiserDomain:assets.advertiser.domain
            advertiserLogoImageUrl:assets.advertiser.logoImage.url]) {
        _assets = assets;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                         body:(NSString *)body
                        price:(NSString *)price
                 callToAction:(NSString *)callToAction
              productImageUrl:(NSString *)productImageUrl
        advertiserDescription:(NSString *)advertiserDescription
             advertiserDomain:(NSString *)advertiserDomain
       advertiserLogoImageUrl:(NSString *)advertiserLogoImageUrl {
    if (self = [super init]) {
        _title = title;
        _body = body;
        _price = price;
        _callToAction = callToAction;
        _productMedia = [[CRMediaContent alloc] initWithImageUrl:[NSURL cr_URLWithStringOrNil:productImageUrl]];
        _advertiserDescription = advertiserDescription;
        _advertiserDomain = advertiserDomain;
        _advertiserLogoMedia = [[CRMediaContent alloc] initWithImageUrl:[NSURL cr_URLWithStringOrNil:advertiserLogoImageUrl]];
    }
    return self;
}

- (CR_NativeProduct *)product {
    return self.assets.products[0];
}

@end
