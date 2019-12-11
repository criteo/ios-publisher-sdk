//
// Created by Aleksandr Pakhmutov on 10/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

@import GoogleMobileAds;


@interface CR_DfpBannerViewChecker : NSObject <GADBannerViewDelegate>

@property(nonatomic, readonly) XCTestExpectation *expectation;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithExpectation:(XCTestExpectation *)expectation NS_DESIGNATED_INITIALIZER;

@end
