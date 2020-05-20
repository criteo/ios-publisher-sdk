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
    self.titleLabel.text = ad.title;
    self.bodyLabel.text = ad.body;
}

@end
