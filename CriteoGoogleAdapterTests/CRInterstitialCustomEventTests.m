//
//  CRInterstitialCustomEventTests.m
//  CriteoGoogleAdapterTests
//
// Copyright © 2019 Criteo. All rights reserved.
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

#import <XCTest/XCTest.h>
#import "CRInterstitialCustomEvent.h"
#import <OCMock.h>

@interface CRInterstitialCustomEventTests : XCTestCase
{
NSString *_serverParameter;
}
@end

@implementation CRInterstitialCustomEventTests

- (void)setUp {
    _serverParameter = nil;
}

- (void)stubMockCRInterstitial:(id)mock mockAdUnit:(id)mockAdUnit {
    OCMStub([mock alloc]).andReturn(mock);
    OCMStub([mock initWithAdUnit:mockAdUnit]).andReturn(mock);
}

- (void)stubMockCRAdUnit:(id)mock {
    OCMStub([mock alloc]).andReturn(mock);
    OCMStub([mock initWithAdUnitId:@"testAdUnitId"]).andReturn(mock);
}

- (NSString *)serverParameter {
    if(!_serverParameter) {
        _serverParameter = @"{\"cpId\":\"testCpId\",\"adUnitId\":\"testAdUnitId\"}";
    }
    return _serverParameter;
}

- (void)testCustomEventDelegateFailWhenParametersisNil {
    CRInterstitialCustomEvent *customEvent = [CRInterstitialCustomEvent new];
    id mockGADInterstitialDelegate = OCMStrictProtocolMock(@protocol(GADCustomEventInterstitialDelegate));
    OCMExpect([mockGADInterstitialDelegate customEventInterstitial:customEvent didFailAd:[OCMArg any]]);
    NSString *invalidServerParameter = @"{\"cpIDD\":\"testCpId\"}";
    customEvent.delegate = mockGADInterstitialDelegate;
    [customEvent requestInterstitialAdWithParameter:invalidServerParameter label:nil request:[GADCustomEventRequest new]];
    OCMVerifyAll(mockGADInterstitialDelegate);
}

- (void)testLoadAndPresentFromRootViewController {
    CRInterstitialCustomEvent *customEvent = [CRInterstitialCustomEvent new];

    id mockCRInterstitialAdUnit = OCMStrictClassMock([CRInterstitialAdUnit class]);
    [self stubMockCRAdUnit:mockCRInterstitialAdUnit];
    UIViewController *realVC = [UIViewController new];
    id mockCRInterstitial = OCMStrictClassMock([CRInterstitial class]);
    [self stubMockCRInterstitial:mockCRInterstitial mockAdUnit:mockCRInterstitialAdUnit];

    OCMExpect([mockCRInterstitial loadAd]);
    OCMExpect([mockCRInterstitial presentFromRootViewController:realVC]);

    id mockCriteo = OCMStrictClassMock([Criteo class]);
    OCMStub([mockCriteo sharedCriteo]).andReturn(mockCriteo);
    OCMExpect([mockCriteo registerCriteoPublisherId:@"testCpId" withAdUnits:@[mockCRInterstitialAdUnit]]);

    [customEvent requestInterstitialAdWithParameter:[self serverParameter] label:nil request:[GADCustomEventRequest new]];
    [customEvent presentFromRootViewController:realVC];

    OCMVerifyAll(mockCRInterstitial);
    OCMVerifyAll(mockCriteo);
}

@end
