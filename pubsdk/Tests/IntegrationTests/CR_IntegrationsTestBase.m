//
// Created by Aleksandr Pakhmutov on 03/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import "CR_IntegrationsTestBase.h"
#import "Criteo+Testing.h"
#import "CR_BidManagerBuilder.h"
#import "CR_NetworkCaptor.h"
#import "CR_ThreadManager+Waiter.h"

@implementation CR_IntegrationsTestBase

- (void)setUp {
    [super setUp];

    self.criteo = nil;
}

- (void)initCriteoWithAdUnits:(NSArray<CRAdUnit *> *)adUnits {
    self.criteo = [Criteo testing_criteoWithNetworkCaptor];
    [self.criteo testing_registerAndWaitForHTTPResponseWithAdUnits:adUnits];
}

- (void)tearDown {
    [self.criteo.bidManagerBuilder.threadManager waiter_waitIdle];
    [super tearDown];
}

@end
