//
//  CR_CreativeViewChecker.h
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

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "Criteo.h"
#import "CRBannerView.h"
#import "CRInterstitial.h"

@interface CR_CreativeViewChecker : NSObject <CRBannerViewDelegate, CRInterstitialDelegate>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithAdUnit:(CRAdUnit *)adUnit criteo:(Criteo *)criteo;

@property(strong, nonatomic, readonly) UIWindow *uiWindow;
@property(strong, nonatomic, readonly) XCTestExpectation *failToReceiveAdExpectation;
@property(strong, nonatomic, readonly) XCTestExpectation *didReceiveAdExpectation;
@property(strong, nonatomic, readonly) XCTestExpectation *adCreativeRenderedExpectation;
@property(strong, nonatomic, readonly) CRBannerView *bannerView;
@property(strong, nonatomic, readonly) CRInterstitial *interstitial;
@property(strong, nonatomic, readonly) CRAdUnit *adUnit;
@property(weak, nonatomic, readonly) Criteo *criteo;
@property(copy, nonatomic) NSString *expectedCreativeUrl;

- (void)resetExpectations;

- (void)resetBannerView;

- (void)injectBidWithExpectedCreativeUrl:(NSString *)creativeUrl;

- (void)injectBidWithAppStoreClickUrl;
- (void)clickUrl;

@end
