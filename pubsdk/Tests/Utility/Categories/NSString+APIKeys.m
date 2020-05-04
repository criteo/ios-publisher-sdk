//
//  NSString+APIKeys.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "NSString+APIKeys.h"

@implementation NSString (APIKeys)

#pragma mark - General

+ (NSString *)userKey {
    return @"user";
}

+ (NSString *)sdkVersionKey {
    return @"sdkVersion";
}

+ (NSString *)publisherKey {
    return @"publisher";
}

+ (NSString *)profileIdKey {
    return @"profileId";
}

#pragma mark - Publisher

+ (NSString *)bundleIdKey {
    return @"bundleId";
}

+ (NSString *)cpIdKey {
    return @"cpId";
}

#pragma mark - User

+ (NSString *)userAgentKey {
    return @"userAgent";
}

+ (NSString *)deviceIdKey {
    return @"deviceId";
}

+ (NSString *)deviceOsKey {
    return @"deviceOs";
}

+ (NSString *)deviceModelKey {
    return @"deviceModel";
}

+ (NSString *)deviceIdTypeKey {
    return @"deviceIdType";
}

+ (NSString *)deviceIdTypeValue {
    return @"IDFA";
}

#pragma mark - GDPR

+ (NSString *)gdprConsentKey {
    return @"gdprConsent";
}

+ (NSString *)gdprAppliesKey {
    return @"gdprApplies";
}

+ (NSString *)gdprVersionKey {
    return @"version";
}

+ (NSString *)gdprConsentDataKey {
    return @"consentData";
}

#pragma mark - US privacy

+ (NSString *)uspCriteoOptout {
    return @"uspOptout";
}

+ (NSString *)uspIabKey {
    return @"uspIab";
}

+ (NSString *)mopubConsent {
    return @"mopubConsent";
}

@end
