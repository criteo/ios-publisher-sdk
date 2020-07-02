//
//  CR_SafeMediaDownloader.m
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

#import "CR_SafeMediaDownloader.h"
#import "CR_ThreadManager.h"

@interface CR_SafeMediaDownloader ()

@property(strong, nonatomic, readonly) id<CRMediaDownloader> unsafeDownloader;
@property(strong, nonatomic, readonly) CR_ThreadManager *threadManager;
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
  CR_ThreadManager *threadManager = self.threadManager;
  [self.unsafeDownloader downloadImage:url
                     completionHandler:^(UIImage *image, NSError *error) {
                       [threadManager dispatchAsyncOnMainQueue:^{
                         handler(image, error);
                       }];
                     }];
}

@end
