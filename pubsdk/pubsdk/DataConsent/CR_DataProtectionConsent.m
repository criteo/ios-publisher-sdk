//
//  CR_DataProtectionConsent.m
//  pubsdk
//
//  Created by Adwait Kulkarni on 1/23/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <AdSupport/ASIdentifierManager.h>

#import "CR_CCPAConsent.h"
#import "CR_DataProtectionConsent.h"
#import "CR_Gdpr.h"

NSString * const CR_DataProtectionConsentMopubConsentKey = @"MopubConsent_String";

@interface CR_DataProtectionConsent ()

@property (class, nonatomic, strong, readonly) NSArray<NSString *> *mopubConsentDeclinedStrings;

@property (nonatomic, strong, readonly) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readonly) CR_CCPAConsent *ccpaConsent;

@end

@implementation CR_DataProtectionConsent

+ (NSArray<NSString *> *)mopubConsentDeclinedStrings {
    return @[ @"EXPLICIT_NO", @"POTENTIAL_WHITELIST", @"DNT" ];
}

- (instancetype)init {
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
    if(self = [super init]) {
        _userDefaults = userDefaults;
        _ccpaConsent = [[CR_CCPAConsent alloc] initWithUserDefaults:userDefaults];
        _gdpr = [[CR_Gdpr alloc] initWithUserDefaults:userDefaults];
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
    NSString *uppercases = [self.mopubConsent uppercaseString];
    return [self.class.mopubConsentDeclinedStrings containsObject:uppercases];
}

@end
