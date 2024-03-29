//
//  CR_DataProtectionConsent.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <AppTrackingTransparency/AppTrackingTransparency.h>

#import "CR_Ccpa.h"
#import "CR_DataProtectionConsent.h"
#import "CR_Gdpr.h"
#import "CR_Logging.h"
#import "NSUserDefaults+Criteo.h"

NSString *const CR_DataProtectionConsentGivenKey = @"CRITEO_ConsentGiven";

@interface CR_DataProtectionConsent ()

@property(nonatomic, strong, readonly) NSUserDefaults *userDefaults;
@property(nonatomic, strong, readonly) CR_Ccpa *ccpa;
@property(nonatomic, assign) BOOL userDefaultForConsentGiven;

@end

@implementation CR_DataProtectionConsent

- (instancetype)init {
  return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
  if (self = [super init]) {
    _userDefaults = userDefaults;
    _ccpa = [[CR_Ccpa alloc] initWithUserDefaults:userDefaults];
    _consentGiven = self.userDefaultForConsentGiven;
  }
  return self;
}

- (CR_Gdpr *)gdpr {
  return [[CR_Gdpr alloc] initWithUserDefaults:_userDefaults];
}

- (NSNumber *)trackingAuthorizationStatus {
  if (@available(iOS 14.0, *)) {
    return @(ATTrackingManager.trackingAuthorizationStatus);
  }
  return nil;
}

- (NSString *)usPrivacyIabConsentString {
  return self.ccpa.iabConsentString;
}

- (void)setUsPrivacyCriteoState:(CR_CcpaCriteoState)usPrivacyCriteoState {
  self.ccpa.criteoState = usPrivacyCriteoState;
  CRLogInfo(@"Consent", @"CCPA setUsPrivacyCriteoState: %d", usPrivacyCriteoState);
}

- (CR_CcpaCriteoState)usPrivacyCriteoState {
  return self.ccpa.criteoState;
}

- (BOOL)shouldSendAppEvent {
  return self.ccpa.isOptIn;
}

#pragma mark Consent given

- (void)setConsentGiven:(BOOL)consentGiven {
  _consentGiven = consentGiven;
  self.userDefaultForConsentGiven = consentGiven;
}

- (BOOL)userDefaultForConsentGiven {
  return [self.userDefaults boolForKey:CR_DataProtectionConsentGivenKey withDefaultValue:NO];
}

- (void)setUserDefaultForConsentGiven:(BOOL)consentGiven {
  [self.userDefaults setBool:consentGiven forKey:CR_DataProtectionConsentGivenKey];
}

@end
