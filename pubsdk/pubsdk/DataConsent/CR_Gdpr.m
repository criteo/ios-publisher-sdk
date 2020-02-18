//
//  CR_Gdpr.m
//  pubsdk
//
//  Created by Romain Lofaso on 2/18/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_Gdpr.h"

NSString * const CR_GdprAppliesForTcf2_0Key = @"IABTCF_gdprApplies";
NSString * const CR_GdprConsentStringForTcf2_0Key = @"IABTCF_TCString";
NSString * const CR_GdprVendorConsentsForTcf2_0Key = @"IABTCF_VendorConsents";

NSString * const CR_GdprSubjectToGdprForTcf1_1Key = @"IABConsent_SubjectToGDPR";
NSString * const CR_GdprConsentStringForTcf1_1Key = @"IABConsent_ConsentString";
NSString * const CR_GdprVendorConsentsForTcf1_1Key = @"IABConsent_ParsedVendorConsents";

const NSUInteger CR_GDPRConsentCriteoIdentifierInVendorList = 91;

@interface CR_Gdpr ()

@property (nonatomic, strong, readonly) NSUserDefaults *userDefaults;

@property (nonatomic, copy, readonly) NSString *consentStringV1;
@property (nonatomic, copy, readonly) NSString *consentStringV2;

@end

@implementation CR_Gdpr

#pragma mark - Lifecycle

- (instancetype)init {
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
    if (self = [super init]) {
        _userDefaults = userDefaults;
    }
    return self;
}

#pragma mark - Custom Accessors

- (CR_GdprTcfVersion)tcfVersion {
    if (self.consentStringV2 != nil) {
        return CR_GdprTcfVersion2_0;
    } else if (self.consentStringV1 != nil) {
        return CR_GdprTcfVersion1_1;
    } else {
        return CR_GdprTcfVersionUnknown;
    }
}

- (NSString *)consentString {
    return self.consentStringV2 ?: self.consentStringV1;
}

- (BOOL)isApplied {
    NSString *key = (self.tcfVersion == 2) ? CR_GdprAppliesForTcf2_0Key : CR_GdprSubjectToGdprForTcf1_1Key;
    return [self.userDefaults boolForKey:key];
}

- (BOOL)consentGivenToCriteo {
    NSString *key = (self.tcfVersion == 2) ? CR_GdprVendorConsentsForTcf2_0Key : CR_GdprVendorConsentsForTcf1_1Key;
    NSString *vendorConsents = [self.userDefaults stringForKey:key];
    const NSUInteger criteoId = CR_GDPRConsentCriteoIdentifierInVendorList;
    const NSUInteger criteoIndex = criteoId - 1;
    return  (vendorConsents.length > criteoIndex) &&
            ([vendorConsents characterAtIndex:criteoIndex] == '1');
}

#pragma mark - Private

- (NSString *)consentStringV1 {
    return [self.userDefaults stringForKey:CR_GdprConsentStringForTcf1_1Key];
}

- (NSString *)consentStringV2 {
    return [self.userDefaults stringForKey:CR_GdprConsentStringForTcf2_0Key];
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:
            @"<%@: %p, tcfVersion: %ld, isApplied: %d, consentString: %@, consentGivenToCriteo: %d >",
            NSStringFromClass(self.class),
            self,
            (long)self.tcfVersion,
            self.isApplied,
            self.consentString,
            self.consentGivenToCriteo
            ];
}

@end
