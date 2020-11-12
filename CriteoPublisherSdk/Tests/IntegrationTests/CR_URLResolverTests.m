//
//  CR_URLResolverTests.m
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
#import "CR_DeviceInfoMock.h"
#import "CR_URLResolver.h"
#import "XCTestCase+Criteo.h"

@interface CR_URLResolverTests : XCTestCase
@end

// Note: These tests are depending on WireMock
@implementation CR_URLResolverTests

#pragma mark - Resolution

- (void)testResolutionToStandardUrl {
  [self resolveURL:@"https://localhost:9099/standard-url"
        thenVerify:^(CR_URLResolution *resolution) {
          XCTAssertEqual(resolution.type, CR_URLResolutionStandardUrl);
          XCTAssertEqualObjects(resolution.URL.absoluteString,
                                @"https://localhost:9099/standard-url");
        }];
}

- (void)testResolutionToStandardUrlWithRedirects {
  [self resolveURL:@"https://localhost:9099/redirect/3/2/1/standard-url"
        thenVerify:^(CR_URLResolution *resolution) {
          XCTAssertEqual(resolution.type, CR_URLResolutionStandardUrl);
          XCTAssertEqualObjects(resolution.URL.absoluteString,
                                @"https://localhost:9099/standard-url");
        }];
}

- (void)testResolutionError {
  [self resolveURL:@"https://localhost:9099/error"
        thenVerify:^(CR_URLResolution *resolution) {
          XCTAssertEqual(resolution.type, CR_URLResolutionError);
          XCTAssertNil(resolution.URL);
        }];
}

- (void)testResolutionErrorWithRedirects {
  [self resolveURL:@"https://localhost:9099/redirect/3/2/1/error"
        thenVerify:^(CR_URLResolution *resolution) {
          XCTAssertEqual(resolution.type, CR_URLResolutionError);
          XCTAssertNil(resolution.URL);
        }];
}

- (void)testResolutionErrorWithInfiniteRedirects {
  [self resolveURL:@"https://localhost:9099/redirect/infinite"
        thenVerify:^(CR_URLResolution *resolution) {
          XCTAssertEqual(resolution.type, CR_URLResolutionError);
          XCTAssertNil(resolution.URL);
        }];
}

#pragma mark - App Store

- (BOOL)isAppStoreHost:(NSString *)host {
  NSString *urlString =
      [NSString stringWithFormat:@"itms-apps://%@/us/app/apple-developer/id640199958", host];
  NSURL *url = [NSURL URLWithString:urlString];
  return [CR_URLResolver isAppStoreURL:url];
}

- (void)testIsAppStoreURL {
  XCTAssertTrue([self isAppStoreHost:@"apps.apple.com"]);
  XCTAssertTrue([self isAppStoreHost:@"itunes.apple.com"]);
  XCTAssertTrue([self isAppStoreHost:@"books.apple.com"]);
  XCTAssertTrue([self isAppStoreHost:@"music.apple.com"]);
  XCTAssertFalse([self isAppStoreHost:@"apps.apple.fr"]);
  XCTAssertFalse([self isAppStoreHost:@"example.com"]);
}

- (void)resolveURL:(NSString *)url thenVerify:(CR_URLResolutionHandler)resolutionVerify {
  __block NSUInteger callCount = 0;
  XCTestExpectation *resolvedExpectation = [[XCTestExpectation alloc] init];
  XCTestExpectation *resolvedOnceExpectation = [[XCTestExpectation alloc] init];
  resolvedOnceExpectation.inverted = YES;
  [CR_URLResolver resolveURL:[[NSURL alloc] initWithString:url]
                  deviceInfo:[[CR_DeviceInfoMock alloc] init]
                  resolution:^(CR_URLResolution *resolution) {
                    resolutionVerify(resolution);
                    [resolvedExpectation fulfill];
                    callCount++;
                    if (callCount > 1) {
                      [resolvedOnceExpectation fulfill];
                    }
                  }];
  [self cr_waitShortlyForExpectations:@[ resolvedExpectation, resolvedOnceExpectation ]];
}

@end
