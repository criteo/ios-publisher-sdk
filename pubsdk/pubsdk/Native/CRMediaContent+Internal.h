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
@class CR_NativeImage;

NS_ASSUME_NONNULL_BEGIN

@interface CRMediaContent ()

@property (weak, nonatomic, readonly) id <CRMediaDownloader> mediaDownloader;

- (instancetype)initWithNativeImage:(CR_NativeImage *)image
                    mediaDownloader:(id <CRMediaDownloader>)mediaDownloader
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END