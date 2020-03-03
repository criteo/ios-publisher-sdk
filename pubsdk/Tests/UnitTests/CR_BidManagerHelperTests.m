//
//  CR_BidManagerHelperTests.m
//  pubsdkTests
//
//  Created by Robert Aung Hein Oo on 7/26/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MoPub.h>
#import <OCMock.h>
#import "CR_BidManager.h"
#import "CR_BidmanagerHelper.h"

@interface CR_BidManagerHelperTests : XCTestCase

@end

@implementation CR_BidManagerHelperTests

- (void) testRemoveCriteoBidFromMopubAdRequest{
    CR_CacheAdUnit *slot_1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adunitid" width:300 height:250];

    CR_CdbBid *testBid_1 = [[CR_CdbBid alloc] initWithZoneId:nil placementId:@"adunitid" cpm:@"1.1200000047683716" currency:@"EUR" width:@(300) height:@(250) ttl:600 creative:nil displayUrl:@"https://publisherdirect.criteo.com/publishertag/preprodtest/FakeAJS.js" insertTime:[NSDate date] nativeAssets:nil];

    CR_CacheManager *cache = [[CR_CacheManager alloc] init];
    [cache setBid:testBid_1];

    NSString *testMopubCustomTargeting = @"key1:object_1,key_2:object_2";

    MPInterstitialAdController *mopubBidRequest = [[MPInterstitialAdController alloc] init];
    mopubBidRequest.keywords = testMopubCustomTargeting;

    CR_Config *config = [[CR_Config alloc] initWithCriteoPublisherId:@("1234")];

    CR_BidManager *bidManager = [[CR_BidManager alloc] initWithApiHandler:nil
                                                             cacheManager:cache
                                                               tokenCache:nil
                                                                   config:config
                                                            configManager:nil
                                                               deviceInfo:nil
                                                                  consent:nil
                                                           networkManager:nil
                                                                appEvents:nil
                                                           timeToNextCall:0
                                                          feedbackStorage:nil];

    [bidManager addCriteoBidToRequest:mopubBidRequest forAdUnit:slot_1];
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
