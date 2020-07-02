//
//  CR_NativeLoaderDispatchChecker.m
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
#import "CR_NativeLoaderDispatchChecker.h"
#import "CRNativeLoader+Internal.h"

@implementation CR_NativeLoaderDispatchChecker

- (instancetype)init {
  self = [super init];
  if (self) {
    _didFailOnMainQueue =
        [[XCTestExpectation alloc] initWithDescription:@"Delegate should be called on main queue"];
    _didReceiveOnMainQueue =
        [[XCTestExpectation alloc] initWithDescription:@"Delegate should be called on main queue"];
    _didDetectImpression =
        [[XCTestExpectation alloc] initWithDescription:@"Delegate should be called on main queue"];
    _didDetectClick =
        [[XCTestExpectation alloc] initWithDescription:@"Delegate should be called on main queue"];
    _willLeaveApplicationForNativeAd =
        [[XCTestExpectation alloc] initWithDescription:@"Delegate should be called on main queue"];
  }
  return self;
}

- (void)nativeLoader:(CRNativeLoader *)loader didReceiveAd:(CRNativeAd *)ad {
  if (@available(iOS 10.0, *)) {
    dispatch_assert_queue(dispatch_get_main_queue());
  }
  [self.didReceiveOnMainQueue fulfill];
}

- (void)nativeLoader:(CRNativeLoader *)loader didFailToReceiveAdWithError:(NSError *)error {
  if (@available(iOS 10.0, *)) {
    dispatch_assert_queue(dispatch_get_main_queue());
  }
  [self.didFailOnMainQueue fulfill];
}

- (void)nativeLoaderDidDetectImpression:(CRNativeLoader *)loader {
  if (@available(iOS 10.0, *)) {
    dispatch_assert_queue(dispatch_get_main_queue());
  }
  [self.didDetectImpression fulfill];
}

- (void)nativeLoaderDidDetectClick:(CRNativeLoader *)loader {
  if (@available(iOS 10.0, *)) {
    dispatch_assert_queue(dispatch_get_main_queue());
  }
  [self.didDetectClick fulfill];
}

- (void)nativeLoaderWillLeaveApplication:(CRNativeLoader *)loader {
  if (@available(iOS 10.0, *)) {
    dispatch_assert_queue(dispatch_get_main_queue());
  }
  [self.willLeaveApplicationForNativeAd fulfill];
}

@end
