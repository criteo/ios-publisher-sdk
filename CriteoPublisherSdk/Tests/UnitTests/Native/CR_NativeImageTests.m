//
//  CR_NativeImageTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <XCTest/XCTest.h>
#import "CR_NativeImage.h"
#import "NSDictionary+Criteo.h"

@interface CR_NativeImageTests : XCTestCase

@property(strong) NSDictionary *jdict1;
@property(strong) NSDictionary *jdict2;
@property(strong) CR_NativeImage *image1;
@property(strong) CR_NativeImage *image2;

@end

@implementation CR_NativeImageTests

- (void)setUp {
  self.jdict1 =
      @{@"url" : @"https://pix.us.criteo.net/img/img?", @"width" : @(400), @"height" : @(512)};

  NSString *jsonText = @"{\n"
                        "\"url\": \"https://pix.us.criteo.net/img/img?\",\n"
                        "\"height\": 512,\n"
                        "\"width\": 400\n"
                        "}";
  NSData *jsonData = [jsonText dataUsingEncoding:NSUTF8StringEncoding];
  NSError *e = nil;
  self.jdict2 = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
  if (e) {
    XCTFail(@"%@", e);
  }
  XCTAssertNotNil(self.jdict2);

  self.image1 = [[CR_NativeImage alloc] initWithDict:self.jdict1];
  XCTAssertNotNil(self.image1);
  self.image2 = [[CR_NativeImage alloc] initWithDict:self.jdict2];
  XCTAssertNotNil(self.image2);
}

- (BOOL)testHashAndIsEqualForUnequalObjects:(NSDictionary *)dict key:(id)key modValue:(id)modValue {
  NSDictionary *modDict = [dict cr_dictionaryWithNewValue:modValue forKey:key];
  NSDictionary *dictWithNil1 = [dict cr_dictionaryWithNewValue:nil forKey:key];
  NSDictionary *dictWithNil2 = [dict cr_dictionaryWithNewValue:nil forKey:key];

  CR_NativeImage *image = [[CR_NativeImage alloc] initWithDict:dict];
  CR_NativeImage *modImage = [[CR_NativeImage alloc] initWithDict:modDict];
  CR_NativeImage *imageWithNil1 = [[CR_NativeImage alloc] initWithDict:dictWithNil1];
  CR_NativeImage *imageWithNil2 = [[CR_NativeImage alloc] initWithDict:dictWithNil2];

  XCTAssertNotEqual(image.hash, modImage.hash);
  XCTAssertNotEqual(image.hash, imageWithNil1.hash);
  XCTAssertEqual(imageWithNil1.hash, imageWithNil2.hash);

  XCTAssertNotEqualObjects(image, nil);
  XCTAssertNotEqualObjects(image, @"astring");
  XCTAssertNotEqualObjects(image, modImage);
  XCTAssertNotEqualObjects(modImage, image);
  XCTAssertNotEqualObjects(image, imageWithNil1);
  XCTAssertNotEqualObjects(imageWithNil1, image);
  XCTAssertEqualObjects(imageWithNil1, imageWithNil2);
  XCTAssertEqualObjects(imageWithNil2, imageWithNil1);
}

- (void)checkIsAllNormal:(CR_NativeImage *)image {
  XCTAssertEqualObjects(image.url, @"https://pix.us.criteo.net/img/img?");
  XCTAssertEqual(image.width, 400);
  XCTAssertEqual(image.height, 512);
}

- (void)testInitialization {
  CR_NativeImage *image = [[CR_NativeImage alloc] initWithDict:self.jdict1];
  [self checkIsAllNormal:image];
}

- (void)checkFactoryMethod {
  XCTAssertNil([CR_NativeImage nativeImageWithDict:nil]);
  CR_NativeImage *image = [CR_NativeImage nativeImageWithDict:self.jdict1];
  [self checkIsAllNormal:image];
}

- (void)checkIsAllNil:(CR_NativeImage *)image {
  XCTAssertNil(image.url);
  XCTAssertEqual(image.width, 0);
  XCTAssertEqual(image.height, 0);
}

- (void)testWrongTypes {
  NSDictionary *badJsonDict = @{
    @"url" : @(2),
    @"width" : @"200",
    @"height" : @"200",
  };
  CR_NativeImage *image = [[CR_NativeImage alloc] initWithDict:badJsonDict];
  XCTAssertNil(image.url);
  XCTAssertEqual(image.width, 200);
  XCTAssertEqual(image.height, 200);
}

- (void)testEmptyInitialization {
  CR_NativeImage *image = [[CR_NativeImage alloc] initWithDict:[NSDictionary new]];
  [self checkIsAllNil:image];
}

- (void)testNilInitialization {
  CR_NativeImage *image = [[CR_NativeImage alloc] initWithDict:nil];
  XCTAssertNil(image.url);
  XCTAssertEqual(image.width, 0);
  XCTAssertEqual(image.height, 0);
}

- (void)testHashEquality {
  XCTAssertEqual(self.image1.hash, self.image2.hash);
}

- (void)testIsEqualTrue {
  XCTAssertEqualObjects(self.image1, self.image1);
  XCTAssertEqualObjects(self.image1, self.image2);
  XCTAssertEqualObjects(self.image2, self.image1);
}

- (void)testIsEqualToNativeImageTrue {
  XCTAssertTrue([self.image1 isEqual:self.image1]);
  XCTAssertTrue([self.image1 isEqual:self.image2]);
  XCTAssertTrue([self.image2 isEqual:self.image1]);
}

- (void)testUnequalObjects {
  [self testHashAndIsEqualForUnequalObjects:self.jdict1 key:@"url" modValue:@"baerf"];
  [self testHashAndIsEqualForUnequalObjects:self.jdict1 key:@"width" modValue:@(900)];
  [self testHashAndIsEqualForUnequalObjects:self.jdict1 key:@"height" modValue:@(1200)];
}

- (void)testCopy {
  CR_NativeImage *image1Copy = [self.image1 copy];
  XCTAssertNotNil(image1Copy);
  XCTAssertFalse(self.image1 == image1Copy);
  XCTAssertEqualObjects(self.image1, image1Copy);

  CR_NativeImage *image2Copy = [self.image2 copy];
  XCTAssertNotNil(image2Copy);
  XCTAssertEqualObjects(image1Copy, image2Copy);
}

@end
