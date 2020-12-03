//
//  CRBid.m
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

#import "CRBid+Internal.h"
#import "CR_CdbBid.h"

@implementation CRBid

- (instancetype)initWithCdbBid:(CR_CdbBid *)cdbBid adUnit:(CRAdUnit *)adUnit {
  if (self = [super init]) {
    _adUnit = adUnit;
    _price = [cdbBid.cpm doubleValue];
    _cdbBid = cdbBid;
  }
  return self;
}

- (CR_CdbBid *)consume {
  CR_CdbBid *bid = nil;
  @synchronized(self) {
    bid = self.cdbBid;
    self.cdbBid = nil;
  }
  return bid.isValid && !bid.isExpired ? bid : nil;
}

- (NSString *)description {
  NSMutableString *description =
      [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
  [description appendFormat:@"self.adUnit=%@", self.adUnit];
  [description appendFormat:@", self.price=%lf", self.price];
  [description appendString:@">"];
  return description;
}

@end
