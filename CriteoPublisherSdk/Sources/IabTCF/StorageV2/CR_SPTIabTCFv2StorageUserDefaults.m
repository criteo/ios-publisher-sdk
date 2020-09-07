//
//  CMPDataStorageUserDefaults.m
//  GDPR
//

#import "CR_SPTIabTCFv2StorageUserDefaults.h"

NSString *const SPT_IABTCF_CmpSdkID = @"IABTCF_CmpSdkID";
NSString *const SPT_IABTCF_CmpSdkVersion = @"IABTCF_CmpSdkVersion";
NSString *const SPT_IABTCF_PolicyVersion = @"IABTCF_PolicyVersion";
NSString *const SPT_IABTCF_gdprApplies = @"IABTCF_gdprApplies";
NSString *const SPT_IABTCF_PublisherCC = @"IABTCF_PublisherCC";
NSString *const SPT_IABTCF_PurposeOneTreatment = @"IABTCF_PurposeOneTreatment";
NSString *const SPT_IABTCF_UseNonStandardStacks = @"IABTCF_UseNonStandardStacks";
NSString *const SPT_IABTCF_TCString = @"IABTCF_TCString";
NSString *const SPT_IABTCF_VendorConsents = @"IABTCF_VendorConsents";
NSString *const SPT_IABTCF_VendorLegitimateInterests = @"IABTCF_VendorLegitimateInterests";
NSString *const SPT_IABTCF_PurposeConsents = @"IABTCF_PurposeConsents";
NSString *const SPT_IABTCF_PurposeLegitimateInterests = @"IABTCF_PurposeLegitimateInterests";
NSString *const SPT_IABTCF_SpecialFeaturesOptIns = @"IABTCF_SpecialFeaturesOptIns";
NSString *const SPT_IABTCF_PublisherRestrictions = @"IABTCF_PublisherRestrictions";
NSString *const SPT_IABTCF_PublisherConsent = @"IABTCF_PublisherConsent";
NSString *const SPT_IABTCF_PublisherLegitimateInterests = @"IABTCF_PublisherLegitimateInterests";
NSString *const SPT_IABTCF_PublisherCustomPurposesConsents = @"IABTCF_PublisherCustomPurposesConsents";
NSString *const SPT_IABTCF_PublisherCustomPurposesLegitimateInterests = @"IABTCF_PublisherCustomPurposesLegitimateInterests";

@implementation CR_SPTIabTCFv2StorageUserDefaults

@synthesize cmpSdkId;
@synthesize cmpSdkVersion;
@synthesize policyVersion;
@synthesize publisherCountryCode;
@synthesize purposeOneTreatment;
@synthesize useNonStandardStack;
@synthesize isServiceSpecific;

@synthesize tcString;

@synthesize parsedVendorsConsents;
@synthesize parsedVendorsLegitmateInterest;
@synthesize parsedPurposesConsents;
@synthesize parsedPurposesLegitmateInterest;

@synthesize specialFeatureOptIns;

@synthesize publisherTCParsedPurposesConsents;
@synthesize publisherTCParsedPurposesLegitmateInterest;
@synthesize publisherTCParsedCustomPurposesConsents;
@synthesize publisherTCParsedCustomPurposesLegitmateInterest;

/*
 * Test method for uncoupling userDefaults
 */
- (instancetype)initWithUserDefault:(NSUserDefaults *)userDefs
{
    self = [super init];
    if (self) {
        _userDefaults = userDefs;
        [self registerDefaultUserDefault];
    }
    return self;
}
// **************************************************************

- (NSUserDefaults *)userDefaults {
    if (!_userDefaults) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        [self registerDefaultUserDefault];

    }
    return _userDefaults;
}

- (void) registerDefaultUserDefault {
    NSDictionary *dataStorageDefaultValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                              
                                              [NSNumber numberWithInteger:-1], SPT_IABTCF_gdprApplies,
                                              @"AA", SPT_IABTCF_PublisherCC,
                                              [NSNumber numberWithInteger:0], SPT_IABTCF_PurposeOneTreatment,
                                              @"", SPT_IABTCF_TCString,
                                              
                                              @"", SPT_IABTCF_VendorConsents,
                                              @"", SPT_IABTCF_VendorLegitimateInterests,
                                              @"", SPT_IABTCF_PurposeConsents,
                                              @"", SPT_IABTCF_PurposeLegitimateInterests,
                                              @"", SPT_IABTCF_SpecialFeaturesOptIns,
                                              @"", SPT_IABTCF_PublisherConsent,
                                              @"", SPT_IABTCF_PublisherLegitimateInterests,
                                              @"", SPT_IABTCF_PublisherCustomPurposesConsents,
                                              @"", SPT_IABTCF_PublisherCustomPurposesLegitimateInterests,
                                              
                                              nil];
    [_userDefaults registerDefaults:dataStorageDefaultValues];
}


- (NSString *)tcString {
    return [self.userDefaults objectForKey:SPT_IABTCF_TCString];
}

- (void)setTcString:(NSString *)tcString{
    [self.userDefaults setObject:tcString forKey:SPT_IABTCF_TCString];
    [self.userDefaults synchronize];
}

- (GdprApplies)gdprApplies {
    NSString *gdprAppliesAsString = [self.userDefaults objectForKey:SPT_IABTCF_gdprApplies];
    
    if (gdprAppliesAsString != nil) {
        if ([gdprAppliesAsString isEqualToString:@"0"]) {
            return GdprApplies_No;
        } else if ([gdprAppliesAsString isEqualToString:@"1"]) {
            return GdprApplies_Yes;
        } else {
            return GdprApplies_Unset;
        }
    } else {
        return GdprApplies_Unset;
    }
}

- (void)setGdprApplies:(GdprApplies)gdprApplies {
    NSString *gdprAppliesAsString = nil;

    if (gdprApplies == GdprApplies_No || gdprApplies == GdprApplies_Yes) {
        gdprAppliesAsString = [NSString stringWithFormat:@"%li", (long)gdprApplies];
    }
    
    [self.userDefaults setObject:gdprAppliesAsString forKey:SPT_IABTCF_gdprApplies];
    [self.userDefaults synchronize];
}



- (NSString *)parsedVendorConsents {
    return [self.userDefaults objectForKey:SPT_IABTCF_VendorConsents];
}

- (void)setParsedVendorConsents:(NSString *)parsedVendorConsents {
    [self.userDefaults setObject:parsedVendorConsents forKey:SPT_IABTCF_VendorConsents];
    [self.userDefaults synchronize];
}

- (NSString *)parsedVendorsLegitmateInterest {
    return [self.userDefaults objectForKey:SPT_IABTCF_VendorLegitimateInterests];
}

- (void)setParsedVendorsLegitmateInterest:(NSString *)parsedVendorsLegitmateInterest {
    [self.userDefaults setObject:parsedVendorsLegitmateInterest forKey:SPT_IABTCF_VendorLegitimateInterests];
    [self.userDefaults synchronize];
}

-(NSString *)parsedPurposeConsents {
    return [self.userDefaults objectForKey:SPT_IABTCF_PurposeConsents];
}

-(void)setParsedPurposeConsents:(NSString *)parsedPurposeConsents {
    [self.userDefaults setObject:parsedPurposeConsents forKey:SPT_IABTCF_PurposeConsents];
    [self.userDefaults synchronize];
}

- (NSString *)parsedPurposesLegitmateInterest {
    return [self.userDefaults objectForKey:SPT_IABTCF_PurposeLegitimateInterests];
}

- (void)setParsedPurposesLegitmateInterest:(NSString *)parsedPurposesLegitmateInterest {
    [self.userDefaults setObject:parsedPurposesLegitmateInterest forKey:SPT_IABTCF_PurposeLegitimateInterests];
    [self.userDefaults synchronize];
}

- (NSString *)specialFeatureOptIns {
    return [self.userDefaults objectForKey:SPT_IABTCF_SpecialFeaturesOptIns];
}

- (void)setSpecialFeatureOptIns:(NSString *)specialFeatureOptIns {
    [self.userDefaults setObject:specialFeatureOptIns forKey:SPT_IABTCF_SpecialFeaturesOptIns];
    [self.userDefaults synchronize];
}

- (NSString *)publisherTCParsedPurposesConsents {
    return [self.userDefaults objectForKey:SPT_IABTCF_PublisherConsent];
}

- (void)setPublisherTCParsedPurposesConsents:(NSString *)publisherTCParsedPurposesConsents {
    [self.userDefaults setObject:publisherTCParsedPurposesConsents forKey:SPT_IABTCF_PublisherConsent];
    [self.userDefaults synchronize];
}

- (NSString *)publisherTCParsedPurposesLegitmateInterest {
    return [self.userDefaults objectForKey:SPT_IABTCF_PublisherLegitimateInterests];
}

- (void)setPublisherTCParsedPurposesLegitmateInterest:(NSString *)publisherTCParsedPurposesLegitmateInterest {
    [self.userDefaults setObject:publisherTCParsedPurposesLegitmateInterest forKey:SPT_IABTCF_PublisherLegitimateInterests];
    [self.userDefaults synchronize];
}

- (NSString *)publisherTCParsedCustomPurposesConsents {
    return [self.userDefaults objectForKey:SPT_IABTCF_PublisherCustomPurposesConsents];
}

- (void)setPublisherTCParsedCustomPurposesConsents:(NSString *)publisherTCParsedCustomPurposesConsents {
    [self.userDefaults setObject:publisherTCParsedCustomPurposesConsents forKey:SPT_IABTCF_PublisherCustomPurposesConsents];
    [self.userDefaults synchronize];
}

- (NSString *)publisherTCParsedCustomPurposesLegitmateInterest {
    return [self.userDefaults objectForKey:SPT_IABTCF_PublisherCustomPurposesLegitimateInterests];
}

- (void)setPublisherTCParsedCustomPurposesLegitmateInterest:(NSString *)publisherTCParsedCustomPurposesLegitmateInterest {
    [self.userDefaults setObject:publisherTCParsedCustomPurposesLegitmateInterest forKey:SPT_IABTCF_PublisherCustomPurposesLegitimateInterests];
    [self.userDefaults synchronize];
}


- (NSString *)publisherRestrictionsForPurposeId:(NSInteger)purposeId {
    NSString *key = [NSString stringWithFormat:@"%@%ld", SPT_IABTCF_PublisherRestrictions, (long)purposeId];
    return [self.userDefaults objectForKey:key];
}


- (void)setPublisherRestrictions:(NSString *)publisherRestriction ForPurposeId:(NSInteger)purposeId {
    NSString *key = [NSString stringWithFormat:@"%@%ld", SPT_IABTCF_PublisherRestrictions, (long)purposeId];
    [self.userDefaults setObject:publisherRestriction forKey:key];
    [self.userDefaults synchronize];
}

@end
