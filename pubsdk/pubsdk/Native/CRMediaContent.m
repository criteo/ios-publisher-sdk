//
//  CRMediaContent.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRMediaContent.h"
#import "CRMediaContent+Internal.h"
#import "CRMediaDownloader.h"

@implementation CRMediaContent

- (instancetype)initWithImageUrl:(NSURL *_Nullable)imageUrl
                 mediaDownloader:(id <CRMediaDownloader>)mediaDownloader {
    if (self = [super init]) {
        _imageUrl = imageUrl;
        _mediaDownloader = mediaDownloader;
    }
    return self;
}

@end