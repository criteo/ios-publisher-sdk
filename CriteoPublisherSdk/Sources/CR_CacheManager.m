//
//  CR_CacheManager.m
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

#import "CR_CacheManager.h"
#import "Logging.h"
#import "CR_DeviceInfo.h"

@implementation CR_CacheManager

- (instancetype)init {
  if (self = [super init]) {
    _bidCache = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)initSlots:(NSArray *)slots {
  for (CR_CacheAdUnit *slot in slots) {
    _bidCache[slot] = [CR_CdbBid emptyBid];
  }
}

- (CRAdUnitType)adUnitTypeFromBid:(CR_CdbBid *)bid {
  if (bid.nativeAssets) {
    return CRAdUnitTypeNative;
  }
  if ([CR_DeviceInfo validScreenSize:CGSizeMake(bid.width.floatValue, bid.height.floatValue)]) {
    return CRAdUnitTypeInterstitial;
  }
  return CRAdUnitTypeBanner;
}

- (CR_CacheAdUnit *)setBid:(CR_CdbBid *)bid {
  if (!bid) {
    return nil;
  }
  if (!bid.isValid) {
    CLog(@"Cache update failed because bid is not valid. bid:  %@", bid);
    return nil;
  }
  CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc]
      initWithAdUnitId:bid.placementId
                  size:CGSizeMake(bid.width.floatValue, bid.height.floatValue)
            adUnitType:[self adUnitTypeFromBid:bid]];
  if (!adUnit.isValid) {
    CLog(@"Cache update failed because adUnit was not valid. bid:  %@", bid);
    return nil;
  }
  @synchronized(_bidCache) {
    CLogInfo(@"[INFO][CACH] setBid: %@", adUnit);
    _bidCache[adUnit] = bid;
  }
  return adUnit;
}

- (CR_CdbBid *)getBidForAdUnit:(CR_CacheAdUnit *)adUnit {
  CR_CdbBid *bid = _bidCache[adUnit];
  CLogInfo(@"[INFO][CACH] getBidForAdUnit: %@, isNil: %d", adUnit, bid == nil);
  return bid;
}

- (void)removeBidForAdUnit:(CR_CacheAdUnit *)adUnit {
  CLogInfo(@"[INFO][CACH] removeBidForAdUnit: %@", adUnit);
  _bidCache[adUnit] = nil;
}

@end