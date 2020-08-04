//
//  CR_CdbRequest.m
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

#import "CR_CdbRequest.h"
#import "CR_CdbResponse.h"
#import "CR_UniqueIdGenerator.h"

@interface CR_CdbRequest ()

@property(strong, nonatomic) NSDictionary *adUnitToImpressionIdMap;

@end

@implementation CR_CdbRequest

- (instancetype)initWithProfileId:(NSNumber *)profileId adUnits:(CR_CacheAdUnitArray *)adUnits {
  if (self = [super init]) {
    _profileId = profileId;
    _requestGroupId = [CR_UniqueIdGenerator generateId];
    _adUnits = adUnits;
    _adUnitToImpressionIdMap = [self buildAdUnitToImpressionIdMapForAdUnits:adUnits];
  }
  return self;
}

- (NSDictionary *)buildAdUnitToImpressionIdMapForAdUnits:(CR_CacheAdUnitArray *)adUnits {
  NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
  for (CR_CacheAdUnit *adUnit in adUnits) {
    map[adUnit] = [CR_UniqueIdGenerator generateId];
  }
  return map;
}

- (NSString *)impressionIdForAdUnit:(CR_CacheAdUnit *)adUnit {
  return self.adUnitToImpressionIdMap[adUnit];
}

- (NSArray<NSString *> *)impressionIds {
  return self.adUnitToImpressionIdMap.allValues;
}

- (NSArray<NSString *> *)impressionIdsMissingInCdbResponse:(CR_CdbResponse *)cdbResponse {
  NSMutableArray<NSString *> *cdbRequestBidImpressionIds = [[NSMutableArray alloc] init];
  for (CR_CdbBid *bid in cdbResponse.cdbBids) {
    if (bid.impressionId) {
      [cdbRequestBidImpressionIds addObject:bid.impressionId];
    }
  }
  NSMutableArray<NSString *> *result = [NSMutableArray arrayWithArray:self.impressionIds];
  [result removeObjectsInArray:cdbRequestBidImpressionIds];
  return result;
}

@end
