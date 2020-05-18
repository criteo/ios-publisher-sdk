//
//  CR_DefaultMediaDownloader.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_DefaultMediaDownloader.h"

@implementation CR_DefaultMediaDownloader

- (void)downloadImage:(NSURL *)url completionHandler:(CRImageDownloaderHandler)handler {
    // TODO implement a real downloader, async, cache...
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    handler(image, nil);
}

@end
