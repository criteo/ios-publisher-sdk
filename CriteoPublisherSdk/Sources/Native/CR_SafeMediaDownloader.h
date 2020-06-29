//
//  CR_SafeMediaDownloader.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "CRMediaDownloader.h"

NS_ASSUME_NONNULL_BEGIN

@class CR_ThreadManager;

@interface CR_SafeMediaDownloader : NSObject <CRMediaDownloader>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithUnsafeDownloader:(id<CRMediaDownloader>)downloader
                           threadManager:(CR_ThreadManager *)threadManager
    NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
