//
//  UIImage+Testing.m
//  CriteoPublisherSdkTests
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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