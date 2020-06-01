//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_IntegrationsTestBase.h"
#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_DependencyProvider.h"
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

- (void)waitForIdleState {
    [self.criteo.dependencyProvider.threadManager waiter_waitIdle];
    [self.criteo.threadManager waiter_waitIdle];
}


- (void)tearDown {
    [self waitForIdleState];
    [super tearDown];
}

@end
