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

@property(nonatomic, copy, readonly, nullable) NSURL *imageUrl;
@property(nonatomic, weak, readonly) id <CRMediaDownloader> mediaDownloader;

- (instancetype)initWithImageUrl:(NSURL *_Nullable)imageUrl
                 mediaDownloader:(id <CRMediaDownloader>)mediaDownloader
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END