//
// Created by Aleksandr Pakhmutov on 03/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import "CR_IntegrationsTestBase.h"
#import "Criteo+Testing.h"


@implementation CR_IntegrationsTestBase

- (void)initCriteoWithAdUnits:(NSArray<CRAdUnit *> *)adUnits {
    self.criteo = [Criteo testing_criteoWithNetworkCaptor];
    [self.criteo testing_registerAndWaitForHTTPResponseWithAdUnits:adUnits];
}

@end
