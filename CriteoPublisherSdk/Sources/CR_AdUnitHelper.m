//
//  CR_AdUnitHelper.m
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

#import "CR_AdUnitHelper.h"
#import "CRBannerAdUnit.h"
#import "CRAdUnit+Internal.h"
#import "CR_DeviceInfo.h"
#import "CR_Logging.h"
#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CR_DependencyProvider.h"
#import "CR_IntegrationRegistry.h"

@implementation CR_AdUnitHelper

static const CGSize nativeSize = {2.0, 2.0};

// return an array of cacheAdUnits
+ (CR_CacheAdUnitArray *)cacheAdUnitsForAdUnits:(NSArray<CRAdUnit *> *)adUnits {
  NSMutableArray<CR_CacheAdUnit *> *cacheAdUnits = [NSMutableArray new];
  for (int i = 0; i < [adUnits count]; i++) {
    CR_CacheAdUnit *unit = [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnits[i]];
    if (unit != nil) {
      [cacheAdUnits addObject:unit];
    }
  }
  return [cacheAdUnits copy];
}

+ (CR_CacheAdUnit *)cacheAdUnitForAdUnit:(CRAdUnit *)adUnit {
  switch ([adUnit adUnitType]) {
    case CRAdUnitTypeBanner:
      return [[CR_CacheAdUnit alloc] initWithAdUnitId:[adUnit adUnitId]
                                                 size:[(CRBannerAdUnit *)adUnit size]
                                           adUnitType:CRAdUnitTypeBanner];
    case CRAdUnitTypeInterstitial:
      return [CR_CacheAdUnit cacheAdUnitForInterstialWithAdUnitId:adUnit.adUnitId
                                                             size:self.deviceInfo.screenSize];
    case CRAdUnitTypeNative:
      return [[CR_CacheAdUnit alloc] initWithAdUnitId:adUnit.adUnitId
                                                 size:nativeSize
                                           adUnitType:CRAdUnitTypeNative];
    case CRAdUnitTypeRewarded:
      if (![self.integrationRegistry.profileId isEqual:@(CR_IntegrationGamAppBidding)]) {
        CRLogWarn(@"Bidding", @"RewardedAdUnit %@ can only be used with GAM app bidding",
                  [adUnit adUnitId]);
        return nil;
      }
      return [[CR_CacheAdUnit alloc] initWithAdUnitId:adUnit.adUnitId
                                                 size:self.deviceInfo.screenSize
                                           adUnitType:CRAdUnitTypeRewarded];
    default:
      CRLogWarn(@"AdUnit", @"Unexpected AdUnitType %@", adUnit);
      return nil;
  }
}

#pragma - Private
// TODO inject these dependencies instead of accessing it statically (see DPP-3734)

+ (CR_DeviceInfo *)deviceInfo {
  return Criteo.sharedCriteo.dependencyProvider.deviceInfo;
}

+ (CR_IntegrationRegistry *)integrationRegistry {
  return Criteo.sharedCriteo.dependencyProvider.integrationRegistry;
}

@end
