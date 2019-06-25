//
//  CRInterstitial.h
//  pubsdk
//
//  Created by Julien Stoeffler on 4/15/19.
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CRInterstitialDelegate.h"
#import "CRBidToken.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRInterstitial : NSObject

@property (nonatomic, readonly) BOOL isAdLoaded;
@property (nullable, nonatomic, weak) id <CRInterstitialDelegate> delegate;

- (void)loadAd:(NSString *)adUnitId;
- (void)loadAdWithBidToken:(CRBidToken *)bidToken;
- (void)presentFromRootViewController:(UIViewController *)rootViewController;

@end

NS_ASSUME_NONNULL_END
