//
//  CR_MediaDownloaderDispatchChecker.h
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CR_SafeMediaDownloader.h"

@class XCTestExpectation;

NS_ASSUME_NONNULL_BEGIN

@interface CR_MediaDownloaderDispatchChecker : NSObject <CRMediaDownloader>

@property(strong, nonatomic) XCTestExpectation *didDownloadImageOnMainQueue;

@end

NS_ASSUME_NONNULL_END
