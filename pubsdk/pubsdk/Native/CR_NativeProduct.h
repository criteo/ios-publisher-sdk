//
//  CR_NativeProduct.h
//  pubsdk
//
//  Created by Richard Clark on 9/11/19.
//  copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_NativeImage.h"

@interface CR_NativeProduct : NSObject <NSCopying>

@property (readonly, copy, nonatomic) NSString *title;
@property (readonly, copy, nonatomic) NSString *description;
@property (readonly, copy, nonatomic) NSString *price;
@property (readonly, copy, nonatomic) NSString *clickUrl;
@property (readonly, copy, nonatomic) NSString *callToAction;
@property (readonly, copy, nonatomic) CR_NativeImage *image;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (CR_NativeProduct *)nativeProductWithDict:(NSDictionary *)dict;

typedef NSArray<CR_NativeProduct *> CR_NativeProductArray;
typedef NSMutableArray<CR_NativeProduct *> CR_MutableNativeProductArray;

@end
