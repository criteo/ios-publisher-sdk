//
// Created by Aleksandr Pakhmutov on 03/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "Criteo.h"

@class CRBannerAdUnit;
@class CRInterstitialAdUnit;

@interface CR_IntegrationsTestBase : XCTestCase

@property (nonatomic) Criteo* criteo;

- (void)initCriteoWithAdUnits:(NSArray<CRAdUnit *> *)adUnits;
- (void)assertMopubKeywordsUpdated:(NSString *)keywords andStillHaveInitialKeywords:(NSString *)initialKeywords;

@end
