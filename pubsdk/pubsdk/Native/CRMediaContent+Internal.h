//
//  CRMediaContent+Internal.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRMediaContent.h"

@protocol CRMediaDownloader;
@class CR_ThreadManager;

NS_ASSUME_NONNULL_BEGIN

@interface CRMediaContent ()

@property (copy, nonatomic, readonly, nullable) NSURL *url;
@property (weak, nonatomic, readonly) id <CRMediaDownloader> mediaDownloader;

- (instancetype)initWithUrl:(NSURL *_Nullable)url
            mediaDownloader:(id <CRMediaDownloader>)mediaDownloader
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END