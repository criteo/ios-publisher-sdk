//
//  CR_HeaderBiddingDictionaryFunctionalTests.m
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

#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "CR_NetworkManagerSimulator.h"

static NSString *const kCpmKey = @"crt_cpm";
static NSString *const kDictionaryDisplayUrlKey = @"crt_displayUrl";
static NSString *const kSizeKey = @"crt_size";

@interface CR_HeaderBiddingDictionaryFunctionalTests : CR_IntegrationsTestBase

@end

@implementation CR_HeaderBiddingDictionaryFunctionalTests

- (void)testExample {
  CRAdUnit *adUnit = [CR_TestAdUnits preprodBanner320x50];
  NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
  NSDictionary *expected = @{
    kCpmKey : CR_NetworkManagerSimulatorDefaultCpm,
    kDictionaryDisplayUrlKey : CR_NetworkManagerSimulatorDefaultDisplayUrl,
    kSizeKey : @"320x50"
  };

  [self initCriteoWithAdUnits:@[ adUnit ]];

  [self enrichAdObject:request forAdUnit:adUnit];

  XCTAssertEqualObjects(request, expected);
}

@end
