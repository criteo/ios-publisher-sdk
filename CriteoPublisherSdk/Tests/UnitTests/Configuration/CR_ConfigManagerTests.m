//
//  CR_ConfigManagerTests.m
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

#import <OCMock.h>

#import "CR_ConfigManager.h"
#import "CR_IntegrationRegistry.h"
#import "CR_RemoteConfigRequest.h"
#import "NSUserDefaults+Testing.h"

@interface CR_ConfigManagerTests : XCTestCase

@property(nonatomic, strong) NSUserDefaults *userDefault;
@property(nonatomic, strong) CR_ConfigManager *configManager;

@end

@implementation CR_ConfigManagerTests {
  CR_Config *localConfig;
  CR_ApiHandler *mockApiHandler;
  CR_IntegrationRegistry *mockIntegrationRegistry;
}

- (void)setUp {
  localConfig = [[CR_Config alloc] initWithCriteoPublisherId:@"1337"];
  mockApiHandler = OCMStrictClassMock(CR_ApiHandler.class);
  mockIntegrationRegistry = OCMStrictClassMock(CR_IntegrationRegistry.class);
  OCMStub([mockIntegrationRegistry profileId]).andReturn(@42);

  self.userDefault = [[NSUserDefaults alloc] init];
  self.configManager = [[CR_ConfigManager alloc] initWithApiHandler:mockApiHandler
                                                integrationRegistry:mockIntegrationRegistry];
}

- (void)tearDown {
  mockApiHandler = nil;
  localConfig = nil;

  [self.userDefault removeObjectForKey:NSUserDefaultsKillSwitchKey];
  [self.userDefault removeObjectForKey:NSUserDefaultsCsmEnabledKey];
}

- (void)testConfigManagerDisableKillSwitch {
  [self prepareApiHandlerToRespondRemoteConfigJson:@"{\"killSwitch\": false }"];
  localConfig.killSwitch = YES;

  [self.configManager refreshConfig:localConfig];

  XCTAssertEqual(localConfig.killSwitch, NO,
                 @"Kill switch should be deactivated after config is refreshed from remote API");
}

- (void)testConfigManagerEnabledKillSwitch {
  [self prepareApiHandlerToRespondRemoteConfigJson:@"{\"killSwitch\": true }"];
  localConfig.killSwitch = NO;

  [self.configManager refreshConfig:localConfig];

  XCTAssertEqual(localConfig.killSwitch, YES,
                 @"Kill switch should be activated after config is refreshed from remote API");
}

- (void)testRefreshConfig_CsmFeatureFlagNotInResponse_DoNotUpdateIt {
  [self prepareApiHandlerToRespondRemoteConfigJson:@"{}"];
  localConfig.csmEnabled = NO;

  [self.configManager refreshConfig:localConfig];

  XCTAssertFalse(localConfig.csmEnabled);
}

- (void)testRefreshConfig_GivenCsmFeatureFlagSetToTrueInRequest_CsmIsEnabled {
  [self prepareApiHandlerToRespondRemoteConfigJson:@"{\"csmEnabled\": true }"];
  localConfig.csmEnabled = NO;

  [self.configManager refreshConfig:localConfig];

  XCTAssertTrue(localConfig.isCsmEnabled);
}

- (void)testRefreshConfig_GivenCsmFeatureFlagSetToFalseInRequest_CsmIsDisabled {
  [self prepareApiHandlerToRespondRemoteConfigJson:@"{\"csmEnabled\": false }"];
  localConfig.csmEnabled = YES;

  [self.configManager refreshConfig:localConfig];

  XCTAssertFalse(localConfig.isCsmEnabled);
}

- (void)testRefreshConfig_GivenIntegrationRegistry_ProfileIdIsUsedInRequest {
  BOOL (^checkRequest)(CR_RemoteConfigRequest *) = ^(CR_RemoteConfigRequest *request) {
    XCTAssertEqual(request.postBody[@"rtbProfileId"], @42);
    return YES;
  };
  OCMStub([mockApiHandler getConfig:[OCMArg checkWithBlock:checkRequest]
                    ahConfigHandler:([OCMArg invokeBlockWithArgs:@{}, nil])];);
  [self.configManager refreshConfig:localConfig];
}

#pragma mark - Private

- (void)prepareApiHandlerToRespondRemoteConfigJson:(NSString *)jsonResponse {
  NSData *dataResponse = [jsonResponse dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *dictionaryResponse = [CR_Config getConfigValuesFromData:dataResponse];

  OCMStub([mockApiHandler getConfig:OCMOCK_ANY
                    ahConfigHandler:([OCMArg invokeBlockWithArgs:dictionaryResponse, nil])]);
}

@end
