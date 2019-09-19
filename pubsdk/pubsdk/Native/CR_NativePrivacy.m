//
//  CR_NativePrivacy.m
//  pubsdk
//
//  Created by Richard Clark on 9/12/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_NativePrivacy.h"
#import "NSObject+Criteo.h"
#import "NSURL+Criteo.h"
#import "NSString+Criteo.h"

// Writable properties for internal use
@interface CR_NativePrivacy ()

@property (copy, nonatomic) NSString *optoutClickUrl;
@property (copy, nonatomic) NSString *optoutImageUrl;
@property (copy, nonatomic) NSString *longLegalText;

@end

@implementation CR_NativePrivacy

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _optoutClickUrl = [NSString nonEmptyStringWithStringOrNil:dict[@"optoutClickUrl"]];
        _optoutImageUrl = [NSString nonEmptyStringWithStringOrNil:dict[@"optoutImageUrl"]];
        _longLegalText  = [NSString nonEmptyStringWithStringOrNil:dict[@"longLegalText"]];
    }
    return self;
}

+ (CR_NativePrivacy *)nativePrivacyWithDict:(NSDictionary *)dict {
    if (dict && [dict isKindOfClass:NSDictionary.class]) {
        return [[CR_NativePrivacy alloc] initWithDict:dict];
    } else {
        return nil;
    }
}

// Hash values of two CR_NativePrivacy objects must be the same if the objects are equal. The reverse is not
// guaranteed (nor does it need to be).
- (NSUInteger) hash {
    return  _optoutClickUrl.hash ^
            _optoutImageUrl.hash ^
            _longLegalText.hash;
}

- (BOOL)isEqual:(nullable id)other {
    if (!other || ![other isMemberOfClass:CR_NativePrivacy.class]) { return NO; }
    CR_NativePrivacy *otherPrivacy = (CR_NativePrivacy *)other;
    BOOL result = YES;
    result &= [NSObject object:_optoutClickUrl isEqualTo:otherPrivacy.optoutClickUrl];
    result &= [NSObject object:_optoutImageUrl isEqualTo:otherPrivacy.optoutImageUrl];
    result &= [NSObject object:_longLegalText  isEqualTo:otherPrivacy.longLegalText];
    return result;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    CR_NativePrivacy *copy = [[CR_NativePrivacy alloc] init];
    copy.optoutClickUrl = self.optoutClickUrl;
    copy.optoutImageUrl = self.optoutImageUrl;
    copy.longLegalText  = self.longLegalText;
    return copy;
}

@end
