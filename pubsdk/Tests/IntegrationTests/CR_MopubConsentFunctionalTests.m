//
//  CR_MopubPrivacyFunctionalTests.m
//  pubsdkTests
//
//  Created by Romain Lofaso on 1/20/20.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_DataProtectionConsent.h"
#import "Criteo+Testing.h"
#import "CR_NetworkCaptor.h"
#import "CR_ApiHandler.h"

@interface CR_MopubConsentFunctionalTests : XCTestCase

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation CR_MopubConsentFunctionalTests

- (void)setUp {
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    [self.userDefaults removeObjectForKey:CR_DataProtectionConsentMopubConsentKey];
}

- (void)testGivenMopubConsentNOTSet_whenCriteoRegister_thenMopubConsentNOTSetInBidRequest {
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];

    [criteo testing_registerBannerAndWaitForHTTPResponses];

    NSString * actualConsent = [self _mopubConsentInLastBidRequestWithCriteo:criteo];
    XCTAssertNil(actualConsent);
}

- (void)testGivenMopubConsentSet_whenCriteoRegister_thenMopubConsentSetInBidRequest {
    NSString *expected = @"UNKNOWN";
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];
    [criteo setMopubContent:expected];

    [criteo testing_registerBannerAndWaitForHTTPResponses];

    NSString * actualConsent = [self _mopubConsentInLastBidRequestWithCriteo:criteo];
    XCTAssertEqualObjects(actualConsent, expected);
}

#pragma mark - Private

- (NSString *)_mopubConsentInLastBidRequestWithCriteo:(Criteo *)criteo {
    CR_HttpContent *bidRequest = criteo.testing_lastBidHttpContent;
    NSString *actualConsent = bidRequest.requestBody[CR_ApiHandlerUserKey][CR_ApiHandlerMopubConsentKey];
    return actualConsent;
}

@end
