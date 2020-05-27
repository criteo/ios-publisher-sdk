//
//  CR_NativeAssetsTest.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_NativeAssets.h"
#import "NSDictionary+Criteo.h"

@interface CR_NativeAssetsTests : XCTestCase

@property (strong) NSDictionary *jdict;
@property (strong) NSDictionary *productDict1;
@property (strong) NSDictionary *productDict2;
@property (strong) NSDictionary *impressionPixelDict1;
@property (strong) NSDictionary *impressionPixelDict2;
@property (strong) NSDictionary *advertiserDict;
@property (strong) NSDictionary *privacyDict;
@property (strong) CR_NativeAssets *assets1;
@property (strong) CR_NativeAssets *assets2;

@end

@implementation CR_NativeAssetsTests

+ (CR_NativeAssets *)loadNativeAssets:(NSString *)fileName {
    NSError *e = nil;
    NSURL *jsonURL = [[NSBundle bundleForClass:[self class]] URLForResource:fileName withExtension:@"json"];
    NSString *jsonText = [NSString stringWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&e];
    NSData *jsonData = [jsonText dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    return [[CR_NativeAssets alloc] initWithDict:dictionary];
}

- (void)setUp {
    self.productDict1 = @{ @"title": @"\"Stripe Pima Dress\" - $99",
                           @"description": @"We're All About Comfort.",
                           @"price": @"$99",
                           @"clickUrl": @"https://cat.sv.us.criteo.com/delivery/ckn.php?",
                           @"callToAction": @"scipio",
                           @"image": @{
                                   @"url": @"https://pix.us.criteo.net/img/img?",
                                   @"height": @(501),
                                   @"width": @(502)
                                }
                           };
    self.productDict2 = @{ @"title": @"\"Just a Dress\" - $9999",
                           @"description": @"We're NOT About Comfort.",
                           @"price": @"$9999",
                           @"clickUrl": @"https://cat.sv.us.criteo.com/delivery/ckn2.php?",
                           @"callToAction": @"Buy this blinkin dress",
                           @"image": @{
                                   @"url": @"https://pix.us.criteo.net/img/img2?",
                                   @"height": @(401),
                                   @"width": @(402)
                                }
                         };
    self.impressionPixelDict1 = @{ @"url": @"https://cat.sv.us.criteo.com/delivery/lgn.php?" };
    self.impressionPixelDict2 = @{ @"url": @"https://cat.sv.us.criteo.com/delivery2/lgn.php?" };
    self.advertiserDict = @{ @"description": @"The Company Store",
                             @"domain": @"thecompanystore.com",
                             @"logo": @{
                                    @"url": @"https://pix.us.criteo.net/img/img?",
                                    @"height": @(200),
                                    @"width":  @(300)
                                 },
                             @"logoClickUrl": @"https://cat.sv.us.criteo.com/delivery/ckn.php?"
                           };
    self.privacyDict = @{
                            @"optoutClickUrl": @"https://privacy.us.criteo.com/adcenter?",
                            @"optoutImageUrl": @"https://static.criteo.net/flash/icon/nai_small.png",
                            @"longLegalText": @"Blah dee blah blah"
                        };

    self.jdict = @{ @"products": @[ self.productDict1, self.productDict2 ],
                    @"privacy": self.privacyDict,
                    @"advertiser": self.advertiserDict,
                    @"impressionPixels": @[ self.impressionPixelDict1, self.impressionPixelDict2]
                  };

    NSString *jsonText = @"{\n"
    "\"products\": [\n"
    "{\n"
    "\"title\": \"\\\"Stripe Pima Dress\\\" - $99\",\n"
    "\"description\": \"We're All About Comfort.\",\n"
    "\"price\": \"$99\",\n"
    "\"clickUrl\": \"https://cat.sv.us.criteo.com/delivery/ckn.php?\",\n"
    "\"callToAction\": \"scipio\",\n"
    "\"image\": {\n"
    "\"url\": \"https://pix.us.criteo.net/img/img?\",\n"
    "\"height\": 501,\n"
    "\"width\": 502\n"
    "}\n"
    "},\n"
    "{\n"
    "\"title\": \"\\\"Just a Dress\\\" - $9999\",\n"
    "\"description\": \"We're NOT About Comfort.\",\n"
    "\"price\": \"$9999\",\n"
    "\"clickUrl\": \"https://cat.sv.us.criteo.com/delivery/ckn2.php?\",\n"
    "\"callToAction\": \"Buy this blinkin dress\",\n"
    "\"image\": {\n"
    "\"url\": \"https://pix.us.criteo.net/img/img2?\",\n"
    "\"height\": 401,\n"
    "\"width\": 402\n"
    "}\n"
    "}\n"
    "],\n"
    "\"advertiser\": {\n"
    "\"description\": \"The Company Store\",\n"
    "\"domain\": \"thecompanystore.com\",\n"
    "\"logo\": {\n"
    "\"url\": \"https://pix.us.criteo.net/img/img?\",\n"
    "\"height\": 200,\n"
    "\"width\": 300,\n"
    "},\n"
    "\"logoClickUrl\": \"https://cat.sv.us.criteo.com/delivery/ckn.php?\"\n"
    "},\n"
    "\"privacy\": {\n"
    "\"optoutClickUrl\": \"https://privacy.us.criteo.com/adcenter?\",\n"
    "\"optoutImageUrl\": \"https://static.criteo.net/flash/icon/nai_small.png\",\n"
    "\"longLegalText\": \"Blah dee blah blah\"\n"
    "},"
    "\"impressionPixels\": [\n"
    "{\n"
    "\"url\": \"https://cat.sv.us.criteo.com/delivery/lgn.php?\",\n"
    "},\n"
    "{\n"
    "\"url\": \"https://cat.sv.us.criteo.com/delivery2/lgn.php?\",\n"
    "}\n"
    "]\n"
    "}";
    NSData *jsonData = [jsonText dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSDictionary *jdict2 = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    if (e) { XCTFail(@"%@", e); }
    XCTAssertNotNil(jdict2);

    self.assets1 = [[CR_NativeAssets alloc] initWithDict:self.jdict];
    XCTAssertNotNil(self.assets1);
    self.assets2 = [[CR_NativeAssets alloc] initWithDict:jdict2];
    XCTAssertNotNil(self.assets2);
}

- (BOOL)testHashAndIsEqualForUnequalObjects:(NSDictionary *)dict key:(id)key modValue:(id)modValue {
    NSDictionary *modDict = [dict cr_dictionaryWithNewValue:modValue forKey:key];
    NSDictionary *dictWithNil1 = [dict cr_dictionaryWithNewValue:nil forKey:key];
    NSDictionary *dictWithNil2 = [dict cr_dictionaryWithNewValue:nil forKey:key];

    CR_NativeAssets *assets = [[CR_NativeAssets alloc] initWithDict:dict];
    CR_NativeAssets *modAssets = [[CR_NativeAssets alloc] initWithDict:modDict];
    CR_NativeAssets *assetsWithNil1 = [[CR_NativeAssets alloc] initWithDict:dictWithNil1];
    CR_NativeAssets *assetsWithNil2 = [[CR_NativeAssets alloc] initWithDict:dictWithNil2];

    NSLog(@"assets.hash = %lu, modAssets.hash= %lu", (unsigned long)assets.hash, (unsigned long)modAssets.hash);
    XCTAssertNotEqual(assets.hash, modAssets.hash);
    XCTAssertNotEqual(assets.hash, assetsWithNil1.hash);
    XCTAssertEqual(assetsWithNil1.hash, assetsWithNil2.hash);

    XCTAssertFalse([assets isEqual:modAssets]);
    XCTAssertFalse([modAssets isEqual:assets]);
    XCTAssertFalse([assets isEqual:assetsWithNil1]);
    XCTAssertFalse([assetsWithNil1 isEqual:assets]);
    XCTAssertTrue([assetsWithNil1 isEqual:assetsWithNil2]);
    XCTAssertTrue([assetsWithNil2 isEqual:assetsWithNil1]);

    XCTAssertNotEqualObjects(assets, nil);
    XCTAssertNotEqualObjects(assets, @"astring");
    XCTAssertNotEqualObjects(assets, modAssets);
    XCTAssertNotEqualObjects(modAssets, assets);
    XCTAssertNotEqualObjects(assets, assetsWithNil1);
    XCTAssertNotEqualObjects(assetsWithNil1, assets);
    XCTAssertEqualObjects(assetsWithNil1, assetsWithNil2);
    XCTAssertEqualObjects(assetsWithNil2, assetsWithNil1);
}

- (void)checkIsAllNormal:(CR_NativeAssets *)assets {
    XCTAssertEqualObjects(assets.products[0].title, @"\"Stripe Pima Dress\" - $99");
    XCTAssertEqualObjects(assets.products[0].description, @"We're All About Comfort.");
    XCTAssertEqualObjects(assets.products[0].price, @"$99");
    XCTAssertEqualObjects(assets.products[0].clickUrl, @"https://cat.sv.us.criteo.com/delivery/ckn.php?");
    XCTAssertEqualObjects(assets.products[0].callToAction, @"scipio");
    XCTAssertEqualObjects(assets.products[0].image.url, @"https://pix.us.criteo.net/img/img?");
    XCTAssertEqual(assets.products[0].image.width, 502);
    XCTAssertEqual(assets.products[0].image.height, 501);
    
    XCTAssertEqualObjects(assets.products[1].title, @"\"Just a Dress\" - $9999");
    XCTAssertEqualObjects(assets.products[1].description, @"We're NOT About Comfort.");
    XCTAssertEqualObjects(assets.products[1].price, @"$9999");
    XCTAssertEqualObjects(assets.products[1].clickUrl, @"https://cat.sv.us.criteo.com/delivery/ckn2.php?");
    XCTAssertEqualObjects(assets.products[1].callToAction, @"Buy this blinkin dress");
    XCTAssertEqualObjects(assets.products[1].image.url, @"https://pix.us.criteo.net/img/img2?");
    XCTAssertEqual(assets.products[1].image.width, 402);
    XCTAssertEqual(assets.products[1].image.height, 401);
    
    XCTAssertEqualObjects(assets.advertiser.description, @"The Company Store");
    XCTAssertEqualObjects(assets.advertiser.domain, @"thecompanystore.com");
    XCTAssertEqualObjects(assets.advertiser.logoClickUrl, @"https://cat.sv.us.criteo.com/delivery/ckn.php?");
    XCTAssertEqualObjects(assets.advertiser.logoImage.url, @"https://pix.us.criteo.net/img/img?");
    XCTAssertEqual(assets.advertiser.logoImage.width, 300);
    XCTAssertEqual(assets.advertiser.logoImage.height, 200);
    
    XCTAssertEqualObjects(assets.privacy.optoutClickUrl, @"https://privacy.us.criteo.com/adcenter?");
    XCTAssertEqualObjects(assets.privacy.optoutImageUrl, @"https://static.criteo.net/flash/icon/nai_small.png");
    XCTAssertEqualObjects(assets.privacy.longLegalText, @"Blah dee blah blah");
    
    XCTAssertEqualObjects(assets.impressionPixels[0], @"https://cat.sv.us.criteo.com/delivery/lgn.php?");
    XCTAssertEqualObjects(assets.impressionPixels[1], @"https://cat.sv.us.criteo.com/delivery2/lgn.php?");
}

- (void)testInitialization {
    CR_NativeAssets *assets = [[CR_NativeAssets alloc] initWithDict:self.jdict];
    [self checkIsAllNormal:assets];
}

- (void)checkIsAllNil:(CR_NativeAssets *)assets {
    XCTAssertNil(assets.products);
    XCTAssertNil(assets.advertiser);
    XCTAssertNil(assets.privacy);
    XCTAssertNil(assets.impressionPixels);
}

- (void)testWrongTypes {
    NSDictionary *badJsonDict1 = @{
                                   @"products": @(1),
                                   @"advertiser": @(1),
                                   @"privacy": @(1),
                                   @"impressionPixels": @(1)
                                   };
    NSDictionary *badJsonDict2 = @{
                                   @"products": @[@(3), @(4)],
                                   @"advertiser": @(1),
                                   @"privacy": @(1),
                                   @"impressionPixels": @[@(3), @(4)]
                                   };
    CR_NativeAssets *assets1 = [[CR_NativeAssets alloc] initWithDict:badJsonDict1];
    CR_NativeAssets *assets2 = [[CR_NativeAssets alloc] initWithDict:badJsonDict2];
    [self checkIsAllNil:assets1];
    [self checkIsAllNil:assets2];
}

- (void)testEmptyInitialization {
    CR_NativeAssets *assets = [[CR_NativeAssets alloc] initWithDict:[NSDictionary new]];
    [self checkIsAllNil:assets];
}

- (void)testNullInitialization {
    CR_NativeAssets *assets = [[CR_NativeAssets alloc] initWithDict:nil];
    [self checkIsAllNil:assets];
}

- (void)testHashEquality {
    XCTAssertEqual(self.assets1.hash, self.assets2.hash);
}

- (void)testIsEqualTrue {
    XCTAssertEqualObjects(self.assets1, self.assets1);
    XCTAssertEqualObjects(self.assets1, self.assets2);
    XCTAssertEqualObjects(self.assets2, self.assets1);
}

- (void)testUnequalObjects {
    NSDictionary *modProductDict2 = [self.productDict2 cr_dictionaryWithNewValue:@"$99999" forKey:@"price"];
    NSArray *modProductArray = @[self.productDict1, modProductDict2];
    [self testHashAndIsEqualForUnequalObjects:self.jdict key:@"products" modValue:modProductArray];

    NSDictionary *modAdvertiserDict = [self.advertiserDict cr_dictionaryWithNewValue:@"Blah blah" forKey:@"domain"];
    [self testHashAndIsEqualForUnequalObjects:self.jdict key:@"advertiser" modValue:modAdvertiserDict];

    NSDictionary *modPrivacyDict = [self.privacyDict cr_dictionaryWithNewValue:@"Oink!" forKey:@"longLegalText"];
    [self testHashAndIsEqualForUnequalObjects:self.jdict key:@"privacy" modValue:modPrivacyDict];

    NSDictionary *modImpressionPixelDict1 = [self.impressionPixelDict1 cr_dictionaryWithNewValue:@"Hannibal"
                                                                                          forKey:@"url"];
    NSArray *modImpressionPixelArray = @[modImpressionPixelDict1, self.impressionPixelDict2];
    [self testHashAndIsEqualForUnequalObjects:self.jdict key:@"impressionPixels" modValue:modImpressionPixelArray];
}

- (void)testCopy {
    CR_NativeAssets *assets1Copy = [self.assets1 copy];
    XCTAssertNotNil(assets1Copy);
    XCTAssertFalse(self.assets1 == assets1Copy);
    XCTAssertEqualObjects(self.assets1, assets1Copy);

    CR_NativeAssets *assets2Copy = [self.assets2 copy];
    XCTAssertNotNil(assets2Copy);
    XCTAssertEqualObjects(assets1Copy, assets2Copy);
}

@end
