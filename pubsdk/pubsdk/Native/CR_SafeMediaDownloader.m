//
//  CR_SafeMediaDownloader.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_SafeMediaDownloader.h"

@interface CR_SafeMediaDownloader ()
@property (strong, nonatomic, readonly) id <CRMediaDownloader> unsafeDownloader;
@end

@implementation CR_SafeMediaDownloader

- (instancetype)initWithUnsafeDownloader:(id)downloader {
    if (self = [super init]) {
        _unsafeDownloader = downloader;
    }
    return self;
}

- (void)downloadImage:(NSURL *)url completionHandler:(CRImageDownloaderHandler)handler {
    [_unsafeDownloader downloadImage:url completionHandler:^(UIImage *image, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(image, error);
        });
    }];
}

@end
