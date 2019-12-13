//
//  CR_AssertDfp.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/6/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import "CR_TargetingKeys.h"

#ifndef CR_AssertDfp_h
#define CR_AssertDfp_h

#define CR_AssertDfpCustomTargetingContainsCriteoBid(customTargeting) \
    XCTAssertEqualObjects(customTargeting[CR_TargetingKey_crtCpm], @"20.00"); \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtDfpDisplayUrl]);

#define CR_AssertDfpNativeCustomTargetingContainsCriteoBid(customTargeting) \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtCpm]); \
    XCTAssertNil(customTargeting[CR_TargetingKey_crtDfpDisplayUrl]); \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtnTitle]); \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtnDesc]); \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtnImageUrl]); \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtnPrice]); \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtnClickUrl]); \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtnCta]); \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtnAdvName]); \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtnAdvDomain]); \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtnAdvLogoUrl]); \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtnAdvUrl]); \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtnPrUrl]); \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtnPrImageUrl]); \
    XCTAssertNotNil(customTargeting[[CR_TargetingKey_crtnPixUrl stringByAppendingString:@"0"]]); \
    XCTAssertNotNil(customTargeting[[CR_TargetingKey_crtnPixUrl stringByAppendingString:@"1"]]); \
    XCTAssertNotNil(customTargeting[CR_TargetingKey_crtnPixCount]);

#endif /* CR_AssertDfp_h */
