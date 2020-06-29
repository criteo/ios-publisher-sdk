//
//  CR_NativeAdvertiser.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CR_NativeImage.h"

@interface CR_NativeAdvertiser : NSObject <NSCopying>

@property(readonly, copy, nonatomic) NSString *description;
@property(readonly, copy, nonatomic) NSString *domain;
@property(readonly, copy, nonatomic) CR_NativeImage *logoImage;
@property(readonly, copy, nonatomic) NSString *logoClickUrl;

- (instancetype)initWithDict:(NSDictionary *)jdict;
+ (CR_NativeAdvertiser *)nativeAdvertiserWithDict:(NSDictionary *)jdict;

@end
