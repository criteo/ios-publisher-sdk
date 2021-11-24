//
//  CR_IntegrationRegistry.m
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

#import "CR_IntegrationRegistry.h"
#import "CR_Logging.h"

NSString *const NSUserDefaultsIntegrationKey = @"CRITEO_ProfileId";

@interface CR_IntegrationRegistry ()

@property(nonatomic, strong, readonly) NSUserDefaults *userDefaults;
@property(nonatomic, readonly) BOOL isMoPubMediationPresent;
@property(nonatomic, readonly) BOOL isAdMobMediationPresent;

@end

@implementation CR_IntegrationRegistry

- (instancetype)init {
  return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
  if (self = [super init]) {
    _userDefaults = userDefaults;
  }
  return self;
}

- (void)declare:(CR_IntegrationType)integrationType {
  [self.userDefaults setInteger:integrationType forKey:NSUserDefaultsIntegrationKey];
}

- (NSNumber *)profileId {
  if (self.isMoPubMediationPresent && self.isAdMobMediationPresent) {
    return @(CR_IntegrationFallback);
  } else if (self.isMoPubMediationPresent) {
    return @(CR_IntegrationMopubMediation);
  } else if (self.isAdMobMediationPresent) {
    return @(CR_IntegrationAdmobMediation);
  }

  NSInteger profileId = [self.userDefaults integerForKey:NSUserDefaultsIntegrationKey];
  switch (profileId) {
    case CR_IntegrationStandalone:
    case CR_IntegrationInHouse:
    case CR_IntegrationAdmobMediation:
    case CR_IntegrationMopubMediation:
    case CR_IntegrationMopubAppBidding:
    case CR_IntegrationGamAppBidding:
    case CR_IntegrationCustomAppBidding:
      return @(profileId);
    default:
      return @(CR_IntegrationFallback);
  }
}

- (BOOL)isMoPubMediationPresent {
  return NSClassFromString(@"CRBannerCustomEvent") != nil &&
         NSProtocolFromString(@"MPThirdPartyInlineAdAdapter") != nil;
}

- (BOOL)isAdMobMediationPresent {
  return NSClassFromString(@"CRBannerCustomEvent") != nil &&
         NSProtocolFromString(@"GADCustomEventBanner") != nil;
}

- (CR_CacheAdUnitArray *)keepSupportedAdUnits:(CR_CacheAdUnitArray *)units {
  return [units
      filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id _Nullable adUnit,
                                                                        NSDictionary<NSString *, id>
                                                                            *_Nullable bindings) {
        // Rewarded ad units are only supported for GAM app bidding (DPP-3644)
        if ([adUnit adUnitType] == CRAdUnitTypeRewarded &&
            ![self.profileId isEqual:@(CR_IntegrationGamAppBidding)]) {
          CRLogWarn(@"Bidding", @"RewardedAdUnit %@ can only be used with GAM app bidding",
                    [adUnit adUnitId]);
          return NO;
        }

        return YES;
      }]];
}
@end
