//
//  CR_NativeAssets.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_NativeAssets.h"
#import "NSObject+Criteo.h"
#import "NSString+Criteo.h"

// Writable properties for internal use
@interface CR_NativeAssets ()

@property (copy, nonatomic) CR_NativeProductArray *products;
@property (copy, nonatomic) CR_NativeAdvertiser *advertiser;
@property (copy, nonatomic) CR_NativePrivacy *privacy;
@property (copy, nonatomic) NSArray<NSString *> *impressionPixels;

@end

@implementation CR_NativeAssets

- (instancetype)initWithDict:(NSDictionary *)jdict {
    self = [super init];
    if (self) {
        
        // Product array
        _products = nil;
        NSArray<NSDictionary *> *productDicts = jdict[@"products"];
        if (productDicts && [productDicts isKindOfClass:NSArray.class] && productDicts.count > 0) {
            CR_MutableNativeProductArray *productArray = [CR_MutableNativeProductArray new];
            for (NSDictionary *productDict in productDicts) {
                if (productDict && [productDict isKindOfClass:NSDictionary.class]) {
                    CR_NativeProduct *product = [CR_NativeProduct nativeProductWithDict:productDict];
                    if (product) {
                        [productArray addObject:product];
                    }
                }
            }
            _products = productArray.count > 0 ? productArray : nil;
        }

        // Impression pixel array
        _impressionPixels = nil;
        NSArray<NSDictionary *> *imprPixelDicts = jdict[@"impressionPixels"];
        if (imprPixelDicts && [imprPixelDicts isKindOfClass:NSArray.class] && imprPixelDicts.count > 0) {
            NSMutableArray<NSString *> *imprPixelArray = [NSMutableArray<NSString *> new];
            for (NSDictionary *imprPixelDict in imprPixelDicts) {
                if (imprPixelDict && [imprPixelDict isKindOfClass:NSDictionary.class]) {
                    NSString *impressionPixel = [NSString cr_nonEmptyStringWithStringOrNil:imprPixelDict[@"url"]];
                    if (impressionPixel) {
                        [imprPixelArray addObject:impressionPixel];
                    }
                }
            }
            _impressionPixels = imprPixelArray.count > 0 ? imprPixelArray : nil;
        }

        // ... and the rest
        _advertiser = [CR_NativeAdvertiser nativeAdvertiserWithDict: jdict[@"advertiser"]];
        _privacy    = [CR_NativePrivacy    nativePrivacyWithDict:    jdict[@"privacy"]];
    }
    return self;
}

// Hash values of two CR_NativeAssets objects must be the same if the objects are equal. The reverse is not
// guaranteed (nor does it need to be).
- (NSUInteger) hash {
    NSUInteger hashval = 0;
    for (CR_NativeProduct *product in self.products) {
        hashval ^= product.hash;
    }
    hashval ^= self.advertiser.hash;
    hashval ^= self.privacy.hash;
    for (NSString *impressionPixel in self.impressionPixels) {
        hashval ^= impressionPixel.hash;
    }
    return hashval;
}

- (BOOL)isEqual:(nullable id)other {
    if (!other || ![other isMemberOfClass:CR_NativeAssets.class]) { return NO; }
    CR_NativeAssets *otherAssets = (CR_NativeAssets *)other;
    BOOL result = YES;
    result &= [NSObject cr_object:_products isEqualTo:otherAssets.products];
    result &= [NSObject cr_object:_advertiser isEqualTo:otherAssets.advertiser];
    result &= [NSObject cr_object:_privacy isEqualTo:otherAssets.privacy];
    result &= [NSObject cr_object:_impressionPixels isEqualTo:otherAssets.impressionPixels];
    return result;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    CR_NativeAssets *copy = [[CR_NativeAssets alloc] init];
    copy.products         = self.products;
    copy.advertiser       = self.advertiser;
    copy.privacy          = self.privacy;
    copy.impressionPixels = self.impressionPixels;
    return copy;
}

@end
