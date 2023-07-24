//
//  CR_RemoteConfigRequestTests.m
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
#import <OCMock.h>
#import "CR_RemoteConfigRequest.h"
#import "CR_Config.h"

@interface CR_RemoteConfigRequestTests : XCTestCase
@end

@implementation CR_RemoteConfigRequestTests

- (void)testToPostPayload_GivenConfig {
  CR_Config *config = OCMClassMock([CR_Config class]);
  OCMStub(config.criteoPublisherId).andReturn(@"myCpId");
  OCMStub(config.sdkVersion).andReturn(@"1.3.3.7");
  OCMStub(config.appId).andReturn(@"myAppId");
  OCMStub(config.deviceModel).andReturn(@"myDeviceModel");
  OCMStub(config.deviceOs).andReturn(@"myDeviceOs");
  NSNumber *profileId = @42;

  CR_RemoteConfigRequest *request = [CR_RemoteConfigRequest requestWithConfig:config
                                                                    profileId:profileId];
  NSDictionary *postBody = request.postBody;

  NSDictionary *expected = @{
    @"cpId" : @"myCpId",
    @"bundleId" : @"myAppId",
    @"sdkVersion" : @"1.3.3.7",
    @"rtbProfileId" : profileId,
    @"deviceModel" : @"myDeviceModel",
    @"deviceOs" : @"myDeviceOs"
  };

  XCTAssertEqualObjects(postBody, expected);
}

@end
