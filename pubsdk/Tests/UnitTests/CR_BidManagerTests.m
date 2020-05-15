//
//  CR_BidManagerTests.m
//  pubsdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import <MoPub.h>
#import <OCMock.h>
#import "DFPRequestClasses.h"
#import "NSString+Testing.h"
#import "CR_BidManager.h"
#import "CR_BidManagerBuilder.h"
#import "CR_BidManagerBuilder+Testing.h"
#import "CR_CdbBidBuilder.h"
#import "CR_DeviceInfoMock.h"
#import "CR_HeaderBidding.h"
#import "CR_SynchronousThreadManager.h"
#import "pubsdkTests-Swift.h"

static NSString * const CR_BidManagerTestsCpm = @"crt_cpm";
static NSString * const CR_BidManagerTestsDisplayUrl = @"crt_displayUrl";
static NSString * const CR_BidManagerTestsDfpDisplayUrl = @"crt_displayurl";

#define CR_OCMockVerifyCallCdb(apiHandlerMock, adUnits) \
    OCMVerify([apiHandlerMock callCdb:adUnits \
                              consent:[OCMArg any] \
                               config:[OCMArg any] \
                           deviceInfo:[OCMArg any] \
                        beforeCdbCall:[OCMArg any] \
                    completionHandler:[OCMArg any]]);

#define CR_OCMockRejectCallCdb(apiHandlerMock, adUnits) \
    OCMReject([apiHandlerMock callCdb:adUnits \
                              consent:[OCMArg any] \
                               config:[OCMArg any] \
                           deviceInfo:[OCMArg any] \
                        beforeCdbCall:[OCMArg any] \
                    completionHandler:[OCMArg any]]);

@interface CR_BidManagerTests : XCTestCase

@property (nonatomic, strong) CR_CacheAdUnit *adUnit1;
@property (nonatomic, strong) CR_CdbBid *bid1;

@property (nonatomic, strong) CR_CacheAdUnit *adUnit2;
@property (nonatomic, strong) CR_CdbBid *bid2;

@property (nonatomic, strong) CR_CacheAdUnit *adUnitForEmptyBid;
@property (nonatomic, strong) CR_CacheAdUnit *adUnitUncached;

@property (nonatomic, strong) DFPRequest *dfpRequest;

@property (nonatomic, strong) CR_DeviceInfo *deviceInfoMock;
@property (nonatomic, strong) CR_TokenCache *tokenCache;
@property (nonatomic, strong) CR_CacheManager *cacheManager;
@property (nonatomic, strong) CR_ApiHandler *apiHandlerMock;
@property (nonatomic, strong) CR_ConfigManager *configManagerMock;
@property (strong, nonatomic) CR_HeaderBidding *headerBiddingMock;
@property (nonatomic, strong) CR_BidManagerBuilder *builder;
@property (nonatomic, strong) CR_BidManager *bidManager;

@end

@implementation CR_BidManagerTests

- (void)setUp {
    self.deviceInfoMock = [[CR_DeviceInfoMock alloc] init];
    self.cacheManager = OCMPartialMock([[CR_CacheManager alloc] init]);
    self.configManagerMock = OCMClassMock([CR_ConfigManager class]);
    self.apiHandlerMock = OCMClassMock([CR_ApiHandler class]);
    self.headerBiddingMock = OCMPartialMock(CR_HeaderBidding.new);

    CR_BidManagerBuilder *builder = [CR_BidManagerBuilder testing_bidManagerBuilder];
    builder.threadManager = [[CR_SynchronousThreadManager alloc] init];
    builder.configManager = self.configManagerMock;
    builder.cacheManager = self.cacheManager;
    builder.apiHandler = self.apiHandlerMock;
    builder.deviceInfo = self.deviceInfoMock;
    builder.headerBidding = self.headerBiddingMock;

    self.builder = builder;
    self.bidManager = [builder buildBidManager];
    self.tokenCache = builder.tokenCache;

    self.adUnit1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit1" width:300 height:250];
    self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).build;
    self.adUnit2 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnit2" width:200 height:100];
    self.bid2 = CR_CdbBidBuilder.new.adUnit(self.adUnit2).cpm(@"0.5").displayUrl(@"bid2.displayUrl").build;
    self.adUnitForEmptyBid = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnitForEmptyBid" width:300 height:250];
    self.adUnitUncached = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"adUnitUncached" width:200 height:100];

    self.cacheManager.bidCache[self.adUnit1] = self.bid1;
    self.cacheManager.bidCache[self.adUnit2] = self.bid2;
    self.cacheManager.bidCache[self.adUnitForEmptyBid] = [CR_CdbBid emptyBid];

    self.dfpRequest = [[DFPRequest alloc] init];
    self.dfpRequest.customTargeting = @{ @"key_1": @"object 1", @"key_2": @"object_2" };

    [self.builder.feedbackStorage popMessagesToSend];
}

- (void)tearDown {
    [self.builder.feedbackStorage popMessagesToSend];
}

- (void)testGetBidForCachedAdUnits {
    NSDictionary *bids = [self.bidManager getBids:@[self.adUnit1, self.adUnit2]];

    XCTAssertEqualObjects(self.bid1, bids[self.adUnit1]);
    XCTAssertEqualObjects(self.bid2, bids[self.adUnit2]);
    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[self.adUnit1]);
    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[self.adUnit2]);
}

- (void)testGetBidForUncachedAdUnit {
    CR_CdbBid *bid = [self.bidManager getBid:self.adUnitUncached];

    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[self.adUnitUncached]);
    XCTAssert(bid.isEmpty);
}

- (void)testGetEmptyBid {
    OCMReject([self.cacheManager removeBidForAdUnit:self.adUnitForEmptyBid]);

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnitForEmptyBid];

    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[self.adUnitForEmptyBid]);
    XCTAssert(bid.isEmpty);
}

- (void)testGetBidUncachedAdUnitInSilentMode {
    self.builder.timeToNextCall = INFINITY; // in silent mode
    self.bidManager = [self.builder buildBidManager];

    CR_OCMockRejectCallCdb(self.apiHandlerMock, @[self.adUnitUncached]);

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnitUncached];

    XCTAssert(bid.isEmpty);
}

- (void)testGetEmptyBidForAdUnitInSilentMode {
    self.builder.timeToNextCall = INFINITY; // in silent mode
    self.bidManager = [self.builder buildBidManager];

    CR_OCMockRejectCallCdb(self.apiHandlerMock, @[self.adUnitForEmptyBid]);

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnitForEmptyBid];

    XCTAssert(bid.isEmpty);
}


- (void)testRegistrationSetEmptyBid {
    [self.bidManager registerWithSlots:@[self.adUnitUncached]];

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnitUncached];

    XCTAssert(bid.isEmpty);
}

- (void)testGetBidWhenBeforeTtnc { // TTNC -> Time to next call
    self.builder.timeToNextCall = [[NSDate dateWithTimeIntervalSinceNow:360] timeIntervalSinceReferenceDate];
    self.bidManager = [self.builder buildBidManager];
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;
    self.cacheManager.bidCache[self.adUnit2] = self.bid2;

    CR_OCMockRejectCallCdb(self.apiHandlerMock, [OCMArg any]);

    NSDictionary *bids = [self.bidManager getBids:@[self.adUnit1, self.adUnit2, self.adUnitUncached]];

    XCTAssertEqualObjects(self.bid1, bids[self.adUnit1]);
    XCTAssertEqualObjects(self.bid2, bids[self.adUnit2]);
    XCTAssertTrue([bids[self.adUnitUncached] isEmpty]);
}

- (void)testGetBidForAdUnitInSilenceMode { // Silence mode = cpm ==0 && ttl > 0
    self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).cpm(@"0.0").ttl(42.0).build;
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;
    CR_OCMockRejectCallCdb(self.apiHandlerMock, @[self.adUnit1]);

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnit1];

    XCTAssert(bid.isEmpty);
}

- (void)testGetBidForBidWithSilencedModeElapsed { // Silence mode = cpm ==0 && ttl > 0 && insertTime + ttl expired
    self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).cpm(@"0.0").ttl(42.0).expiredInsertTime().build;
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnit1];

    XCTAssert(bid.isEmpty);
    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[self.adUnit1]);
}

- (void)testBidResponseForEmptyBid {
    self.adUnitUncached = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                              size:CGSizeMake(320, 50)
                                                        adUnitType:CRAdUnitTypeBanner];

    CRBidResponse *bidResponse = [self.bidManager bidResponseForCacheAdUnit:self.adUnitUncached
                                                                 adUnitType:CRAdUnitTypeBanner];

    XCTAssertEqualWithAccuracy(bidResponse.price, 0.0f, 0.1);
    XCTAssertNil(bidResponse.bidToken);
    XCTAssertFalse(bidResponse.bidSuccess);
}

- (void)testBidResponseForValidBid {
    self.adUnit1 = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"123"
                                                       size:CGSizeMake(320, 50)
                                                 adUnitType:CRAdUnitTypeBanner];
    self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).cpm(@"4.2").build;
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;

    CRBidResponse *bidResponse = [self.bidManager bidResponseForCacheAdUnit:self.adUnit1
                                                                 adUnitType:CRAdUnitTypeBanner];

    XCTAssertEqualWithAccuracy(bidResponse.price, 4.2, 0.1);
    XCTAssert(bidResponse.bidSuccess);
}

- (void)testGetBidWhenNoBid { // No bid: cpm == 0 && ttl == 0
    self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).cpm(@"0.0").ttl(0).build;
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnit1];

    XCTAssertTrue(bid.isEmpty);
    CR_OCMockVerifyCallCdb(self.apiHandlerMock, @[self.adUnit1]);
}

- (void)testGetBidWhenBidExpired {
    self.bid1 = CR_CdbBidBuilder.new.adUnit(self.adUnit1).expiredInsertTime().build;
    self.cacheManager.bidCache[self.adUnit1] = self.bid1;

    CR_CdbBid *bid = [self.bidManager getBid:self.adUnit1];

    XCTAssertTrue(bid.isEmpty);
}

- (void)testInitDoNotRefreshConfiguration {
    OCMReject([self.configManagerMock refreshConfig:[OCMArg any]]);
}

- (void)testSlotRegistrationRefreshConfiguration {
    [self.bidManager registerWithSlots:@[self.adUnitUncached]];

    OCMVerify([self.configManagerMock refreshConfig:[OCMArg any]]);
}

#pragma mark - Header Bidding

- (void)testAddCriteoBidToNonBiddableObjectsDoesNotCrash {
    [self.bidManager addCriteoBidToRequest:[NSDictionary new] forAdUnit:self.adUnit1];
    [self.bidManager addCriteoBidToRequest:[NSSet new] forAdUnit:self.adUnit1];
    [self.bidManager addCriteoBidToRequest:@"1234abcd" forAdUnit:self.adUnit1];
    [self.bidManager addCriteoBidToRequest:(NSMutableDictionary *)nil forAdUnit:self.adUnit1];
}

- (void)testAddCriteoBidToRequestCallHeaderBidding {
    [self.bidManager addCriteoBidToRequest:self.dfpRequest
                                 forAdUnit:self.adUnit1];

    OCMVerify([self.headerBiddingMock enrichRequest:self.dfpRequest
                                            withBid:self.bid1
                                             adUnit:self.adUnit1]);
}

- (void)testAddCriteoBidToRequestWhenKillSwitchIsEngagedShouldNotEnrichRequest {
    self.builder.config.killSwitch = YES;

    [self.bidManager addCriteoBidToRequest:self.dfpRequest
                                 forAdUnit:self.adUnit1];

    OCMReject([self.headerBiddingMock enrichRequest:[OCMArg any]
                                            withBid:[OCMArg any]
                                             adUnit:[OCMArg any]]);
    XCTAssertTrue(self.dfpRequest.customTargeting.count == 2);
    XCTAssertNil([self.dfpRequest.customTargeting objectForKey:CR_BidManagerTestsDfpDisplayUrl]);
    XCTAssertNil([self.dfpRequest.customTargeting objectForKey:CR_BidManagerTestsCpm]);
}

@end
