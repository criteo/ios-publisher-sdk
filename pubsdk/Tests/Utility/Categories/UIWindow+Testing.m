//
//  UIWindow+Testing.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
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
