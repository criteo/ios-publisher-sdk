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

@implementation CRNativeAd

@synthesize productMedia = _productMedia;
@synthesize advertiserLogoMedia = _advertiserLogoMedia;

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
             advertiserDescription:assets.advertiser.description
                  advertiserDomain:assets.advertiser.domain]) {
        _assets = assets;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                         body:(NSString *)body
                        price:(NSString *)price
                 callToAction:(NSString *)callToAction
        advertiserDescription:(NSString *)advertiserDescription
             advertiserDomain:(NSString *)advertiserDomain {
    if (self = [super init]) {
        _title = title;
        _body = body;
        _price = price;
        _callToAction = callToAction;
        _advertiserDescription = advertiserDescription;
        _advertiserDomain = advertiserDomain;
    }
    return self;
}

- (CR_NativeProduct *)product {
    return self.assets.products[0];
}

- (CRMediaContent *)productMedia {
    if (!_productMedia) {
        _productMedia = [[CRMediaContent alloc] initWithNativeImage:self.product.image
                                                    mediaDownloader:_loader.mediaDownloader];
    }
    return _productMedia;
}

- (CRMediaContent *)advertiserLogoMedia {
    if (!_advertiserLogoMedia) {
        _advertiserLogoMedia = [[CRMediaContent alloc] initWithNativeImage:self.assets.advertiser.logoImage
                                                           mediaDownloader:_loader.mediaDownloader];
    }
    return _advertiserLogoMedia;
}

- (void)markAsImpressed {
    // Use an ivar because the class extension is used for internal API and we
    // want a readonly property in it.
    _isImpressed = YES;
}

@end
