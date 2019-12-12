//
// Created by Aleksandr Pakhmutov on 26/11/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_NetworkCaptor.h"
#import "CR_BidManagerBuilder.h"
#import "CRInterstitialAdUnit.h"
#import "CRBannerAdUnit.h"
#import "CR_NetworkWaiter.h"
#import "CR_TestAdUnits.h"

// This publisherId B-056946 exists in production.
NSString *const CriteoTestingPublisherId = @"B-000001";

NSString *const DemoBannerAdUnitId = @"30s6zt3ayypfyemwjvmp";
NSString *const DemoInterstitialAdUnitId = @"6yws53jyfjgoq1ghnuqb";

NSString *const PreprodBannerAdUnitId = @"test-PubSdk-Base";
NSString *const PreprodInterstitialAdUnitId = @"test-PubSdk-Interstitial";
NSString *const PreprodNativeAdUnitId = @"test-PubSdk-Native";

@implementation Criteo (Testing)

- (CR_NetworkCaptor *)testing_networkCaptor {
    NSAssert([self.bidManagerBuilder.networkManager isKindOfClass:[CR_NetworkCaptor class]], @"Checking that the networkManager is the CR_NetworkCaptor");
    return (CR_NetworkCaptor *) self.bidManagerBuilder.networkManager;
}

- (CR_HttpContent *)testing_lastBidHttpContent
{
    for (CR_HttpContent *content in [self.testing_networkCaptor.history reverseObjectEnumerator]) {
        if ([content.url.absoluteString containsString:self.config.cdbUrl]) {
            return content;
        }
    }
    return nil;
}

+ (Criteo *)testing_criteoWithNetworkCaptor {
    CR_BidManagerBuilder *builder = [[CR_BidManagerBuilder alloc] init];
    CR_NetworkCaptor *networkCaptor = [[CR_NetworkCaptor alloc] initWithNetworkManager:builder.networkManager];
    CR_Config *config = [CR_Config configForPreprodWithCriteoPublisherId:CriteoTestingPublisherId];
    builder.networkManager = networkCaptor;
    builder.config = config;
    Criteo *criteo = [[Criteo alloc] initWithBidManagerBuilder:builder];
    return criteo;
}

#pragma mark - Register

- (void)testing_registerInterstitial {
    [self testing_registerWithAdUnits:@[[CR_TestAdUnits randomInterstitial]]];
}

- (void)testing_registerBanner {
    [self testing_registerWithAdUnits:@[[CR_TestAdUnits randomBanner320x50]]];
}

- (void)testing_registerWithAdUnits:(NSArray<CRAdUnit *> *)adUnits {
    [self registerCriteoPublisherId:CriteoTestingPublisherId withAdUnits:adUnits];
}

#pragma mark - Wait

- (BOOL)testing_waitForRegisterHTTPResponses {
    if ([self _isHTTPCallsForRegisterFinished]) {
        return YES;
    }
    CR_NetworkWaiter *waiter = [[CR_NetworkWaiter alloc] initWithNetworkCaptor:self.testing_networkCaptor];
    const BOOL success = [waiter waitWithResponseTester:^BOOL(CR_HttpContent *_Nonnull httpContent) {
        return [self _isHTTPCallsForRegisterFinished];
    }];
    return success;
}

#pragma mark - Register & Wait

- (void)testing_registerInterstitialAndWaitForHTTPResponses {
    [self testing_registerAndWaitForHTTPResponseWithAdUnits:@[[CR_TestAdUnits randomInterstitial]]];
}

- (void)testing_registerBannerAndWaitForHTTPResponses {
    [self testing_registerAndWaitForHTTPResponseWithAdUnits:@[[CR_TestAdUnits randomBanner320x50]]];
}

- (void)testing_registerAndWaitForHTTPResponseWithAdUnits:(NSArray<CRAdUnit *> *)adUnits {
    [self testing_registerWithAdUnits:adUnits];
    BOOL finished = [self testing_waitForRegisterHTTPResponses];
    NSAssert(finished, @"Failed to received all the requests for the register: %@", self.testing_networkCaptor);
}

#pragma mark - Private methods

- (BOOL)_isHTTPCallsForRegisterFinished {
    CR_Config *config = self.bidManagerBuilder.config;
    BOOL isConfigCallFinished = false;
    BOOL isLaunchAppEventSent = false;
    BOOL isCDBCallFinished = false;
    for (CR_HttpContent *content in self.testing_networkCaptor.history) {
        NSString *urlString = content.url.absoluteString;
        isConfigCallFinished |= [urlString containsString:config.configUrl];
        isLaunchAppEventSent |= [urlString containsString:config.appEventsUrl] && [urlString containsString:@"eventType=Launch"];
        isCDBCallFinished |= [urlString containsString:config.cdbUrl];
    }
    return isConfigCallFinished && isLaunchAppEventSent && isCDBCallFinished;
}

@end
