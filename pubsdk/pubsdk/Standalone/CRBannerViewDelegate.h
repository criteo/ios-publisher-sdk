//
//  CRBannerViewDelegate.h
//  CriteoPublisherSdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CRBannerViewDelegate_h
#define CRBannerViewDelegate_h

@class CRBannerView;

@protocol CRBannerViewDelegate <NSObject>

@optional
- (void)banner:(CRBannerView *)bannerView didFailToLoadAdWithError:(NSError *)error;
- (void)bannerDidLoad:(CRBannerView *)bannerView;
- (void)bannerWillLeaveApplication:(CRBannerView *)bannerView;

@end

#endif /* CRBannerViewDelegate_h */
