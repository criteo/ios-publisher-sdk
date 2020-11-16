//
//  CR_InternalContextProviderTests.m
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
#import "CR_InternalContextProvider.h"

@interface CR_InternalContextProviderTests : XCTestCase

@property(nonatomic, strong) CR_InternalContextProvider *internalContextProvider;

@end

@implementation CR_InternalContextProviderTests

- (void)setUp {
  [super setUp];
  self.internalContextProvider = OCMPartialMock(CR_InternalContextProvider.new);
}

- (void)testFetchInternalUserContext_GivenMockedData_PutThemInRightField {
  OCMStub([self.internalContextProvider fetchDeviceMake]).andReturn(@"deviceMake");
  OCMStub([self.internalContextProvider fetchDeviceModel]).andReturn(@"deviceModel");
  OCMStub([self.internalContextProvider fetchDeviceOrientation]).andReturn(@"deviceOrientation");
  OCMStub([self.internalContextProvider fetchDeviceWidth]).andReturn(@1337);
  OCMStub([self.internalContextProvider fetchDeviceHeight]).andReturn(@22);
  OCMStub([self.internalContextProvider fetchDeviceConnectionType])
      .andReturn(CR_DeviceConnectionTypeWifi);
  OCMStub([self.internalContextProvider fetchUserCountry]).andReturn(@"userCountry");
  OCMStub([self.internalContextProvider fetchUserLanguages]).andReturn((@[ @"en", @"he" ]));
  OCMStub([self.internalContextProvider fetchSessionDuration]).andReturn(@10000);

  NSDictionary<NSString *, id> *internalUserContext =
      [self.internalContextProvider fetchInternalUserContext];

  NSDictionary<NSString *, id> *expected = @{
    @"device.model" : @"deviceModel",
    @"device.make" : @"deviceMake",
    @"device.contype" : @2,
    @"user.geo.country" : @"userCountry",
    @"data.inputLanguage" : @[ @"en", @"he" ],
    @"device.w" : @1337,
    @"device.h" : @22,
    @"data.orientation" : @"deviceOrientation",
    @"data.sessionDuration" : @10000L
  };

  XCTAssertEqualObjects(internalUserContext, expected);
}

- (void)testFetchInternalUserContext_GivenNoData_PutNothing {
  OCMStub([self.internalContextProvider fetchDeviceMake]).andReturn(nil);
  OCMStub([self.internalContextProvider fetchDeviceModel]).andReturn(nil);
  OCMStub([self.internalContextProvider fetchDeviceOrientation]).andReturn(nil);
  OCMStub([self.internalContextProvider fetchDeviceWidth]).andReturn(nil);
  OCMStub([self.internalContextProvider fetchDeviceHeight]).andReturn(nil);
  OCMStub([self.internalContextProvider fetchDeviceConnectionType])
      .andReturn(CR_DeviceConnectionTypeUnknown);
  OCMStub([self.internalContextProvider fetchUserCountry]).andReturn(nil);
  OCMStub([self.internalContextProvider fetchUserLanguages]).andReturn(nil);
  OCMStub([self.internalContextProvider fetchSessionDuration]).andReturn(nil);

  NSDictionary<NSString *, id> *internalUserContext =
      [self.internalContextProvider fetchInternalUserContext];

  NSDictionary<NSString *, id> *expected = @{};

  XCTAssertEqualObjects(internalUserContext, expected);
}

@end