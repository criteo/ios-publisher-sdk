//
//  CR_AdChoiceButton.m
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_AdChoice.h"
#import "CR_NativePrivacy.h"
#import "NSURL+Criteo.h"
#import "CRNativeLoader+Internal.h"
#import "CRNativeAd+Internal.h"
#import "CR_NativeAssets.h"

static const CGSize CR_AdChoiceButtonSize = (CGSize) {40, 15};

@interface CR_AdChoice ()
@property (strong, nonatomic, readonly) CR_NativePrivacy *privacy;
@property (weak, nonatomic, readonly) CRNativeLoader *loader;
@end

@implementation CR_AdChoice

#pragma mark - Lifecycle

- (instancetype)init {
    return [self initWithFrame:(CGRect) {0, 0, CR_AdChoiceButtonSize}];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self addTarget:self action:@selector(buttonClicked:)
       forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark - Events

- (void)buttonClicked:(id)button {
    NSURL *url = [NSURL URLWithStringOrNil:self.privacy.optoutClickUrl];
    [url openExternal:^(BOOL success) {
        [self.loader notifyWillLeaveApplicationForNativeAd];
    }];
}

#pragma mark - Properties

- (void)setNativeAd:(CRNativeAd *)nativeAd {
    if (_nativeAd == nativeAd) {
        return;
    }
    _nativeAd = nativeAd;
    [self loadView];
}

- (CR_NativePrivacy *)privacy {
    return _nativeAd.assets.privacy;
}

- (CRNativeLoader *)loader {
    return _nativeAd.loader;
}

#pragma mark - Data

- (void)loadView {
    //TODO Add a downloader / cache manager
    NSURL *imageURL = [NSURL URLWithStringOrNil:self.privacy.optoutImageUrl];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    [self setImage:image forState:UIControlStateNormal];
    self.imageView.frame = self.bounds;
}

@end
