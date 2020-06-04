//
//  CR_ImpressionDetector.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIView;
@protocol CR_ImpressionDetectorDelegate;

@interface CR_ImpressionDetector : NSObject

@property (weak, nonatomic, readonly) UIView *view;
@property (weak, nonatomic) id <CR_ImpressionDetectorDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithView:(UIView *)view NS_DESIGNATED_INITIALIZER;

- (void)startDetection;
- (void)stopDetection;

+ (BOOL)isViewVisible:(UIView *)view;

@end

@protocol CR_ImpressionDetectorDelegate <NSObject>

- (void)impressionDetectorDidDetectImpression:(CR_ImpressionDetector *)detector;

@end

NS_ASSUME_NONNULL_END
