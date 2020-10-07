//
//  CR_IntegrationsTestBase.m
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
#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_ThreadManager+Waiter.h"
#import "XCTestCase+Criteo.h"

@implementation CR_IntegrationsTestBase

#pragma mark - Lifecycle

- (void)setUp {
  [super setUp];

  self.criteo = nil;
}

- (void)tearDown {
  [self waitForIdleState];
  [super tearDown];
}

- (void)initCriteoWithAdUnits:(NSArray<CRAdUnit *> *)adUnits {
  self.criteo = [Criteo testing_criteoWithNetworkCaptor];
  [self.criteo testing_registerAndWaitForHTTPResponseWithAdUnits:adUnits];
}

- (void)waitForIdleState {
  [self.criteo.threadManager waiter_waitIdle];
}

#pragma mark - App Bidding helper

- (void)enrichAdObject:(id)object forAdUnit:(CRAdUnit *)adUnit {
  [self.criteo loadBidForAdUnit:adUnit
                responseHandler:^(CRBid *bid) {
                  [self.criteo enrichAdObject:object withBid:bid];
                }];
  [self waitForIdleState];
}

@end
