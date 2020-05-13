//
//  CR_AdChoiceButton.m
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_AdChoice.h"
#import "CR_NativePrivacy.h"
#import "NSURL+Criteo.h"

static const CGSize CR_AdChoiceButtonSize = (CGSize) {40, 15};

@interface CR_AdChoice ()
@end

@implementation CR_AdChoice

#pragma mark - Lifecycle

- (instancetype)init {
    return [self initWithFrame:(CGRect) {0, 0, CR_AdChoiceButtonSize}];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    }
    return self;
}

- (void)setNativePrivacy:(CR_NativePrivacy *)nativePrivacy {
    if (_nativePrivacy == nativePrivacy) {
        return;
    }
    _nativePrivacy = nativePrivacy;
    //TODO Add a downloader / cache manager
    NSURL *imageURL = [NSURL URLWithStringOrNil:_nativePrivacy.optoutImageUrl];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    [self setImage:image forState:UIControlStateNormal];
    self.imageView.frame = self.bounds;
}

@end
