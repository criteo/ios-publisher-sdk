//
//  CR_UsPrivacyConsentFunctionalTests.m
//  pubsdkTests
//
//  Created by Romain Lofaso on 12/11/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_DataProtectionConsent.h"
#import "CR_DataProtectionConsentMock.h"
#import "Criteo+Testing.h"
#import "CR_NetworkCaptor.h"
#import "CR_ApiHandler.h"

@interface CR_UsPrivacyConsentFunctionalTests : XCTestCase

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation CR_UsPrivacyConsentFunctionalTests

- (void)setUp
{
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    [self.userDefaults removeObjectForKey:CR_DataProtectionConsentUsPrivacyIabConsentStringKey];
}

- (void)tearDown {
    [self setUp];
}

- (void)testGivenIabConsentStringSet_whenCriteoRegister_thenUsIabSetInBidRequest
{
    [self.userDefaults setObject:CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString
                          forKey:CR_DataProtectionConsentUsPrivacyIabConsentStringKey];
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];

    [criteo testing_registerBannerAndWaitForHTTPResponses];

    NSString * actualConsent = [self _iabConsentInLastBidRequestWithCriteo:criteo];
    XCTAssertEqualObjects(actualConsent, CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString);
}

- (void)testGivenIabConsentStringNil_whenCriteoRegister_thenUsIabNotSetInBidRequest
{
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];

    [criteo testing_registerBannerAndWaitForHTTPResponses];

    NSString * actualConsent = [self _iabConsentInLastBidRequestWithCriteo:criteo];
    XCTAssertNil(actualConsent);
}

- (void)testGivenIabConsentStringEmpty_whenCriteoRegister_thenUsIabNotSetInBidRequest
{
    [self.userDefaults setObject:@""
                          forKey:CR_DataProtectionConsentUsPrivacyIabConsentStringKey];
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];

    [criteo testing_registerBannerAndWaitForHTTPResponses];

    NSString * actualConsent = [self _iabConsentInLastBidRequestWithCriteo:criteo];
    XCTAssertNil(actualConsent);
}


#pragma mark - Private methods

- (NSString *)_iabConsentInLastBidRequestWithCriteo:(Criteo *)criteo
{
    CR_HttpContent *bidRequest = criteo.testing_lastBidHttpContent;
    NSString *actualConsent = bidRequest.requestBody[CR_ApiHandlerUserKey][CR_ApiHandlerUspIabStringKey];
    return actualConsent;
}

@end

