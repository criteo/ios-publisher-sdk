//
//  CRInterstitialDelegate.h
//  CriteoPublisherSdk
//
//  Copyright © 2019 Criteo. All rights reserved.
//

#ifndef CRInterstitialDelegate_h
#define CRInterstitialDelegate_h

@class CRInterstitial;

@protocol CRInterstitialDelegate  <NSObject>
@optional

- (void)interstitialDidLoadAd:(CRInterstitial *)interstitial;
- (void)interstitial:(CRInterstitial *)interstitial didFailToLoadAdWithError:(NSError *)error;

- (void)interstitialWillAppear:(CRInterstitial *)interstitial;
- (void)interstitialDidAppear:(CRInterstitial *)interstitial;

- (void)interstitialWillDisappear:(CRInterstitial *)interstitial;
- (void)interstitialDidDisappear:(CRInterstitial *)interstitial;

- (void)interstitialWillLeaveApplication:(CRInterstitial *)interstitial;

@end

#endif /* CRInterstitialDelegate_h */
