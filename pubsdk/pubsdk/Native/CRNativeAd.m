//
//  CRNativeAd.m
//  pubsdk
//
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CRNativeAd.h"
#import "CR_NativeAssets.h"

@implementation CRNativeAd

- (instancetype)initWithNativeAssets:(CR_NativeAssets *)assets {
    CR_NativeProduct *product = assets.products[0];
    return [[CRNativeAd alloc] initWithTitle:product.title
                                        body:product.description
                                       price:product.price
                                callToAction:product.callToAction
                             productImageUrl:product.image.url
                       advertiserDescription:assets.advertiser.description
                            advertiserDomain:assets.advertiser.domain
                      advertiserLogoImageUrl:assets.advertiser.logoImage.url];
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
        _productImageUrl = productImageUrl;
        _advertiserDescription = advertiserDescription;
        _advertiserDomain = advertiserDomain;
        _advertiserLogoImageUrl = advertiserLogoImageUrl;
    }
    return self;
}

@end
