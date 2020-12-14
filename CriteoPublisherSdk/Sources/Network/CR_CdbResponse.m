//
//  CR_CdbResponse.m
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

#import "CR_CdbResponse.h"
#import "CR_Logging.h"

@implementation CR_CdbResponse

- (instancetype)init {
  if (self = [super init]) {
    _cdbBids = nil;
    _timeToNextCall = 0;
  }
  return self;
}

+ (nullable CR_CdbResponse *)responseWithData:(nullable NSData *)data
                                   receivedAt:(nullable NSDate *)receivedAt {
  if ((data == nil) || (receivedAt == nil)) {
    return nil;
  }

  CR_CdbResponse *cdbResponse = [[CR_CdbResponse alloc] init];
  cdbResponse.cdbBids = [CR_CdbBid cdbBidsWithData:data receivedAt:receivedAt];
  cdbResponse.timeToNextCall = 0;

  NSError *e = nil;
  NSDictionary *timeToNextCall = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
  if (e) {
    CRLogWarn(@"Bidding", @"Error parsing timeToNextCall of CdbResponse: %@", e);
  } else if (timeToNextCall[@"timeToNextCall"] &&
             [timeToNextCall[@"timeToNextCall"] isKindOfClass:[NSNumber class]]) {
    cdbResponse.timeToNextCall = [timeToNextCall[@"timeToNextCall"] unsignedIntegerValue];
  }
  return cdbResponse;
}

@end
