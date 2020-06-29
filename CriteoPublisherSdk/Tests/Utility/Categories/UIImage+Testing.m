//
//  UIImage+Testing.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "UIImage+Testing.h"

// UIImage and the Testing category is not in the test bundle. That's why we need a dummy class to
// get access to the test bundle.
@interface CR_TestImage : NSObject
@end

@implementation CR_TestImage
@end

@implementation UIImage (Testing)

+ (nullable UIImage *)testImageNamed:(NSString *)name {
  NSBundle *testBundle = [NSBundle bundleForClass:CR_TestImage.class];
  return [UIImage imageNamed:name inBundle:testBundle compatibleWithTraitCollection:nil];
}

+ (UIImage *)imageWithSize:(CGSize)size {
  CGRect rect = (CGRect){0, 0, size};
  UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0);
  UIRectFill(rect);
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

@end