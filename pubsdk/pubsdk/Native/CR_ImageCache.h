//
//  CR_ImageCache.h
//  CriteoPublisherSdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

NS_ASSUME_NONNULL_BEGIN

@interface CR_ImageCache : NSObject

- (void)setImage:(UIImage *)image forUrl:(NSURL *)url imageSize:(NSUInteger)size;

- (nullable UIImage *) imageForUrl:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
