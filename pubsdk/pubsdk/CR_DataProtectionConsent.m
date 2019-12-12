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

@interface CR_DataProtectionConsent ()

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation CR_DataProtectionConsent;

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

        _usPrivacyIabConsentString = [userDefaults stringForKey:CR_DataProtectionConsentUsPrivacyIabConsentStringKey];
    }
    return self;
}

- (void)setUsPrivacyCriteoState:(CR_UsPrivacyCriteoState)usPrivacyCriteoState
{
    [self.userDefaults setInteger:usPrivacyCriteoState
                           forKey:CR_DataProtectionConsentUsPrivacyCriteoStateKey];
}

- (CR_UsPrivacyCriteoState)usPrivacyCriteoState
{
    return [self.userDefaults integerForKey:CR_DataProtectionConsentUsPrivacyCriteoStateKey];
}


@end
