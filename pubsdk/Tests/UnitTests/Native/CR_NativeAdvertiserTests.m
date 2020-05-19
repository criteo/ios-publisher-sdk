//
//  CR_NativeAdvertiserTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_NativeAdvertiser.h"
#import "NSDictionary+Criteo.h"

@interface CR_NativeAdvertiserTests : XCTestCase

@property (strong) NSDictionary *jdict1;
@property (strong) NSDictionary *jdict2;
@property (strong) CR_NativeAdvertiser *advertiser1;
@property (strong) CR_NativeAdvertiser *advertiser2;

@end

@implementation CR_NativeAdvertiserTests

- (void)setUp {
    self.jdict1 = @{
                    @"description": @"The Company Store",
                    @"domain": @"thecompanystore.com",
                    @"logo": @{
                            @"url": @"https://pix.us.criteo.net/img/img?",
                            @"height": @(200),
                            @"width":  @(300)
                            },
                    @"logoClickUrl": @"https://cat.sv.us.criteo.com/delivery/ckn.php?"
                    };

    NSString *jsonText = @"{\n"
                            "\"description\": \"The Company Store\",\n"
                            "\"domain\": \"thecompanystore.com\",\n"
                            "\"logo\": {\n"
                                 "\"url\": \"https://pix.us.criteo.net/img/img?\",\n"
                                 "\"height\": 200,\n"
                                 "\"width\": 300,\n"
                            "},\n"
                            "\"logoClickUrl\": \"https://cat.sv.us.criteo.com/delivery/ckn.php?\"\n"
                          "}";
    NSData *jsonData = [jsonText dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    self.jdict2 = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    if (e) { XCTFail(@"%@", e); }
    XCTAssertNotNil(self.jdict2);

    self.advertiser1 = [[CR_NativeAdvertiser alloc] initWithDict:self.jdict1];
    XCTAssertNotNil(self.advertiser1);
    self.advertiser2 = [[CR_NativeAdvertiser alloc] initWithDict:self.jdict2];
    XCTAssertNotNil(self.advertiser2);
}

- (BOOL)testHashAndIsEqualForUnequalObjects:(NSDictionary *)dict key:(id)key modValue:(id)modValue {
    NSDictionary *modDict = [dict cr_dictionaryWithNewValue:modValue forKey:key];
    NSDictionary *dictWithNil1 = [dict cr_dictionaryWithNewValue:nil forKey:key];
    NSDictionary *dictWithNil2 = [dict cr_dictionaryWithNewValue:nil forKey:key];

    CR_NativeAdvertiser *advertiser = [[CR_NativeAdvertiser alloc] initWithDict:dict];
    CR_NativeAdvertiser *modAdvertiser = [[CR_NativeAdvertiser alloc] initWithDict:modDict];
    CR_NativeAdvertiser *advertiserWithNil1 = [[CR_NativeAdvertiser alloc] initWithDict:dictWithNil1];
    CR_NativeAdvertiser *advertiserWithNil2 = [[CR_NativeAdvertiser alloc] initWithDict:dictWithNil2];

    XCTAssertNotEqual(advertiser.hash, modAdvertiser.hash);
    XCTAssertNotEqual(advertiser.hash, advertiserWithNil1.hash);
    XCTAssertEqual(advertiserWithNil1.hash, advertiserWithNil2.hash);

    XCTAssertFalse([advertiser isEqual:modAdvertiser]);
    XCTAssertFalse([modAdvertiser isEqual:advertiser]);
    XCTAssertFalse([advertiser isEqual:advertiserWithNil1]);
    XCTAssertFalse([advertiserWithNil1 isEqual:advertiser]);
    XCTAssertTrue([advertiserWithNil1 isEqual:advertiserWithNil2]);
    XCTAssertTrue([advertiserWithNil2 isEqual:advertiserWithNil1]);

    XCTAssertNotEqualObjects(advertiser, nil);
    XCTAssertNotEqualObjects(advertiser, @"astring");
    XCTAssertNotEqualObjects(advertiser, modAdvertiser);
    XCTAssertNotEqualObjects(modAdvertiser, advertiser);
    XCTAssertNotEqualObjects(advertiser, advertiserWithNil1);
    XCTAssertNotEqualObjects(advertiserWithNil1, advertiser);
    XCTAssertEqualObjects(advertiserWithNil1, advertiserWithNil2);
    XCTAssertEqualObjects(advertiserWithNil2, advertiserWithNil1);
}

- (void)checkIsAllNormal:(CR_NativeAdvertiser *)advertiser {
    XCTAssertEqualObjects(advertiser.description, @"The Company Store");
    XCTAssertEqualObjects(advertiser.domain, @"thecompanystore.com");
    XCTAssertEqualObjects(advertiser.logoImage.url, @"https://pix.us.criteo.net/img/img?");
    XCTAssertEqual(advertiser.logoImage.width, 300);
    XCTAssertEqual(advertiser.logoImage.height, 200);
    XCTAssertEqualObjects(advertiser.logoClickUrl, @"https://cat.sv.us.criteo.com/delivery/ckn.php?");
}

- (void)testInitialization {
    CR_NativeAdvertiser *advertiser = [[CR_NativeAdvertiser alloc] initWithDict:self.jdict1];
    [self checkIsAllNormal:advertiser];
}

- (void)checkFactoryMethod {
    XCTAssertNil([CR_NativeImage nativeImageWithDict:nil]);
    id string = @"hello";
    XCTAssertNil([CR_NativeImage nativeImageWithDict:string]);
    CR_NativeAdvertiser *image = [CR_NativeAdvertiser nativeAdvertiserWithDict:self.jdict1];
    [self checkIsAllNormal:image];
}

- (void)checkIsAllNil:(CR_NativeAdvertiser *)advertiser {
    XCTAssertNil(advertiser.description);
    XCTAssertNil(advertiser.domain);
    XCTAssertNil(advertiser.logoImage);
    XCTAssertNil(advertiser.logoClickUrl);
}

- (void)testWrongTypes {
    NSDictionary *badJsonDict = @{
                                  @"description": @(1),
                                  @"domain": @(1),
                                  @"logo": @(2),
                                  @"logoClickUrl": @(3)
                                  };
    CR_NativeAdvertiser *advertiser = [[CR_NativeAdvertiser alloc] initWithDict:badJsonDict];
    [self checkIsAllNil:advertiser];
}
- (void)testEmptyInitialization {
    CR_NativeAdvertiser *advertiser = [[CR_NativeAdvertiser alloc] initWithDict:[NSDictionary new]];
    [self checkIsAllNil:advertiser];
}

- (void)testNilInitialization {
    CR_NativeAdvertiser *advertiser = [[CR_NativeAdvertiser alloc] initWithDict:nil];
    [self checkIsAllNil:advertiser];
}

- (void)testHashEquality {
    XCTAssertEqual(self.advertiser1.hash, self.advertiser2.hash);
}

- (void)testIsEqualTrue {
    XCTAssertEqualObjects(self.advertiser1, self.advertiser1);
    XCTAssertEqualObjects(self.advertiser1, self.advertiser2);
    XCTAssertEqualObjects(self.advertiser2, self.advertiser1);
}

- (void)testUnequalObjects {
    [self testHashAndIsEqualForUnequalObjects:self.jdict1 key:@"description" modValue:@"baerf"];
    [self testHashAndIsEqualForUnequalObjects:self.jdict1 key:@"domain" modValue:@"yday gday"];
    [self testHashAndIsEqualForUnequalObjects:self.jdict1 key:@"logo" modValue:@{
                                                                                     @"url": @"https://pix",
                                                                                     @"height": @(200),
                                                                                     @"width":  @(300)
                                                                                  }];
    [self testHashAndIsEqualForUnequalObjects:self.jdict1 key:@"logoClickUrl" modValue:@"sheeeeesh"];
}

- (void)testCopy {
    CR_NativeAdvertiser *advertiser1Copy = [self.advertiser1 copy];
    XCTAssertNotNil(advertiser1Copy);
    XCTAssertFalse(self.advertiser1 == advertiser1Copy);
    XCTAssertEqualObjects(self.advertiser1, advertiser1Copy);

    CR_NativeAdvertiser *advertiser2Copy = [self.advertiser2 copy];
    XCTAssertNotNil(advertiser2Copy);
    XCTAssertEqualObjects(advertiser1Copy, advertiser2Copy);
}

@end
