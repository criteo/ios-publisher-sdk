//
//  CR_SafeAreaView.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_SafeAreaView.h"

@interface CR_SafeAreaView ()

@property (strong, nonatomic) UILabel *unsafeAreaLabel;

@end

@implementation CR_SafeAreaView

#pragma mark - Public

- (CGRect)unsafeAreaFrame {
    return (CGRect) {
        0, 0,
        CGRectGetWidth(self.bounds),
        CGRectGetHeight(self.bounds) / 2
    };
}

- (CGRect)safeAreaFrame {
    return (CGRect) {
        0,
        CGRectGetHeight(self.bounds) / 2,
        CGRectGetWidth(self.bounds),
        CGRectGetHeight(self.bounds) / 2
    };
}

#pragma mark - UIView

-(void)layoutSubviews {
    [super layoutSubviews];
    [self addUnsafeAreaLabelIfNeeded];
    self.unsafeAreaLabel.frame = self.unsafeAreaFrame;
    [self bringSubviewToFront:self.unsafeAreaLabel];
}

- (UIEdgeInsets)safeAreaInsets {
    return (UIEdgeInsets) {
        CGRectGetHeight(self.bounds) / 2,
        0, 0, 0
    };
}

#pragma mark - Private

- (void)addUnsafeAreaLabelIfNeeded {
    if (self.unsafeAreaLabel != nil) {
        return;
    }

    self.unsafeAreaLabel = [self buildUnsafeAreaLabel];
    [self addSubview:self.unsafeAreaLabel];
}

- (UILabel *)buildUnsafeAreaLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:self.unsafeAreaFrame];
    label.text = @"Unsafe Area";
    label.alpha = 0.5;
    label.backgroundColor = [UIColor grayColor];
    return label;
}

@end
