//
//  CR_AssertDfp.h
//  pubsdk
//
//  Created by Romain Lofaso on 12/6/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CR_AssertDfp_h
#define CR_AssertDfp_h

static NSString * const crtnTitle = @"crtn_title";
static NSString * const crtnDesc = @"crtn_desc";
static NSString * const crtnPrice = @"crtn_price";
static NSString * const crtnClickUrl = @"crtn_clickurl";
static NSString * const crtnCta = @"crtn_cta";
static NSString * const crtnImageUrl = @"crtn_imageurl";
static NSString * const crtnAdvName = @"crtn_advname";
static NSString * const crtnAdvDomain = @"crtn_advdomain";
static NSString * const crtnAdvLogoUrl = @"crtn_advlogourl";
static NSString * const crtnAdvUrl = @"crtn_advurl";
static NSString * const crtnPrUrl = @"crtn_prurl";
static NSString * const crtnPrImageUrl = @"crtn_primageurl";
static NSString * const crtnPixUrl0 = @"crtn_pixurl_0";
static NSString * const crtnPixUrl1 = @"crtn_pixurl_1";
static NSString * const crtnPixCount = @"crtn_pixcount";


#define CR_AssertDfpCustomTargetingContainsCriteoBid(customTargeting) \
    XCTAssertEqualObjects(customTargeting[@"crt_cpm"], @"20.00"); \
    XCTAssertNotNil(customTargeting[@"crt_displayurl"]);

#define CR_AssertDfpNativeCustomTargetingContainsCriteoBid(customTargeting) \
    XCTAssertNotNil(customTargeting[@"crt_cpm"]); \
    XCTAssertNil(customTargeting[@"crt_displayurl"]); \
    XCTAssertNotNil(customTargeting[crtnTitle]); \
    XCTAssertNotNil(customTargeting[crtnDesc]); \
    XCTAssertNotNil(customTargeting[crtnImageUrl]); \
    XCTAssertNotNil(customTargeting[crtnPrice]); \
    XCTAssertNotNil(customTargeting[crtnClickUrl]); \
    XCTAssertNotNil(customTargeting[crtnCta]); \
    XCTAssertNotNil(customTargeting[crtnAdvName]); \
    XCTAssertNotNil(customTargeting[crtnAdvDomain]); \
    XCTAssertNotNil(customTargeting[crtnAdvLogoUrl]); \
    XCTAssertNotNil(customTargeting[crtnAdvUrl]); \
    XCTAssertNotNil(customTargeting[crtnPrUrl]); \
    XCTAssertNotNil(customTargeting[crtnPrImageUrl]); \
    XCTAssertNotNil(customTargeting[crtnPixUrl0]); \
    XCTAssertNotNil(customTargeting[crtnPixUrl1]); \
    XCTAssertNotNil(customTargeting[crtnPixCount]);

#endif /* CR_AssertDfp_h */
