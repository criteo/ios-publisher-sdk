//
//  CRBannerCustomEvent.m
//  CriteoGoogleAdapter
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
//  in compliance with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the License for the specific language governing permissions and
//  limitations under the License.

#import "CRBannerCustomEvent.h"
#import "CRGoogleMediationParameters.h"

// Private property
@interface CRBannerCustomEvent ()

@property(nonatomic, strong) CRBannerView *bannerView;

@end

@implementation CRBannerCustomEvent

@synthesize delegate;

#pragma mark GADCustomEventBanner implementation

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request {
    NSError *error;
    CRGoogleMediationParameters *params =
    [CRGoogleMediationParameters parametersFromJSONString:serverParameter error:&error];
    if (params == nil) {
        if ([self.delegate respondsToSelector:@selector(customEventBanner:didFailAd:)]) {
            __block CRBannerCustomEvent *blocksafeSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [blocksafeSelf.delegate customEventBanner:blocksafeSelf didFailAd:error];
            });
        }
        return;
    }
    CRBannerAdUnit *adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:params.adUnitId
                                                                 size:adSize.size];
    [Criteo.sharedCriteo registerCriteoPublisherId:params.publisherId withAdUnits:@[ adUnit ]];
    if (self.bannerView == nil) {
        self.bannerView = [[CRBannerView alloc] initWithAdUnit:adUnit];
    }
    self.bannerView.delegate = self;
    [self.bannerView loadAd];
}

#pragma mark CRBannerViewDelegate implementation

- (void)bannerDidReceiveAd:(CRBannerView *)bannerView {
    if ([self.delegate respondsToSelector:@selector(customEventBanner:didReceiveAd:)]) {
        [self.delegate customEventBanner:self didReceiveAd:bannerView];
    }
}

- (void)banner:(CRBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(customEventBanner:didFailAd:)]) {
        [self.delegate
         customEventBanner:self
         didFailAd:[NSError
                    errorWithDomain:GADErrorDomain
                    code:GADErrorNoFill
                    userInfo:[NSDictionary
                              dictionaryWithObject:error.description
                              forKey:NSLocalizedDescriptionKey]]];
    }
}

- (void)bannerWillLeaveApplication:(CRBannerView *)bannerView {
    if ([self.delegate respondsToSelector:@selector(customEventBannerWasClicked:)]) {
        [self.delegate customEventBannerWasClicked:self];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    else if ([self.delegate respondsToSelector:@selector(customEventBanner:clickDidOccurInAd:)]) {
        [self.delegate customEventBanner:self clickDidOccurInAd:bannerView];
    }
    if ([self.delegate respondsToSelector:@selector(customEventBannerWillLeaveApplication:)]) {
        [self.delegate customEventBannerWillLeaveApplication:self];
    }
#pragma clang diagnostic pop
}

@end
