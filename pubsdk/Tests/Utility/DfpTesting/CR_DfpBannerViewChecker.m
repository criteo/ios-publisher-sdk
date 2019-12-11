//
// Created by Aleksandr Pakhmutov on 10/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_DfpBannerViewChecker.h"
#import "UIView+Testing.h"
#import "UIWebView+Testing.h"
#import "Logging.h"

static NSString *stubCreativeImage = @"https://publisherdirect.criteo.com/publishertag/preprodtest/creative.png";

@implementation CR_DfpBannerViewChecker

- (instancetype)initWithExpectation:(XCTestExpectation *)expectation {
    if (self = [super init]) {
        _expectation = expectation;
    }
    return self;
}

#pragma mark - GADBannerViewDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    [self checkView:bannerView andFullfilExpectation:self.expectation];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    CLog(@"[ERROR] CR_DfpBannerViewChecker (didFailToReceiveAdWithError) %@", error.description);
}

#pragma mark - Private methods

- (void)checkView:(UIView *)view andFullfilExpectation:(XCTestExpectation *)expectation {
    UIWebView *firstWebView = [view testing_findFirstWebView];
    NSString *htmlContent = [firstWebView testing_getHtmlContent];
    if ([htmlContent containsString:stubCreativeImage]) {
        [expectation fulfill];
    }
}


@end