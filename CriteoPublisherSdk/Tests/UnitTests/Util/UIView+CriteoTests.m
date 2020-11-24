//
//  UIView+CriteoTests.m
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

#import <XCTest/XCTest.h>

#import "UIWindow+Testing.h"
#import "UIView+Criteo.h"

@interface UIView_CriteoTests : XCTestCase

@property(strong, nonatomic) UIWindow *window;

@end

@implementation UIView_CriteoTests

#pragma mark - Lifecycle

- (void)tearDown {
  [self.window cr_removeFromScreen];
}

#pragma mark - Parent View Controller

- (void)testParentViewControllerFromDetachedView {
  UIView *view = [[UIView alloc] init];
  XCTAssertNil([view cr_parentViewController]);
}

- (void)testParentViewControllerFromView {
  UIViewController *controller = [[UIViewController alloc] init];
  self.window = [UIWindow cr_keyWindowWithViewController:controller];
  XCTAssertEqual([controller.view cr_parentViewController], controller);
}

- (void)testParentViewControllerFromSubview {
  UIView *subview = [[UIView alloc] init];
  UIViewController *controller = [[UIViewController alloc] init];
  [controller.view addSubview:subview];
  self.window = [UIWindow cr_keyWindowWithViewController:controller];
  XCTAssertEqual([subview cr_parentViewController], controller);
}

@end
