//
//  CRNativeAd.m
//  pubsdk
//
//  Created by Romain Lofaso on 2/10/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CRNativeAd.h"

@implementation CRNativeAd

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
