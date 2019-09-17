//
//  CR_NativeAssets.h
//  pubsdk
//
//  Created by Richard Clark on 9/12/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_NativeProduct.h"
#import "CR_NativeAdvertiser.h"
#import "CR_NativePrivacy.h"
#import "NSArray+Criteo.h"

@interface CR_NativeAssets : NSObject <NSCopying>

@property (readonly, copy, nonatomic) CR_NativeProductArray *products;
@property (readonly, copy, nonatomic) CR_NativeAdvertiser *advertiser;
@property (readonly, copy, nonatomic) CR_NativePrivacy *privacy;
@property (readonly, copy, nonatomic) NSArray<NSString *> *impressionPixels;

- (instancetype)initWithDict:(NSDictionary *)jdict;

@end
