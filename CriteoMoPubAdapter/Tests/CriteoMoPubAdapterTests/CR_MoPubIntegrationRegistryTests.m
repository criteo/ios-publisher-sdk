//
//  CR_MoPubIntegrationRegistryTests.h
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

#import <XCTest/XCTest.h>

@interface CR_MoPubIntegrationRegistryTests : XCTestCase
@end

@implementation CR_MoPubIntegrationRegistryTests

- (void)testIsMoPubMediationPresent_GivenThisAdapterInRuntime_ReturnYes {
  id integrationRegistry = [self newIntegrationRegistry];

  BOOL isPresent = [[integrationRegistry valueForKey:@"isMoPubMediationPresent"] boolValue];

  XCTAssertNotNil(integrationRegistry);
  XCTAssertTrue(isPresent);
}

- (void)testIsAdMobMediationPresent_GivenThisAdapterInRuntime_ReturnNo {
  id integrationRegistry = [self newIntegrationRegistry];

  BOOL isPresent = [[integrationRegistry valueForKey:@"isAdMobMediationPresent"] boolValue];

  XCTAssertNotNil(integrationRegistry);
  XCTAssertFalse(isPresent);
}

- (id)newIntegrationRegistry {
  Class klass = NSClassFromString(@"CR_IntegrationRegistry");
  return klass.new;
}

@end