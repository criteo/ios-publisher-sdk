//
//  CMPDataStorageUserDefaults.m
//  GDPR
//

#import "CR_SPTIabTCFv1StorageUserDefaults.h"

NSString *const SPT_IABConsent_SubjectToGDPRKey = @"IABConsent_SubjectToGDPR";
NSString *const SPT_IABConsent_ConsentStringKey = @"IABConsent_ConsentString";
NSString *const SPT_IABConsent_ParsedVendorConsentsKey = @"IABConsent_ParsedVendorConsents";
NSString *const SPT_IABConsent_ParsedPurposeConsentsKey = @"IABConsent_ParsedPurposeConsents";
NSString *const SPT_IABConsent_CMPPresentKey = @"IABConsent_CMPPresent";

@implementation CR_SPTIabTCFv1StorageUserDefaults

@synthesize consentString;
@synthesize subjectToGDPR;
@synthesize cmpPresent;
@synthesize parsedVendorConsents;
@synthesize parsedPurposeConsents;

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
                                              @"", SPT_IABConsent_ConsentStringKey,
                                              @"", SPT_IABConsent_ParsedVendorConsentsKey,
                                              @"", SPT_IABConsent_ParsedPurposeConsentsKey,
                                              [NSNumber numberWithBool:NO], SPT_IABConsent_CMPPresentKey,
                                              nil];
    [_userDefaults registerDefaults:dataStorageDefaultValues];
}

+(NSString*)keyIABConsentString {
    return SPT_IABConsent_ConsentStringKey;
}

-(NSString *)consentString {
    return [self.userDefaults objectForKey:SPT_IABConsent_ConsentStringKey];
}

-(void)setConsentString:(NSString *)consentString{
    [self.userDefaults setObject:consentString forKey:SPT_IABConsent_ConsentStringKey];
    [self.userDefaults synchronize];
}

-(SubjectToGDPR)subjectToGDPR {
    NSString *subjectToGDPRAsString = [self.userDefaults objectForKey:SPT_IABConsent_SubjectToGDPRKey];
    
    if (subjectToGDPRAsString != nil) {
        if ([subjectToGDPRAsString isEqualToString:@"0"]) {
            return SubjectToGDPR_No;
        } else if ([subjectToGDPRAsString isEqualToString:@"1"]) {
            return SubjectToGDPR_Yes;
        } else {
            return SubjectToGDPR_Unknown;
        }
    } else {
        return SubjectToGDPR_Unknown;
    }
}

-(void)setSubjectToGDPR:(SubjectToGDPR)subjectToGDPR {
    NSString *subjectToGDPRAsString = nil;

    if (subjectToGDPR == SubjectToGDPR_No || subjectToGDPR == SubjectToGDPR_Yes) {
        subjectToGDPRAsString = [NSString stringWithFormat:@"%li", (long)subjectToGDPR];
    }
    
    [self.userDefaults setObject:subjectToGDPRAsString forKey:SPT_IABConsent_SubjectToGDPRKey];
    [self.userDefaults synchronize];
}

-(BOOL)cmpPresent {
    return [[self.userDefaults objectForKey:SPT_IABConsent_CMPPresentKey] boolValue];
}

-(void)setCmpPresent:(BOOL)cmpPresent {
    [self.userDefaults setBool:cmpPresent forKey:SPT_IABConsent_CMPPresentKey];
    [self.userDefaults synchronize];
}

-(NSString *)parsedVendorConsents {
    return [self.userDefaults objectForKey:SPT_IABConsent_ParsedVendorConsentsKey];
}

-(void)setParsedVendorConsents:(NSString *)parsedVendorConsents {
    [self.userDefaults setObject:parsedVendorConsents forKey:SPT_IABConsent_ParsedVendorConsentsKey];
    [self.userDefaults synchronize];
}

-(NSString *)parsedPurposeConsents {
    return [self.userDefaults objectForKey:SPT_IABConsent_ParsedPurposeConsentsKey];
}

-(void)setParsedPurposeConsents:(NSString *)parsedPurposeConsents {
    [self.userDefaults setObject:parsedPurposeConsents forKey:SPT_IABConsent_ParsedPurposeConsentsKey];
    [self.userDefaults synchronize];
}

@end
