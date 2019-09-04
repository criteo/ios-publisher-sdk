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

// Private property
@interface CRBannerCustomEvent ()

@property(nonatomic, strong) CRBannerView *bannerView;

@end

// Test-only initializer
@interface CRBannerCustomEvent (Test)

- (instancetype)initWithBannerView:(CRBannerView *)bannerView;

@end


@implementation CRBannerCustomEvent (Test)

- (instancetype)initWithBannerView:(CRBannerView *)bannerView {
    if(self = [super init]) {
        self.bannerView = bannerView;
    }
    return self;
}

@end

@protocol GADCustomEventBannerDelegateDeprecated <NSObject>
- (void)customEventBanner:(id<GADCustomEventBanner>)customEvent didReceiveAd:(UIView *)view;
- (void)customEventBanner:(id<GADCustomEventBanner>)customEvent didFailAd:(nullable NSError *)error;
@property(nonatomic, readonly) UIViewController *viewControllerForPresentingModalView;
- (void)customEventBannerWillPresentModal:(id<GADCustomEventBanner>)customEvent;
- (void)customEventBannerWillDismissModal:(id<GADCustomEventBanner>)customEvent;
- (void)customEventBannerDidDismissModal:(id<GADCustomEventBanner>)customEvent;
- (void)customEventBannerWillLeaveApplication:(id<GADCustomEventBanner>)customEvent;
- (void)customEventBanner:(id<GADCustomEventBanner>)customEvent clickDidOccurInAd:(UIView *)view GAD_DEPRECATED_MSG_ATTRIBUTE("Use customEventBannerWasClicked:.");
@end

#define SERVER_PARAMETER @"{\"cpId\":\"testCpId\",\"adUnitId\":\"testAdUnitId\"}"

@implementation CRBannerCustomEventTests

- (void)testRequestBannerAdSuccess {
    CRBannerView *mockCRBannerView = OCMStrictClassMock([CRBannerView class]);
    CRBannerAdUnit *bannerAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:@"testAdUnitId"
                                                                       size:CGSizeMake(320, 50)];
    CRBannerCustomEvent *customEvent = [[CRBannerCustomEvent alloc] initWithBannerView:mockCRBannerView];

    OCMStub([mockCRBannerView loadAd]);
    OCMStub([mockCRBannerView setDelegate:customEvent]);
    
    id mockCriteo = OCMClassMock([Criteo class]);
    OCMStub([mockCriteo sharedCriteo]).andReturn(mockCriteo);
    OCMStub([mockCriteo registerCriteoPublisherId:@"testCpId" withAdUnits:@[bannerAdUnit]]);
    
    [customEvent requestBannerAd:kGADAdSizeBanner parameter:SERVER_PARAMETER label:nil
                            request:[GADCustomEventRequest new]];
    
    OCMVerify([mockCRBannerView loadAd]);
    OCMVerify([mockCRBannerView setDelegate:customEvent]);
    OCMVerify([mockCriteo registerCriteoPublisherId:@"testCpId" withAdUnits:@[bannerAdUnit]]);
}

- (void)testRequestBannerAdFail {
    CRBannerCustomEvent *customEvent = [CRBannerCustomEvent new];
    id mockGADBannerDelegate = OCMStrictProtocolMock(@protocol(GADCustomEventBannerDelegate));
    OCMExpect([mockGADBannerDelegate customEventBanner:customEvent didFailAd:[NSError errorWithDomain:kGADErrorDomain
                                                                                                 code:kGADErrorInvalidArgument
                                                                                             userInfo:nil]]);
    NSString *invalid = @"{\"cpIDD\":\"testCpId\"}";
    customEvent.delegate = mockGADBannerDelegate;
    GADCustomEventRequest *request = [GADCustomEventRequest new];
    [customEvent requestBannerAd:kGADAdSizeLargeBanner parameter:invalid label:nil request:request];
    OCMVerifyAllWithDelay(mockGADBannerDelegate, 1);
}

#pragma mark CRBannerViewDelegate tests

- (void)testDidReceiveAdDelegate {
    CRBannerCustomEvent *customEvent = [CRBannerCustomEvent new];
    CRBannerView *bannerView = [CRBannerView new];
    id mockGADBannerDelegate = OCMStrictProtocolMock(@protocol(GADCustomEventBannerDelegate));
    OCMExpect([mockGADBannerDelegate customEventBanner:customEvent didReceiveAd:bannerView]);
    customEvent.delegate = mockGADBannerDelegate;
    [customEvent bannerDidReceiveAd:bannerView];
    OCMVerifyAll(mockGADBannerDelegate);
}

- (void)testDidFailToReceiveAdDelegate {
    CRBannerCustomEvent *customEvent = [CRBannerCustomEvent new];
    id mockGADBannerDelegate = OCMStrictProtocolMock(@protocol(GADCustomEventBannerDelegate));
    NSError *criteoError = [NSError errorWithDomain:@"test domain"
                                               code:0
                                           userInfo:[NSDictionary dictionaryWithObject:@"test description"
                                                                                forKey:NSLocalizedDescriptionKey]];
    NSError *expectedError = [NSError errorWithDomain:kGADErrorDomain
                                                 code:kGADErrorNoFill
                                             userInfo:[NSDictionary dictionaryWithObject:criteoError.description
                                                                                  forKey:NSLocalizedDescriptionKey]];
    OCMExpect([mockGADBannerDelegate customEventBanner:customEvent didFailAd:expectedError]);
    customEvent.delegate = mockGADBannerDelegate;
    [customEvent banner:[CRBannerView new] didFailToReceiveAdWithError:criteoError];
    OCMVerifyAll(mockGADBannerDelegate);
}

- (void)testWillLeaveApplicationDelegate {
    CRBannerCustomEvent *customEvent = [CRBannerCustomEvent new];
    id mockGADBannerDelegate = OCMStrictProtocolMock(@protocol(GADCustomEventBannerDelegate));
    OCMExpect([mockGADBannerDelegate customEventBannerWasClicked:customEvent]);
    OCMExpect([mockGADBannerDelegate customEventBannerWillLeaveApplication:customEvent]);
    customEvent.delegate = mockGADBannerDelegate;
    [customEvent bannerWillLeaveApplication:[CRBannerView new]];
    OCMVerifyAll(mockGADBannerDelegate);
}

- (void)testWillLeaveApplicationDelegateDeprecated {
    CRBannerCustomEvent *customEvent = [CRBannerCustomEvent new];
    id mockGADBannerDelegate = OCMStrictProtocolMock(@protocol(GADCustomEventBannerDelegateDeprecated));
    CRBannerView *bannerView = [CRBannerView new];
    OCMExpect([mockGADBannerDelegate customEventBanner:customEvent clickDidOccurInAd:bannerView]);
    OCMExpect([mockGADBannerDelegate customEventBannerWillLeaveApplication:customEvent]);
    customEvent.delegate = mockGADBannerDelegate;
    [customEvent bannerWillLeaveApplication:bannerView];
    OCMVerifyAll(mockGADBannerDelegate);
}

@end
