//
//  CR_DataProtectionConsent.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <AdSupport/ASIdentifierManager.h>

#import "CR_Ccpa.h"
#import "CR_DataProtectionConsent.h"
#import "CR_Gdpr.h"

NSString * const CR_DataProtectionConsentMopubConsentKey = @"MopubConsent_String";

@interface CR_DataProtectionConsent ()

@property (class, nonatomic, strong, readonly) NSArray<NSString *> *mopubConsentDeclinedStrings;

@property (nonatomic, strong, readonly) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readonly) CR_Ccpa *ccpa;

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
        _ccpa = [[CR_Ccpa alloc] initWithUserDefaults:userDefaults];
        _gdpr = [[CR_Gdpr alloc] initWithUserDefaults:userDefaults];
#if TARGET_OS_SIMULATOR
        _isAdTrackingEnabled = YES;
#else
        _isAdTrackingEnabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
#endif
    }
    return self;
}

- (NSString *)usPrivacyIabConsentString {
    return self.ccpa.iabConsentString;
}

- (void)setUsPrivacyCriteoState:(CR_CcpaCriteoState)usPrivacyCriteoState {
    self.ccpa.criteoState = usPrivacyCriteoState;
}

- (CR_CcpaCriteoState)usPrivacyCriteoState {
    return self.ccpa.criteoState;
}

- (BOOL)shouldSendAppEvent {
    if ([self _isMopubConsentDeclined]) {
        return NO;
    }
    return self.ccpa.isOptIn;
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
