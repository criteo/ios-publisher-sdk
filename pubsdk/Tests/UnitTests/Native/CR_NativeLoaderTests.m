//
//  CR_NativeImageTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>

#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CRMediaDownloader.h"
#import "CRNativeAdUnit.h"
#import "CRNativeAd+Internal.h"
#import "CRNativeLoader+Internal.h"
#import "CR_AdUnitHelper.h"
#import "CR_BidManager.h"
#import "CR_CdbBidBuilder.h"
#import "CR_DependencyProvider+Testing.h"
#import "CRBidToken+Internal.h"
#import "CR_TokenValue.h"
#import "CR_NativeAssets+Testing.h"
#import "CR_NativeLoaderDispatchChecker.h"
#import "CR_NetworkCaptor.h"
#import "CR_MediaDownloaderDispatchChecker.h"
#import "CR_TestAdUnits.h"
#import "CR_SynchronousThreadManager.h"
#import "CR_URLOpenerMock.h"
#import "CRMediaDownloader.h"
#import "XCTestCase+Criteo.h"
#import "CR_NativeAssets+Testing.h"

@interface CR_NativeLoaderTests : XCTestCase
@property(strong, nonatomic) CRNativeLoader *loader;
@property(strong, nonatomic) CRNativeAd *nativeAd;
@property(strong, nonatomic) CR_NativeLoaderDispatchChecker *delegate;
@property(strong, nonatomic) OCMockObject<CRMediaDownloader> *mediaDownloaderMock;
@property(strong, nonatomic) CR_URLOpenerMock *urlOpener;
@property(strong, nonatomic) Criteo *criteo;
@property(strong, nonatomic) CR_NetworkManager *networkManagerMock;

@end

@implementation CR_NativeLoaderTests

- (void)setUp {
  self.delegate = [[CR_NativeLoaderDispatchChecker alloc] init];
  self.urlOpener = [[CR_URLOpenerMock alloc] init];
  self.networkManagerMock = OCMClassMock([CR_NetworkManager class]);
  self.mediaDownloaderMock = OCMProtocolMock(@protocol(CRMediaDownloader));

  CR_DependencyProvider *provider = [CR_DependencyProvider testing_dependencyProvider];
  provider.networkManager = self.networkManagerMock;
  provider.mediaDownloader = self.mediaDownloaderMock;

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
  [self loadNativeWithBid:self.validBid
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

- (void)testFailureWithNoBid {
  [self loadNativeWithBid:[CR_CdbBid emptyBid]
                   verify:^(CRNativeLoader *loader, id<CRNativeLoaderDelegate> delegateMock,
                            Criteo *criteoMock) {
                     OCMExpect([delegateMock nativeLoader:loader
                              didFailToReceiveAdWithError:[OCMArg any]]);
                     OCMReject([delegateMock nativeLoader:loader didReceiveAd:[OCMArg any]]);
                   }];

  OCMVerify(never(), [self.mediaDownloaderMock downloadImage:[OCMArg any]
                                           completionHandler:[OCMArg any]]);
}

- (void)testInHouseReceiveWithValidToken {
  [self loadNativeWithTokenValue:self.validTokenValue
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
  [self loadNativeWithTokenValue:nil
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
  [self dispatchCheckerForBid:self.validBid delegate:delegate];
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
  [self mockCriteoWithAdUnit:adUnit returnBid:[CR_CdbBid emptyBid]];
  CRNativeLoader *loader = [self buildLoaderWithAdUnit:adUnit criteo:self.criteo];
  CR_MediaDownloaderDispatchChecker *mediaDownloader = [CR_MediaDownloaderDispatchChecker new];
  loader.mediaDownloader = mediaDownloader;
  [loader.mediaDownloader downloadImage:[NSURL URLWithString:@""]
                      completionHandler:^(UIImage *image, NSError *error){
                      }];
  [self waitForExpectations:@[ mediaDownloader.didDownloadImageOnMainQueue ] timeout:5];
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

  [self waitForExpectations:@[ self.delegate.didDetectImpression ] timeout:1.f];
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

  [self waitForExpectations:@[ self.delegate.willLeaveApplicationForNativeAd ] timeout:1.f];
}

- (void)testHandleClickOnAdChoiceCallDelegateForOpenExternal {
  [self.loader handleClickOnAdChoiceOfNativeAd:self.nativeAd];

  [self cr_waitForExpectations:@[ self.delegate.willLeaveApplicationForNativeAd ]];
}

- (void)testHandleClickOnAdChoiceDoNotCallDelegateForOpenExternalFailure {
  self.urlOpener.successInCompletion = NO;
  self.delegate.willLeaveApplicationForNativeAd.inverted = YES;

  [self.loader handleClickOnAdChoiceOfNativeAd:self.nativeAd];

  [self waitForExpectations:@[ self.delegate.willLeaveApplicationForNativeAd ] timeout:1.f];
}

#pragma mark - Private

- (void)mockCriteoWithAdUnit:(CRNativeAdUnit *)adUnit returnBid:(CR_CdbBid *)bid {
  CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit];
  OCMStub([self.criteo getBid:cacheAdUnit]).andReturn(bid);
}

- (void)mockCriteoWithBidToken:(CRBidToken *)bidToken returnTokenValue:(CR_TokenValue *)tokenValue {
  OCMStub([self.criteo tokenValueForBidToken:bidToken adUnitType:CRAdUnitTypeNative])
      .andReturn(tokenValue);
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

- (void)loadNativeWithBid:(CR_CdbBid *)bid
                 delegate:(id<CRNativeLoaderDelegate>)delegate
                   verify:(void (^)(CRNativeLoader *loader, id<CRNativeLoaderDelegate> delegateMock,
                                    Criteo *criteoMock))verify {
  CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"123"];
  [self mockCriteoWithAdUnit:adUnit returnBid:bid];
  id<CRNativeLoaderDelegate> testDelegate =
      delegate ?: OCMStrictProtocolMock(@protocol(CRNativeLoaderDelegate));
  CRNativeLoader *loader = [self buildLoaderWithAdUnit:adUnit criteo:self.criteo];
  loader.delegate = testDelegate;
  [loader loadAd];
  verify(loader, testDelegate, self.criteo);
}

- (void)loadNativeWithBid:(CR_CdbBid *)bid
                   verify:(void (^)(CRNativeLoader *loader, id<CRNativeLoaderDelegate> delegateMock,
                                    Criteo *criteoMock))verify {
  [self loadNativeWithBid:bid delegate:nil verify:verify];
}

- (void)loadNativeWithTokenValue:(CR_TokenValue *)tokenValue
                        delegate:(id<CRNativeLoaderDelegate>)delegate
                          verify:(void (^)(CRNativeLoader *loader,
                                           id<CRNativeLoaderDelegate> delegateMock,
                                           Criteo *criteoMock))verify {
  CRBidToken *bidToken = [CRBidToken.alloc initWithUUID:[NSUUID UUID]];
  [self mockCriteoWithBidToken:bidToken returnTokenValue:tokenValue];
  id<CRNativeLoaderDelegate> testDelegate =
      delegate ?: OCMStrictProtocolMock(@protocol(CRNativeLoaderDelegate));
  CRNativeLoader *loader = [self buildLoaderWithAdUnit:(CRNativeAdUnit *)tokenValue.adUnit
                                                criteo:self.criteo];
  loader.delegate = testDelegate;
  [loader loadAdWithBidToken:bidToken];
  verify(loader, testDelegate, self.criteo);
}

- (CR_CdbBid *)validBid {
  return CR_CdbBidBuilder.new.nativeAssets([[CR_NativeAssets alloc] initWithDict:@{}]).build;
}

- (CR_TokenValue *)validTokenValue {
  CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"123"];
  CR_TokenValue *tokenValue = [CR_TokenValue.alloc initWithCdbBid:self.validBid adUnit:adUnit];
  return tokenValue;
}

- (CRNativeLoader *)dispatchCheckerForBid:(CR_CdbBid *)bid
                                 delegate:(id<CRNativeLoaderDelegate>)delegate {
  CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"123"];
  [self mockCriteoWithAdUnit:adUnit returnBid:bid];
  CRNativeLoader *loader = [self buildLoaderWithAdUnit:adUnit criteo:self.criteo];
  loader.delegate = delegate;
  [loader loadAd];
  return loader;
}

- (void)testStandaloneDoesNotConsumeBidWhenNotListeningToAds {
  id<CRNativeLoaderDelegate> delegateMock = OCMPartialMock([NSObject new]);
  [self loadNativeWithBid:self.validBid
                 delegate:delegateMock
                   verify:^(CRNativeLoader *loader, id<CRNativeLoaderDelegate> delegateMock,
                            Criteo *criteoMock) {
                     OCMReject([criteoMock getBid:[OCMArg any]]);
                   }];
}

- (void)testInHouseDoesNotConsumeBidWhenNotListeningToAds {
  id<CRNativeLoaderDelegate> delegateMock = OCMPartialMock([NSObject new]);
  [self loadNativeWithTokenValue:self.validTokenValue
                        delegate:delegateMock
                          verify:^(CRNativeLoader *loader, id<CRNativeLoaderDelegate> delegateMock,
                                   Criteo *criteoMock) {
                            OCMReject([criteoMock tokenValueForBidToken:[OCMArg any]
                                                             adUnitType:CRAdUnitTypeNative]);
                          }];
}

@end
