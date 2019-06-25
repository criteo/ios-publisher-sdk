//
//  CRInterstitial.h
//  CriteoPublisherSdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CRInterstitialDelegate.h"
#import "CRBidToken.h"
#import "CRInterstitialAdUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRInterstitial : NSObject

@property (nonatomic, readonly) BOOL isAdLoaded;
@property (nullable, nonatomic, weak) id <CRInterstitialDelegate> delegate;

- (instancetype) init NS_UNAVAILABLE;

- (instancetype) initWithAdUnit:(CRInterstitialAdUnit *)adUnit;
- (void)loadAd;
- (void)loadAdWithBidToken:(CRBidToken *)bidToken;
- (void)presentFromRootViewController:(UIViewController *)rootViewController;

@end

NS_ASSUME_NONNULL_END
