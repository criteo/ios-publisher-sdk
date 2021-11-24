//
//  CR_IntegrationRegistryTests.m
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
#import "CR_IntegrationRegistry.h"

FOUNDATION_EXPORT NSString *const NSUserDefaultsIntegrationKey;

@interface CR_IntegrationRegistry (Testing)

@property(nonatomic, readonly) BOOL isMoPubMediationPresent;
@property(nonatomic, readonly) BOOL isAdMobMediationPresent;

@end

@interface CR_IntegrationRegistryTests : XCTestCase

@property(nonatomic, strong) NSUserDefaults *userDefault;
@property(nonatomic, strong) CR_IntegrationRegistry *integrationRegistry;

@end

@implementation CR_IntegrationRegistryTests

- (void)setUp {
  [super setUp];

  self.userDefault = [[NSUserDefaults alloc] init];
  self.integrationRegistry =
      OCMPartialMock([[CR_IntegrationRegistry alloc] initWithUserDefaults:self.userDefault]);
}

- (void)tearDown {
  [self.userDefault removeObjectForKey:NSUserDefaultsIntegrationKey];
}

- (void)testProfileId_GivenNoDeclaredOne_ReturnFallback {
  NSNumber *profileId = self.integrationRegistry.profileId;

  XCTAssertEqualObjects(profileId, @(CR_IntegrationFallback));
}

- (void)testProfileId_GivenIllFormedDeclaration_ReturnFallback {
  [self.userDefault setObject:@"ill formed" forKey:NSUserDefaultsIntegrationKey];

  NSNumber *profileId = self.integrationRegistry.profileId;

  XCTAssertEqualObjects(profileId, @(CR_IntegrationFallback));
}

- (void)testProfileId_GivenUnknownDeclaration_ReturnFallback {
  [self.userDefault setInteger:-1 forKey:NSUserDefaultsIntegrationKey];

  NSNumber *profileId = self.integrationRegistry.profileId;

  XCTAssertEqualObjects(profileId, @(CR_IntegrationFallback));
}

- (void)testProfileId_GivenPreviouslyDeclaredOne_ReturnDeclareOne {
  [self testProfileId_GivenPreviouslyDeclaredOne_ForIntegration:CR_IntegrationFallback];
  [self testProfileId_GivenPreviouslyDeclaredOne_ForIntegration:CR_IntegrationStandalone];
  [self testProfileId_GivenPreviouslyDeclaredOne_ForIntegration:CR_IntegrationInHouse];
  [self testProfileId_GivenPreviouslyDeclaredOne_ForIntegration:CR_IntegrationAdmobMediation];
  [self testProfileId_GivenPreviouslyDeclaredOne_ForIntegration:CR_IntegrationMopubMediation];
  [self testProfileId_GivenPreviouslyDeclaredOne_ForIntegration:CR_IntegrationMopubAppBidding];
  [self testProfileId_GivenPreviouslyDeclaredOne_ForIntegration:CR_IntegrationGamAppBidding];
  [self testProfileId_GivenPreviouslyDeclaredOne_ForIntegration:CR_IntegrationCustomAppBidding];
}

- (void)testProfileId_GivenPreviouslyDeclaredOne_ForIntegration:(CR_IntegrationType)integration {
  [self.integrationRegistry declare:integration];
  NSNumber *profileId = self.integrationRegistry.profileId;

  XCTAssertEqualObjects(profileId, @(integration));
}

- (void)testProfileId_GivenPreviouslyDeclaredOneAndNewSession_ReturnDeclaredOne {
  [self.integrationRegistry declare:CR_IntegrationInHouse];

  [self setUp];
  NSNumber *profileId = self.integrationRegistry.profileId;

  XCTAssertEqualObjects(profileId, @(CR_IntegrationInHouse));
}

- (void)testProfileId_GivenStandaloneDeclaredButMoPubMediationIsDetected_ReturnMoPubMediation {
  OCMStub(self.integrationRegistry.isMoPubMediationPresent).andReturn(YES);

  [self.integrationRegistry declare:CR_IntegrationStandalone];
  NSNumber *profileId = self.integrationRegistry.profileId;

  XCTAssertEqualObjects(profileId, @(CR_IntegrationMopubMediation));
}

- (void)testProfileId_GivenStandaloneDeclaredButAdMobMediationIsDetected_ReturnAdMobMediation {
  OCMStub(self.integrationRegistry.isAdMobMediationPresent).andReturn(YES);

  [self.integrationRegistry declare:CR_IntegrationStandalone];
  NSNumber *profileId = self.integrationRegistry.profileId;

  XCTAssertEqualObjects(profileId, @(CR_IntegrationAdmobMediation));
}

- (void)testProfileId_GivenBothMediationAdaptersDetected_ReturnFallback {
  OCMStub(self.integrationRegistry.isMoPubMediationPresent).andReturn(YES);
  OCMStub(self.integrationRegistry.isAdMobMediationPresent).andReturn(YES);

  NSNumber *profileId = self.integrationRegistry.profileId;

  XCTAssertEqualObjects(profileId, @(CR_IntegrationFallback));
}

- (void)testIsMoPubMediationPresent_GivenMoPubMediationNotInRuntime_ReturnNo {
  // Assume that no adapters are present in this runtime

  BOOL isPresent = self.integrationRegistry.isMoPubMediationPresent;

  XCTAssertFalse(isPresent);
}

- (void)testIsAdMobMediationPresent_GivenAdMobMediationNotInRuntime_ReturnNo {
  // Assume that no adapters are present in this runtime

  BOOL isPresent = self.integrationRegistry.isAdMobMediationPresent;

  XCTAssertFalse(isPresent);
}

@end
