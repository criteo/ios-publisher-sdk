//
//  CRBannerView.h
//  pubsdk
//
//  Created by Julien Stoeffler on 4/3/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRBannerViewDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface CRBannerView : UIView
@property (nullable, nonatomic, weak) id<CRBannerViewDelegate> delegate;
- (void)loadAd:(NSString *)adUnitId;
@end

NS_ASSUME_NONNULL_END
