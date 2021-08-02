//
//  CR_URLOpenerTests.m
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

#import "CR_URLOpener.h"
#import "CR_SKAdNetworkParameters.h"

@interface CR_URLOpenerTests : XCTestCase
@end

@interface CR_URLOpener (Testing)
- (void)presentStoreKitControllerWithProductParameters:(NSDictionary *)parameters
                                    fromViewController:(UIViewController *)controller
                                        withCompletion:(CR_URLOpeningCompletion)completion;
@end

@implementation CR_URLOpenerTests

- (void)testOpenAppStoreURLWithSKAdNetworkParameters {
  // this assertions does not work for versions lower than 14, url will be opened otherwise
  if (@available(iOS 14, *)) {
    CR_URLOpener *opener = OCMPartialMock([[CR_URLOpener alloc] init]);
    OCMExpect([opener presentStoreKitControllerWithProductParameters:OCMArg.any
                                                  fromViewController:OCMArg.any
                                                      withCompletion:OCMArg.any]);
    OCMReject([opener openExternalURL:OCMArg.any withCompletion:OCMArg.any]);
    [opener openExternalURL:[NSURL URLWithString:@"https://apps.apple.com/whatever"]
        withSKAdNetworkParameters:[self buildParameters]
                         fromView:[[UIView alloc] init]
                       completion:^(BOOL success) {
                         XCTAssertTrue(success);
                       }];
    OCMVerifyAll(opener);
  }
}

- (void)testOpenAppStoreURLWithoutSKAdNetworkParameters {
  CR_URLOpener *opener = OCMPartialMock([[CR_URLOpener alloc] init]);
  OCMReject([opener presentStoreKitControllerWithProductParameters:OCMArg.any
                                                fromViewController:OCMArg.any
                                                    withCompletion:OCMArg.any]);
  OCMExpect([opener openExternalURL:OCMArg.any withCompletion:OCMArg.any]);
  [opener openExternalURL:[NSURL URLWithString:@"https://apps.apple.com/whatever"]
      withSKAdNetworkParameters:nil
                       fromView:[[UIView alloc] init]
                     completion:^(BOOL success) {
                       XCTAssertTrue(success);
                     }];
  OCMVerifyAll(opener);
}

- (CR_SKAdNetworkParameters *)buildParameters {
  return [[CR_SKAdNetworkParameters alloc] initWithNetworkId:@"networkId"
                                                     version:@"2.0"
                                                  campaignId:@1
                                                iTunesItemId:@12345
                                                       nonce:[NSUUID UUID]
                                                   timestamp:@123567890
                                                 sourceAppId:@67890
                                                   signature:@"tlkjlkj"];
}

@end
