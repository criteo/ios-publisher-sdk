//
//  CRBannerViewDelegateMock.m
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

#import "CRBannerViewDelegateMock.h"

@implementation CRBannerViewDelegateMock

- (instancetype)init {
  if (self = [super init]) {
    _didFailToReceiveAdWithErrorExpectation =
        [[XCTestExpectation alloc] initWithDescription:@"banner:didFailToReceiveAdWithError: call"];
    _didReceiveAdExpectation =
        [[XCTestExpectation alloc] initWithDescription:@"bannerDidReceiveAd: call"];
    _willLeaveApplicationExpectation =
        [[XCTestExpectation alloc] initWithDescription:@"bannerWillLeaveApplication: call"];
    _wasClickedExpectation =
        [[XCTestExpectation alloc] initWithDescription:@"bannerWasClicked: call"];
  }
  return self;
}

- (NSArray<XCTestExpectation *> *)allExpectations {
  return @[
    self.didFailToReceiveAdWithErrorExpectation, self.didReceiveAdExpectation,
    self.willLeaveApplicationExpectation, self.wasClickedExpectation
  ];
}

- (void)invertAllExpectations {
  self.didFailToReceiveAdWithErrorExpectation.inverted = YES;
  self.didReceiveAdExpectation.inverted = YES;
  self.willLeaveApplicationExpectation.inverted = YES;
  self.wasClickedExpectation.inverted = YES;
}

- (void)banner:(CRBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
  if ((self.expectedError == nil) || [self.expectedError isEqual:error]) {
    [self.didFailToReceiveAdWithErrorExpectation fulfill];
  }
}

- (void)bannerDidReceiveAd:(CRBannerView *)bannerView {
  [self.didReceiveAdExpectation fulfill];
}

- (void)bannerWillLeaveApplication:(CRBannerView *)bannerView {
  [self.willLeaveApplicationExpectation fulfill];
}

- (void)bannerWasClicked:(CRBannerView *)bannerView {
  [self.wasClickedExpectation fulfill];
}

@end
