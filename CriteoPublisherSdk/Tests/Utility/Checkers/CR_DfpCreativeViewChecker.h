//
//  CR_DfpCreativeViewChecker.h
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

@import GoogleMobileAds;

@interface CR_DfpCreativeViewChecker : NSObject <GADBannerViewDelegate, GADInterstitialDelegate>

@property(strong, nonatomic, readonly) XCTestExpectation *adCreativeRenderedExpectation;
@property(weak, nonatomic, readonly) UIWindow *uiWindow;
@property(strong, nonatomic, readonly) DFPBannerView *dfpBannerView;
@property(strong, nonatomic, readonly) DFPInterstitial *dfpInterstitial;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithBannerWithSize:(GADAdSize)size withAdUnitId:(NSString *)adUnitId;
- (instancetype)initWithInterstitial:(DFPInterstitial *)dfpInterstitial;
- (BOOL)waitAdCreativeRendered;
- (BOOL)waitAdCreativeRenderedWithTimeout:(NSTimeInterval)timeout;

@end
