//
//  UIWindow+Testing.m
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import "UIWindow+Testing.h"

@implementation UIWindow (Testing)

+ (UIWindow *)cr_keyWindowWithViewController:(UIViewController *)viewController {
    CGRect bounds = [UIScreen mainScreen].bounds;
    UIWindow *window = [[UIWindow alloc] initWithFrame:bounds];
    [window makeKeyAndVisible];
    window.rootViewController = viewController;
    return window;
}

- (void)cr_removeFromScreen {
    self.hidden = YES;
    if (@available(iOS 13.0, *)) {
        self.windowScene = nil;
    }
}

@end
