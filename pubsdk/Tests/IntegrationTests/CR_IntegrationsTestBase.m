//
// Created by Aleksandr Pakhmutov on 03/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import "CR_IntegrationsTestBase.h"
#import "Criteo+Testing.h"


@implementation CR_IntegrationsTestBase

- (void)initCriteoWithAdUnits:(NSArray<CRAdUnit *> *)adUnits {
    self.criteo = [Criteo testing_criteoWithNetworkCaptor];
    [self.criteo testing_registerWithAdUnitsAndWaitForHTTPResponse:adUnits];
}

- (void)assertDfpCustomTargetingUpdated:(NSDictionary *)customTargeting {
    XCTAssertEqualObjects(customTargeting[@"crt_cpm"], @"20.00");
    XCTAssertNotNil(customTargeting[@"crt_displayurl"]);
}

- (void)assertMopubKeywordsUpdated:(NSString *)keywords andStillHaveInitialKeywords:(NSString *)initialKeywords {
    XCTAssertTrue([keywords containsString:initialKeywords]);
    XCTAssertTrue([keywords containsString:@"crt_cpm:20.00"]);
    XCTAssertTrue([keywords containsString:@"crt_displayUrl:"]);
}

@end
