//
//  CR_DataProtectionConsent.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 1/23/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_DataProtectionConsent.h"
#import <AdSupport/ASIdentifierManager.h>

/**
 Specification for the US Privacy in IAB:
 https://iabtechlab.com/wp-content/uploads/2019/11/U.S.-Privacy-String-v1.0-IAB-Tech-Lab.pdf
 */

/**
 Specification for the GDPR in IAB:
 https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Mobile%20In-App%20Consent%20APIs%20v1.0%20Final.md#structure
 */

NSString * const CR_DataProtectionConsentUsPrivacyIabConsentStringKey = @"IABUSPrivacy_String";
NSString * const CR_DataProtectionConsentUsPrivacyCriteoStateKey = @"CriteoUSPrivacy_Bool";
NSString * const CR_DataProtectionConsentMopubConsentKey = @"MopubConsent_String";

@interface CR_DataProtectionConsent ()

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation CR_DataProtectionConsent

- (instancetype)init
{
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
{
    if(self = [super init]) {
        _userDefaults = userDefaults;
        _gdprApplies = [userDefaults boolForKey:@"IABConsent_SubjectToGDPR"];
        _consentString = [userDefaults stringForKey:@"IABConsent_ConsentString"];
        // set to default
        _consentGiven = NO;
        NSString *vendorConsents = [userDefaults stringForKey:@"IABConsent_ParsedVendorConsents"];
        // Criteo is vendor id 91
        if(vendorConsents.length >= 91 && [vendorConsents characterAtIndex:90] == '1') {
            _consentGiven = YES;
        }
        _isAdTrackingEnabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    }
    return self;
}

- (NSString *)usPrivacyIabConsentString
{
    return [self.userDefaults stringForKey:CR_DataProtectionConsentUsPrivacyIabConsentStringKey];
}

- (void)setUsPrivacyCriteoState:(CR_UsPrivacyCriteoState)usPrivacyCriteoState
{
    [self.userDefaults setInteger:usPrivacyCriteoState
                           forKey:CR_DataProtectionConsentUsPrivacyCriteoStateKey];
}

- (void)setMopubConsent:(NSString *)mopubConsent {
    [self.userDefaults setObject:mopubConsent
                          forKey:CR_DataProtectionConsentMopubConsentKey];
}

- (NSString *)mopubConsent {
    return [self.userDefaults objectForKey:CR_DataProtectionConsentMopubConsentKey];
}

- (CR_UsPrivacyCriteoState)usPrivacyCriteoState
{
    return [self.userDefaults integerForKey:CR_DataProtectionConsentUsPrivacyCriteoStateKey];
}

- (BOOL)shouldSendAppEvent
{
    if (self.usPrivacyIabConsentString.length > 0) {
        return [self _isUSPrivacyConsentStringOptIn];
    }
    return [self _isUsPrivacyCriteoOptIn];
}

- (BOOL)_isUsPrivacyCriteoOptIn
{
    return  (self.usPrivacyCriteoState == CR_UsPrivacyCriteoStateOptIn) ||
            (self.usPrivacyCriteoState == CR_UsPrivacyCriteoStateUnset);
}

- (BOOL)_isUSPrivacyConsentStringOptIn
{
    NSError *error = NULL;
    NSString *pattern = @"1(Y|N|-){3}";
    NSString *consentString = [self.usPrivacyIabConsentString uppercaseString];
    if (consentString.length == 0) return YES;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:&error];
    NSAssert(!error, @"Error occured for the given regexp %@: %@", pattern, error);
    if (error) return NO; // if our regexp isn't right, we opt out.
    const NSRange range = NSMakeRange(0, [consentString length]);
    NSArray* matches = [regex matchesInString:consentString
                                      options:0
                                        range:range];
    if (matches.count != 1) return YES;
    // According to the matrix specified here:
    // https://confluence.criteois.com/display/PP/CCPA+Buying+Policy?focusedCommentId=532758801#comment-532758801
    return  [consentString isEqualToString:@"1YNN"] ||
            [consentString isEqualToString:@"1YNY"] ||
            [consentString isEqualToString:@"1---"];
}


@end
