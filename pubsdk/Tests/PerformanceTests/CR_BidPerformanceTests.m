//
//  CR_BidPerformanceTests.m
//  pubsdkTests
//
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo+Testing.h"
#import "CR_BidManagerBuilder+Testing.h"
#import "CR_TestAdUnits.h"
#import "CR_ThreadManager+Waiter.h"
#import "CR_ThreadManagerWaiter.h"

@interface CR_BidPerformanceTests : XCTestCase

@property (strong, nonatomic) Criteo *criteo;

@end

@implementation CR_BidPerformanceTests

- (void)setUp {
    CR_BidManagerBuilder *builder =
    CR_BidManagerBuilder.new.withIsolatedUserDefaults
    .withPreprodConfiguration
    .withListenedNetworkManager
    // We don't want to isolate the tests from the disk
    //.withIsolatedFeedbackStorage
    .withIsolatedNotificationCenter;

    self.criteo = [[Criteo alloc] initWithBidManagerBuilder:builder];
}

- (void)test500Bids {
    NSArray *adUnits = [self badAdUnitsWithCount:500];

    [self.criteo testing_registerWithAdUnits:adUnits];
    [self waitThreadManagerIdle];

    for (NSUInteger i = 0; i < adUnits.count; i++) {
        CRAdUnit *adUnit = adUnits[i];
        XCTAssertNoThrow([self.criteo getBidResponseForAdUnit:adUnit]);
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
    CR_ThreadManager *threadManager = self.criteo.bidManagerBuilder.threadManager;
    CR_ThreadManagerWaiter *waiter = [[CR_ThreadManagerWaiter alloc] initWithThreadManager:threadManager];
    [waiter waitIdleForPerformanceTests];
}

@end
