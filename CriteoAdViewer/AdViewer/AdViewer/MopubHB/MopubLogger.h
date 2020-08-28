//
//  MopubLogger.h
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MoPub.h>

@protocol InterstitialUpdateDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface MopubLogger : NSObject <MPAdViewDelegate, MPInterstitialAdControllerDelegate>

#pragma mark - Lifecycle

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithInterstitialDelegate:(UIViewController <InterstitialUpdateDelegate> *)viewController;

@end

NS_ASSUME_NONNULL_END
