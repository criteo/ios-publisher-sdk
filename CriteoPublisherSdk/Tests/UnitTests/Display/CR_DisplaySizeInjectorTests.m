//
//  CR_DisplaySizeInjectorTests.m
//  CriteoPublisherSdk
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
#import <OCMock/OCMock.h>
#import "CR_DeviceInfo.h"
#import "CR_DisplaySizeInjector.h"

@interface CR_DisplaySizeInjectorTests : XCTestCase

@property(strong, nonatomic) CR_DeviceInfo *deviceInfo;
@property(strong, nonatomic) CR_DisplaySizeInjector *injection;

@end

@implementation CR_DisplaySizeInjectorTests

- (void)setUp {
  [super setUp];

  self.deviceInfo = OCMClassMock(CR_DeviceInfo.class);
  self.injection = [CR_DisplaySizeInjector.alloc initWithDeviceInfo:self.deviceInfo];
}

- (void)testInjectFullScreenSize_GivenUrlWithoutQueryParams_InjectDisplaySizeQueryParams {
  OCMStub(self.deviceInfo.screenSize).andReturn(CGSizeMake(42, 1337));

  NSString *injectedUrl =
      [self.injection injectFullScreenSizeInDisplayUrl:@"https://an.url/without/a.query#string"];

  XCTAssertEqualObjects(injectedUrl, @"https://an.url/without/a.query#string?wvw=42&wvh=1337");
}

- (void)testInjectFullScreenSize_GivenUrlWithQueryParams_InjectDisplaySizeQueryParamsAfter {
  OCMStub(self.deviceInfo.screenSize).andReturn(CGSizeMake(42, 1337));

  NSString *injectedUrl = [self.injection
      injectFullScreenSizeInDisplayUrl:@"https://an.url/with/a.query#string?already=set"];

  XCTAssertEqualObjects(injectedUrl,
                        @"https://an.url/with/a.query#string?already=set&wvw=42&wvh=1337");
}

- (void)testInjectSafeScreenSize_GivenUrlWithoutQueryParams_InjectDisplaySizeQueryParams {
  OCMStub(self.deviceInfo.safeScreenSize).andReturn(CGSizeMake(1337, 42));

  NSString *injectedUrl =
      [self.injection injectSafeScreenSizeInDisplayUrl:@"https://an.url/without/a.query#string"];

  XCTAssertEqualObjects(injectedUrl, @"https://an.url/without/a.query#string?wvw=1337&wvh=42");
}

- (void)testInjectSafeScreenSize_GivenUrlWithQueryParams_InjectDisplaySizeQueryParamsAfter {
  OCMStub(self.deviceInfo.safeScreenSize).andReturn(CGSizeMake(1337, 42));

  NSString *injectedUrl = [self.injection
      injectSafeScreenSizeInDisplayUrl:@"https://an.url/with/a.query#string?already=set"];

  XCTAssertEqualObjects(injectedUrl,
                        @"https://an.url/with/a.query#string?already=set&wvw=1337&wvh=42");
}

@end