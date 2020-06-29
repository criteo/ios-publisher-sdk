//
//  CR_MediaDownloaderDispatchChecker.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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
