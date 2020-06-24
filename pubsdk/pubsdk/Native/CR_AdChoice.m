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
#import "CRMediaDownloader.h"

static const CGSize CR_AdChoiceButtonSize = (CGSize){19, 15};

@interface CR_AdChoice ()
@property(strong, nonatomic, readonly) CR_NativePrivacy *privacy;
@property(weak, nonatomic, readonly) CRNativeLoader *loader;
@property(weak, nonatomic, readonly) id<CRMediaDownloader> mediaDownloader;
@end

@implementation CR_AdChoice

#pragma mark - Lifecycle

- (instancetype)init {
  return [self initWithFrame:(CGRect){0, 0, CR_AdChoiceButtonSize}];
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self addTarget:self
                  action:@selector(buttonClicked:)
        forControlEvents:UIControlEventTouchUpInside];
  }
  return self;
}

#pragma mark - Events

- (void)buttonClicked:(id)button {
  [self.loader handleClickOnAdChoiceOfNativeAd:self.nativeAd];
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

- (id<CRMediaDownloader>)mediaDownloader {
  return self.loader.mediaDownloader;
}

#pragma mark - Data

- (void)loadView {
  NSURL *imageURL = [NSURL cr_URLWithStringOrNil:self.privacy.optoutImageUrl];
  __weak __typeof__(self) weakSelf = self;
  [self.mediaDownloader downloadImage:imageURL
                    completionHandler:^(UIImage *image, NSError *error) {
                      __typeof__(self) strongSelf = weakSelf;
                      [strongSelf setImage:image forState:UIControlStateNormal];
                      strongSelf.imageView.frame = self.bounds;
                    }];
}

@end
