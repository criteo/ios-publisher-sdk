//
//  NSString+APIKeys.m
//  pubsdk
//
//  Created by Romain Lofaso on 3/23/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "NSString+APIKeys.h"

@implementation NSString (APIKeys)

#pragma mark - General

+ (NSString *)userKey {
    return @"user";
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

+ (NSString *)gdprConsentGivenKey {
    return @"consentGiven";
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
