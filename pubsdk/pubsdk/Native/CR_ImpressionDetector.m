//
//  CR_ImpressionDetector.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CR_ImpressionDetector.h"

@interface CR_ImpressionDetector ()

@property (weak, nonatomic) UIView *view;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation CR_ImpressionDetector

#pragma mark - Life cycle

- (instancetype)initWithView:(UIView *)view {
    if (self = [super init]) {
        _view = view;
    }
    return self;
}

- (void)dealloc {
    [self stopDetection];
}

#pragma mark - Public

- (void)startDetection {
    [self stopDetection];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                  target:self
                                                selector:@selector(onTimerTick)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopDetection {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Private

- (void)onTimerTick {
    if (self.view == nil) {
        [self stopDetection];
        return;
    }
    
    BOOL isVisible = [self.class isViewVisible:self.view];
    if (!isVisible) {
        return;
    }

    [self.delegate impressionDetectorDidDetectImpression:self];
    [self stopDetection];
}

+ (BOOL)isViewVisible:(UIView *)view {
    NSAssert(view, @"View cannot be nil");
    if (view.window == nil) {
        // Not in the view hierarchy.
        return NO;
    }
    if (view.superview == nil) {
        // Is the root view.
        return YES;
    }

    CGRect visibleFrame = view.bounds;
    while (view.superview != nil) {
        if (view.isHidden) {
            return NO;
        }

        UIView *superview = view.superview;
        CGRect convertedFrame = [view convertRect:visibleFrame
                                           toView:superview];

        visibleFrame = CGRectIntersection(superview.bounds, convertedFrame);
        if (CGRectEqualToRect(visibleFrame, CGRectNull)) {
            return NO;
        }

        view = superview;
    }

    BOOL visible = CGRectIntersectsRect(view.frame, visibleFrame);
    return visible;
}

@end
