//
//  UIWindow+Testing.h
//  pubsdk
//
//  Copyright © 2018-2020 Criteo. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (Testing)

 /** Create a new window, attach it to the screen and make it as keyWindow */
+ (UIWindow *)cr_keyWindowWithViewController:(UIViewController *)viewController;

- (void)cr_removeFromScreen;

@end

NS_ASSUME_NONNULL_END
