//
// Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <objc/runtime.h>
#import <OCMock/OCMock.h>

#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_DependencyProvider+Testing.h"
#import "CR_NetworkManagerDecorator.h"
#import "CR_NetworkCaptor.h"
#import "CR_NetworkManagerSimulator.h"
#import "CRInterstitialAdUnit.h"
#import "CRBannerAdUnit.h"
#import "CR_NetworkWaiter.h"
#import "CR_NetworkWaiterBuilder.h"
#import "CR_TestAdUnits.h"
#import "CR_Assert.h"
#import "CR_Config.h"

// This publisherId B-056946 exists in production.
NSString *const CriteoTestingPublisherId = @"B-000001";

NSString *const DemoBannerAdUnitId = @"30s6zt3ayypfyemwjvmp";
NSString *const DemoInterstitialAdUnitId = @"6yws53jyfjgoq1ghnuqb";

NSString *const PreprodBannerAdUnitId = @"test-PubSdk-Base";
NSString *const PreprodInterstitialAdUnitId = @"test-PubSdk-Interstitial";
NSString *const PreprodNativeAdUnitId = @"test-PubSdk-Native";

static void *CriteoTestingDependencyProviderKey = &CriteoTestingDependencyProviderKey;

@implementation Criteo (Testing)

@dynamic bidManager;

- (instancetype)initWithDependencyProvider:(CR_DependencyProvider *)dependencyProvider
{
    CR_BidManager *bidManager = [dependencyProvider buildBidManager];
    Criteo *criteo = [[Criteo alloc] initWithBidManager:bidManager];
    criteo.dependencyProvider = dependencyProvider;
    return criteo;
}

- (CR_DependencyProvider *)dependencyProvider
{
    return objc_getAssociatedObject(self, CriteoTestingDependencyProviderKey);
}

- (void)setDependencyProvider:(CR_DependencyProvider *)dependencyProvider
{
    objc_setAssociatedObject(self, CriteoTestingDependencyProviderKey, dependencyProvider, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CR_NetworkCaptor *)testing_networkCaptor {
    NSAssert([self.dependencyProvider.networkManager isKindOfClass:[CR_NetworkCaptor class]], @"Checking that the networkManager is the CR_NetworkCaptor");
    return (CR_NetworkCaptor *) self.dependencyProvider.networkManager;
}

- (id)testing_networkManagerMock {
    // Note that [captor.networkManager isKindOfClass:[OCMockObject class]] doesn't work.
    // Indeed, OCMockObject is a subclass of NSProxy, not of NSObject. So to know if we
    // use an OCMock, we verify that is it an NSProxy with object.isProxy.
    if ([self.dependencyProvider.networkManager isKindOfClass:[CR_NetworkCaptor class]]) {
        NSAssert(self.testing_networkCaptor.networkManager.isProxy, @"OCMockObject class not found on the networkCaptor");
        return self.testing_networkCaptor.networkManager;
    } else {
        NSAssert(self.dependencyProvider.networkManager.isProxy, @"OCMockObject class not found on the networkCaptor");
        return self.dependencyProvider.networkManager;
    }
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
    CR_DependencyProvider *dependencyProvider = [CR_DependencyProvider testing_dependencyProvider];
    Criteo *criteo = [[Criteo alloc] initWithDependencyProvider:dependencyProvider];
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
