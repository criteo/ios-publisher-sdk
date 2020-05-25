//
//  CR_SafeMediaDownloader.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_SafeMediaDownloader.h"
#import "CR_ThreadManager.h"

@interface CR_SafeMediaDownloader ()

@property (strong, nonatomic, readonly) id <CRMediaDownloader> unsafeDownloader;
@property (strong, nonatomic, readonly) CR_ThreadManager *threadManager;
@end

@implementation CR_SafeMediaDownloader

- (instancetype)initWithUnsafeDownloader:(id)downloader
                           threadManager:(CR_ThreadManager *)threadManager {
    if (self = [super init]) {
        _unsafeDownloader = downloader;
        _threadManager = threadManager;
    }
    return self;
}

- (void)downloadImage:(NSURL *)url completionHandler:(CRImageDownloaderHandler)handler {
    __weak typeof(self) weakSelf = self;
    [self.unsafeDownloader downloadImage:url completionHandler:^(UIImage *image, NSError *error) {
        [weakSelf.threadManager dispatchAsyncOnMainQueue:^{
            handler(image, error);
        }];
    }];
}

@end
