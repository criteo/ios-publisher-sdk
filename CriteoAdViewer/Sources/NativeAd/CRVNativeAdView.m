//
//  CRNativeAdView.m
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRVNativeAdView.h"

@implementation CRVNativeAdView

#pragma mark - CRNativeDelegate

- (void)nativeLoader:(CRNativeLoader *)loader didReceiveAd:(CRNativeAd *)ad {
    self.nativeAd = ad;
    self.titleLabel.text = ad.title ?: @"No title";
    self.bodyLabel.text = ad.body ?: @"No body";
    self.productMediaView.mediaContent = ad.productMedia;
    self.advertiserDescriptionLabel.text = ad.advertiserDescription ?: @"No advertiser description";
    self.advertiserMediaView.mediaContent = ad.advertiserLogoMedia;
}

@end
