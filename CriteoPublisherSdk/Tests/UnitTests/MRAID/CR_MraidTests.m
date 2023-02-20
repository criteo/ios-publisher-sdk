//
//  CR_MraidTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2023 Criteo. All rights reserved.
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
#import "CRMRAIDUtils.h"
#import "CRBannerView+Internal.h"
#import "CRBannerAdUnit.h"
#import "CRAdUnit+Internal.h"
#import "CRMRAIDConstants.h"

@interface CR_MraidTests : XCTestCase

@end

@implementation CR_MraidTests

- (void)testMraidInjectScript {
  NSBundle *mraidBundle = [self mraidBundle];
  NSString *mraid = [CRMRAIDUtils loadMraidFromBundle:mraidBundle];
  NSString *html = @"<html><head></head><body></body></html>";
  html = [CRMRAIDUtils insertMraid:html fromBundle:mraidBundle];
  XCTAssertTrue([html containsString:mraid]);
}

- (NSBundle *)mraidBundle {
  for (NSBundle *bundle in [NSBundle allBundles]) {
    if ([[bundle bundlePath] hasSuffix:@"xctest"]) {
      return [NSBundle bundleWithPath:[bundle pathForResource:CR_MRAID_BUNDLE
                                                       ofType:CR_MRAID_BUNDLE_EXTENSION]];
    }
  }
  return NULL;
}

@end
