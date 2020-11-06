//
//  CRNativeLoaderTests.m
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

#import <XCTest/XCTest.h>
#import <OCMock.h>

#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CRMediaDownloader.h"
#import "CRNativeAdUnit.h"
#import "CRNativeAd+Internal.h"
#import "CRNativeLoader+Internal.h"
#import "CRBid+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CR_BidManager.h"
#import "CR_CdbBidBuilder.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_NativeAssets+Testing.h"
#import "CR_NativeLoaderDispatchChecker.h"
#import "CR_MediaDownloaderDispatchChecker.h"
#import "CR_TestAdUnits.h"
#import "CR_URLOpenerMock.h"
#import "CR_IntegrationRegistry.h"
#import "XCTestCase+Criteo.h"
#import "NSError+Criteo.h"
#import "CRContextData.h"

@interface CRNativeLoaderTests : XCTestCase
@property(strong, nonatomic) CRNativeLoader *loader;
@property(strong, nonatomic) CRNativeAd *nativeAd;
@property(strong, nonatomic) CR_NativeLoaderDispatchChecker *delegate;
@property(strong, nonatomic) OCMockObject<CRMediaDownloader> *mediaDownloaderMock;
@property(strong, nonatomic) CRContextData *contextData;
@property(strong, nonatomic) CR_URLOpenerMock *urlOpener;
@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) CR_NetworkManager *networkManagerMock;
@property(strong, nonatomic) CR_IntegrationRegistry *integrationRegistry;

@end

@implementation CRNativeLoaderTests

- (void)setUp {
  self.delegate = [[CR_NativeLoaderDispatchChecker alloc] init];
  self.urlOpener = [[CR_URLOpenerMock alloc] init];
  self.networkManagerMock = OCMClassMock([CR_NetworkManager class]);
  self.mediaDownloaderMock = OCMProtocolMock(@protocol(CRMediaDownloader));
  self.contextData = CRContextData.new;

  CR_DependencyProvider *provider = [CR_DependencyProvider testing_dependencyProvider];
  provider.networkManager = self.networkManagerMock;
  provider.mediaDownloader = self.mediaDownloaderMock;
  self.integrationRegistry = provider.integrationRegistry;

  self.criteo = OCMClassMock([Criteo class]);
  OCMStub([self.criteo dependencyProvider]).andReturn(provider);

  self.loader = [[CRNativeLoader alloc] initWithAdUnit:[CR_TestAdUnits preprodNative]
                                                criteo:self.criteo
                                             urlOpener:self.urlOpener];
  self.loader.delegate = self.delegate;

  CR_NativeAssets *assets = [CR_NativeAssets nativeAssetsFromCdb];
  self.nativeAd = [[CRNativeAd alloc] initWithLoader:self.loader assets:assets];
}

#pragma mark - Tests

- (void)testReceiveWithValidBid {
  [self loadNativeWithCdbBid:self.validCdbBid
                      verify:^(CRNativeLoader *loader, id<CRNativeLoaderDelegate> delegateMock,
                               Criteo *criteoMock) {
                        OCMExpect([delegateMock nativeLoader:loader didReceiveAd:[OCMArg any]]);
                        OCMReject([delegateMock nativeLoader:loader
                                 didFailToReceiveAdWithError:[OCMArg any]]);
                      }];

  // FIXME We want to expect URL from native assets, but URL instances are mocked
  OCMVerify(times(3), [self.mediaDownloaderMock downloadImage:[OCMArg any]
                                            completionHandler:[OCMArg any]]);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationStandalone]);
}

- (void)testFailureWithNoBid {
  [self loadNativeWithCdbBid:[CR_CdbBid emptyBid]
                      verify:^(CRNativeLoader *loader, id<CRNativeLoaderDelegate> delegateMock,
                               Criteo *criteoMock) {
                        OCMExpect([delegateMock nativeLoader:loader
                                 didFailToReceiveAdWithError:[OCMArg any]]);
                        OCMReject([delegateMock nativeLoader:loader didReceiveAd:[OCMArg any]]);
                      }];

  OCMVerify(never(), [self.mediaDownloaderMock downloadImage:[OCMArg any]
                                           completionHandler:[OCMArg any]]);
  OCMVerify([self.integrationRegistry declare:CR_IntegrationStandalone]);
}

- (void)testInHouseReceiveWithValidBid {
  [self loadNativeWithBid:self.validBid
                 delegate:nil
                   verify:^(CRNativeLoader *loader, id<CRNativeLoaderDelegate> delegateMock,
                            Criteo *criteoMock) {
                     OCMExpect([delegateMock nativeLoader:loader didReceiveAd:[OCMArg any]]);
                     OCMReject([delegateMock nativeLoader:loader
                              didFailToReceiveAdWithError:[OCMArg any]]);
                   }];

  // FIXME We want to expect URL from native assets, but URL instances are mocked
  OCMVerify(times(3), [self.mediaDownloaderMock downloadImage:[OCMArg any]
                                            completionHandler:[OCMArg any]]);
}

- (void)testInHouseFailureWithInvalidToken {
  [self loadNativeWithBid:nil
                 delegate:nil
                   verify:^(CRNativeLoader *loader, id<CRNativeLoaderDelegate> delegateMock,
                            Criteo *criteoMock) {
                     OCMExpect([delegateMock nativeLoader:loader didReceiveAd:[OCMArg any]]);
                     OCMReject([delegateMock nativeLoader:loader
                              didFailToReceiveAdWithError:[OCMArg any]]);
                   }];

  OCMVerify(never(), [self.mediaDownloaderMock downloadImage:[OCMArg any]
                                           completionHandler:[OCMArg any]]);
}

- (void)testReceiveOnMainQueue {
  CR_NativeLoaderDispatchChecker *delegate = [[CR_NativeLoaderDispatchChecker alloc] init];
  [self dispatchCheckerForBid:self.validCdbBid delegate:delegate];
  [self cr_waitForExpectations:@[ delegate.didReceiveOnMainQueue ]];
}

- (void)testFailureOnMainQueue {
  CR_NativeLoaderDispatchChecker *delegate = [[CR_NativeLoaderDispatchChecker alloc] init];
  [self dispatchCheckerForBid:[CR_CdbBid emptyBid] delegate:delegate];
  [self cr_waitForExpectations:@[ delegate.didFailOnMainQueue ]];
}

- (void)testDidDetectImpressionOnMainQueue {
  CR_NativeLoaderDispatchChecker *delegate = [[CR_NativeLoaderDispatchChecker alloc] init];
  CRNativeLoader *loader = [self dispatchCheckerForBid:[CR_CdbBid emptyBid] delegate:delegate];
  [loader notifyDidDetectImpression];
  [self cr_waitForExpectations:@[ delegate.didDetectImpression ]];
}

- (void)testDidDetectClickOnMainQueue {
  CR_NativeLoaderDispatchChecker *delegate = [[CR_NativeLoaderDispatchChecker alloc] init];
  CRNativeLoader *loader = [self dispatchCheckerForBid:[CR_CdbBid emptyBid] delegate:delegate];
  [loader notifyDidDetectClick];
  [self cr_waitForExpectations:@[ delegate.didDetectClick ]];
}

- (void)testMediaDownloadOnMainQueue {
  CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"123"];
  [self mockCriteoWithAdUnit:adUnit respondBid:[CR_CdbBid emptyBid]];
  CRNativeLoader *loader = [self buildLoaderWithAdUnit:adUnit criteo:self.criteo];
  CR_MediaDownloaderDispatchChecker *mediaDownloader = [CR_MediaDownloaderDispatchChecker new];
  loader.mediaDownloader = mediaDownloader;
  [loader.mediaDownloader downloadImage:[NSURL URLWithString:@""]
                      completionHandler:^(UIImage *image, NSError *error){
                      }];
  [self cr_waitForExpectations:@[ mediaDownloader.didDownloadImageOnMainQueue ]];
}

- (void)testLoadAdWithBid {
  CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"123"];
  id<CRNativeLoaderDelegate> delegate = OCMStrictProtocolMock(@protocol(CRNativeLoaderDelegate));
  CRNativeLoader *loader = [self buildLoaderWithAdUnit:adUnit criteo:self.criteo];
  loader.delegate = delegate;

  CR_CdbBid *cdbBid = CR_CdbBidBuilder.new.build;
  CRBid *bid = [[CRBid alloc] initWithCdbBid:cdbBid adUnit:adUnit];
  [loader loadAdWithBid:bid];
  OCMExpect([delegate nativeLoader:loader didReceiveAd:[OCMArg any]]);
  OCMReject([delegate nativeLoader:loader didFailToReceiveAdWithError:[OCMArg any]]);
}

- (void)testLoadAdFailWithMissingAdUnit {
  CRNativeLoader *loader = [[CRNativeLoader alloc] init];
  id<CRNativeLoaderDelegate> delegate = OCMStrictProtocolMock(@protocol(CRNativeLoaderDelegate));
  loader.delegate = delegate;
  OCMExpect([delegate nativeLoader:loader
       didFailToReceiveAdWithError:[OCMArg checkWithBlock:^BOOL(NSError *error) {
         return error.code == CRErrorCodeInvalidParameter;
       }]]);
  [loader loadAdWithContext:self.contextData];
  OCMVerifyAllWithDelay(delegate, 1);
}

#pragma mark - Internal
#pragma mark handleImpressionOnNativeAd

- (void)testHandleImpressionOnNativeAdCallsDelegate {
  [self.loader handleImpressionOnNativeAd:self.nativeAd];

  [self cr_waitForExpectations:@[ self.delegate.didDetectImpression ]];
}

- (void)testHandleImpressionOnNativeAdMarksImpression {
  [self.loader handleImpressionOnNativeAd:self.nativeAd];

  XCTAssertTrue(self.nativeAd.isImpressed);
}

- (void)testHandleImpressionOnNativeAdOnAlreadyMarkedNativeAd {
  self.delegate.didDetectImpression.inverted = YES;
  [self.nativeAd markAsImpressed];

  [self.loader handleImpressionOnNativeAd:self.nativeAd];
  [self cr_waitShortlyForExpectations:@[ self.delegate.didDetectImpression ]];
}

- (void)testHandleImpressionOnNativeAdCallPixels {
  [self.loader handleImpressionOnNativeAd:self.nativeAd];

  NSUInteger expectedCallCount = self.nativeAd.assets.impressionPixels.count;
  OCMVerify(times(expectedCallCount), [self.networkManagerMock getFromUrl:[OCMArg any]
                                                          responseHandler:nil]);
}

- (void)testHandleImpressionOnNativeAdDoNotCallPixelsOnAlreadyMarkedNativeAd {
  [self.nativeAd markAsImpressed];

  [self.loader handleImpressionOnNativeAd:self.nativeAd];

  OCMVerify(never(), [self.networkManagerMock getFromUrl:[OCMArg any] responseHandler:nil]);
}

#pragma mark handleClickOnNativeAd

- (void)testHandleClickOnNativeAdCallsDelegateForClick {
  [self.loader handleClickOnNativeAd:self.nativeAd];

  [self cr_waitForExpectations:@[ self.delegate.didDetectClick ]];
}

- (void)testHandleClickOnNativeAdCallsDelegateForOpenExternal {
  [self.loader handleClickOnNativeAd:self.nativeAd];

  [self cr_waitForExpectations:@[ self.delegate.willLeaveApplicationForNativeAd ]];
}

- (void)testHandleClickOnNativeAdDoesNotCallDelegateForOpenExternalFailure {
  self.urlOpener.successInCompletion = NO;
  self.delegate.willLeaveApplicationForNativeAd.inverted = YES;

  [self.loader handleClickOnNativeAd:self.nativeAd];

  [self cr_waitShortlyForExpectations:@[ self.delegate.willLeaveApplicationForNativeAd ]];
}

- (void)testHandleClickOnAdChoiceCallDelegateForOpenExternal {
  [self.loader handleClickOnAdChoiceOfNativeAd:self.nativeAd];

  [self cr_waitForExpectations:@[ self.delegate.willLeaveApplicationForNativeAd ]];
}

- (void)testHandleClickOnAdChoiceDoNotCallDelegateForOpenExternalFailure {
  self.urlOpener.successInCompletion = NO;
  self.delegate.willLeaveApplicationForNativeAd.inverted = YES;

  [self.loader handleClickOnAdChoiceOfNativeAd:self.nativeAd];

  [self cr_waitShortlyForExpectations:@[ self.delegate.willLeaveApplicationForNativeAd ]];
}

#pragma mark - Private

- (void)mockCriteoWithAdUnit:(CRNativeAdUnit *)adUnit respondBid:(CR_CdbBid *)bid {
  CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit];
  OCMStub([self.criteo loadCdbBidForAdUnit:cacheAdUnit
                                   context:self.contextData
                           responseHandler:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        CR_CdbBidResponseHandler handler;
        [invocation getArgument:&handler atIndex:4];
        handler(bid);
      });
}

- (CRNativeLoader *)buildLoaderWithAdUnit:(CRNativeAdUnit *)adUnit criteo:(Criteo *)criteo {
  CR_URLOpenerMock *opener = [[CR_URLOpenerMock alloc] init];
  CRNativeLoader *loader = [[CRNativeLoader alloc] initWithAdUnit:adUnit
                                                           criteo:criteo
                                                        urlOpener:opener];
  // Mock downloader to prevent actual downloads from the default downloader implementation.
  loader.mediaDownloader = self.mediaDownloaderMock;
  return loader;
}

- (void)loadNativeWithCdbBid:(CR_CdbBid *)bid
                    delegate:(id<CRNativeLoaderDelegate>)delegate
                      verify:(void (^)(CRNativeLoader *loader,
                                       id<CRNativeLoaderDelegate> delegateMock,
                                       Criteo *criteoMock))verify {
  CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"123"];
  [self mockCriteoWithAdUnit:adUnit respondBid:bid];
  id<CRNativeLoaderDelegate> testDelegate =
      delegate ?: OCMStrictProtocolMock(@protocol(CRNativeLoaderDelegate));
  CRNativeLoader *loader = [self buildLoaderWithAdUnit:adUnit criteo:self.criteo];
  loader.delegate = testDelegate;
  [loader loadAdWithContext:self.contextData];
  verify(loader, testDelegate, self.criteo);
}

- (void)loadNativeWithCdbBid:(CR_CdbBid *)bid
                      verify:(void (^)(CRNativeLoader *loader,
                                       id<CRNativeLoaderDelegate> delegateMock,
                                       Criteo *criteoMock))verify {
  [self loadNativeWithCdbBid:bid delegate:nil verify:verify];
}

- (void)loadNativeWithBid:(CRBid *)bid
                 delegate:(id<CRNativeLoaderDelegate>)delegate
                   verify:(void (^)(CRNativeLoader *loader, id<CRNativeLoaderDelegate> delegateMock,
                                    Criteo *criteoMock))verify {
  CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"123"];
  id<CRNativeLoaderDelegate> testDelegate =
      delegate ?: OCMStrictProtocolMock(@protocol(CRNativeLoaderDelegate));
  CRNativeLoader *loader = [self buildLoaderWithAdUnit:adUnit criteo:self.criteo];
  loader.delegate = testDelegate;
  [loader loadAdWithBid:bid];
  verify(loader, testDelegate, self.criteo);
}

- (CR_CdbBid *)validCdbBid {
  CR_NativeAssets *assets = [CR_NativeAssets nativeAssetsFromCdb];
  return CR_CdbBidBuilder.new.nativeAssets(assets).build;
}

- (CRBid *)validBid {
  CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"123"];
  return [[CRBid alloc] initWithCdbBid:self.validCdbBid adUnit:adUnit];
}

- (CRNativeLoader *)dispatchCheckerForBid:(CR_CdbBid *)bid
                                 delegate:(id<CRNativeLoaderDelegate>)delegate {
  CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"123"];
  [self mockCriteoWithAdUnit:adUnit respondBid:bid];
  CRNativeLoader *loader = [self buildLoaderWithAdUnit:adUnit criteo:self.criteo];
  loader.delegate = delegate;
  [loader loadAdWithContext:self.contextData];
  return loader;
}

- (void)testStandaloneDoesNotConsumeBidWhenNotListeningToAds {
  id<CRNativeLoaderDelegate> delegateMock = OCMPartialMock([NSObject new]);
  [self loadNativeWithCdbBid:self.validCdbBid
                    delegate:delegateMock
                      verify:^(CRNativeLoader *loader, id<CRNativeLoaderDelegate> delegateMock,
                               Criteo *criteoMock) {
                        OCMReject([criteoMock loadCdbBidForAdUnit:[OCMArg any]
                                                          context:[OCMArg any]
                                                  responseHandler:[OCMArg any]]);
                      }];

  OCMVerify([self.integrationRegistry declare:CR_IntegrationStandalone]);
}

- (void)testInHouseDoesNotConsumeBidWhenNotListeningToAds {
  id<CRNativeLoaderDelegate> delegateMock = OCMPartialMock([NSObject new]);
  CRBid *bid = OCMPartialMock(self.validBid);
  [self loadNativeWithBid:bid
                 delegate:delegateMock
                   verify:^(CRNativeLoader *loader, id<CRNativeLoaderDelegate> delegateMock,
                            Criteo *criteoMock) {
                     OCMReject([bid consume]);
                   }];
}

@end
