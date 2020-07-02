//
//  CRMediaDownloader.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
