//
//  CR_NativeAdvertiser.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_NativeAdvertiser.h"
#import "NSObject+Criteo.h"
#import "NSURL+Criteo.h"
#import "NSString+Criteo.h"

@interface CR_NativeAdvertiser ()

@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) NSString *domain;
@property (copy, nonatomic) CR_NativeImage *logoImage;
@property (copy, nonatomic) NSString *logoClickUrl;

@end

@implementation CR_NativeAdvertiser

@synthesize description = _description;

- (instancetype)initWithDict:(NSDictionary  *)dict {
    self = [super init];
    if (self) {
        _description  = [NSString nonEmptyStringWithStringOrNil: dict[@"description"]];
        _domain       = [NSString nonEmptyStringWithStringOrNil: dict[@"domain"]];
        _logoImage    = [CR_NativeImage nativeImageWithDict:     dict[@"logo"]];
        _logoClickUrl = [NSString nonEmptyStringWithStringOrNil: dict[@"logoClickUrl"]];
    }
    return self;
}

+ (CR_NativeAdvertiser *)nativeAdvertiserWithDict:(NSDictionary *)dict {
    if (dict && [dict isKindOfClass:NSDictionary.class]) {
        return [[CR_NativeAdvertiser alloc] initWithDict:dict];
    } else {
        return nil;
    }
}

// Hash values of two CR_NativeAdvertiser objects must be the same if the objects are equal. The reverse is not
// guaranteed (nor does it need to be).
- (NSUInteger) hash {
    return _description.hash ^
           _domain.hash ^
           _logoImage.hash ^
           _logoClickUrl.hash;
}

- (BOOL)isEqual:(id)other {
    if (!other || ![other isMemberOfClass:CR_NativeAdvertiser.class]) { return NO; }
    CR_NativeAdvertiser *otherAdvertiser = (CR_NativeAdvertiser *)other;
    BOOL result = YES;
    result &= [NSObject object:_description  isEqualTo:otherAdvertiser.description];
    result &= [NSObject object:_domain       isEqualTo:otherAdvertiser.domain];
    result &= [NSObject object:_logoImage    isEqualTo:otherAdvertiser.logoImage];
    result &= [NSObject object:_logoClickUrl isEqualTo:otherAdvertiser.logoClickUrl];
    return result;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    CR_NativeAdvertiser *copy = [[CR_NativeAdvertiser alloc] init];
    copy.description  = self.description;
    copy.domain       = self.domain;
    copy.logoImage    = self.logoImage;
    copy.logoClickUrl = self.logoClickUrl;
    return copy;
}

@end
