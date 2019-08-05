//
//  CRBannerCustomEventTests.m
//  CriteoGoogleAdapterTests
//
//  Copyright © 2019 Criteo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
//  in compliance with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License
//  is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
//  or implied. See the License for the specific language governing permissions and limitations under
//  the License.

#import <XCTest/XCTest.h>
#import "CRBannerCustomEvent.h"
#import <OCMock.h>

@interface CRBannerCustomEventTests : XCTestCase

@end

@implementation CRBannerCustomEventTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCustomEventDelegateFailWhenParametersisNil {
    CRBannerCustomEvent *customEvent = [CRBannerCustomEvent new];
    id mockGADBannerDelegate = OCMStrictProtocolMock(@protocol(GADCustomEventBannerDelegate));
    OCMExpect([mockGADBannerDelegate customEventBanner:customEvent didFailAd:[OCMArg any]]);
    NSString *invalid = @"{\"cpIDD\":\"testCpId\"}";
    customEvent.delegate = mockGADBannerDelegate;
    GADCustomEventRequest *request = [GADCustomEventRequest new];
    [customEvent requestBannerAd:kGADAdSizeLargeBanner parameter:invalid label:nil request:request];
    OCMVerifyAllWithDelay(mockGADBannerDelegate, 1);
}

#pragma mark CRInterstitial Delegate tests

- (void)testDidReceiveAdDelegate {
    CRBannerCustomEvent *customEvent = [CRBannerCustomEvent new];
    CRBannerView *bannerView = [CRBannerView new];
    id mockGADBannerDelegate = OCMStrictProtocolMock(@protocol(GADCustomEventBannerDelegate));
    OCMExpect([mockGADBannerDelegate customEventBanner:customEvent didReceiveAd:bannerView]);
    customEvent.delegate = mockGADBannerDelegate;
    [customEvent bannerDidReceiveAd:bannerView];
    OCMVerifyAll(mockGADBannerDelegate);
}

@end
