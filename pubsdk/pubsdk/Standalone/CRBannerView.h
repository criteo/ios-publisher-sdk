//
//  CRBannerView.h
//  CriteoPublisherSdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRBannerViewDelegate.h"
#import "CRBidToken.h"
NS_ASSUME_NONNULL_BEGIN

@interface CRBannerView : UIView
@property (nullable, nonatomic, weak) id<CRBannerViewDelegate> delegate;
- (void)loadAd:(NSString *)adUnitId;
- (void)loadAdWithBidToken:(CRBidToken *)bidToken;
@end

NS_ASSUME_NONNULL_END
