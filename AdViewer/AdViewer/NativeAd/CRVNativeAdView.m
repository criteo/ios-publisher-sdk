//
//  CRNativeAdView.m
//  AdViewer
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRVNativeAdView.h"

@implementation CRVNativeAdView

#pragma mark - CRNativeDelegate

- (void)nativeLoader:(CRNativeLoader *)loader didReceiveAd:(CRNativeAd *)ad {
    self.titleLabel.text = ad.title;
    self.bodyLabel.text = ad.body;
    NSURL *url = [[NSURL alloc] initWithString:ad.productImageUrl];
    [self downloadNativeAdImageWithUrl:url];
}

#pragma mark - Network

- (void)downloadNativeAdImageWithUrl:(NSURL *)url {
    __weak CRVNativeAdView *weakSelf = self;
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:
        ^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            if ((data.length == 0) && (error != nil)) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imageView.image = [[UIImage alloc] initWithData:data];
            });
        }];
    [task resume];
}

@end
