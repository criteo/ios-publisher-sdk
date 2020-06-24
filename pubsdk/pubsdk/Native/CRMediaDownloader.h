//
//  CRMediaDownloader.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Image Download Handler
 * @param image Downloaded UImage, nil on error
 * @param error Download error, nil on successful download
 */
typedef void (^CRImageDownloaderHandler)(UIImage *_Nullable image, NSError *_Nullable error);

/**
 * Media downloader interface
 */
@protocol CRMediaDownloader <NSObject>

/**
 * Downloads a image resource
 * Should also be responsible of caching / asynchronous
 * @param url Image to download URL
 * @param handler Downloader handler
 */
- (void)downloadImage:(NSURL *)url completionHandler:(CRImageDownloaderHandler)handler;

@end

NS_ASSUME_NONNULL_END
