//
// Created by Aleksandr Pakhmutov on 26/11/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import "Criteo+Testing.h"
#import "Criteo+Internal.h"
#import "CR_NetworkCaptor.h"
#import "CR_BidManagerBuilder.h"
#import "CRInterstitialAdUnit.h"

NSString *const CriteoTestingPublisherId = @"B-123456";

@implementation Criteo (Testing)

- (CR_NetworkCaptor *)testing_networkCaptor {
    NSAssert([self.bidManagerBuilder.networkManager isKindOfClass:[CR_NetworkCaptor class]], @"Checking that the networkManager is the CR_NetworkCaptor");
    return (CR_NetworkCaptor *) self.bidManagerBuilder.networkManager;
}

+ (Criteo *)testing_criteoWithNetworkCaptor {
    CR_BidManagerBuilder *builder = [[CR_BidManagerBuilder alloc] init];
    CR_NetworkCaptor *networkCaptor = [[CR_NetworkCaptor alloc] initWithNetworkManager:builder.networkManager];
    builder.networkManager = networkCaptor;
    Criteo *criteo = [[Criteo alloc] initWithBidManagerBuilder:builder];
    return criteo;
}

- (void)testing_register {
    CRInterstitialAdUnit *adUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:@"adUnitId"];
    [self registerCriteoPublisherId:CriteoTestingPublisherId withAdUnits:@[adUnit]];
}

@end