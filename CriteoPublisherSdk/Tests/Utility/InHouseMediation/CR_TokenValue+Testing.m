//
//  CR_TokenValue+Testing.m
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

#import <OCMock.h>
#import "CR_TokenValue+Testing.h"
#import "CR_CdbBid.h"
#import "CR_CdbBidBuilder.h"

@implementation CR_TokenValue (Testing)

+ (CR_TokenValue *)tokenValueWithDisplayUrl:(NSString *)displayUrl adUnit:(CRAdUnit *)adUnit {
  return [CR_TokenValue tokenValueWithDisplayUrl:displayUrl adUnit:adUnit expired:NO];
}

+ (CR_TokenValue *)tokenValueWithDisplayUrl:(NSString *)displayUrl
                                     adUnit:(CRAdUnit *)adUnit
                                    expired:(BOOL)expired {
  CR_CdbBidBuilder *builder = CR_CdbBidBuilder.new.displayUrl(displayUrl);

  if (expired) {
    builder = builder.expiredInsertTime();
  }

  CR_CdbBid *cdbBid = builder.build;

  return [CR_TokenValue.alloc initWithCdbBid:cdbBid adUnit:adUnit];
}

@end