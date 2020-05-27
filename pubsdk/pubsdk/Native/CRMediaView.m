//
//  CRMediaView.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRMediaView.h"
#import "CRMediaView+Internal.h"
#import "CRMediaContent.h"
#import "CRMediaContent+Internal.h"
#import "CRMediaDownloader.h"

@implementation CRMediaView

- (void)setMediaContent:(CRMediaContent *)mediaContent {
    NSURL* url = mediaContent.imageUrl;

    // Media downloader may spend time to load the image.
    // We only set the placeholder if a new image comes.
    if (url == nil || ![url isEqual:self.imageUrl]) {
        self.imageView.image = nil;
        self.imageView.image = self.placeholder;
    }

    if (url == nil) {
        _mediaContent = mediaContent;
        return;
    }

    __weak typeof(self) weakSelf = self;
    [mediaContent.mediaDownloader downloadImage:url completionHandler:^(UIImage *image, NSError *error) {
        if (image != nil) {
            weakSelf.imageView.image = nil;
            weakSelf.imageView.image = image;
            weakSelf.imageUrl = url;
        }
    }];

    _mediaContent = mediaContent;
}

#pragma mark - Private

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
    }
    return _imageView;
}

@end
