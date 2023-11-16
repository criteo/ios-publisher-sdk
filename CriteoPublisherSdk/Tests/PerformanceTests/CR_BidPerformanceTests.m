//
//  CR_BidPerformanceTests.m
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

#import <XCTest/XCTest.h>
#import "Criteo+Testing.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_TestAdUnits.h"
#import "CR_ThreadManager+Waiter.h"
#import "CR_ThreadManagerWaiter.h"
#import "Criteo+Internal.h"

@interface CR_BidPerformanceTests : XCTestCase

@property(strong, nonatomic) Criteo *criteo;

@end

@implementation CR_BidPerformanceTests

- (void)setUp {
  CR_DependencyProvider *dependencyProvider =
      CR_DependencyProvider.new.withIsolatedUserDefaults.withWireMockConfiguration
          .withListenedNetworkManager
          // We don't want to isolate the tests from the disk
          //.withIsolatedFeedbackStorage
          .withIsolatedNotificationCenter.withIsolatedIntegrationRegistry;

  self.criteo = [[Criteo alloc] initWithDependencyProvider:dependencyProvider];
}

- (void)tearDown {
  [super tearDown];
}

- (void)test500Bids {
  NSArray *adUnits = [self badAdUnitsWithCount:500];

  [self.criteo testing_registerWithAdUnits:adUnits];
  [self waitThreadManagerIdle];

  for (NSUInteger i = 0; i < adUnits.count; i++) {
    CRAdUnit *adUnit = adUnits[i];
    XCTAssertNoThrow([self.criteo loadBidForAdUnit:adUnit
                                   responseHandler:^(CRBid *bid){
                                   }]);
  }
  [self waitThreadManagerIdle];
}

- (NSArray<CRAdUnit *> *)badAdUnitsWithCount:(NSUInteger)count {
  NSMutableArray *adUnitArray = [[NSMutableArray alloc] init];
  for (NSUInteger i = 0; i < count; i++) {
    NSString *adUnitId = [[NSString alloc] initWithFormat:@"bad_adunit_%ld", (unsigned long)i];
    CRAdUnit *adUnit = [CR_TestAdUnits banner320x50WithId:adUnitId];
    [adUnitArray addObject:adUnit];
  }
  return adUnitArray;
}

- (void)waitThreadManagerIdle {
  CR_ThreadManager *threadManager = self.criteo.dependencyProvider.threadManager;
  CR_ThreadManagerWaiter *waiter =
      [[CR_ThreadManagerWaiter alloc] initWithThreadManager:threadManager];
  [waiter waitIdleForPerformanceTests];
}

@end
