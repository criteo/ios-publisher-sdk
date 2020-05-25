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
#import "CR_NativeAssets.h"
#import "CR_NativeLoaderDispatchChecker.h"
#import "CR_MediaDownloaderDispatchChecker.h"
#import "CR_TestAdUnits.h"
#import "CR_SynchronousThreadManager.h"
#import "NSURL+Criteo.h"
#import "XCTestCase+Criteo.h"

@interface CR_NativeLoaderTests : XCTestCase
@property (strong, nonatomic) CRNativeLoader *loader;
@property (strong, nonatomic) CRNativeAd *nativeAd;
@property (strong, nonatomic) CR_NativeLoaderDispatchChecker *delegate;
@property (strong, nonatomic) OCMockObject *urlMock;

@end

@implementation CR_NativeLoaderTests

- (void)setUp {
    CRNativeAdUnit *adUnit = [CR_TestAdUnits preprodNative];
    id criteoMock = OCMClassMock([Criteo class]);
    self.loader = [self buildLoaderWithAdUnit:adUnit
                                       criteo:criteoMock];

    CR_NativeAssets *assets = [[CR_NativeAssets alloc] initWithDict:@{}];
    self.nativeAd = [[CRNativeAd alloc] initWithLoader:self.loader
                                                assets:assets];

    self.delegate = [[CR_NativeLoaderDispatchChecker alloc] init];
    self.loader.delegate = self.delegate;
}

#pragma mark - Tests

- (void)testReceiveWithValidBid {
    [self loadNativeWithBid:self.validBid verify:
        ^(CRNativeLoader *loader, id <CRNativeDelegate> delegateMock, Criteo *criteoMock) {
            OCMExpect([delegateMock nativeLoader:loader didReceiveAd:[OCMArg any]]);
            OCMReject([delegateMock nativeLoader:loader didFailToReceiveAdWithError:[OCMArg any]]);
        }];
}

- (void)testFailureWithNoBid {
    [self loadNativeWithBid:[CR_CdbBid emptyBid] verify:
        ^(CRNativeLoader *loader, id <CRNativeDelegate> delegateMock, Criteo *criteoMock) {
            OCMExpect([delegateMock nativeLoader:loader didFailToReceiveAdWithError:[OCMArg any]]);
            OCMReject([delegateMock nativeLoader:loader didReceiveAd:[OCMArg any]]);
        }];
}

- (void)testReceiveOnMainQueue {
    CR_NativeLoaderDispatchChecker *delegate = [[CR_NativeLoaderDispatchChecker alloc] init];
    [self dispatchCheckerForBid:self.validBid delegate:delegate];
    [self cr_waitForExpectations:@[delegate.didReceiveOnMainQueue]];
}

- (void)testFailureOnMainQueue {
    CR_NativeLoaderDispatchChecker *delegate = [[CR_NativeLoaderDispatchChecker alloc] init];
    [self dispatchCheckerForBid:[CR_CdbBid emptyBid] delegate:delegate];
    [self cr_waitForExpectations:@[delegate.didFailOnMainQueue]];
}

- (void)testWillLeaveApplicationForNativeAdOnMainQueue {
    CR_NativeLoaderDispatchChecker *delegate = [[CR_NativeLoaderDispatchChecker alloc] init];
    CRNativeLoader *loader = [self dispatchCheckerForBid:[CR_CdbBid emptyBid] delegate:delegate];
    [loader notifyWillLeaveApplicationForNativeAd];
    [self cr_waitForExpectations:@[delegate.willLeaveApplicationForNativeAd]];
}

- (void)testDidDetectImpressionOnMainQueue {
    CR_NativeLoaderDispatchChecker *delegate = [[CR_NativeLoaderDispatchChecker alloc] init];
    CRNativeLoader *loader = [self dispatchCheckerForBid:[CR_CdbBid emptyBid] delegate:delegate];
    [loader notifyDidDetectImpression];
    [self cr_waitForExpectations:@[delegate.didDetectImpression]];
}

- (void)testDidDetectClickOnMainQueue {
    CR_NativeLoaderDispatchChecker *delegate = [[CR_NativeLoaderDispatchChecker alloc] init];
    CRNativeLoader *loader = [self dispatchCheckerForBid:[CR_CdbBid emptyBid] delegate:delegate];
    [loader notifyDidDetectClick];
    [self cr_waitForExpectations:@[delegate.didDetectClick]];
}

- (void)testMediaDownloadOnMainQueue {
    CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"123"];
    Criteo *criteoMock = [self mockCriteoWithAdUnit:adUnit returnBid:[CR_CdbBid emptyBid]];
    CRNativeLoader *loader = [self buildLoaderWithAdUnit:adUnit criteo:criteoMock];
    CR_MediaDownloaderDispatchChecker *mediaDownloader = [CR_MediaDownloaderDispatchChecker new];
    loader.mediaDownloader = mediaDownloader;
    [loader.mediaDownloader downloadImage:[NSURL cr_URLWithStringOrNil:nil]
                        completionHandler:^(UIImage *image, NSError *error) {}];
    [self waitForExpectations:@[mediaDownloader.didDownloadImageOnMainQueue] timeout:5];
}

#pragma mark - Internal

- (void)testHandleClickOnNativeAdCallDelegateForClick {
    [self mockURLForOpeningExternalWithSuccess:YES];

    [self.loader handleClickOnNativeAd:self.nativeAd];

    [self cr_waitForExpectations:@[self.delegate.didDetectClick]];
}

- (void)testHandleClickOnNativeAdCallDelegateForOpenExternal {
    [self mockURLForOpeningExternalWithSuccess:YES];

    [self.loader handleClickOnNativeAd:self.nativeAd];

    [self cr_waitForExpectations:@[self.delegate.willLeaveApplicationForNativeAd]];
}

- (void)testHandleClickOnNativeAdDoNotCallDelegateForOpenExternalFailure {
    [self mockURLForOpeningExternalWithSuccess:NO];
    self.delegate.willLeaveApplicationForNativeAd.inverted = YES;

    [self.loader handleClickOnNativeAd:self.nativeAd];

    [self waitForExpectations:@[self.delegate.willLeaveApplicationForNativeAd]
                      timeout:1.f];
}

#pragma mark - Private

- (void)mockURLForOpeningExternalWithSuccess:(BOOL)success {
    self.urlMock = OCMClassMock([NSURL class]);
    OCMStub([(id)self.urlMock cr_URLWithStringOrNil:OCMOCK_ANY]).andReturn(self.urlMock);
    OCMExpect([(id)self.urlMock cr_openExternal:([OCMArg invokeBlockWithArgs:@(success), nil])]);
}

- (Criteo *)mockCriteoWithAdUnit:(CRNativeAdUnit *)adUnit
                       returnBid:(CR_CdbBid *)bid {
    Criteo *criteoMock = OCMStrictClassMock([Criteo class]);

    CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit];
    OCMStub([criteoMock getBid:cacheAdUnit]).andReturn(bid);

    CR_SynchronousThreadManager *threadManager = [[CR_SynchronousThreadManager alloc] init];
    OCMStub([criteoMock threadManager]).andReturn(threadManager);

    return criteoMock;
}

- (CRNativeLoader *)buildLoaderWithAdUnit:(CRNativeAdUnit *)adUnit criteo:(Criteo *)criteo {
    CRNativeLoader *loader = [[CRNativeLoader alloc] initWithAdUnit:adUnit criteo:criteo];
    // Mock downloader to prevent actual downloads from the default downloader implementation.
    loader.mediaDownloader = OCMProtocolMock(@protocol(CRMediaDownloader));
    return loader;
}

- (void)loadNativeWithBid:(CR_CdbBid *)bid
                 delegate:(id <CRNativeDelegate>)delegate
                   verify:(void (^)(CRNativeLoader *loader, id <CRNativeDelegate> delegateMock, Criteo *criteoMock))verify {
    CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"123"];
    Criteo *criteoMock = [self mockCriteoWithAdUnit:adUnit returnBid:bid];
    id <CRNativeDelegate> testDelegate = delegate ?: OCMStrictProtocolMock(@protocol(CRNativeDelegate));
    CRNativeLoader *loader = [self buildLoaderWithAdUnit:adUnit criteo:criteoMock];
    loader.delegate = testDelegate;
    [loader loadAd];
    verify(loader, testDelegate, criteoMock);
}

- (void)loadNativeWithBid:(CR_CdbBid *)bid
                   verify:(void (^)(CRNativeLoader *loader, id <CRNativeDelegate> delegateMock, Criteo *criteoMock))verify {
    [self loadNativeWithBid:bid delegate:nil verify:verify];
}

- (CR_CdbBid *)validBid {
    return CR_CdbBidBuilder.new.build;
}

- (CRNativeLoader *)dispatchCheckerForBid:(CR_CdbBid *)bid
                                 delegate:(id <CRNativeDelegate>)delegate {
    CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"123"];
    Criteo *criteoMock = [self mockCriteoWithAdUnit:adUnit returnBid:bid];
    CRNativeLoader *loader = [self buildLoaderWithAdUnit:adUnit criteo:criteoMock];
    loader.delegate = delegate;
    [loader loadAd];
    return loader;
}

- (void)testDoesNotConsumeBidWhenNotListeningToAds {
    id <CRNativeDelegate> delegateMock = OCMPartialMock([NSObject new]);
    [self loadNativeWithBid:self.validBid delegate:delegateMock verify:
        ^(CRNativeLoader *loader, id <CRNativeDelegate> delegateMock, Criteo *criteoMock) {
            OCMReject([criteoMock getBid:[OCMArg any]]);
        }];
}

@end
