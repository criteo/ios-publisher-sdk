//
//  Criteo+Internal.h
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#ifndef Criteo_Internal_h
#define Criteo_Internal_h

#import "NetworkManagerDelegate.h"
#import <CriteoPublisherSdk/CRInterstitial.h>
#import <CriteoPublisherSdk/CRBannerView.h>

@class Criteo;

@interface Criteo ()

@property (nonatomic) id <NetworkManagerDelegate> networkManagerDelegate;

+ (instancetype)criteo;

@end

@interface CRInterstitial ()
- (instancetype)initWithAdUnit:(CRInterstitialAdUnit *)adUnit criteo:(Criteo *)criteo;
@end

@interface CRBannerView ()
- (instancetype)initWithAdUnit:(CRBannerAdUnit *)adUnit criteo:(Criteo *)criteo;
@end

#endif /* Criteo_Internal_h */
