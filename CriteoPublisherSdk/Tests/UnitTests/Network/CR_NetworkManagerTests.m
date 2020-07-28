//
//  CR_NetworkManagerTests.m
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

#import <Foundation/Foundation.h>
#import <OCMock.h>
#import <XCTest/XCTest.h>

#import "CR_CacheAdUnit.h"
#import "CR_CdbBid.h"
#import "CR_Config.h"
#import "Logging.h"
#import "CR_NetworkManager.h"
#import "XCTestCase+Criteo.h"
#import "CR_ThreadManager.h"

@interface CR_NetworkManagerTests : XCTestCase

@property(nonatomic, strong) CR_Config *config;
@property(nonatomic, strong) CR_NetworkManager *networkManager;
@property(nonatomic, strong) NSURLSession *session;

@end

@implementation CR_NetworkManagerTests

- (void)setUp {
  self.config = [[CR_Config alloc] init];
  self.session = OCMStrictClassMock([NSURLSession class]);
  CR_DeviceInfo *mockDeviceInfo = OCMClassMock([CR_DeviceInfo class]);
  self.networkManager =
      [[CR_NetworkManager alloc] initWithDeviceInfo:mockDeviceInfo
                                            session:self.session
                                      threadManager:[[CR_ThreadManager alloc] init]];
}

- (void)testPostWithResponse204ShouldExecuteHandlerOnce {
  [self stubSessionDataTaskResponseWithStatusCode204];
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Expect that responseHandler was executed"];

  [self.networkManager postToUrl:[NSURL URLWithString:self.config.cdbUrl]
                        postBody:@{@"any key" : @"any value"}
                 responseHandler:^(NSData *data, NSError *error) {
                   [expectation fulfill];
                 }];

  // In case of responseHandler is executed < 1 times - expectation will not be
  // fulfilled. In case of responseHandler is executed > 1 times - expectation
  // will fire an exception because expectation can be fulfilled only once.
  [self cr_waitForExpectations:@[ expectation ]];
}

- (void)testGetWithoutResponseHandlerDoesNotCrash {
  [self stubSessionDataTaskResponseWithStatusCode204];
  XCTAssertNoThrow([self.networkManager getFromUrl:[NSURL URLWithString:self.config.cdbUrl]
                                   responseHandler:nil]);
}

- (void)testPostWithoutResponseHandlerDoesNotCrash {
  [self stubSessionDataTaskResponseWithStatusCode204];
  XCTAssertNoThrow([self.networkManager postToUrl:[NSURL URLWithString:self.config.cdbUrl]
                                         postBody:@{}
                                  responseHandler:nil]);
}

- (void)testNetworkManagerPostCall {
  XCTestExpectation *expectation = [self expectationWithDescription:@"CDB network call"];
  CR_DeviceInfo *deviceInfo = [[CR_DeviceInfo alloc] init];
  NSString *placementId = @"div-Test-DirectBidder";
  NSUInteger width = 300;
  NSUInteger height = 250;
  CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:placementId
                                                              width:width
                                                             height:height];

  NSString *userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 12_1 like Mac OS X) "
                        @"AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16B91";

  BOOL gdprApplies = YES;
  BOOL consentGiven = YES;
  NSString *consentString =
      @"BOO9ZXlOO9auMAKABBITA1-AAAAZ17_______9______9uz_Gv_r_f__33e8_39v_h_7_u_"
      @"_7m_-zzV4-_lrQV1yPA1OrZArgEA";

  NSDictionary *user = @{
    @"deviceId" : @"A0EF6A5A-428B-4C96-AAF0-9A23795C5F0C",
    @"deviceIdType" : @"IDFA",
    @"deviceModel" : @"iPhone 11",
    @"deviceOs" : @"ios",
    @"userAgent" : userAgent
  };

  NSDictionary *publisher =
      @{@"cpId" : @"B-056946", @"bundleId" : @"com.criteo.PublisherSDKTester"};

  NSDictionary *gdprDict = @{
    @"consentData" : consentString,
    @"gdprApplies" : @(gdprApplies),
    @"consentGiven" : @(consentGiven),
    @"version" : @(1)
  };

  NSDictionary *postBody = @{
    @"gdprConsent" : gdprDict,
    @"user" : user,
    @"publisher" : publisher,
    @"sdkVersion" : @"2.0",
    @"profileId" : @(235),
    @"slots" : @[ @{@"placementId" : placementId, @"sizes" : @[ adUnit.cdbSize ]} ]
  };

  NSURL *url = [NSURL URLWithString:@"https://localhost:9099/directbidder-test-app/inapp/v2"];

  CR_NetworkManager *networkManager = [[CR_NetworkManager alloc] initWithDeviceInfo:deviceInfo];
  id<CR_NetworkManagerDelegate> delegateMock =
      [self stubNetworkManagerDelegateForNetworkManager:networkManager];

  networkManager.delegate = delegateMock;
  [networkManager postToUrl:url
                   postBody:postBody
            responseHandler:^(NSData *data, NSError *error) {
              if (error == nil) {
                XCTAssertNotNil(data);
                if (data) {
                  CLog(@"CDB returned : %@", [[NSString alloc] initWithData:data
                                                                   encoding:NSUTF8StringEncoding]);
                  NSArray *cdbBids = [CR_CdbBid getCdbResponsesForData:data
                                                            receivedAt:[NSDate date]];
                  XCTAssertNotNil(cdbBids);
                  XCTAssertNotEqual(0, cdbBids.count);
                }
              } else {
                CLog(@"%@", error);
              }
              [self verifyNetworkManagerDelegate:delegateMock
                              withNetworkManager:networkManager
                                     expectation:expectation];
            }];

  [self waitForExpectations:@[ expectation ] timeout:250];
}

#pragma mark - Private methods

- (void)stubSessionDataTaskResponseWithStatusCode204 {
  NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@""]
                                                            statusCode:204
                                                           HTTPVersion:nil
                                                          headerFields:nil];
  id completion = [OCMArg invokeBlockWithArgs:[NSNull null], response, [NSNull null], nil];
  OCMStub([self.session dataTaskWithRequest:[OCMArg any] completionHandler:completion]);
}

- (id<CR_NetworkManagerDelegate>)stubNetworkManagerDelegateForNetworkManager:
    (CR_NetworkManager *)networkManager {
  id<CR_NetworkManagerDelegate> delegateMock =
      OCMStrictProtocolMock(@protocol(CR_NetworkManagerDelegate));

  OCMStub([delegateMock networkManager:networkManager
                           sentRequest:[OCMArg isKindOfClass:NSURLRequest.class]]);
  OCMStub([delegateMock networkManager:networkManager
                      receivedResponse:[OCMArg isKindOfClass:NSHTTPURLResponse.class]
                              withData:[OCMArg isKindOfClass:NSData.class]
                                 error:[OCMArg isNil]]);

  return delegateMock;
}

- (void)verifyNetworkManagerDelegate:(id<CR_NetworkManagerDelegate>)delegateMock
                  withNetworkManager:(CR_NetworkManager *)networkManager
                         expectation:(XCTestExpectation *)expectation {
  dispatch_async(dispatch_get_main_queue(), ^{
    OCMVerify([delegateMock networkManager:networkManager
                               sentRequest:[OCMArg isKindOfClass:NSURLRequest.class]]);
    OCMVerify([delegateMock networkManager:networkManager
                          receivedResponse:[OCMArg isKindOfClass:NSHTTPURLResponse.class]
                                  withData:[OCMArg isKindOfClass:NSData.class]
                                     error:[OCMArg isNil]]);
    [expectation fulfill];
  });
}

@end
