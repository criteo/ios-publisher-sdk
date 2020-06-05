//
//  CRCustomBannerEvent.m
//  CriteoMoPubAdapter
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "CRBannerCustomEvent.h"
#import "CRCustomEventHelper.h"

// Private properties
@interface CRBannerCustomEvent()

@property (nonatomic, strong) CRBannerView *bannerView;

@end

@implementation CRBannerCustomEvent

- (instancetype) init {
    self = [super init];
    return self;
}

- (void) requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
    [self requestAdWithSize:size customEventInfo:info adMarkup:nil];
}

- (void) requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if (![CRCustomEventHelper checkValidInfo:info]) {
        if ([self.delegate respondsToSelector:@selector(bannerCustomEvent:didFailToLoadAdWithError:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *errorDescription = [NSString stringWithFormat:@"Criteo Banner ad request failed due to invalid server parameters."];
                [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:[NSError errorWithCode:MOPUBErrorServerError localizedDescription:errorDescription]];
            });
        }
        return;
    }
    CRBannerAdUnit *bannerAdUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:info[@"adUnitId"] size:size];
    [[Criteo sharedCriteo] registerCriteoPublisherId:info[@"cpId"] withAdUnits:@[bannerAdUnit]];
    // MoPub SDK instantiates a new CustomEvent object on every ad call so the bannerView will not be reused.
    // This check is done so that a mock bannerView can be injected without being replaced again during testing.
    if (!self.bannerView) {
        self.bannerView = [[CRBannerView alloc] initWithAdUnit:bannerAdUnit];
    }
    self.bannerView.delegate = self;
    [self.bannerView loadAd];
}

# pragma mark - CRBannerViewDelegate methods
- (void) bannerDidReceiveAd:(CRBannerView *)bannerView {
    if ([self.delegate respondsToSelector:@selector(bannerCustomEvent:didLoadAd:)]){
        [self.delegate bannerCustomEvent:self didLoadAd:self.bannerView];
    }
}

- (void) banner:(CRBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(bannerCustomEvent:didFailToLoadAdWithError:)]) {
        NSString *errorDescription = [NSString stringWithFormat:@"Criteo Banner failed to load with error: %@", error.localizedDescription];
        NSError *mopubError = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:errorDescription];
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:mopubError];
    }
}

# pragma mark - optional delegate invocations
- (void) bannerWillLeaveApplication:(CRBannerView *)bannerView {
    if ([self.delegate respondsToSelector:@selector(bannerCustomEventWillLeaveApplication:)]) {
        [self.delegate bannerCustomEventWillLeaveApplication:self];
    }
}

@end
