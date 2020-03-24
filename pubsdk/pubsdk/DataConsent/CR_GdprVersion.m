//
//  CR_Gdpr1_1.m
//  pubsdk
//
//  Created by Romain Lofaso on 3/24/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import "CR_GdprVersion.h"

NSString * const CR_GdprAppliesForTcf2_0Key = @"IABTCF_gdprApplies";
NSString * const CR_GdprConsentStringForTcf2_0Key = @"IABTCF_TCString";
NSString * const CR_GdprVendorConsentsForTcf2_0Key = @"IABTCF_VendorConsents";

NSString * const CR_GdprSubjectToGdprForTcf1_1Key = @"IABConsent_SubjectToGDPR";
NSString * const CR_GdprConsentStringForTcf1_1Key = @"IABConsent_ConsentString";
NSString * const CR_GdprVendorConsentsForTcf1_1Key = @"IABConsent_ParsedVendorConsents";

const NSUInteger CR_GDPRConsentCriteoIdentifierInVendorList = 91;

@interface CR_GdprVersionWithKeys ()

@property (copy, nonatomic, readonly) NSString *consentStringKey;
@property (copy, nonatomic, readonly) NSString *vendorConsentsKey;
@property (copy, nonatomic, readonly) NSString *appliesKey;
@property (strong, nonatomic, readonly) NSUserDefaults *userDefaults;

@property (copy, nonatomic, readonly) NSNumber *appliesObject;
@property (copy, nonatomic, readonly) NSString *vendorConsents;

@end

@implementation CR_GdprVersionWithKeys

@synthesize tcfVersion = _tcfVersion;

+ (instancetype)gdprTcf1_1WithUserDefaults:(NSUserDefaults *)userDefaults {
    return [[self.class alloc] initWithConsentStringKey:CR_GdprConsentStringForTcf1_1Key
                                      vendorConsentsKey:CR_GdprVendorConsentsForTcf1_1Key
                                             appliesKey:CR_GdprSubjectToGdprForTcf1_1Key
                                             tcfVersion:CR_GdprTcfVersion1_1
                                           userDefaults:userDefaults];
}


+ (instancetype)gdprTcf2_0WithUserDefaults:(NSUserDefaults *)userDefaults {
    return [[self.class alloc] initWithConsentStringKey:CR_GdprConsentStringForTcf2_0Key
                                      vendorConsentsKey:CR_GdprVendorConsentsForTcf2_0Key
                                             appliesKey:CR_GdprAppliesForTcf2_0Key
                                             tcfVersion:CR_GdprTcfVersion2_0
                                           userDefaults:userDefaults];
}

#pragma mark - Life cycle

- (instancetype)initWithConsentStringKey:(NSString *)constantStringKey
                       vendorConsentsKey:(NSString *)vendorConsentsKey
                              appliesKey:(NSString *)appliesKey
                              tcfVersion:(CR_GdprTcfVersion)tcfVersion
                            userDefaults:(NSUserDefaults *)userDefaults {
    if (self = [super init]) {
        _consentStringKey = [constantStringKey copy];
        _vendorConsentsKey = [vendorConsentsKey copy];
        _appliesKey = [appliesKey copy];
        _userDefaults = userDefaults;
        _tcfVersion = tcfVersion;
    }
    return self;
}

#pragma mark - Properties

- (BOOL)isValid {
    return  (self.consentString != nil) ||
            (self.appliesObject != nil) ||
            (self.vendorConsents != nil);
}

- (NSString *)consentString {
    return [self.userDefaults stringForKey:self.consentStringKey];
}

- (BOOL)applies {
    return [self.appliesObject boolValue];
}

- (BOOL)consentGivenToCriteo {
    NSString *vendorConsents = self.vendorConsents;
    const NSUInteger criteoId = CR_GDPRConsentCriteoIdentifierInVendorList;
    const NSUInteger criteoIndex = criteoId - 1;
    return  (vendorConsents.length > criteoIndex) &&
            ([vendorConsents characterAtIndex:criteoIndex] == '1');
}

#pragma mark - Private

- (NSNumber *)appliesObject {
    NSNumber *number = [self.userDefaults objectForKey:self.appliesKey];
    return [number isKindOfClass:NSNumber.class] ? number : nil;
}

- (NSString *)vendorConsents {
    return [self.userDefaults stringForKey:self.vendorConsentsKey];
}

@end

@implementation CR_NoGdpr

- (BOOL)isValid {
    return YES;
}

- (CR_GdprTcfVersion)tcfVersion {
    return CR_GdprTcfVersionUnknown;
}

- (NSString *)consentString {
    return nil;
}

- (BOOL)applies {
    return YES;
}

- (BOOL)consentGivenToCriteo {
    return NO;
}

@end
