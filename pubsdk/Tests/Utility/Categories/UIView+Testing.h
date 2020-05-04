//
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

@interface UIView (Testing)

- (UIWebView *)testing_findFirstWebView;
- (WKWebView *)testing_findFirstWKWebView;
- (NSMutableArray*)testing_findAllElementsOfClass:(Class)class;

@end
