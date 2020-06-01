//
//  CR_DefaultMediaDownloader.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_DefaultMediaDownloader.h"
#import "CR_NetworkManager.h"

@interface CR_DefaultMediaDownloader ()

@property (strong, nonatomic, readonly) CR_NetworkManager *networkManager;

@end

@implementation CR_DefaultMediaDownloader

- (instancetype)initWithNetworkManager:(CR_NetworkManager *)networkManager {
    if (self = [super init]) {
        _networkManager = networkManager;
    }
    return self;
}


- (void)downloadImage:(NSURL *)url completionHandler:(CRImageDownloaderHandler)handler {
    // TODO implement cache...
    [self.networkManager getFromUrl:url responseHandler:^(NSData *data, NSError *error) {
        UIImage *image;
        if (data) {
            image = [UIImage imageWithData:data];
        }
        handler(image, error);
    }];
}

@end
