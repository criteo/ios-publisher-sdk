//
//  CR_NativeImageTests.m
//  pubsdkTests
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>

#import "Criteo.h"
#import "Criteo+Internal.h"
#import "CR_BidManager.h"
#import "CRNativeAdUnit.h"
#import "CRNativeLoader.h"
#import "CRNativeLoader+Internal.h"
#import "CR_AdUnitHelper.h"


@interface CR_NativeLoaderTests : XCTestCase
@end

@interface CR_NativeLoaderDispatchChecker : NSObject <CRNativeDelegate>
@property (strong, nonatomic) XCTestExpectation *didReceiveOnMainQueue;
@property (strong, nonatomic) XCTestExpectation *didFailOnMainQueue;
@end

@implementation CR_NativeLoaderTests

- (void)testReceiveWithValidBid {
    [self loadNativeWithBid:self.validBid verify:^(CRNativeLoader *loader, id <CRNativeDelegate> delegateMock) {
        OCMExpect([delegateMock native:loader didReceiveAd:[OCMArg any]]);
        OCMReject([delegateMock native:loader didFailToReceiveAdWithError:[OCMArg any]]);
    }];
}

- (void)testFailureWithNoBid {
    [self loadNativeWithBid:[CR_CdbBid emptyBid] verify:^(CRNativeLoader *loader, id <CRNativeDelegate> delegateMock) {
        OCMExpect([delegateMock native:loader didFailToReceiveAdWithError:[OCMArg any]]);
        OCMReject([delegateMock native:loader didReceiveAd:[OCMArg any]]);
    }];
}

- (Criteo *)mockCriteoWithAdUnit:(CRNativeAdUnit *)adUnit
                       returnBid:(CR_CdbBid *)bid {
    Criteo *criteoMock = OCMStrictClassMock([Criteo class]);
    CR_CacheAdUnit *cacheAdUnit = [CR_AdUnitHelper cacheAdUnitForAdUnit:adUnit];
    OCMStub([criteoMock getBid:cacheAdUnit]).andReturn(bid);
    return criteoMock;
}

- (void)loadNativeWithBid:(CR_CdbBid *)bid
                   verify:(void (^)(CRNativeLoader *loader, id <CRNativeDelegate> delegateMock))verify {
    CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"123"];
    Criteo *criteoMock = [self mockCriteoWithAdUnit:adUnit returnBid:bid];
    id <CRNativeDelegate> delegateMock = OCMStrictProtocolMock(@protocol(CRNativeDelegate));
    CRNativeLoader *loader = [[CRNativeLoader alloc] initWithAdUnit:adUnit delegate:delegateMock criteo:criteoMock];
    [loader loadAd];
    verify(loader, delegateMock);
}

- (CR_CdbBid *)validBid {
    return [[CR_CdbBid alloc] initWithZoneId:@123
                                 placementId:@"placementId"
                                         cpm:@"4.2"
                                    currency:@"₹😀"
                                       width:@456.0f
                                      height:@789.0f
                                         ttl:26
                                    creative:@"THIS IS USELESS LEGACY"
                                  displayUrl:@""
                                  insertTime:[NSDate date]
                                nativeAssets:nil
                                impressionId:nil];
}

- (void)testReceiveOnMainQueue {
    CR_NativeLoaderDispatchChecker *delegate = [self dispatchCheckerForBid:self.validBid];
    [self waitForExpectations:@[delegate.didReceiveOnMainQueue] timeout:5];
}

- (void)testFailureOnMainQueue {
    CR_NativeLoaderDispatchChecker *delegate = [self dispatchCheckerForBid:[CR_CdbBid emptyBid]];
    [self waitForExpectations:@[delegate.didFailOnMainQueue] timeout:5];
}

- (CR_NativeLoaderDispatchChecker *)dispatchCheckerForBid:(CR_CdbBid *)bid {
    CRNativeAdUnit *adUnit = [[CRNativeAdUnit alloc] initWithAdUnitId:@"123"];
    CR_NativeLoaderDispatchChecker *delegate = [[CR_NativeLoaderDispatchChecker alloc] init];
    Criteo *criteoMock = [self mockCriteoWithAdUnit:adUnit returnBid:bid];
    CRNativeLoader *loader = [[CRNativeLoader alloc] initWithAdUnit:adUnit delegate:delegate criteo:criteoMock];
    [loader loadAd];
    return delegate;
}

@end

@implementation CR_NativeLoaderDispatchChecker

- (instancetype)init {
    self = [super init];
    if (self) {
        _didFailOnMainQueue = [[XCTestExpectation alloc] initWithDescription:@"Delegate should be called on main queue"];
        _didReceiveOnMainQueue = [[XCTestExpectation alloc] initWithDescription:@"Delegate should be called on main queue"];
    }
    return self;
}

- (void)native:(CRNativeLoader *)native didReceiveAd:(CRNativeAd *)nativeAd {
    if (@available(iOS 10.0, *)) {
        dispatch_assert_queue(dispatch_get_main_queue());
        [_didReceiveOnMainQueue fulfill];
    }
}

- (void)native:(CRNativeLoader *)native didFailToReceiveAdWithError:(NSError *)error {
    if (@available(iOS 10.0, *)) {
        dispatch_assert_queue(dispatch_get_main_queue());
        [_didFailOnMainQueue fulfill];
    }
}

@end