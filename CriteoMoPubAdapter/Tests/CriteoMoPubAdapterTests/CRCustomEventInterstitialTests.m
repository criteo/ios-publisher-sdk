//
//  CRCustomEventInterstitialTests.m
//  CriteoMoPubAdapterTests
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

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CRCustomEventInterstitial.h"

@interface CRCustomEventInterstitial ()

@property(nonatomic, strong) CRInterstitial *interstitial;

@end

@interface CRCustomEventInterstitial (Test)

@property(nonatomic, weak) id<MPFullscreenAdAdapterDelegate> delegate;

- (void)requestAdWithAdapterInfo:(NSDictionary *)info;

@end

@implementation CRCustomEventInterstitial (Test)

- (void)requestAdWithAdapterInfo:(NSDictionary *)info {
  [self requestAdWithAdapterInfo:info adMarkup:nil];
}

@dynamic delegate;
static void *DelegateAssociationKey;

- (id)delegate {
  return objc_getAssociatedObject(self, DelegateAssociationKey);
}

- (void)setDelegate:(id)delegate {
  objc_setAssociatedObject(self, DelegateAssociationKey, delegate, OBJC_ASSOCIATION_ASSIGN);
}

@end

@interface CRCustomEventInterstitialTests : XCTestCase
@end

@implementation CRCustomEventInterstitialTests {
  NSString *adUnitId;
  NSDictionary *info;
  NSString *publisherId;
  id mockInterstitial;
  id mockDelegate;
  CRCustomEventInterstitial *event;
}

- (void)setUp {
  adUnitId = @"some/test/InterstitialId";
  publisherId = @"unitTestPublisher";
  info = @{@"cpId" : publisherId, @"adUnitId" : adUnitId};
  mockInterstitial = OCMClassMock([CRInterstitial class]);
  mockDelegate = OCMStrictProtocolMock(@protocol(MPFullscreenAdAdapterDelegate));
  event = [[CRCustomEventInterstitial alloc] init];
  event.interstitial = mockInterstitial;
  event.delegate = mockDelegate;
}

- (void)tearDown {
  adUnitId = nil;
  publisherId = nil;
  info = nil;
  mockInterstitial = nil;
  mockDelegate = nil;
}

- (void)testCriteoRegistration {
  id mockCriteo = [OCMockObject partialMockForObject:[Criteo sharedCriteo]];
  CRInterstitialAdUnit *adUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:adUnitId];
  OCMExpect([mockCriteo registerCriteoPublisherId:info[@"cpId"] withAdUnits:@[ adUnit ]]);

  [event requestAdWithAdapterInfo:info];
  OCMVerifyAll(mockCriteo);
}

- (void)testIncorrectDataFromMoPub {
  NSDictionary *badInfoFromMoPub = @{@"cpId" : publisherId, @"adUnitId" : @""};
  NSError *error =
      [NSError errorWithCode:MOPUBErrorServerError
          localizedDescription:
              @"Criteo Interstitial ad request failed due to invalid server parameters."];
  OCMExpect([mockDelegate fullscreenAdAdapter:event didFailToLoadAdWithError:error]);

  [event requestAdWithAdapterInfo:badInfoFromMoPub];
  OCMVerifyAllWithDelay(mockDelegate, 2);
}

- (void)testCorrectDataFromMoPub {
  OCMStub([mockInterstitial loadAd]).andDo(^(NSInvocation *invocation) {
    [self->event interstitialDidReceiveAd:self->mockInterstitial];
  });

  OCMExpect([mockDelegate fullscreenAdAdapterDidLoadAd:event]);
  OCMExpect([mockInterstitial setDelegate:event]);

  [event requestAdWithAdapterInfo:info];
  OCMVerifyAll(mockDelegate);
  OCMVerifyAll(mockInterstitial);
}

- (void)testCrInterstitialShowIsCalled {
  id mockViewController = OCMClassMock([UIViewController class]);
  OCMExpect([mockInterstitial presentFromRootViewController:mockViewController]);

  [event presentAdFromViewController:mockViewController];
  OCMVerifyAll(mockInterstitial);
}

- (void)testAdFailedToLoad {
  OCMStub([mockInterstitial loadAd]).andDo(^(NSInvocation *invocation) {
    [self->event interstitial:self->mockInterstitial
        didFailToReceiveAdWithError:[NSError errorWithCode:MOPUBErrorUnknown]];
  });

  NSError *criteoError = [NSError errorWithCode:MOPUBErrorUnknown];
  NSString *description =
      [NSString stringWithFormat:@"Criteo Interstitial failed to load with error : %@",
                                 criteoError.localizedDescription];
  NSError *expectedError = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd
                             localizedDescription:description];

  OCMExpect([mockDelegate fullscreenAdAdapter:event didFailToLoadAdWithError:expectedError]);
  [event requestAdWithAdapterInfo:info];
  OCMVerifyAll(mockDelegate);
}

- (void)testAppearDelegates {
  OCMStub([mockInterstitial loadAd]).andDo(^(NSInvocation *invocation) {
    [self->event interstitialWillAppear:self->mockInterstitial];
    [self->event interstitialDidAppear:self->mockInterstitial];
  });

  OCMExpect([mockDelegate fullscreenAdAdapterAdWillAppear:event]);
  OCMExpect([mockDelegate fullscreenAdAdapterAdDidAppear:event]);
  [event requestAdWithAdapterInfo:info];
  OCMVerifyAll(mockDelegate);
}

- (void)testDisappearDelegates {
  OCMStub([mockInterstitial loadAd]).andDo(^(NSInvocation *invocation) {
    [self->event interstitialWillDisappear:self->mockInterstitial];
    [self->event interstitialDidDisappear:self->mockInterstitial];
  });

  OCMExpect([mockDelegate fullscreenAdAdapterAdWillDisappear:event]);
  OCMExpect([mockDelegate fullscreenAdAdapterAdDidDisappear:event]);

  [event requestAdWithAdapterInfo:info];
  OCMVerifyAll(mockDelegate);
}

- (void)testInterstitialWillLeaveApplicationDelegate {
  OCMStub([mockInterstitial loadAd]).andDo(^(NSInvocation *invocation) {
    [self->event interstitialWillLeaveApplication:self->mockInterstitial];
  });

  OCMExpect([mockDelegate fullscreenAdAdapterWillLeaveApplication:event]);
  OCMExpect([mockDelegate fullscreenAdAdapterDidReceiveTap:event]);

  [event requestAdWithAdapterInfo:info];
  OCMVerifyAll(mockDelegate);
}

- (void)testInterstitialSetMopubConsentToCriteo {
  id mockCriteo = [OCMockObject partialMockForObject:[Criteo sharedCriteo]];
  id mockMopub = [OCMockObject partialMockForObject:[MoPub sharedInstance]];
  OCMStub([mockMopub currentConsentStatus]).andReturn(MPConsentStatusDoNotTrack);

  [mockCriteo setExpectationOrderMatters:YES];
  OCMExpect([mockCriteo setMopubConsent:@"dnt"]);
  OCMExpect([mockCriteo registerCriteoPublisherId:[OCMArg any] withAdUnits:[OCMArg any]]);

  [event requestAdWithAdapterInfo:info];
  OCMVerifyAll(mockCriteo);
}

@end
