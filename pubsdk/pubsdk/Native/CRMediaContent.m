//
//  CRMediaContent.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRMediaContent.h"
#import "CRMediaContent+Internal.h"
#import "CRMediaDownloader.h"
#import "CR_NativeImage.h"
#import "NSURL+Criteo.h"

@implementation CRMediaContent

- (instancetype)initWithNativeImage:(CR_NativeImage *)image
                    mediaDownloader:(id <CRMediaDownloader>)mediaDownloader {
    if (self = [super init]) {
        _url = [NSURL cr_URLWithStringOrNil:image.url];
        _imageSize = CGSizeMake(image.width, image.height);
        _mediaDownloader = mediaDownloader;
    }
    return self;
}

@end