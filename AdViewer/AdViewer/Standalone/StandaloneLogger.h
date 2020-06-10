//
//  StandaloneLogger.h
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CriteoPublisherSdk/CriteoPublisherSdk.h>

@protocol InterstitialUpdateDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface StandaloneLogger : NSObject <CRBannerViewDelegate, CRInterstitialDelegate, CRNativeLoaderDelegate>

@property (weak, nonatomic) id <InterstitialUpdateDelegate> interstitialDelegate;

@end

NS_ASSUME_NONNULL_END
