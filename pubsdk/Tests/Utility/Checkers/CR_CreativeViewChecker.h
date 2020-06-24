//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRBannerView.h"
#import "Criteo.h"
#import <XCTest/XCTest.h>

@interface CR_CreativeViewChecker : NSObject <CRBannerViewDelegate>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithAdUnit:(CRBannerAdUnit *)adUnit criteo:(Criteo *)criteo;

@property(strong, nonatomic, readonly) UIWindow *uiWindow;
@property(strong, nonatomic, readonly) XCTestExpectation *bannerViewFailToReceiveAdExpectation;
@property(strong, nonatomic, readonly) XCTestExpectation *bannerViewDidReceiveAdExpectation;
@property(strong, nonatomic, readonly) XCTestExpectation *adCreativeRenderedExpectation;
@property(strong, nonatomic, readonly) CRBannerView *bannerView;
@property(strong, nonatomic, readonly) CRBannerAdUnit *adUnit;
@property(weak, nonatomic, readonly) Criteo *criteo;
@property(copy, nonatomic) NSString *expectedCreativeUrl;

- (void)resetExpectations;

- (void)resetBannerView;

- (void)injectBidWithExpectedCreativeUrl:(NSString *)creativeUrl;

@end
