//
//  pubsdkTests.m
//  pubsdkTests
//
//  Copyright © 2018 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface pubsdkTests : XCTestCase

@end

@implementation pubsdkTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

// This is an end to end test that hits the internet
- (void)testEndToEnd {
    // TODO: ignoring test for now because it crashes on jenkins
    return;
    /*
     
     CR_CacheAdUnit *adUnit = [[CR_CacheAdUnit alloc] initWithAdUnitId:@"div-Test-DirectBidder" width:300 height:250];
     Criteo *pubSdk = [Criteo sharedCriteo];
     [pubSdk registerAdUnit:adUnit];
     DummyDfpRequest *dfpRequest = [[DummyDfpRequest alloc] init];
     [pubSdk addCriteoBidToRequest:dfpRequest forAdUnit:adUnit];
     //the request will be empty the first time
     
     //this is TEMPORARY for this e2e test only
     // wait for 2 seconds
     [pubSdk addCriteoBidToRequest:dfpRequest forAdUnit:adUnit];
     XCTAssertNotNil(dfpRequest.customTargeting);
     
     */
}

@end
