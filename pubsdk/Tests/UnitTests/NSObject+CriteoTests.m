//
//  NSObject+CriteoTests.m
//  pubsdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+Criteo.h"
#import "CR_TargetingKeys.h"

@interface NSObject_CriteoTests : XCTestCase

@end

@implementation NSObject_CriteoTests

- (void)testObjectIsEqualTo {
    XCTAssertTrue([NSObject object:@"a" isEqualTo:@"a"]);
    XCTAssertFalse([NSObject object:@"a" isEqualTo:@"b"]);
    XCTAssertFalse([NSObject object:@"a" isEqualTo:nil]);
    XCTAssertFalse([NSObject object:nil isEqualTo:@"a"]);
    XCTAssertTrue([NSObject object:nil isEqualTo:nil]);
}

- (void)testCriteoTargetingKeysConstantsWereNotChanged {
    XCTAssertEqualObjects(CR_TargetingKey_crtCpm, @"crt_cpm");
    XCTAssertEqualObjects(CR_TargetingKey_crtDisplayUrl, @"crt_displayUrl");
    XCTAssertEqualObjects(CR_TargetingKey_crtDfpDisplayUrl, @"crt_displayurl");

    XCTAssertEqualObjects(CR_TargetingKey_crtnTitle, @"crtn_title");
    XCTAssertEqualObjects(CR_TargetingKey_crtnDesc, @"crtn_desc");
    XCTAssertEqualObjects(CR_TargetingKey_crtnPrice, @"crtn_price");
    XCTAssertEqualObjects(CR_TargetingKey_crtnClickUrl, @"crtn_clickurl");
    XCTAssertEqualObjects(CR_TargetingKey_crtnCta, @"crtn_cta");
    XCTAssertEqualObjects(CR_TargetingKey_crtnImageUrl, @"crtn_imageurl");
    XCTAssertEqualObjects(CR_TargetingKey_crtnAdvName, @"crtn_advname");
    XCTAssertEqualObjects(CR_TargetingKey_crtnAdvDomain, @"crtn_advdomain");
    XCTAssertEqualObjects(CR_TargetingKey_crtnAdvLogoUrl, @"crtn_advlogourl");
    XCTAssertEqualObjects(CR_TargetingKey_crtnAdvUrl, @"crtn_advurl");
    XCTAssertEqualObjects(CR_TargetingKey_crtnPrUrl, @"crtn_prurl");
    XCTAssertEqualObjects(CR_TargetingKey_crtnPrImageUrl, @"crtn_primageurl");
    XCTAssertEqualObjects(CR_TargetingKey_crtnPrText, @"crtn_prtext");
    XCTAssertEqualObjects(CR_TargetingKey_crtnPixCount, @"crtn_pixcount");
    XCTAssertEqualObjects(CR_TargetingKey_crtnPixUrl, @"crtn_pixurl_");
}

@end
