//
//  CR_MediaDownloaderDispatchChecker.m
//  CriteoPublisherSdkTests
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

#import <XCTest/XCTest.h>
#import "CR_MediaDownloaderDispatchChecker.h"

@implementation CR_MediaDownloaderDispatchChecker

- (instancetype)init {
  self = [super init];
  if (self) {
    _didDownloadImageOnMainQueue = [[XCTestExpectation alloc]
        initWithDescription:@"Download handler should be called on main queue"];
  }
  return self;
}

- (void)downloadImage:(NSURL *)url completionHandler:(CRImageDownloaderHandler)handler {
  if (@available(iOS 10.0, *)) {
    dispatch_assert_queue(dispatch_get_main_queue());
    [self.didDownloadImageOnMainQueue fulfill];
  }
}

@end
