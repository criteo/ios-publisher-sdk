//
//  CRInterstitialCustomEventTests.m
//  CriteoMoPubAdapterTests
//
//  Copyright © 2019 Criteo. All rights reserved.
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
#import <MoPub.h>
@import CriteoPublisherSdk;

// Private property (duplicates code in CRIntrstitialCustomEvent.m so that we can use it in testing)
@interface CRInterstitialCustomEvent ()

@property (nonatomic, strong) CRInterstitial *interstitial;

@end

// Test-only initializer
@interface CRInterstitialCustomEvent (Test)

- (instancetype) initWithInterstitial:(CRInterstitial *)crInterstitial;

@end

@implementation CRInterstitialCustomEvent (Test)

- (instancetype) initWithInterstitial:(CRInterstitial *)crInterstitial {
    if (self = [super init]) {
        self.interstitial = crInterstitial;
    }
    return self;
}

@end

@interface CRInterstitialCustomEventTests :XCTestCase

@end

@implementation CRInterstitialCustomEventTests

{
    NSString *adUnitId;
    NSDictionary *info;
    NSString *publisherId;
    id mockInterstitial;
    id mockDelegate;
}

- (void) setUp {
    adUnitId = @"some/test/InterstitialId";
    publisherId = @"untiTestPublisher";
    info = @{@"cpId": publisherId, @"adUnitId" : adUnitId};
    mockInterstitial = OCMClassMock([CRInterstitial class]);
    mockDelegate = OCMStrictProtocolMock(@protocol(MPInterstitialCustomEventDelegate));
}

- (void)tearDown {
    adUnitId = nil;
    publisherId = nil;
    info = nil;
    mockInterstitial = nil;
    mockDelegate = nil;
}

- (void) testCriteoRegistration {
    id mockCriteo = [OCMockObject partialMockForObject:[Criteo sharedCriteo]];
    CRInterstitialAdUnit *adUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:adUnitId];
    OCMExpect([mockCriteo registerCriteoPublisherId:info[@"cpId"] withAdUnits:@[adUnit]]);

    CRInterstitialCustomEvent *interstitialEvent = [[CRInterstitialCustomEvent alloc] initWithInterstitial:mockInterstitial];
    [interstitialEvent requestInterstitialWithCustomEventInfo:info];
    OCMVerifyAll(mockCriteo);
}

- (void) testIncorrectDataFromMoPub {
    NSDictionary *badInfoFromMoPub = @{@"cpId" : publisherId, @"adUnitId" : @""};

    CRInterstitialCustomEvent *event = [[CRInterstitialCustomEvent alloc] initWithInterstitial:mockInterstitial];
    event.delegate = mockDelegate;

    OCMExpect([mockDelegate interstitialCustomEvent:event
                           didFailToLoadAdWithError:[NSError errorWithCode:MOPUBErrorServerError
                                                      localizedDescription:@"Criteo Interstitial ad request failed due to invalid server parameters."]]);

    [event requestInterstitialWithCustomEventInfo:badInfoFromMoPub];
    OCMVerifyAllWithDelay(mockDelegate, 2);
}

- (void) testCorrectDataFromMoPub {
    CRInterstitialCustomEvent *event = [[CRInterstitialCustomEvent alloc] initWithInterstitial:mockInterstitial];
    event.delegate = mockDelegate;

    OCMStub([mockInterstitial loadAd]).andDo(^(NSInvocation *invocation){
        [event interstitialDidReceiveAd:self->mockInterstitial];
        [event interstitialIsReadyToPresent:self->mockInterstitial];
    });

    OCMExpect([mockDelegate interstitialCustomEvent:event didLoadAd:mockInterstitial]);
    OCMExpect([mockInterstitial setDelegate:event]);

    [event requestInterstitialWithCustomEventInfo:info];
    OCMVerifyAll(mockDelegate);
    OCMVerifyAll(mockInterstitial);
}

- (void) testCrInterstitialShowIsCalled {
    CRInterstitialCustomEvent *event = [[CRInterstitialCustomEvent alloc] initWithInterstitial:mockInterstitial];

    id mockViewController = OCMClassMock([UIViewController class]);
    OCMExpect([mockInterstitial presentFromRootViewController:mockViewController]);

    [event showInterstitialFromRootViewController:mockViewController];
    OCMVerifyAll(mockInterstitial);
}

- (void) testAdFailedToLoad {
    CRInterstitialCustomEvent *event = [[CRInterstitialCustomEvent alloc] initWithInterstitial:mockInterstitial];
    event.delegate = mockDelegate;

    OCMStub([mockInterstitial loadAd]).andDo(^(NSInvocation *invocation){
        [event interstitial:self->mockInterstitial didFailToReceiveAdWithError:[NSError errorWithCode:1]];
    });

    NSError *criteoError = [NSError errorWithCode:1];
    NSString *description = [NSString stringWithFormat:@"Criteo Interstitial failed to load with error : %@"
                             , criteoError.localizedDescription];
    NSError *expectedError = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:description];

    OCMExpect([mockDelegate interstitialCustomEvent:event didFailToLoadAdWithError:expectedError]);
    [event requestInterstitialWithCustomEventInfo:info];
    OCMVerifyAll(mockDelegate);
}

- (void) testAdReceivedButFailedToLoadContent {
    CRInterstitialCustomEvent *event = [[CRInterstitialCustomEvent alloc] initWithInterstitial:mockInterstitial];
    event.delegate = mockDelegate;

    OCMStub([mockInterstitial loadAd]).andDo(^(NSInvocation *invocation){
        [event interstitialDidReceiveAd:self->mockInterstitial];
        [event interstitial:self->mockInterstitial didFailToReceiveAdContentWithError:[NSError errorWithCode:1]];
    });

    NSError *criteoError = [NSError errorWithCode:1];
    NSString *description = [NSString stringWithFormat:@"Criteo Interstitial failed to load ad content with error : %@"
                             , criteoError.localizedDescription];
    NSError *expectedError = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:description];

    OCMExpect([mockDelegate interstitialCustomEvent:event didFailToLoadAdWithError:expectedError]);
    [event requestInterstitialWithCustomEventInfo:info];
    OCMVerifyAll(mockDelegate);
}

- (void) testAppearDelegates {
    CRInterstitialCustomEvent *event = [[CRInterstitialCustomEvent alloc] initWithInterstitial:mockInterstitial];
    event.delegate = mockDelegate;

    OCMStub([mockInterstitial loadAd]).andDo(^(NSInvocation *invocation){
        [event interstitialWillAppear:self->mockInterstitial];
        [event interstitialDidAppear:self->mockInterstitial];
    });

    OCMExpect([mockDelegate interstitialCustomEventWillAppear:event]);
    OCMExpect([mockDelegate interstitialCustomEventDidAppear:event]);
    [event requestInterstitialWithCustomEventInfo:info];
    OCMVerifyAll(mockDelegate);
}

- (void) testDisappearDelegates {
    CRInterstitialCustomEvent *event = [[CRInterstitialCustomEvent alloc] initWithInterstitial:mockInterstitial];
    event.delegate = mockDelegate;

    OCMStub([mockInterstitial loadAd]).andDo(^(NSInvocation *invocation){
        [event interstitialWillDisappear:self->mockInterstitial];
        [event interstitialDidDisappear:self->mockInterstitial];
    });

    OCMExpect([mockDelegate interstitialCustomEventWillDisappear:event]);
    OCMExpect([mockDelegate interstitialCustomEventDidDisappear:event]);

    [event requestInterstitialWithCustomEventInfo:info];
    OCMVerifyAll(mockDelegate);
}

- (void) testInterstitialWillLeaveApplicationDelegate {
    CRInterstitialCustomEvent *event = [[CRInterstitialCustomEvent alloc] initWithInterstitial:mockInterstitial];
    event.delegate = mockDelegate;

    OCMStub([mockInterstitial loadAd]).andDo(^(NSInvocation *invocation){
        [event interstitialWillLeaveApplication:self->mockInterstitial];
    });

    OCMExpect([mockDelegate interstitialCustomEventWillLeaveApplication:event]);
    OCMExpect([mockDelegate interstitialCustomEventDidReceiveTapEvent:event]);

    [event requestInterstitialWithCustomEventInfo:info];
    OCMVerifyAll(mockDelegate);
}

@end
