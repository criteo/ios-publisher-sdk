//
//  CR_DataProtectionConsentMock.m
//  CriteoPublisherSdkTests
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

#import "CR_DataProtectionConsentMock.h"
#import "CriteoPublisherSdkTests-Swift.h"

NSString *const CR_DataProtectionConsentMockDefaultConsentString =
    @"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA";
NSString *const CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString = @"1YNN";

@interface CR_DataProtectionConsentMock ()

@property(nonatomic, copy, nullable) NSString *mopubConsent_mock;
@property(nonatomic, assign) CR_CcpaCriteoState criteoState_mock;

@end

@implementation CR_DataProtectionConsentMock

- (instancetype)init {
  self = [super init];
  if (self) {
    _gdprMock = [[CR_GdprMock alloc] init];
    self.usPrivacyIabConsentString_mock =
        CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString;
    self.isAdTrackingEnabled_mock = YES;
  }
  return self;
}

- (CR_Gdpr *)gdpr {
  return self.gdprMock;
}

- (BOOL)isAdTrackingEnabled {
  return self.isAdTrackingEnabled_mock;
}

- (NSNumber *)trackingAuthorizationStatus {
  return self.trackingAuthorizationStatus_mock;
}

- (NSString *)usPrivacyIabConsentString {
  return self.usPrivacyIabConsentString_mock;
}

#pragma mark - Override for avoiding NSUserDefaults

- (NSString *)mopubConsent {
  return self.mopubConsent_mock;
}

- (void)setMopubConsent:(NSString *)mopubConsent {
  self.mopubConsent_mock = mopubConsent;
}

- (CR_CcpaCriteoState)usPrivacyCriteoState {
  return self.criteoState_mock;
}

- (void)setUsPrivacyCriteoState:(CR_CcpaCriteoState)usPrivacyCriteoState {
  self.criteoState_mock = usPrivacyCriteoState;
}

@end
