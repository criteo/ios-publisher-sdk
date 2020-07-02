//
//  UIView+Testing.m
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

#import "UIView+Testing.h"

@implementation UIView (Testing)

- (UIWebView *)testing_findFirstWebView {
  NSMutableArray *arr = [self testing_findAllElementsOfClass:UIWebView.class];
  return arr.count > 0 ? arr[0] : nil;
}

- (WKWebView *)testing_findFirstWKWebView {
  NSMutableArray *arr = [self testing_findAllElementsOfClass:WKWebView.class];
  return arr.count > 0 ? arr[0] : nil;
}

- (NSMutableArray *)testing_findAllElementsOfClass:(Class)class {
  NSMutableArray *results = [[NSMutableArray alloc] init];
  [self walkOverView:self andSaveNestedElementsOfClass:class toArray:results];
  return results;
}

- (void)walkOverView:(UIView *)view
    andSaveNestedElementsOfClass:(Class)class
                         toArray:(NSMutableArray *)result {
  if ([view isKindOfClass:class]) {
    [result addObject:view];
  }
  for (UIView *subview in view.subviews) {
    [self walkOverView:subview andSaveNestedElementsOfClass:class toArray:result];
  }
}

@end
