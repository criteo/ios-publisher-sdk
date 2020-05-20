//
//  CR_NetworkManagerTests.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OCMock.h>
#import <XCTest/XCTest.h>

#import "CR_CacheAdUnit.h"
#import "CR_CdbBid.h"
#import "CR_Config.h"
#import "Logging.h"
#import "CR_NetworkManager.h"
#import "CR_NetworkManagerDelegate.h"
#import "XCTestCase+Criteo.h"

@interface CR_NetworkManagerTests : XCTestCase

@property (nonatomic, strong) CR_Config *config;
@property (nonatomic, strong) CR_NetworkManager *networkManager;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation CR_NetworkManagerTests

- (void)setUp {
    self.config = [[CR_Config alloc] init];
    self.session = OCMStrictClassMock([NSURLSession class]);
    self.networkManager = [[CR_NetworkManager alloc] initWithDeviceInfo: nil session:self.session];
}

- (void)testPostWithResponse204ShouldExecuteHandlerOnce {
    [self stubSessionDataTaskResponseWithStatusCode204];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expect that responseHandler was executed"];

    [self.networkManager postToUrl:[NSURL URLWithString:self.config.cdbUrl]
                     postBody:@{@"any key" : @"any value"}
              responseHandler:^(NSData *data, NSError *error) {
        [expectation fulfill];
    }];

    // In case of responseHandler is executed < 1 times - expectation will not be fulfilled.
    // In case of responseHandler is executed > 1 times - expectation will fire an exception
    // because expectation can be fulfilled only once.
    [self cr_waitForExpectations:@[expectation]];
}

// NOT a unit test as it uses the interwebs.
// This keeps failing, skip it until we have something that could work
// https://jira.criteois.com/browse/EE-204
- (void) skipped_testNetworkManagerPostCall {
    XCTestExpectation *expectation = [self expectationWithDescription:@"CDB network call"];
    CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] init];
    // test values
    NSString *placementId = @"div-Test-DirectBidder";
    //NSNumber *zoneId = @(497747);
    NSUInteger width = 300;
    NSUInteger height = 250;
    CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:placementId width:width height:height];
    
    NSString *userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 12_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16B91";
    
    BOOL gdprApplies = YES;
    BOOL consentGiven = YES;
    NSString * consentString = @"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u__7m_-zzV4-_lrQV1yPA1OrZArgEA";
    
    NSDictionary *user = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"A0EF6A5A-428B-4C96-AAF0-9A23795C5F0C",    @"deviceId",     //The ID that uniquely identifies a device (IDFA, GAID or Hashed Android ID)
                          @"IDFA",            @"deviceIdType",                        // The device type. This parameter can only have two values: IDFA or GAID
                          @"iPhone XR",       @"deviceModel",
                          @"12.1",            @"deviceOs",                            // The operating system of the device.
                          userAgent,          @"userAgent",
                          nil];
    
    NSDictionary *publisher = [NSDictionary dictionaryWithObjectsAndKeys:
                               //borrowing from Android folks for now
                               @"com.criteo.pubsdk", @"bundleId",   // The bundle ID identifying the app
                               @(1),              @"networkId",
                               nil];
    
    NSDictionary *gdprDict = [NSDictionary dictionaryWithObjectsAndKeys:
                          consentString, @"consentData",
                          @(gdprApplies), @"gdprApplies",
                          @(consentGiven), @"consentGiven", nil];
    
    NSDictionary *postBody = [NSDictionary dictionaryWithObjectsAndKeys:
                              gdprDict, @"gdprConsent",
                              user, @"user",
                              publisher, @"publisher",
                              @"1.0", @"sdkVersion",
                              @(235), @"profileId",
                              [NSArray arrayWithObjects:
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                placementId,         @"placementId",                               // The adunit id provided in the request
                                [NSArray arrayWithObjects:adUnit.cdbSize, nil], @"sizes",
                                nil],
                               nil], @"slots",
                              nil];
    
    NSURL *url = [NSURL URLWithString: @"http://directbidder-test-app.par.preprod.crto.in/inapp/v1?profileId=235"];
    
    CR_NetworkManager *networkManager = [[CR_NetworkManager alloc] initWithDeviceInfo:deviceInfo];
    id<CR_NetworkManagerDelegate> delegateMock = [self stubNetworkManagerDelegateForNetworkManager:networkManager];

    networkManager.delegate = delegateMock;
    [networkManager postToUrl:url postBody:postBody responseHandler:^(NSData *data, NSError *error) {
        if(error == nil) {
            XCTAssertNotNil(data);
            if(data) {
                CLog(@"CDB returned : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                NSArray *cdbBids = [CR_CdbBid getCdbResponsesForData:data receivedAt:[NSDate date]];
                XCTAssertNotNil(cdbBids);
                XCTAssertNotEqual(0, cdbBids.count);
            }
        } else {
            CLog(@"%@", error);
        }
        [self verifyNetworkManagerDelegate:delegateMock withNetworkManager:networkManager expectation:expectation];
    }];

    [self waitForExpectations:@[expectation] timeout:250];
}

// NOT a unit test as it uses the interwebs.
//- (void) testNetworkManagerGetCall {
//    XCTestExpectation *expectation = [self expectationWithDescription:@"Config network call"];
//    CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] init];
//    NSString *query = [NSString stringWithFormat:@"networkId=%@&sdkVersion=%@&appId=%@", @(9138), @"2.0", @"com.washingtonpost.iOS"];
//    NSString *urlString = [NSString stringWithFormat:@"https://pub-sdk-cfg.par.preprod.crto.in/v1.0/api/config?%@", query];
//    NSURL *url = [NSURL URLWithString: urlString];
//
//    CR_NetworkManager *networkManager = [[CR_NetworkManager alloc] initWithDeviceInfo:deviceInfo];
//    id<CR_NetworkManagerDelegate> delegateMock = [self stubNetworkManagerDelegateForNetworkManager:networkManager];
//
//    networkManager.delegate = delegateMock;
//
//    CLog(@"Test called the NetworkManager");
//
//    [networkManager getFromUrl:url responseHandler:^(NSData *data, NSError *error) {
//        CLog(@"NetworkManager called back!");
//        if(error == nil) {
//            if(data) {
//                NSDictionary *configValues = [CR_Config getConfigValuesFromData:data];
//                XCTAssertTrue([configValues objectForKey:@"killSwitch"]);
//            } else {
//                CLog(@"Error on get from Config: response from Config was nil");
//            }
//        } else {
//            CLog(@"Error on get from Config : %@", error);
//        }
//
//        [self verifyNetworkManagerDelegate:delegateMock withNetworkManager:networkManager expectation:expectation];
//    }];
//    [self waitForExpectations:@[expectation] timeout:250];
//}

#pragma mark - Private methods

- (void)stubSessionDataTaskResponseWithStatusCode204 {
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@""]
                                                              statusCode:204
                                                             HTTPVersion:nil
                                                            headerFields:nil];
    id completion = [OCMArg invokeBlockWithArgs:[NSNull null], response, [NSNull null], nil];
    OCMStub([self.session dataTaskWithRequest:[OCMArg any] completionHandler:completion]);
}

- (id<CR_NetworkManagerDelegate>) stubNetworkManagerDelegateForNetworkManager:(CR_NetworkManager*)networkManager
{
    id<CR_NetworkManagerDelegate> delegateMock = OCMStrictProtocolMock(@protocol(CR_NetworkManagerDelegate));

    OCMStub([delegateMock networkManager:networkManager sentRequest:[OCMArg isKindOfClass:NSURLRequest.class]]);
    OCMStub([delegateMock networkManager:networkManager
                        receivedResponse:[OCMArg isKindOfClass:NSHTTPURLResponse.class]
                                withData:[OCMArg isKindOfClass:NSData.class]
                                   error:[OCMArg isNil]]);

    return delegateMock;
}

- (void) verifyNetworkManagerDelegate:(id<CR_NetworkManagerDelegate>)delegateMock
                   withNetworkManager:(CR_NetworkManager*)networkManager
                          expectation:(XCTestExpectation*)expectation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        OCMVerify([delegateMock networkManager:networkManager sentRequest:[OCMArg isKindOfClass:NSURLRequest.class]]);
        OCMVerify([delegateMock networkManager:networkManager
                              receivedResponse:[OCMArg isKindOfClass:NSHTTPURLResponse.class]
                                      withData:[OCMArg isKindOfClass:NSData.class]
                                         error:[OCMArg isNil]]);
        [expectation fulfill];
    });
}

@end
