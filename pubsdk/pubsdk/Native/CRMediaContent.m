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

- (instancetype)initWithUrl:(NSURL *_Nullable)url
            mediaDownloader:(id <CRMediaDownloader>)mediaDownloader {
    if (self = [super init]) {
        _url = url;
        _mediaDownloader = mediaDownloader;
    }
    return self;
}

@end