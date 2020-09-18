//
//  CR_CdbBidBuilder.m
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

#import "CR_CdbBidBuilder.h"
#import "CR_CdbBid.h"
#import "CR_CacheAdUnit.h"

NSUInteger CR_CdbBidBuilderZoneIdValueDefault = 42;
NSString *CR_CdbBidBuilderPlacementIdValueDefault = @"test-PubSdk-Base";
NSString *CR_CdbBidBuilderCpmValueDefault = @"2.0";
NSString *CR_CdbBidBuilderCurrencyValueDefault = @"USD";
NSUInteger CR_CdbBidBuilderWidthValueDefault = 300;
NSUInteger CR_CdbBidBuilderHeightValueDefault = 250;
NSTimeInterval CR_CdbBidBuilderTtlValueDefault = 200;
NSString *CR_CdbBidBuilderDisplayUrlValueDefault =
    @"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js";
NSString *CR_CdbBidBuilderImpressionIdValueDefault = @"thisIsImpId";

#define PROPERTY_INJECTION(name, type, defaultValue) \
  do {                                               \
    __weak typeof(self) weakSelf = self;             \
    _##name##Value = defaultValue;                   \
    _##name = ^CR_CdbBidBuilder *(type value) {      \
      weakSelf.name##Value = value;                  \
      return weakSelf;                               \
    };                                               \
  } while (0);

@implementation CR_CdbBidBuilder

- (instancetype)init {
  if (self = [super init]) {
    PROPERTY_INJECTION(zoneId, NSUInteger, CR_CdbBidBuilderZoneIdValueDefault);
    PROPERTY_INJECTION(placementId, NSString * _Nullable, CR_CdbBidBuilderPlacementIdValueDefault);
    PROPERTY_INJECTION(cpm, NSString * _Nullable, CR_CdbBidBuilderCpmValueDefault);
    PROPERTY_INJECTION(currency, NSString * _Nullable, CR_CdbBidBuilderCurrencyValueDefault);
    PROPERTY_INJECTION(width, NSUInteger, CR_CdbBidBuilderWidthValueDefault);
    PROPERTY_INJECTION(height, NSUInteger, CR_CdbBidBuilderHeightValueDefault);
    PROPERTY_INJECTION(ttl, NSTimeInterval, CR_CdbBidBuilderTtlValueDefault);
    PROPERTY_INJECTION(creative, NSString * _Nullable, @"");
    PROPERTY_INJECTION(displayUrl, NSString * _Nullable, CR_CdbBidBuilderDisplayUrlValueDefault);
    PROPERTY_INJECTION(insertTime, NSDate * _Nullable, [NSDate date]);
    PROPERTY_INJECTION(nativeAssets, CR_NativeAssets * _Nullable, nil);
    PROPERTY_INJECTION(impressionId, NSString * _Nullable,
                       CR_CdbBidBuilderImpressionIdValueDefault);

    __weak typeof(self) weakSelf = self;
    _adUnit = ^CR_CdbBidBuilder *(CR_CacheAdUnit *value) {
      weakSelf.placementIdValue = value.adUnitId;
      weakSelf.widthValue = value.size.width;
      weakSelf.heightValue = value.size.height;
      return weakSelf;
    };
    _noBid = ^CR_CdbBidBuilder *(void) {
      weakSelf.cpmValue = @"0";
      weakSelf.ttlValue = 0;
      return weakSelf;
    };
    _expired = ^CR_CdbBidBuilder *(void) {
      weakSelf.insertTimeValue = [NSDate dateWithTimeIntervalSinceNow:-400];
      return weakSelf;
    };
    _silenced = ^CR_CdbBidBuilder *(void) {
      weakSelf.cpmValue = @"0";
      weakSelf.ttlValue = 300;
      return weakSelf;
    };
    _immediate = ^CR_CdbBidBuilder *(void) {
      weakSelf.cpmValue = @"0.4";
      weakSelf.ttlValue = 0;
      return weakSelf;
    };
  }
  return self;
}

- (CR_CdbBid *)build {
  CR_CdbBid *bid = [[CR_CdbBid alloc] initWithZoneId:@(self.zoneIdValue)
                                         placementId:self.placementIdValue
                                                 cpm:self.cpmValue
                                            currency:self.currencyValue
                                               width:@(self.widthValue)
                                              height:@(self.heightValue)
                                                 ttl:self.ttlValue
                                            creative:self.currencyValue
                                          displayUrl:self.displayUrlValue
                                          insertTime:self.insertTimeValue
                                        nativeAssets:self.nativeAssetsValue
                                        impressionId:self.impressionIdValue];
  return bid;
}

@end
