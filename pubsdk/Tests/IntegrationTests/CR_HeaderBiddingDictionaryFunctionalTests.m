//
//  CR_HeaderBiddingDictionaryFunctionalTests.m
//  pubsdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//


#import "CR_IntegrationsTestBase.h"
#import "CR_TestAdUnits.h"
#import "CR_NetworkManagerSimulator.h"

static NSString * const kCpmKey = @"crt_cpm";
static NSString * const kDictionaryDisplayUrlKey = @"crt_displayUrl";
static NSString * const kSizeKey = @"crt_size";

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

    [self initCriteoWithAdUnits:@[adUnit]];

    [self.criteo setBidsForRequest:request
                        withAdUnit:adUnit];

    XCTAssertEqualObjects(request, expected);
}


@end
