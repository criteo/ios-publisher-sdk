//
//  CR_URLRequesTests.m
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

#import <Foundation/Foundation.h>
#import <OCMock.h>
#import <XCTest/XCTest.h>

#import "CR_DeviceInfo.h"
#import "CR_URLRequest.h"
#import "CRConstants.h"

static const NSString *kTestUserAgent = @"testUserAgent";

@interface CR_URLRequestTests : XCTestCase
@property(nonatomic, strong) CR_URLRequest *request;
@end

@implementation CR_URLRequestTests

- (void)setUp {
  CR_DeviceInfo *deviceInfoMock = OCMStrictClassMock([CR_DeviceInfo class]);
  OCMStub([deviceInfoMock userAgent]).andReturn(kTestUserAgent);
  NSURL *url = [NSURL URLWithString:@"testUrl"];
  self.request = [CR_URLRequest requestWithURL:url deviceInfo:deviceInfoMock];
}

- (void)testUserAgent {
  XCTAssertEqualObjects(self.request.allHTTPHeaderFields[@"User-Agent"], kTestUserAgent);
}

- (void)testCachePolicy {
  XCTAssertEqual(self.request.cachePolicy, NSURLRequestReloadIgnoringCacheData);
}

- (void)testTimeout {
  XCTAssertEqual(self.request.timeoutInterval, CRITEO_DEFAULT_REQUEST_TIMEOUT_IN_SECONDS);
}

@end
