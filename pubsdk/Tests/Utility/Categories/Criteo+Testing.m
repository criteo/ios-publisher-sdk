//
// Created by Aleksandr Pakhmutov on 26/11/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <objc/runtime.h>

#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_NetworkManagerDecorator.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkManagerSimulator.h"
#import "CR_BidManagerBuilder.h"
#import "CRInterstitialAdUnit.h"
#import "CRBannerAdUnit.h"
#import "CR_NetworkWaiter.h"
#import "CR_NetworkWaiterBuilder.h"
#import "CR_TestAdUnits.h"
#import "CR_Assert.h"

// This publisherId B-056946 exists in production.
NSString *const CriteoTestingPublisherId = @"B-000001";

NSString *const DemoBannerAdUnitId = @"30s6zt3ayypfyemwjvmp";
NSString *const DemoInterstitialAdUnitId = @"6yws53jyfjgoq1ghnuqb";

NSString *const PreprodBannerAdUnitId = @"test-PubSdk-Base";
NSString *const PreprodInterstitialAdUnitId = @"test-PubSdk-Interstitial";
NSString *const PreprodNativeAdUnitId = @"test-PubSdk-Native";

static void *CriteoTestingBidManagerBuilderKey = &CriteoTestingBidManagerBuilderKey;

@implementation Criteo (Testing)

@dynamic bidManager;

- (instancetype)initWithBidManagerBuilder:(CR_BidManagerBuilder *)bidManagerBuilder
{
    CR_BidManager *bidManager = [bidManagerBuilder buildBidManager];
    Criteo *criteo = [[Criteo alloc] initWithBidManager:bidManager];
    criteo.bidManagerBuilder = bidManagerBuilder;
    return criteo;
}

- (CR_BidManagerBuilder *)bidManagerBuilder
{
    return objc_getAssociatedObject(self, CriteoTestingBidManagerBuilderKey);
}

- (void)setBidManagerBuilder:(CR_BidManagerBuilder *)bidManagerBuilder
{
    objc_setAssociatedObject(self, CriteoTestingBidManagerBuilderKey, bidManagerBuilder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CR_NetworkCaptor *)testing_networkCaptor {
    NSAssert([self.bidManagerBuilder.networkManager isKindOfClass:[CR_NetworkCaptor class]], @"Checking that the networkManager is the CR_NetworkCaptor");
    return (CR_NetworkCaptor *) self.bidManagerBuilder.networkManager;
}

- (CR_HttpContent *)testing_lastBidHttpContent
{
    for (CR_HttpContent *content in [self.testing_networkCaptor.finishedRequests reverseObjectEnumerator]) {
        if ([content.url.absoluteString containsString:self.config.cdbUrl]) {
            return content;
        }
    }
    return nil;
}

- (CR_HttpContent *)testing_lastAppEventHttpContent {
    for (CR_HttpContent *content in [self.testing_networkCaptor.finishedRequests reverseObjectEnumerator]) {
        if ([content.url.absoluteString containsString:self.config.appEventsUrl]) {
            return content;
        }
    }
    return nil;
}


+ (Criteo *)testing_criteoWithNetworkCaptor {
    CR_Config *config = [CR_Config configForPreprodWithCriteoPublisherId:CriteoTestingPublisherId];
    CR_NetworkManagerDecorator *decorator = [CR_NetworkManagerDecorator decoratorFromConfiguration:config];

    CR_BidManagerBuilder *builder = [[CR_BidManagerBuilder alloc] init];
    builder.networkManager = [decorator decorateNetworkManager:builder.networkManager];
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
    CR_NetworkWaiterBuilder *builder = [[CR_NetworkWaiterBuilder alloc] initWithConfig:self.config
                                                                         networkCaptor:self.testing_networkCaptor];
    CR_NetworkWaiter *waiter = builder  .withBid
                                        .withConfig
                                        .withLaunchAppEvent
                                        .withFinishedRequestsIncluded
                                        .build;
    return [waiter wait];
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
    CR_Assert(finished, @"Failed to received all the requests for the register: %@", self.testing_networkCaptor);
}

@end
