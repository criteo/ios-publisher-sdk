//
//  CR_InterstitialChecker.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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
    _intertitial = [[CRInterstitial alloc] initWithAdUnit:adUnit criteo:criteo];
    _intertitial.delegate = self;
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
