//
//  CR_UsPrivacyConsentFunctionalTests.m
//  pubsdkTests
//
//  Created by Romain Lofaso on 12/11/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_ApiQueryKeys.h"
#import "CR_DataProtectionConsent.h"
#import "CR_DataProtectionConsentMock.h"
#import "CR_Gdpr.h"
#import "CR_GdprVersion.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkWaiter.h"
#import "CR_NetworkWaiterBuilder.h"
#import "NSString+GDPR.h"
#import "NSString+APIKeys.h"
#import "NSString+CR_Url.h"
#import "NSURL+Testing.h"

#define CR_AssertDoNotContainsAppEventRequest(requests) \
do { \
    for (CR_HttpContent *content in requests) { \
        XCTAssertFalse([content.url testing_isAppLaunchEventUrlWithConfig:criteo.config]); \
    } \
} while (0);

@interface CR_DataConsentFunctionalTests : XCTestCase

@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) Criteo *criteo;

// Overriden properties
@property (strong, nonatomic, readonly) NSDictionary *gdprInBidRequest;
@property (strong, nonatomic, readonly) NSString *appEventUrlString;

@end

@implementation CR_DataConsentFunctionalTests

- (void)setUp {
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    [self.userDefaults removeObjectForKey:CR_CcpaIabConsentStringKey];
    [self.userDefaults removeObjectForKey:CR_CcpaCriteoStateKey];
    [self.userDefaults removeObjectForKey:CR_DataProtectionConsentMopubConsentKey];
    [self.userDefaults removeObjectForKey:CR_GdprAppliesForTcf2_0Key];
    [self.userDefaults removeObjectForKey:CR_GdprConsentStringForTcf2_0Key];
    [self.userDefaults removeObjectForKey:CR_GdprVendorConsentsForTcf2_0Key];
    [self.userDefaults removeObjectForKey:CR_GdprSubjectToGdprForTcf1_1Key];
    [self.userDefaults removeObjectForKey:CR_GdprConsentStringForTcf1_1Key];
    [self.userDefaults removeObjectForKey:CR_GdprVendorConsentsForTcf1_1Key];

    self.criteo = [Criteo testing_criteoWithNetworkCaptor];
}

- (void)tearDown {
    [self setUp];
}

#pragma mark - GDPR

- (void)testGivenNoGdpr_whenCriteoRegister_thenConsentStringSetInBidRequest {
    [self.criteo testing_registerBannerAndWaitForHTTPResponses];

    XCTAssertNil(self.gdprInBidRequest);
    XCTAssertNil(self.appEventUrlString.urlQueryParamsDictionary[NSString.gdprConsentKey]);
}

- (void)testGivenGdprV1ConsentStringSet_whenCriteoRegister_thenConsentStringSetInBidRequest {
    NSDictionary *expected = @{
        NSString.gdprVersionKey:      @1,
        NSString.gdprConsentDataKey:  NSString.gdprConsentStringForTcf1_1,
        NSString.gdprAppliesKey:      @NO,
        NSString.gdprConsentGivenKey: @NO
    };
    [self.userDefaults setObject:NSString.gdprConsentStringForTcf1_1
                          forKey:CR_GdprConsentStringForTcf1_1Key];

    [self.criteo testing_registerBannerAndWaitForHTTPResponses];

    XCTAssertEqualObjects(self.gdprInBidRequest, expected);
    XCTAssertNotNil(self.appEventUrlString.urlQueryParamsDictionary[NSString.gdprConsentKey]);
}

- (void)testGivenGdprV1Set_whenCriteoRegister_thenConsentStringSetInBidRequest {
    NSDictionary *expected = @{
        NSString.gdprVersionKey:      @1,
        NSString.gdprConsentDataKey:  NSString.gdprConsentStringForTcf1_1,
        NSString.gdprAppliesKey:      @YES,
        NSString.gdprConsentGivenKey: @YES
    };
    [self.userDefaults setObject:NSString.gdprConsentStringForTcf1_1
                          forKey:CR_GdprConsentStringForTcf1_1Key];
    [self.userDefaults setObject:NSString.gdprOnlyCriteoConsentAllowedString
                          forKey:CR_GdprVendorConsentsForTcf1_1Key];
    [self.userDefaults setBool:YES
                        forKey:CR_GdprSubjectToGdprForTcf1_1Key];

    [self.criteo testing_registerBannerAndWaitForHTTPResponses];

    XCTAssertEqualObjects(self.gdprInBidRequest, expected);
    XCTAssertNotNil(self.appEventUrlString.urlQueryParamsDictionary[NSString.gdprConsentKey]);
}

- (void)testGivenGdprV2Set_whenCriteoRegister_thenConsentStringSetInBidRequest {
    NSDictionary *expected = @{
        NSString.gdprVersionKey:      @2,
        NSString.gdprConsentDataKey:  NSString.gdprConsentStringForTcf2_0,
        NSString.gdprAppliesKey:      @YES,
        NSString.gdprConsentGivenKey: @YES
    };
    [self.userDefaults setObject:NSString.gdprConsentStringForTcf2_0
                          forKey:CR_GdprConsentStringForTcf2_0Key];
    [self.userDefaults setObject:NSString.gdprOnlyCriteoConsentAllowedString
                          forKey:CR_GdprVendorConsentsForTcf2_0Key];
    [self.userDefaults setBool:YES
                        forKey:CR_GdprAppliesForTcf2_0Key];

    [self.criteo testing_registerBannerAndWaitForHTTPResponses];

    XCTAssertEqualObjects(self.gdprInBidRequest, expected);
}

- (void)testGivenGdprV2AndV1Set_whenCriteoRegister_thenConsentStringV2SetInBidRequest {
    NSDictionary *expected = @{
        NSString.gdprVersionKey:      @2,
        NSString.gdprConsentDataKey:  NSString.gdprConsentStringForTcf2_0,
        NSString.gdprAppliesKey:      @YES,
        NSString.gdprConsentGivenKey: @YES
    };
    [self.userDefaults setObject:NSString.gdprConsentStringForTcf1_1
                          forKey:CR_GdprConsentStringForTcf1_1Key];
    [self.userDefaults setObject:NSString.gdprConsentStringForTcf2_0
                          forKey:CR_GdprConsentStringForTcf2_0Key];
    [self.userDefaults setObject:NSString.gdprOnlyCriteoConsentAllowedString
                          forKey:CR_GdprVendorConsentsForTcf2_0Key];
    [self.userDefaults setBool:YES
                        forKey:CR_GdprAppliesForTcf2_0Key];

    [self.criteo testing_registerBannerAndWaitForHTTPResponses];

    XCTAssertEqualObjects(self.gdprInBidRequest, expected);
}

#pragma mark - CCPA

- (void)testGivenIabConsentStringSet_whenCriteoRegister_thenUsIabSetInBidRequest
{
    [self.userDefaults setObject:CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString
                          forKey:CR_CcpaIabConsentStringKey];
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];

    [criteo testing_registerBannerAndWaitForHTTPResponses];

    NSString * actualConsent = [self _iabConsentInLastBidRequestWithCriteo:criteo];
    XCTAssertEqualObjects(actualConsent, CR_DataProtectionConsentMockDefaultUsPrivacyIabConsentString);
}

- (void)testGivenIabConsentStringSetWithoutConsent_whenCriteoRegister_thenUsIabSetInBidRequestAndAppEventNotSent
{
    [self.userDefaults setObject:@"1YYN"
                          forKey:CR_CcpaIabConsentStringKey];
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];

    [criteo testing_registerBanner];
    [self _waitForBidAndConfurationOnlyWithCriteo:criteo];

    NSString * actualConsent = [self _iabConsentInLastBidRequestWithCriteo:criteo];
    XCTAssertEqualObjects(actualConsent, @"1YYN");
    CR_AssertDoNotContainsAppEventRequest(criteo.testing_networkCaptor.allRequests);
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
                          forKey:CR_CcpaIabConsentStringKey];
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];

    [criteo testing_registerBannerAndWaitForHTTPResponses];

    NSString * actualConsent = [self _iabConsentInLastBidRequestWithCriteo:criteo];
    XCTAssertNil(actualConsent);
}

#pragma mark - Criteo Optout

- (void)testGivenCriteoUsPrivacyOptOutYES_whenCriteoRegister_thenBidIncludeUsPrivacyOptOutToYES_noAppEventSent
{
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];
    [criteo setUsPrivacyOptOut:YES];

    [criteo testing_registerBanner];
    [self _waitForBidAndConfurationOnlyWithCriteo:criteo];

    NSNumber *actualConsent = [self _criteoUsPrivacyConsentInLastBidRequestWithCriteo:criteo];
    XCTAssertTrue([actualConsent boolValue]);
    CR_AssertDoNotContainsAppEventRequest(criteo.testing_networkCaptor.allRequests);
}

- (void)testGivenCriteoUsPrivacyOptOutNO_whenCriteoRegister_thenBidIncludeUsPrivacyOptOutToNO_appEventSent
{
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];
    [criteo setUsPrivacyOptOut:NO];

    [criteo testing_registerBannerAndWaitForHTTPResponses];

    NSNumber *actualConsent = [self _criteoUsPrivacyConsentInLastBidRequestWithCriteo:criteo];
    XCTAssertNotNil(actualConsent);
    XCTAssertFalse([actualConsent boolValue]);
}

#pragma mark - Mopub Consent

- (void)testGivenMopubConsentNOTSet_whenCriteoRegister_thenBidDoesntIncludeMopubConsentAndAppEventSent {
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];

    [criteo testing_registerBannerAndWaitForHTTPResponses];

    NSString *actualConsent = [self _mopubConsentInLastBidRequestWithCriteo:criteo];
    XCTAssertNil(actualConsent);
}

- (void)testGivenMopubConsentDeclined_whenCriteoRegister_thenBidIncludesMopubConsentAndAppEventNotSent {
    NSString *expected = @"EXPLICIT_NO";
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];
    [criteo setMopubConsent:expected];

    [criteo testing_registerBanner];
    [self _waitForBidAndConfurationOnlyWithCriteo:criteo]; // Don't wait for the app event call.

    NSString *actualConsent = [self _mopubConsentInLastBidRequestWithCriteo:criteo];
    XCTAssertEqualObjects(actualConsent, expected);
    CR_AssertDoNotContainsAppEventRequest(criteo.testing_networkCaptor.allRequests);
}

- (void)testGivenMopubConsentGiven_whenCriteoRegister_thenBidIncludesMopubConsentAndAppEventSent {
    NSString *expected = @"EXPLICIT_YES";
    Criteo *criteo = [Criteo testing_criteoWithNetworkCaptor];
    [criteo setMopubConsent:expected];

    [criteo testing_registerBannerAndWaitForHTTPResponses];

    NSString *actualConsent = [self _mopubConsentInLastBidRequestWithCriteo:criteo];
    XCTAssertEqualObjects(actualConsent, expected);
}

#pragma mark - Private methods

- (NSDictionary *)gdprInBidRequest {
    CR_HttpContent *bidRequest = self.criteo.testing_lastBidHttpContent;
    return bidRequest.requestBody[NSString.gdprConsentKey];
}

- (NSString *)appEventUrlString {
    CR_HttpContent *request = self.criteo.testing_lastAppEventHttpContent;
    return request.url.absoluteString;
}

- (NSString *)_mopubConsentInLastBidRequestWithCriteo:(Criteo *)criteo
{
    CR_HttpContent *bidRequest = criteo.testing_lastBidHttpContent;
    NSString *actualConsent = bidRequest.requestBody[NSString.userKey][NSString.mopubConsent];
    return actualConsent;
}

- (NSNumber *)_criteoUsPrivacyConsentInLastBidRequestWithCriteo:(Criteo *)criteo
{
    CR_HttpContent *bidRequest = criteo.testing_lastBidHttpContent;
    NSNumber *actualConsent = bidRequest.requestBody[NSString.userKey][NSString.uspCriteoOptout];
    return actualConsent;
}

- (NSString *)_iabConsentInLastBidRequestWithCriteo:(Criteo *)criteo
{
    CR_HttpContent *bidRequest = criteo.testing_lastBidHttpContent;
    NSString *actualConsent = bidRequest.requestBody[NSString.userKey][NSString.uspIabKey];
    return actualConsent;
}

- (void)_waitForBidAndConfurationOnlyWithCriteo:(Criteo *)criteo {
    CR_NetworkWaiterBuilder *builder = [[CR_NetworkWaiterBuilder alloc] initWithConfig:criteo.config
                                                                         networkCaptor:criteo.testing_networkCaptor];
    CR_NetworkWaiter *waiter = builder  .withFinishedRequestsIncluded
                                        .withBid
                                        .withConfig
                                        .build;
    const BOOL result = [waiter wait];
    XCTAssert(result);
    sleep(1); // To be sure that the launch app event isn't sent asynchronously.
}

@end

