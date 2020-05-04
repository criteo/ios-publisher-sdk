//
//  CR_NativeAssets.h
//  pubsdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_NativeProduct.h"
#import "CR_NativeAdvertiser.h"
#import "CR_NativePrivacy.h"
#import "NSArray+Criteo.h"

@interface CR_NativeAssets : NSObject <NSCopying>

// Products array, BidManager ensure we have at least one entry, or bid is considered invalid
@property (readonly, copy, nonatomic) CR_NativeProductArray *products;
@property (readonly, copy, nonatomic) CR_NativeAdvertiser *advertiser;
@property (readonly, copy, nonatomic) CR_NativePrivacy *privacy;
@property (readonly, copy, nonatomic) NSArray<NSString *> *impressionPixels;

- (instancetype)initWithDict:(NSDictionary *)jdict;

@end
