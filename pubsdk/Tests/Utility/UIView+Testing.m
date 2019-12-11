//
// Created by Aleksandr Pakhmutov on 09/12/2019.
// Copyright (c) 2019 Criteo. All rights reserved.
//

#import "UIView+Testing.h"


@implementation UIView (Testing)

- (UIWebView *)testing_findFirstWebView {
    NSMutableArray *arr = [self testing_findAllWebView];
    return arr.count > 0 ? arr[0] : nil;
}

- (NSMutableArray<UIWebView *>*)testing_findAllWebView {
    NSMutableArray<UIWebView *> *results = [[NSMutableArray alloc] init];
    [self walkOverView:self andSaveWebViewsToResult:results];
    return results;
}

- (void)walkOverView:(UIView *)view andSaveWebViewsToResult:(NSMutableArray *)result
{
    if([view isKindOfClass:UIWebView.class]) {
        UIWebView *wv = (UIWebView *)view;
        [result addObject:wv];
    }
    for (UIView *subview in view.subviews)
    {
        [self walkOverView:subview andSaveWebViewsToResult:result];
    }
}

@end