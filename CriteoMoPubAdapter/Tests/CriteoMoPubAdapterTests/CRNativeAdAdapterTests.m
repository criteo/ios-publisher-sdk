//
//  CRNativeAdAdapterTests.m
//  CriteoMoPubAdapter
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

#import <MoPub.h>
#import <OCMock.h>
#import <XCTest/XCTest.h>

#import <CriteoPublisherSdk/CriteoPublisherSdk.h>
#import "CRNativeAdAdapter.h"

#define PRODUCT_URL ([NSURL URLWithString:@"http://prod.uct"])
#define LOGO_URL ([NSURL URLWithString:@"http://lo.go"])

@interface CRNativeAdAdapterTests : XCTestCase

@end

@implementation CRNativeAdAdapterTests

- (void)testEmptyProperties {
  NSDictionary *expected = @{};
  CRNativeAd *ad = OCMClassMock(CRNativeAd.class);
  CRNativeAdAdapter *adapter = [[CRNativeAdAdapter alloc] initWithNativeAd:ad];

  NSDictionary *props = adapter.properties;

  XCTAssertEqualObjects(props, expected);
}

- (void)testProperties {
  // The keys that matter:
  // https://developers.mopub.com/networks/integrate/build-adapters-ios/#quick-start-for-native-ads
  NSDictionary *expected = @{
    kAdTitleKey : NSStringFromSelector(@selector(title)),
    kAdTextKey : NSStringFromSelector(@selector(body)),
    kAdIconImageKey : LOGO_URL,
    kAdMainImageKey : PRODUCT_URL,
    kAdCTATextKey : NSStringFromSelector(@selector(callToAction)),
  };

  CRNativeAdAdapter *adapter = [[CRNativeAdAdapter alloc] initWithNativeAd:[self nativeAdMock]];

  NSDictionary *props = adapter.properties;

  XCTAssertEqualObjects(props, expected);
}

- (CRNativeAd *)nativeAdMock {
  CRMediaContent *product = OCMClassMock(CRMediaContent.class);
  OCMStub([product url]).andReturn(PRODUCT_URL);
  CRMediaContent *logo = OCMClassMock(CRMediaContent.class);
  OCMStub([logo url]).andReturn(LOGO_URL);

  CRNativeAd *ad = OCMClassMock(CRNativeAd.class);
  OCMStub([ad title]).andReturn(@"title");
  OCMStub([ad body]).andReturn(@"body");
  OCMStub([ad price]).andReturn(@"price");
  OCMStub([ad callToAction]).andReturn(@"callToAction");
  OCMStub([ad productMedia]).andReturn(product);
  OCMStub([ad advertiserDescription]).andReturn(@"advertiserDescription");
  OCMStub([ad advertiserDescription]).andReturn(@"advertiserDomain");
  OCMStub([ad advertiserLogoMedia]).andReturn(logo);
  return ad;
}

@end
