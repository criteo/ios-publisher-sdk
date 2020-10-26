//
//  CR_InterstitialChecker.m
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
#import "CR_InterstitialChecker.h"
#import "Criteo.h"
#import "CRInterstitial+Internal.h"
#import "CRInterstitialAdUnit.h"
#import "CRInterstitialDelegate.h"

@interface CR_InterstitialChecker () <CRInterstitialDelegate>

@property(strong, nonatomic, readonly) Criteo *criteo;
@property(strong, nonatomic, readonly) CRInterstitialAdUnit *adUnit;

@property(strong, nonatomic) XCTestExpectation *receiveAdExpectation;
@property(strong, nonatomic) XCTestExpectation *failToReceiveAdExpectation;

@end

@implementation CR_InterstitialChecker

- (instancetype)initWithAdUnit:(CRInterstitialAdUnit *)adUnit criteo:(Criteo *)criteo {
  if (self = [super init]) {
    _receiveAdExpectation = [[XCTestExpectation alloc]
        initWithDescription:@"CRInterstitialDelegate.interstitialDidReceiveAd called"];
    _failToReceiveAdExpectation = [[XCTestExpectation alloc]
        initWithDescription:@"CRInterstitialDelegate.didFailToReceiveAdWithError called"];
    _criteo = criteo;
    _adUnit = adUnit;
    _interstitial = [[CRInterstitial alloc] initWithAdUnit:adUnit criteo:criteo];
    _interstitial.delegate = self;
  }
  return self;
}

#pragma mark - Public

- (void)resetExpectations {
  self.receiveAdExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"CRInterstitialDelegate.interstitialDidReceiveAd called"];
  self.failToReceiveAdExpectation = [[XCTestExpectation alloc]
      initWithDescription:@"CRInterstitialDelegate.didFailToReceiveAdWithError called"];
}

#pragma mark - CRInterstitialDelegate

- (void)interstitialDidReceiveAd:(CRInterstitial *)interstitial {
  [self.receiveAdExpectation fulfill];
}

- (void)interstitial:(CRInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error {
  [self.failToReceiveAdExpectation fulfill];
}

@end
