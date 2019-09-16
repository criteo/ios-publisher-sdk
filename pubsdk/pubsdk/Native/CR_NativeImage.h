//
//  CR_NativeImage.h
//  pubsdk
//
//  Created by Richard Clark on 9/12/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CR_NativeImage : NSObject <NSCopying>

@property (readonly, copy, nonatomic) NSString *url;
@property (readonly) int width;
@property (readonly) int height;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (CR_NativeImage *)nativeImageWithDict:(NSDictionary *)jdict;

@end
