//
//  CR_BidManagerHelperTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MoPub.h>
#import <OCMock.h>
#import "CR_BidmanagerHelper.h"
#import "CR_CacheAdUnit.h"
#import "CR_CdbBid.h"
#import "CR_HeaderBidding.h"
#import "CR_DeviceInfoMock.h"

@interface CR_BidManagerHelperTests : XCTestCase

@end

@implementation CR_BidManagerHelperTests

- (void) testRemoveCriteoBidFromMopubAdRequest{
    CR_DeviceInfoMock *device = [[CR_DeviceInfoMock alloc] init];
    CR_HeaderBidding *headerBidding = [[CR_HeaderBidding alloc] initWithDevice:device];
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];
    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js" insertTime:[NSDate date] nativeAssets:nil impressionId:nil];
    MPInterstitialAdController *mopubBidRequest = [[MPInterstitialAdController alloc] init];
    mopubBidRequest.keywords = @"key1:object_1,key_2:object_2";

    [headerBidding enrichRequest:mopubBidRequest
                         withBid:testBid_1
                          adUnit:slot_1];

    XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_1 mopubCompatibleDisplayUrl]]);
    XCTAssertTrue([mopubBidRequest.keywords containsString:[testBid_1 cpm]]);

    [CR_BidManagerHelper removeCriteoBidsFromMoPubRequest:mopubBidRequest];

    XCTAssertFalse([mopubBidRequest.keywords containsString:[testBid_1 mopubCompatibleDisplayUrl]]);
    XCTAssertFalse([mopubBidRequest.keywords containsString:[testBid_1 cpm]]);
    XCTAssertFalse([mopubBidRequest.keywords containsString:@"crt_"]);
}

- (void)testInterstitialAdControllerAdRemoveCriteoBid {
    MPInterstitialAdController *controller = [[MPInterstitialAdController alloc] init];

    id CR_BidManagerHelperClass = OCMClassMock([CR_BidManagerHelper class]);

    [controller loadAd];

    OCMVerify([CR_BidManagerHelperClass removeCriteoBidsFromMoPubRequest:controller]);
    [CR_BidManagerHelperClass stopMocking];
}

@end
