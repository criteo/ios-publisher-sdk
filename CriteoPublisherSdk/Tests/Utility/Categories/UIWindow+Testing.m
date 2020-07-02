//
//  UIWindow+Testing.m
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

#import "UIWindow+Testing.h"

@implementation UIWindow (Testing)

+ (UIWindow *)cr_keyWindow {
  CGRect bounds = [UIScreen mainScreen].bounds;
  UIWindow *window = [[UIWindow alloc] initWithFrame:bounds];
  [window makeKeyAndVisible];
  return window;
}

+ (UIWindow *)cr_keyWindowWithViewController:(UIViewController *)viewController {
  UIWindow *window = [self cr_keyWindow];
  window.rootViewController = viewController;
  return window;
}

+ (UIWindow *)cr_keyWindowWithView:(UIView *)view {
  UIViewController *ctrl = [[UIViewController alloc] init];
  [ctrl.view addSubview:view];
  UIWindow *window = [self cr_keyWindowWithViewController:ctrl];
  return window;
}

- (void)cr_removeFromScreen {
  self.hidden = YES;
  if (@available(iOS 13.0, *)) {
    self.windowScene = nil;
  }
}

@end
