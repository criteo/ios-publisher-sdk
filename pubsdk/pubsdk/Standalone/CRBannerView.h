//
//  CRBannerView.h
//  CriteoPublisherSdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRBannerViewDelegate.h"
#import "CRBidToken.h"
#import "CRBannerAdUnit.h"
NS_ASSUME_NONNULL_BEGIN

@interface CRBannerView : UIView
@property (nullable, nonatomic, weak) id<CRBannerViewDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (void)loadAdWithBidToken:(CRBidToken *)bidToken;
- (instancetype) initWithAdUnit:(CRBannerAdUnit *)adUnit;
- (void)loadAd;
@end

NS_ASSUME_NONNULL_END
