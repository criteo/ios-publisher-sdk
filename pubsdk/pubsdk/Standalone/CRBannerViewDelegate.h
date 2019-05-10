//
//  CRBannerViewDelegate.h
//  pubsdk
//
//  Created by Sneha Pathrose on 5/8/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CRBannerViewDelegate_h
#define CRBannerViewDelegate_h

@class CRBannerView;

@protocol CRBannerViewDelegate <NSObject>

@optional
- (void)bannerDidFail:(CRBannerView *)bannerView withError:(NSError *)error;
- (void)bannerDidLoad:(CRBannerView *)bannerView;
- (void)bannerWillLeaveApplication:(CRBannerView *)bannerView;

@end

#endif /* CRBannerViewDelegate_h */
