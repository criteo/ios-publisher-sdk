//
//  CR_NativeProductTests.m
//  pubsdkTests
//
//  Created by Richard Clark on 9/12/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_NativeProduct.h"
#import "NSDictionary+Criteo.h"

@interface CR_NativeProductTests : XCTestCase

@property (strong) NSDictionary *jdict;
@property (strong) CR_NativeProduct *product1;
@property (strong) CR_NativeProduct *product2;

@end

@implementation CR_NativeProductTests

- (void)setUp {
    self.jdict  = @{ @"title": @"\"Stripe Pima Dress\" - $99",
                     @"description": @"We're All About Comfort.",
                     @"price": @"$99",
                     @"clickUrl": @"https://cat.sv.us.criteo.com/delivery/ckn.php?",
                     @"callToAction": @"scipio",
                     @"image": @{
                             @"url": @"https://pix.us.criteo.net/img/img?",
                             @"height": @(400),
                             @"width": @(500)
                             }
                     };
    NSString *jsonText = @"{\n"
                            "\"title\": \"\\\"Stripe Pima Dress\\\" - $99\",\n"
                            "\"description\": \"We're All About Comfort.\",\n"
                            "\"price\": \"$99\",\n"
                            "\"clickUrl\": \"https://cat.sv.us.criteo.com/delivery/ckn.php?\",\n"
                            "\"callToAction\": \"scipio\",\n"
                            "\"image\": {\n"
                                 "\"url\": \"https://pix.us.criteo.net/img/img?\",\n"
                                 "\"height\": 400,\n"
                                 "\"width\": 500\n"
                            "}\n"
                          "}";
    NSData *jsonData = [jsonText dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSDictionary *jdict2 = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    if (e) { XCTFail(@"%@", e); }
    XCTAssertNotNil(jdict2);

    self.product1 = [[CR_NativeProduct alloc] initWithDict:self.jdict];
    XCTAssertNotNil(self.product1);
    self.product2 = [[CR_NativeProduct alloc] initWithDict:jdict2];
    XCTAssertNotNil(self.product2);
}

- (void)checkHashAndIsEqualForUnequalObjects:(NSDictionary *)dict key:(id)key modValue:(id)modValue {
    NSDictionary *modDict = [dict dictionaryWithNewValue:modValue forKey:key];
    NSDictionary *dictWithNil1 = [dict dictionaryWithNewValue:nil forKey:key];
    NSDictionary *dictWithNil2 = [dict dictionaryWithNewValue:nil forKey:key];

    CR_NativeProduct *product = [[CR_NativeProduct alloc] initWithDict:dict];
    CR_NativeProduct *modProduct = [[CR_NativeProduct alloc] initWithDict:modDict];
    CR_NativeProduct *productWithNil1 = [[CR_NativeProduct alloc] initWithDict:dictWithNil1];
    CR_NativeProduct *productWithNil2 = [[CR_NativeProduct alloc] initWithDict:dictWithNil2];

    XCTAssertNotEqual(product.hash, modProduct.hash);
    XCTAssertNotEqual(product.hash, productWithNil1.hash);
    XCTAssertEqual(productWithNil1.hash, productWithNil2.hash);

    XCTAssertFalse([product isEqual:modProduct]);
    XCTAssertFalse([modProduct isEqual:product]);
    XCTAssertFalse([product isEqual:productWithNil1]);
    XCTAssertFalse([productWithNil1 isEqual:product]);
    XCTAssertTrue([productWithNil1 isEqual:productWithNil2]);
    XCTAssertTrue([productWithNil2 isEqual:productWithNil1]);

    XCTAssertNotEqualObjects(product, nil);
    XCTAssertNotEqualObjects(product, @"astring");
    XCTAssertNotEqualObjects(product, modProduct);
    XCTAssertNotEqualObjects(modProduct, product);
    XCTAssertNotEqualObjects(product, productWithNil1);
    XCTAssertNotEqualObjects(productWithNil1, product);
    XCTAssertEqualObjects(productWithNil1, productWithNil2);
    XCTAssertEqualObjects(productWithNil2, productWithNil1);
}

- (void)checkIsAllNormal:(CR_NativeProduct *)product {
    XCTAssertEqualObjects(product.title, @"\"Stripe Pima Dress\" - $99");
    XCTAssertEqualObjects(product.description, @"We're All About Comfort.");
    XCTAssertEqualObjects(product.price, @"$99");
    XCTAssertEqualObjects(product.clickUrl, @"https://cat.sv.us.criteo.com/delivery/ckn.php?");
    XCTAssertEqualObjects(product.callToAction, @"scipio");
    XCTAssertEqualObjects(product.image.url, @"https://pix.us.criteo.net/img/img?");
    XCTAssertEqual(product.image.width, 500);
    XCTAssertEqual(product.image.height, 400);
}
    
- (void)testInitialization {
    CR_NativeProduct *product = [[CR_NativeProduct alloc] initWithDict:self.jdict];
    [self checkIsAllNormal:product];
}

- (void)checkFactoryMethod {
    XCTAssertNil([CR_NativeProduct nativeProductWithDict:nil]);
    CR_NativeProduct *product = [CR_NativeProduct nativeProductWithDict:self.jdict];
    [self checkIsAllNormal:product];
}

- (void)checkIsAllNil:(CR_NativeProduct *)product {
    XCTAssertNil(product.title);
    XCTAssertNil(product.description);
    XCTAssertNil(product.price);
    XCTAssertNil(product.clickUrl);
    XCTAssertNil(product.callToAction);
    XCTAssertNil(product.image);
}

- (void)testWrongTypes {
  NSDictionary *badJsonDict = @{ @"title": @(2),
                                 @"description": @(2),
                                 @"price": @(2),
                                 @"clickUrl": @(2),
                                 @"callToAction": @(2),
                                 @"image": @(2)
                               };
    CR_NativeProduct *product = [[CR_NativeProduct alloc] initWithDict:badJsonDict];
    [self checkIsAllNil:product];
}

- (void)testEmptyInitialization {
    CR_NativeProduct *product = [[CR_NativeProduct alloc] initWithDict:[NSDictionary new]];
    [self checkIsAllNil:product];
}

- (void)testNilInitialization {
    CR_NativeProduct *product = [[CR_NativeProduct alloc] initWithDict:nil];
    [self checkIsAllNil:product];
}

- (void)testHashEquality {
    XCTAssertEqual(self.product1.hash, self.product2.hash);
}

- (void)testIsEqualTrue {
    XCTAssertEqualObjects(self.product1, self.product1);
    XCTAssertEqualObjects(self.product1, self.product2);
    XCTAssertEqualObjects(self.product2, self.product1);
}

- (void)testUnequalObjects {
    [self checkHashAndIsEqualForUnequalObjects:self.jdict key:@"title" modValue:@"baerf"];
    [self checkHashAndIsEqualForUnequalObjects:self.jdict key:@"description" modValue:@"yday gday"];
    [self checkHashAndIsEqualForUnequalObjects:self.jdict key:@"price" modValue:@"sheeeeesh"];
    [self checkHashAndIsEqualForUnequalObjects:self.jdict key:@"clickUrl" modValue:@"blech"];
    [self checkHashAndIsEqualForUnequalObjects:self.jdict key:@"callToAction" modValue:@"nyuknyuk"];
    [self checkHashAndIsEqualForUnequalObjects:self.jdict key:@"image" modValue:@{
                                                                                   @"url": @"https://pix",
                                                                                   @"height": @(400),
                                                                                   @"width": @(400)
                                                                                   }];
}

- (void)testCopy {
    CR_NativeProduct *product1Copy = [self.product1 copy];
    XCTAssertNotNil(product1Copy);
    XCTAssertFalse(self.product1 == product1Copy);
    XCTAssertEqualObjects(self.product1, product1Copy);

    CR_NativeProduct *product2Copy = [self.product2 copy];
    XCTAssertNotNil(product2Copy);
    XCTAssertEqualObjects(product1Copy, product2Copy);
}

@end
