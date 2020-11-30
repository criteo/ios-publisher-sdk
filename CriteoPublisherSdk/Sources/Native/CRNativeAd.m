//
//  CRNativeAd.m
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

#import "CRNativeAd+Internal.h"
#import "CR_NativeAssets.h"
#import "CRNativeLoader.h"
#import "CRMediaContent.h"
#import "CRMediaContent+Internal.h"

@implementation CRNativeAd

@synthesize productMedia = _productMedia;
@synthesize advertiserLogoMedia = _advertiserLogoMedia;

- (instancetype)initWithLoader:(CRNativeLoader *)loader
                        assets:(CR_NativeAssets *)assets
         skAdNetworkParameters:(CR_SKAdNetworkParameters *)skAdNetworkParameters {
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
                advertiserDomain:assets.advertiser.domain
                       legalText:assets.privacy.longLegalText]) {
    _assets = assets;
  }
  return self;
}

- (instancetype)initWithTitle:(NSString *_Nullable)title
                         body:(NSString *_Nullable)body
                        price:(NSString *_Nullable)price
                 callToAction:(NSString *_Nullable)callToAction
        advertiserDescription:(NSString *_Nullable)advertiserDescription
             advertiserDomain:(NSString *_Nullable)advertiserDomain
                    legalText:(NSString *_Nullable)legalText {
  if (self = [super init]) {
    _title = title;
    _body = body;
    _price = price;
    _callToAction = callToAction;
    _advertiserDescription = advertiserDescription;
    _advertiserDomain = advertiserDomain;
    _legalText = legalText;
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
    _advertiserLogoMedia =
        [[CRMediaContent alloc] initWithNativeImage:self.assets.advertiser.logoImage
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
