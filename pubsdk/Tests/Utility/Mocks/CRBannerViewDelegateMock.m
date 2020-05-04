//
//  CRBannerViewDelegateMock.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRBannerViewDelegateMock.h"

@implementation CRBannerViewDelegateMock

- (instancetype)init {
    if (self = [super init]) {
        _didFailToReceiveAdWithErrorExpectation = [[XCTestExpectation alloc] initWithDescription:@"banner:didFailToReceiveAdWithError: call"];
        _didReceiveAdExpectation = [[XCTestExpectation alloc] initWithDescription:@"bannerDidReceiveAd: call"];
        _willLeaveApplicationExpectation = [[XCTestExpectation alloc] initWithDescription:@"bannerWillLeaveApplication: call"];
        _wasClickedExpectation = [[XCTestExpectation alloc] initWithDescription:@"bannerWasClicked: call"];
    }
    return self;
}

- (NSArray<XCTestExpectation *> *)allExpectations {
    return @[
        self.didFailToReceiveAdWithErrorExpectation,
        self.didReceiveAdExpectation,
        self.willLeaveApplicationExpectation,
        self.wasClickedExpectation
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
