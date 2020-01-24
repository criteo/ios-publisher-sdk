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
 Specification for the GDPR in IAB:
 https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Mobile%20In-App%20Consent%20APIs%20v1.0%20Final.md#structure
 */

NSString * const CR_DataProtectionConsentMopubConsentKey = @"MopubConsent_String";


@interface CR_DataProtectionConsent ()

@property (class, nonatomic, strong, readonly) NSArray<NSString *> *mopubConsentDeclinedStrings;

@property (nonatomic, strong, readonly) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readonly) CR_CCPAConsent *ccpaConsent;


@end

@implementation CR_DataProtectionConsent

+ (NSArray<NSString *> *)mopubConsentDeclinedStrings {
    return @[ @"EXPLICIT_NO", @"POTENTIAL_WHITELIST", @"DNT"];
}

- (instancetype)init {
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
    if(self = [super init]) {
        _userDefaults = userDefaults;
        _ccpaConsent = [[CR_CCPAConsent alloc] initWithUserDefaults:userDefaults];
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

- (NSString *)usPrivacyIabConsentString {
    return self.ccpaConsent.iabConsentString;
}

- (void)setUsPrivacyCriteoState:(CR_CCPACriteoState)usPrivacyCriteoState {
    self.ccpaConsent.criteoState = usPrivacyCriteoState;
}

- (CR_CCPACriteoState)usPrivacyCriteoState {
    return self.ccpaConsent.criteoState;
}

- (BOOL)shouldSendAppEvent {
    if ([self _isMopubConsentDeclined]) {
        return NO;
    }
    return self.ccpaConsent.isOptIn;
}

- (void)setMopubConsent:(NSString *)mopubConsent {
    [self.userDefaults setObject:mopubConsent
                          forKey:CR_DataProtectionConsentMopubConsentKey];
}

- (NSString *)mopubConsent {
    return [self.userDefaults objectForKey:CR_DataProtectionConsentMopubConsentKey];
}

- (BOOL)_isMopubConsentDeclined {
    return [self.class.mopubConsentDeclinedStrings containsObject:self.mopubConsent];
}

@end
