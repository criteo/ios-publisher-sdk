//
//  NetworkManagerTests.m
//  pubsdkTests
//
//  Created by Adwait Kulkarni on 1/16/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "NetworkManager.h"
#import "CdbBid.h"
#import "AdUnit.h"
#import "Config.h"

@interface NetworkManagerTests : XCTestCase

@end

@implementation NetworkManagerTests

// NOT a unit test as it uses the interwebs.
- (void) testNetworkManagerPostCall {
    XCTestExpectation *expectation = [self expectationWithDescription:@"CDB network call"];
    DeviceInfo *deviceInfo = [[DeviceInfo alloc] init];
    // test values
    NSString *placementId = @"div-Test-DirectBidder";
    //NSNumber *zoneId = @(497747);
    NSUInteger width = 300;
    NSUInteger height = 250;
    AdUnit *adUnit = [[AdUnit alloc] initWithAdUnitId:placementId width:width height:height];
    
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
                                [NSArray arrayWithObjects:[adUnit cdbSize], nil], @"sizes",
                                nil],
                               nil], @"slots",
                              nil];
    
    NSURL *url = [NSURL URLWithString: @"http://directbidder-test-app.par.preprod.crto.in/inapp/v1?profileId=235"];
    
    NetworkManager *networkManager = [[NetworkManager alloc] initWithDeviceInfo:deviceInfo];
    NSLog(@"Test called the NetworkManager");
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postBody options:NSJSONWritingPrettyPrinted error:&jsonError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", jsonString);
    [networkManager postToUrl:url postBody:postBody responseHandler:^(NSData *data, NSError *error) {
        NSLog(@"NetworkManager called back!");
        if(error == nil) {
            XCTAssertNotNil(data);
            if(data) {
                NSLog(@"CDB returned : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                NSArray *cdbBids = [CdbBid getCdbResponsesFromData:data receivedAt:[NSDate date]];
                XCTAssertNotNil(cdbBids);
                XCTAssertNotEqual(0, cdbBids.count);
            }
        } else {
            NSLog(@"%@", error);
        }
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:250];
}

// NOT a unit test as it uses the interwebs.
- (void) testNetworkManagerGetCall {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Config network call"];
    DeviceInfo *deviceInfo = [[DeviceInfo alloc] init];
    NSString *query = [NSString stringWithFormat:@"networkId=%@&sdkVersion=%@&appId=%@", @(4916), @"2.0", @"com.washingtonpost.iOS"];
    NSString *urlString = [NSString stringWithFormat:@"https://pub-sdk-cfg.par.preprod.crto.in/v1.0/api/config?%@", query];
    NSURL *url = [NSURL URLWithString: urlString];
    
    NetworkManager *networkManager = [[NetworkManager alloc] initWithDeviceInfo:deviceInfo];
    NSLog(@"Test called the NetworkManager");
    
    [networkManager getFromUrl:url responseHandler:^(NSData *data, NSError *error) {
        NSLog(@"NetworkManager called back!");
        if(error == nil) {
            if(data) {
                NSDictionary *configValues = [Config getConfigValuesFromData:data];
                XCTAssertTrue([configValues objectForKey:@"killSwitch"]);
            } else {
                NSLog(@"Error on get from Config: response from Config was nil");
            }
        } else {
            NSLog(@"Error on get from Config : %@", error);
        }
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:250];
}

@end
