//
//  CRNativeAdTests.m
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
#import "OCMock.h"
#import "CRNativeLoader.h"
#import "CRNativeAd+Internal.h"
#import "CRMediaDownloader.h"
#import "CRMediaContent+Internal.h"
#import "CR_NativeAssets+Testing.h"

@interface CRNativeAdTests : XCTestCase
@end

@implementation CRNativeAdTests

- (void)testNativeAdInitializationFromAssets {
  id mediaDownloader = OCMProtocolMock(@protocol(CRMediaDownloader));
  CRNativeLoader *loader = OCMClassMock([CRNativeLoader class]);
  OCMStub(loader.mediaDownloader).andReturn(mediaDownloader);

  CR_NativeAssets *assets = [CR_NativeAssets nativeAssetsFromCdb];
  CRNativeAd *ad = [[CRNativeAd alloc] initWithLoader:loader assets:assets];
  // Product
  CR_NativeProduct *product = assets.products[0];
  XCTAssertEqual(ad.title, product.title);
  XCTAssertEqual(ad.body, product.description);
  XCTAssertEqual(ad.price, product.price);
  XCTAssertEqual(ad.callToAction, product.callToAction);
  XCTAssertEqualObjects(ad.productMedia.url.absoluteString, product.image.url);
  XCTAssertEqual(ad.productMedia.mediaDownloader, mediaDownloader);
  // Advertiser
  CR_NativeAdvertiser *advertiser = assets.advertiser;
  XCTAssertEqual(ad.advertiserDescription, advertiser.description);
  XCTAssertEqual(ad.advertiserDomain, advertiser.domain);
  XCTAssertEqualObjects(ad.advertiserLogoMedia.url.absoluteString, advertiser.logoImage.url);
  XCTAssertEqual(ad.advertiserLogoMedia.mediaDownloader, mediaDownloader);
  // Privacy
  CR_NativePrivacy *privacy = assets.privacy;
  XCTAssertEqual(ad.legalText, privacy.longLegalText);
}

@end
