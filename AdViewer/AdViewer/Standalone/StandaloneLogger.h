//
//  StandaloneLogger.h
//  AdViewer
//
//  Created by Vincent Guerci on 10/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CriteoPublisherSdk/CriteoPublisherSdk.h>

@protocol InterstitialUpdateDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface StandaloneLogger : NSObject <CRBannerViewDelegate, CRInterstitialDelegate>

#pragma mark - Lifecycle

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithInterstitialDelegate:(id <InterstitialUpdateDelegate>)interstitialDelegate;

@end

NS_ASSUME_NONNULL_END
