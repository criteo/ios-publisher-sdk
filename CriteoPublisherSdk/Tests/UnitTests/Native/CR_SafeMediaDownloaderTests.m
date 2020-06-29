//
//  CR_SafeMediaDownloaderTests.m
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CR_SafeMediaDownloader.h"
#import "CR_ThreadManager+Waiter.h"

@interface CR_SafeMediaDownloaderTests : XCTestCase
@end

@interface CR_MediaDownloaderMock : NSObject <CRMediaDownloader>
@property(weak, nonatomic) CR_ThreadManager *threadManager;
@end

@implementation CR_SafeMediaDownloaderTests

- (void)testDownloadImageCallbackWhenReleasedEarly {
  CR_ThreadManager *threadManager = [[CR_ThreadManager alloc] init];
  CR_MediaDownloaderMock *mediaDownloaderMock = [[CR_MediaDownloaderMock alloc] init];
  mediaDownloaderMock.threadManager = threadManager;
  CR_SafeMediaDownloader *safeDownloader =
      [[CR_SafeMediaDownloader alloc] initWithUnsafeDownloader:mediaDownloaderMock
                                                 threadManager:threadManager];

  __block BOOL downloaded = NO;
  [safeDownloader downloadImage:[NSURL new]
              completionHandler:^(UIImage *image, NSError *error) {
                downloaded = YES;
              }];

  XCTAssertNil(safeDownloader = nil, @"Explicitly dealloc downloader");
  [threadManager waiter_waitIdle];
  XCTAssert(downloaded);
}

@end

@implementation CR_MediaDownloaderMock

- (void)downloadImage:(NSURL *)url completionHandler:(CRImageDownloaderHandler)handler {
  [self.threadManager dispatchAsyncOnGlobalQueue:^{
    handler(nil, nil);
  }];
}

@end