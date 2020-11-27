//
//  UIWindow+Testing.h
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

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (Testing)

/** Create a new window, attach it to the screen and make it as keyWindow */
+ (UIWindow *)cr_keyWindow;

/**
 * Create a new window, attach it to the screen and make it as keyWindow
 * @param viewController is the rootViewController attached to the new UIWindow
 */
+ (UIWindow *)cr_keyWindowWithViewController:(UIViewController *)viewController;

/**
 * Create a new window, attach it to the screen and make it as keyWindow
 * @param view is attached to a default rootViewController attached to the new UIWindow
 */
+ (UIWindow *)cr_keyWindowWithView:(UIView *)view;

/**
 * Remove the UIWindow from the screen.
 *
 * There is no proper way to do it. The UIScreen may still retain the UIWindow (but hides it)
 * on some iOS versions. In the worst case, the UIWindow isn't the keyWindow anymore
 * but it stays in memory.
 */
- (void)cr_removeFromScreen;

/** Returns the top presented view controller */
- (UIViewController *)cr_topController;

@end

NS_ASSUME_NONNULL_END
