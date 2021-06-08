//
//  CR_HeaderBidding.m
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

#import "CR_HeaderBidding.h"
#import "CR_TargetingKeys.h"
#import "CR_CdbBid.h"
#import "CR_CacheAdUnit.h"
#import "CR_NativeAssets.h"
#import "CR_NativeProduct.h"
#import "CRAdUnit+Internal.h"
#import "CR_BidManagerHelper.h"
#import "NSString+CriteoUrl.h"
#import "CR_DisplaySizeInjector.h"
#import "CR_IntegrationRegistry.h"
#import "CR_Logging.h"

@interface CR_HeaderBidding ()

@property(strong, nonatomic, readonly) id<CR_HeaderBiddingDevice> device;
@property(strong, nonatomic, readonly) CR_DisplaySizeInjector *displaySizeInjector;
@property(strong, nonatomic, readonly) CR_IntegrationRegistry *integrationRegistry;

@end

@implementation CR_HeaderBidding

- (instancetype)initWithDevice:(id<CR_HeaderBiddingDevice>)device
           displaySizeInjector:(CR_DisplaySizeInjector *)displaySizeInjector
           integrationRegistry:(CR_IntegrationRegistry *)integrationRegistry {
  if (self = [super init]) {
    _device = device;
    _displaySizeInjector = displaySizeInjector;
    _integrationRegistry = integrationRegistry;
  }
  return self;
}

- (void)enrichRequest:(id)adRequest withBid:(CR_CdbBid *)bid adUnit:(CR_CacheAdUnit *)adUnit {
  if ([self isDfpRequest:adRequest]) {
    [self.integrationRegistry declare:CR_IntegrationGamAppBidding];
  } else if ([self isMoPubRequest:adRequest]) {
    [self.integrationRegistry declare:CR_IntegrationMopubAppBidding];

    // Reset the keywords in the request in case there is empty bid (EE-412).
    [self removeCriteoBidsFromMoPubRequest:adRequest];
  } else if ([self isCustomRequest:adRequest]) {
    [self.integrationRegistry declare:CR_IntegrationCustomAppBidding];
  }

  if ([bid isEmpty]) {
    CRLogInfo(@"AppBidding", @"No bid found while enriching request for Ad Unit: %@", adUnit);
    return;
  }

  if ([self isDfpRequest:adRequest]) {
    [self addCriteoBidToDfpRequest:adRequest withBid:bid adUnit:adUnit];
  } else if ([self isMoPubRequest:adRequest]) {
    [self addCriteoBidToMopubRequest:adRequest withBid:bid adUnit:adUnit];
  } else if ([self isCustomRequest:adRequest]) {
    [self addCriteoBidToDictionary:adRequest withBid:bid adUnit:adUnit];
  } else {
    CRLogError(@"AppBidding", @"Cannot enrich unsupported ad request: %@, for Ad Unit: %@",
               adRequest, adUnit);
  }
}

#pragma mark - Private

- (void)removeCriteoBidsFromMoPubRequest:(id)adRequest {
  NSAssert([self isMoPubRequest:adRequest], @"Given object isn't from MoPub API: %@", adRequest);
  // For now, this method is a class method because it is used
  // in NSObject+Criteo load for swizzling.
  [CR_BidManagerHelper removeCriteoBidsFromMoPubRequest:adRequest];
}

- (BOOL)isMoPubRequest:(id)request {
  return [self is:request kindOfClassByName:@"MPAdView"] ||
         [self is:request kindOfClassByName:@"MPInterstitialAdController"];
}

- (BOOL)isCustomRequest:(id)request {
  return [request isKindOfClass:NSMutableDictionary.class];
}

- (BOOL)isDfpRequest:(id)request {
  return [self is:request kindOfClassByName:@"GAMRequest"] ||
         [self is:request kindOfClassByName:@"DFPRequest"] ||
         [self is:request kindOfClassByName:@"DFPNRequest"] ||
         [self is:request kindOfClassByName:@"DFPORequest"] ||
         [self is:request kindOfClassByName:@"GADRequest"] ||
         [self is:request kindOfClassByName:@"GADORequest"] ||
         [self is:request kindOfClassByName:@"GADNRequest"];
}

- (BOOL)is:(id)request kindOfClassByName:(NSString *)name {
  Class klass = NSClassFromString(name);
  if (klass == nil) {
    return NO;
  }
  return [request isKindOfClass:klass];
}

- (void)addCriteoBidToDictionary:(NSMutableDictionary *)dictionary
                         withBid:(CR_CdbBid *)bid
                          adUnit:(CR_CacheAdUnit *)adUnit {
  dictionary[CR_TargetingKey_crtDisplayUrl] = bid.displayUrl;
  dictionary[CR_TargetingKey_crtCpm] = bid.cpm;
  dictionary[CR_TargetingKey_crtSize] = [self stringFromSize:adUnit.size];
  CRLogInfo(@"AppBidding", @"Enriching Custom request for Ad Unit: %@, set bid as: %@", adUnit,
            dictionary);
}

- (void)addCriteoBidToDfpRequest:(id)adRequest
                         withBid:(CR_CdbBid *)bid
                          adUnit:(CR_CacheAdUnit *)adUnit {
  SEL dfpCustomTargeting = NSSelectorFromString(@"customTargeting");
  SEL dfpSetCustomTargeting = NSSelectorFromString(@"setCustomTargeting:");
  if ([adRequest respondsToSelector:dfpCustomTargeting] &&
      [adRequest respondsToSelector:dfpSetCustomTargeting]) {
// this is for ignoring warning related to performSelector: on unknown selectors
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id targeting = [adRequest performSelector:dfpCustomTargeting];

    if (targeting == nil) {
      targeting = [NSDictionary dictionary];
    }

    if ([targeting isKindOfClass:[NSDictionary class]]) {
      NSMutableDictionary *customTargeting =
          [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)targeting];
      customTargeting[CR_TargetingKey_crtCpm] = bid.cpm;
      if (adUnit.adUnitType == CRAdUnitTypeNative) {
        // bid will contain at least one product, a privacy section and at least one impression
        // pixel
        CR_NativeAssets *nativeAssets = bid.nativeAssets;
        if (nativeAssets.products.count > 0) {
          CR_NativeProduct *product = nativeAssets.products[0];
          [self setDfpValue:product.title
                     forKey:CR_TargetingKey_crtnTitle
               inDictionary:customTargeting];
          [self setDfpValue:product.description
                     forKey:CR_TargetingKey_crtnDesc
               inDictionary:customTargeting];
          [self setDfpValue:product.price
                     forKey:CR_TargetingKey_crtnPrice
               inDictionary:customTargeting];
          [self setDfpValue:product.clickUrl
                     forKey:CR_TargetingKey_crtnClickUrl
               inDictionary:customTargeting];
          [self setDfpValue:product.callToAction
                     forKey:CR_TargetingKey_crtnCta
               inDictionary:customTargeting];
          [self setDfpValue:product.image.url
                     forKey:CR_TargetingKey_crtnImageUrl
               inDictionary:customTargeting];
        }
        CR_NativeAdvertiser *advertiser = nativeAssets.advertiser;
        [self setDfpValue:advertiser.description
                   forKey:CR_TargetingKey_crtnAdvName
             inDictionary:customTargeting];
        [self setDfpValue:advertiser.domain
                   forKey:CR_TargetingKey_crtnAdvDomain
             inDictionary:customTargeting];
        [self setDfpValue:advertiser.logoImage.url
                   forKey:CR_TargetingKey_crtnAdvLogoUrl
             inDictionary:customTargeting];
        [self setDfpValue:advertiser.logoClickUrl
                   forKey:CR_TargetingKey_crtnAdvUrl
             inDictionary:customTargeting];

        CR_NativePrivacy *privacy = nativeAssets.privacy;
        [self setDfpValue:privacy.optoutClickUrl
                   forKey:CR_TargetingKey_crtnPrUrl
             inDictionary:customTargeting];
        [self setDfpValue:privacy.optoutImageUrl
                   forKey:CR_TargetingKey_crtnPrImageUrl
             inDictionary:customTargeting];
        [self setDfpValue:privacy.longLegalText
                   forKey:CR_TargetingKey_crtnPrText
             inDictionary:customTargeting];
        customTargeting[CR_TargetingKey_crtnPixCount] =
            [NSString stringWithFormat:@"%lu", (unsigned long)nativeAssets.impressionPixels.count];
        for (int i = 0; i < bid.nativeAssets.impressionPixels.count; i++) {
          [self setDfpValue:bid.nativeAssets.impressionPixels[i]
                     forKey:[NSString stringWithFormat:@"%@%d", CR_TargetingKey_crtnPixUrl, i]
               inDictionary:customTargeting];
        }
      } else {
        NSString *displayUrl = bid.displayUrl;
        if (adUnit.adUnitType == CRAdUnitTypeInterstitial) {
          customTargeting[CR_TargetingKey_crtSize] = [self stringSizeForInterstitial];

          if (!bid.isVideo) {
            // DFP is the whole screen even out of the safe area.
            displayUrl = [self.displaySizeInjector injectFullScreenSizeInDisplayUrl:displayUrl];
          }
        } else if (adUnit.adUnitType == CRAdUnitTypeBanner) {
          customTargeting[CR_TargetingKey_crtSize] = [self stringSizeForBannerWithAdUnit:adUnit];
        }

        NSString *dfpCompatibleString;
        if (bid.isVideo) {
          // No base64 encoding as there is no client javascript to decode
          dfpCompatibleString = [[displayUrl cr_urlEncode] cr_urlEncode];
          customTargeting[CR_TargetingKey_crtFormat] = CR_TargetingValue_FormatVideo;
        } else {
          dfpCompatibleString = [NSString cr_dfpCompatibleString:displayUrl];
        }
        customTargeting[CR_TargetingKey_crtDfpDisplayUrl] = dfpCompatibleString;
      }
      NSDictionary *updatedDictionary = [NSDictionary dictionaryWithDictionary:customTargeting];
      [adRequest performSelector:dfpSetCustomTargeting withObject:updatedDictionary];
      CRLogInfo(@"AppBidding", @"Enriching DFP request for Ad Unit: %@, set bid as: %@", adUnit,
                updatedDictionary);
#pragma clang diagnostic pop
    }
  }
}

- (void)addCriteoBidToMopubRequest:(id)adRequest
                           withBid:(CR_CdbBid *)bid
                            adUnit:(CR_CacheAdUnit *)adUnit {
  [self removeCriteoBidsFromMoPubRequest:adRequest];
  SEL mopubKeywords = NSSelectorFromString(@"keywords");
  if ([adRequest respondsToSelector:mopubKeywords]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id targeting = [adRequest performSelector:mopubKeywords];

    if (targeting == nil) {
      targeting = @"";
    }

    if ([targeting isKindOfClass:[NSString class]]) {
      NSString *displayUrl = bid.displayUrl;

      // MoPub interstitial restrains itself to the safe area.
      if (adUnit.adUnitType == CRAdUnitTypeInterstitial) {
        displayUrl = [self.displaySizeInjector injectSafeScreenSizeInDisplayUrl:bid.displayUrl];
      }
      if (bid.isVideo) {
        displayUrl = [displayUrl cr_urlEncode];
      }

      NSMutableString *keywords = [[NSMutableString alloc] initWithString:targeting];
      if ([keywords length] > 0) {
        [keywords appendString:@","];
      }
      [keywords appendString:CR_TargetingKey_crtCpm];
      [keywords appendString:@":"];
      [keywords appendString:bid.cpm];
      [keywords appendString:@","];
      [keywords appendString:CR_TargetingKey_crtDisplayUrl];
      [keywords appendString:@":"];
      [keywords appendString:displayUrl];

      if (bid.isVideo) {
        [keywords appendString:@","];
        [keywords appendString:CR_TargetingKey_crtFormat];
        [keywords appendString:@":"];
        [keywords appendString:CR_TargetingValue_FormatVideo];
      }

      if (adUnit.adUnitType == CRAdUnitTypeBanner) {
        NSString *sizeStr = [self stringSizeForBannerWithAdUnit:adUnit];
        [keywords appendString:@","];
        [keywords appendString:CR_TargetingKey_crtSize];
        [keywords appendString:@":"];
        [keywords appendString:sizeStr];
      }
      [adRequest setValue:keywords forKey:@"keywords"];
      CRLogInfo(@"AppBidding", @"Enriching MoPub request for Ad Unit: %@, set bid as: %@", adUnit,
                keywords);
#pragma clang diagnostic pop
    }
  }
}

- (void)setDfpValue:(NSString *)value
             forKey:(NSString *)key
       inDictionary:(NSMutableDictionary *)dict {
  if (value.length > 0) {
    dict[key] = [NSString cr_dfpCompatibleString:value];
  }
}

#pragma mark - Ad Size

- (NSString *)stringSizeForBannerWithAdUnit:(CR_CacheAdUnit *)adUnit {
  NSAssert(adUnit.adUnitType == CRAdUnitTypeBanner, @"The given adUnit isn't a banner: %@", adUnit);
  NSString *sizeStr = [self stringFromSize:adUnit.size];
  return sizeStr;
}

- (NSString *)stringSizeForInterstitial {
  CGSize size = [self sizeForInterstitial];
  NSString *str = [self stringFromSize:size];
  return str;
}

- (CGSize)sizeForInterstitial {
  if ([self.device isPhone] || [self isSmallScreen]) {
    if ([self.device isInPortrait]) {
      return (CGSize){320.f, 480.f};
    } else {
      return (CGSize){480.f, 320.f};
    }
  } else {  // is iPad (or TV)
    if ([self.device isInPortrait]) {
      return (CGSize){768.f, 1024.f};
    } else {
      return (CGSize){1024.f, 768.f};
    }
  }
}

- (BOOL)isSmallScreen {
  CGSize size = [self.device screenSize];
  BOOL isSmall = NO;
  if (size.width > size.height) {
    isSmall = (size.width < 1024.f) || (size.height < 768.f);
  } else {
    isSmall = (size.width < 768.f) || (size.height < 1024.f);
  }
  return isSmall;
}

- (NSString *)stringFromSize:(CGSize)size {
  NSString *result = [[NSString alloc] initWithFormat:@"%dx%d", (int)size.width, (int)size.height];
  return result;
}

@end

@implementation CR_DeviceInfo (HeaderBidding)

- (BOOL)isPhone {
  UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
  BOOL isPhone = (idiom == UIUserInterfaceIdiomPhone);
  return isPhone;
}

- (BOOL)isInPortrait {
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  BOOL isInPortrait = UIDeviceOrientationIsPortrait(orientation);
  return isInPortrait;
}

@end
