//
//  CR_NativePrivacy.h
//  pubsdk
//
//  Created by Richard Clark on 9/12/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CR_NativePrivacy : NSObject <NSCopying>

@property (readonly, copy, nonatomic) NSString *optoutClickUrl;
@property (readonly, copy, nonatomic) NSString *optoutImageUrl;
@property (readonly, copy, nonatomic) NSString *longLegalText;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (CR_NativePrivacy *)nativePrivacyWithDict:(NSDictionary *)dict;

@end
