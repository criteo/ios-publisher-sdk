//
//  UIImage+Testing.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Testing)

+ (nullable UIImage *)testImageNamed:(NSString *)name;

+ (UIImage *)imageWithSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END