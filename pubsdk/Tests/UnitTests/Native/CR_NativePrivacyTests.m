//
//  CR_NativePrivacyTests.m
//
//
//  Created by Richard Clark on 9/12/19.
//

#import <XCTest/XCTest.h>
#import "CR_NativePrivacy.h"
#import "NSDictionary+Criteo.h"

@interface CR_NativePrivacyTests : XCTestCase

@property (strong) NSDictionary *jdict1;
@property (strong) NSDictionary *jdict2;
@property (strong) CR_NativePrivacy *privacy1;
@property (strong) CR_NativePrivacy *privacy2;

@end

@implementation CR_NativePrivacyTests

- (void)setUp {
    self.jdict1 = @{
                    @"optoutClickUrl": @"https://privacy.us.criteo.com/adcenter?",
                    @"optoutImageUrl": @"https://static.criteo.net/flash/icon/nai_small.png",
                    @"longLegalText": @"Blah dee blah blah"
                    };

    NSString *jsonText = @"{\n"
                            "\"optoutClickUrl\": \"https://privacy.us.criteo.com/adcenter?\",\n"
                            "\"optoutImageUrl\": \"https://static.criteo.net/flash/icon/nai_small.png\",\n"
                            "\"longLegalText\": \"Blah dee blah blah\"\n"
                          "}";
    NSData *jsonData = [jsonText dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    self.jdict2 = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    if (e) { XCTFail(@"%@", e); }
    XCTAssertNotNil(self.jdict2);

    self.privacy1 = [[CR_NativePrivacy alloc] initWithDict:self.jdict1];
    XCTAssertNotNil(self.privacy1);
    self.privacy2 = [[CR_NativePrivacy alloc] initWithDict:self.jdict2];
    XCTAssertNotNil(self.privacy2);
}

- (BOOL)testHashAndIsEqualForUnequalObjects:(NSDictionary *)dict key:(id)key modValue:(id)modValue {
    NSDictionary *modDict = [dict dictionaryWithNewValue:modValue forKey:key];
    NSDictionary *dictWithNil1 = [dict dictionaryWithNewValue:nil forKey:key];
    NSDictionary *dictWithNil2 = [dict dictionaryWithNewValue:nil forKey:key];

    CR_NativePrivacy *privacy = [[CR_NativePrivacy alloc] initWithDict:dict];
    CR_NativePrivacy *modPrivacy = [[CR_NativePrivacy alloc] initWithDict:modDict];
    CR_NativePrivacy *privacyWithNil1 = [[CR_NativePrivacy alloc] initWithDict:dictWithNil1];
    CR_NativePrivacy *privacyWithNil2 = [[CR_NativePrivacy alloc] initWithDict:dictWithNil2];

    XCTAssertNotEqual(privacy.hash, modPrivacy.hash);
    XCTAssertNotEqual(privacy.hash, privacyWithNil1.hash);
    XCTAssertEqual(privacyWithNil1.hash, privacyWithNil2.hash);

    XCTAssertFalse([privacy isEqual:modPrivacy]);
    XCTAssertFalse([modPrivacy isEqual:privacy]);
    XCTAssertFalse([privacy isEqual:privacyWithNil1]);
    XCTAssertFalse([privacyWithNil1 isEqual:privacy]);
    XCTAssertTrue([privacyWithNil1 isEqual:privacyWithNil2]);
    XCTAssertTrue([privacyWithNil2 isEqual:privacyWithNil1]);

    XCTAssertNotEqualObjects(privacy, nil);
    XCTAssertNotEqualObjects(privacy, @"astring");
    XCTAssertNotEqualObjects(privacy, modPrivacy);
    XCTAssertNotEqualObjects(modPrivacy, privacy);
    XCTAssertNotEqualObjects(privacy, privacyWithNil1);
    XCTAssertNotEqualObjects(privacyWithNil1, privacy);
    XCTAssertEqualObjects(privacyWithNil1, privacyWithNil2);
    XCTAssertEqualObjects(privacyWithNil2, privacyWithNil1);
}

- (void)checkIsAllNormal:(CR_NativePrivacy *)privacy {
    XCTAssertEqualObjects(privacy.optoutClickUrl, @"https://privacy.us.criteo.com/adcenter?");
    XCTAssertEqualObjects(privacy.optoutImageUrl, @"https://static.criteo.net/flash/icon/nai_small.png");
    XCTAssertEqualObjects(privacy.longLegalText,  @"Blah dee blah blah");
}

- (void)testInitialization {
    CR_NativePrivacy *privacy = [[CR_NativePrivacy alloc] initWithDict:self.jdict1];
    [self checkIsAllNormal:privacy];
}

- (void)checkFactoryMethod {
    XCTAssertNil([CR_NativePrivacy nativePrivacyWithDict:nil]);
    CR_NativePrivacy *privacy = [CR_NativePrivacy nativePrivacyWithDict:self.jdict1];
    [self checkIsAllNormal:privacy];
}

- (void)checkIsAllNil:(CR_NativePrivacy *)privacy {
    XCTAssertNil(privacy.optoutClickUrl);
    XCTAssertNil(privacy.optoutImageUrl);
    XCTAssertNil(privacy.longLegalText);
}

- (void)testWrongTypes {
    NSDictionary *badJsonDict = @{
                                  @"optoutClickUrl": @(1),
                                  @"optoutImageUrl": @(1),
                                  @"longLegalText": @(1)
                                 };
    CR_NativePrivacy *privacy = [[CR_NativePrivacy alloc] initWithDict:badJsonDict];
    [self checkIsAllNil:privacy];
}

- (void)testEmptyInitialization {
    CR_NativePrivacy *privacy = [[CR_NativePrivacy alloc] initWithDict:[NSDictionary new]];
    [self checkIsAllNil:privacy];
}

- (void)testNilInitialization {
    CR_NativePrivacy *privacy = [[CR_NativePrivacy alloc] initWithDict:nil];
    [self checkIsAllNil:privacy];
}

- (void)testHashEquality {
    XCTAssertEqual(self.privacy1.hash, self.privacy2.hash);
}

- (void)testIsEqualTrue {
    XCTAssertEqualObjects(self.privacy1, self.privacy1);
    XCTAssertEqualObjects(self.privacy1, self.privacy2);
    XCTAssertEqualObjects(self.privacy2, self.privacy1);
}

- (void)testUnequalObjects {
    [self testHashAndIsEqualForUnequalObjects:self.jdict1 key:@"optoutClickUrl" modValue:@"baerf"];
    [self testHashAndIsEqualForUnequalObjects:self.jdict1 key:@"optoutImageUrl" modValue:@"yday gday"];
    [self testHashAndIsEqualForUnequalObjects:self.jdict1 key:@"longLegalText"  modValue:@"sheeeeesh"];
}

- (void)testCopy {
    CR_NativePrivacy *privacy1Copy = [self.privacy1 copy];
    XCTAssertNotNil(privacy1Copy);
    XCTAssertNotEqual(self.privacy1, privacy1Copy);
//    XCTAssertNotEqual(self.privacy1.optoutClickUrl, privacy1Copy.optoutClickUrl);
//    XCTAssertNotEqual(self.privacy1.optoutImageUrl, privacy1Copy.optoutImageUrl);
//    XCTAssertNotEqual(self.privacy1.longLegalText,  privacy1Copy.longLegalText);
    XCTAssertEqualObjects(self.privacy1, privacy1Copy);

    CR_NativePrivacy *privacy2Copy = [self.privacy2 copy];
    XCTAssertNotNil(privacy2Copy);
    XCTAssertEqualObjects(privacy1Copy, privacy2Copy);
}

@end
