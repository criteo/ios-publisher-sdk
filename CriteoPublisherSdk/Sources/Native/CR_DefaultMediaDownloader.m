//
//  CR_DefaultMediaDownloader.m
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

#import "CR_DefaultMediaDownloader.h"
#import "CR_NetworkManager.h"
#import "CR_ImageCache.h"

@interface CR_DefaultMediaDownloader ()

@property(strong, nonatomic, readonly) CR_NetworkManager *networkManager;
@property(strong, nonatomic, readonly) CR_ImageCache *imageCache;

@end

@implementation CR_DefaultMediaDownloader

- (instancetype)initWithNetworkManager:(CR_NetworkManager *)networkManager
                            imageCache:(CR_ImageCache *)imageCache {
  if (self = [super init]) {
    _networkManager = networkManager;
    _imageCache = imageCache;
  }
  return self;
}

- (void)downloadImage:(NSURL *)url completionHandler:(CRImageDownloaderHandler)handler {
  UIImage *cachedImage = [self.imageCache imageForUrl:url];
  if (cachedImage) {
    handler(cachedImage, nil);
    return;
  }

  [self.networkManager getFromUrl:url
                  responseHandler:^(NSData *data, NSError *error) {
                    UIImage *image;
                    if (data) {
                      image = [UIImage imageWithData:data];
                      [self.imageCache setImage:image forUrl:url imageSize:[self imageSize:image]];
                    }
                    handler(image, error);
                  }];
}

#pragma - Private

- (NSUInteger)imageSize:(UIImage *)image {
  CGImageRef cgImage = image.CGImage;
  return CGImageGetHeight(cgImage) * CGImageGetBytesPerRow(cgImage);
}

@end
