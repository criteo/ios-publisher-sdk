//
//  CRMediaContent+Internal.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRMediaContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRMediaContent ()

@property (nonatomic, copy, readonly, nullable) NSURL *imageUrl;

- (instancetype)initWithImageUrl:(NSURL * _Nullable)imageUrl NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END